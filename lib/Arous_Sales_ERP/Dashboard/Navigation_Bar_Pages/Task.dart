import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Task extends StatefulWidget {
  final Function(int) onNavigate;

  const Task({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  List<Map<String, dynamic>> meetings = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredTakeOrders = [];
  List<Map<String, dynamic>> filteredMeetings = [];
  List<Map<String, dynamic>> clients = [];
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _loadClients();
      await _loadMeetings();
      await _loadOrders();
      _filterItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadClients() async {
    const String apiUrl = "http://127.0.0.1:7500/api/client/getall";
    try {
      final token = await getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No valid token found. Please log in again."), backgroundColor: Colors.red),
        );
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['clients'] != null) {
          setState(() {
            clients = List<Map<String, dynamic>>.from(responseData['clients']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No clients found."), backgroundColor: Colors.orange),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch clients: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching clients: $error"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? meetingStrings = prefs.getStringList('meetings');
    if (meetingStrings != null) {
      List<Map<String, dynamic>> tempMeetings = meetingStrings
          .map((meeting) => jsonDecode(meeting) as Map<String, dynamic>)
          .toList();

      for (var meeting in tempMeetings) {
        final client = clients.firstWhere(
          (client) => client['vendorName'] == meeting['vendorName'],
          orElse: () => {
            'vendorName': meeting['vendorName'] ?? 'Unknown Vendor',
            'address': meeting['address'] ?? 'Unknown Address',
            'contactPerson': meeting['contactPerson'] ?? 'Unknown Contact',
          },
        );
        meeting['vendorName'] = client['vendorName'] ?? meeting['vendorName'] ?? 'Unknown Vendor';
        meeting['address'] = client['address'] ?? meeting['address'] ?? 'Unknown Address';
        meeting['contactPerson'] = client['contactPerson'] ?? meeting['contactPerson'] ?? 'Unknown Contact';
        meeting['importantNote'] = meeting['meetingImportantNotes'] ?? 'No notes available';
        meeting['orderType'] = meeting['orderType'] ?? 'Meeting';
        meeting['meetingDate'] = meeting['meetingDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      setState(() {
        meetings = tempMeetings;
      });
    }
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String? orderStrings = prefs.getString('orders');
    if (orderStrings != null) {
      List<Map<String, dynamic>> tempOrders = List<Map<String, dynamic>>.from(jsonDecode(orderStrings));

      final seenOrderIds = <String>{};
      final uniqueOrders = <Map<String, dynamic>>[];
      for (var order in tempOrders) {
        final orderId = order['orderId'] as String?;
        if (orderId != null && !seenOrderIds.contains(orderId)) {
          seenOrderIds.add(orderId);
          uniqueOrders.add(order);
        }
      }

      for (var order in uniqueOrders) {
        final client = clients.firstWhere(
          (client) => client['vendorName'] == order['vendorName'],
          orElse: () => {
            'vendorName': order['vendorName'] ?? 'Unknown Vendor',
            'address': order['address'] ?? 'Unknown Address',
            'contactPerson': order['contactPerson'] ?? 'Unknown Contact',
          },
        );
        order['vendorName'] = client['vendorName'] ?? order['vendorName'] ?? 'Unknown Vendor';
        order['address'] = client['address'] ?? order['address'] ?? 'Unknown Address';
        order['contactPerson'] = client['contactPerson'] ?? order['contactPerson'] ?? 'Unknown Contact';
        order['importantNote'] = 'Order ID: ${order['orderId']}';
        order['orderType'] = 'Take Order';
        order['meetingDate'] = order['orderDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      setState(() {
        orders = uniqueOrders;
      });
    }
  }

  void _filterItems() {
    final allItems = [...meetings, ...orders];
    setState(() {
      if (_selectedDay == null) {
        filteredTakeOrders = allItems.where((item) => item['orderType'] == 'Take Order').toList();
        filteredMeetings = allItems.where((item) => item['orderType'] == 'Meeting').toList();
      } else {
        filteredTakeOrders = allItems.where((item) {
          if (item['orderType'] != 'Take Order') return false;
          try {
            final itemDate = DateFormat('yyyy-MM-dd').parse(item['meetingDate']);
            return isSameDay(itemDate, _selectedDay!);
          } catch (e) {
            return false;
          }
        }).toList();
        filteredMeetings = allItems.where((item) {
          if (item['orderType'] != 'Meeting') return false;
          try {
            final itemDate = DateFormat('yyyy-MM-dd').parse(item['meetingDate']);
            return isSameDay(itemDate, _selectedDay!);
          } catch (e) {
            return false;
          }
        }).toList();
      }
      filteredTakeOrders.sort((a, b) {
        try {
          final dateA = DateFormat('yyyy-MM-dd').parse(a['meetingDate']);
          final dateB = DateFormat('yyyy-MM-dd').parse(b['meetingDate']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
      filteredMeetings.sort((a, b) {
        try {
          final dateA = DateFormat('yyyy-MM-dd').parse(a['meetingDate']);
          final dateB = DateFormat('yyyy-MM-dd').parse(b['meetingDate']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
    });
  }

  String get formattedDate {
    if (_selectedDay == null) return "Select Date";
    return DateFormat("MMM d").format(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/Arous_Sales_ERP_Images/Tasks/backgroundImage.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(3),
                                  bottomRight: Radius.circular(4),
                                ),
                                border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    final allItems = [...meetings, ...orders];
                                    filteredTakeOrders = allItems.where((item) {
                                      final matchesVendor = item['vendorName']
                                              ?.toLowerCase()
                                              .contains(value.toLowerCase()) ??
                                          false;
                                      if (_selectedDay != null) {
                                        try {
                                          final itemDate = DateFormat('yyyy-MM-dd').parse(item['meetingDate']);
                                          return matchesVendor &&
                                              item['orderType'] == 'Take Order' &&
                                              isSameDay(itemDate, _selectedDay!);
                                        } catch (e) {
                                          return false;
                                        }
                                      }
                                      return matchesVendor && item['orderType'] == 'Take Order';
                                    }).toList();
                                    filteredMeetings = allItems.where((item) {
                                      final matchesVendor = item['vendorName']
                                              ?.toLowerCase()
                                              .contains(value.toLowerCase()) ??
                                          false;
                                      if (_selectedDay != null) {
                                        try {
                                          final itemDate = DateFormat('yyyy-MM-dd').parse(item['meetingDate']);
                                          return matchesVendor &&
                                              item['orderType'] == 'Meeting' &&
                                              isSameDay(itemDate, _selectedDay!);
                                        } catch (e) {
                                          return false;
                                        }
                                      }
                                      return matchesVendor && item['orderType'] == 'Meeting';
                                    }).toList();
                                    filteredTakeOrders.sort((a, b) {
                                      try {
                                        final dateA = DateFormat('yyyy-MM-dd').parse(a['meetingDate']);
                                        final dateB = DateFormat('yyyy-MM-dd').parse(b['meetingDate']);
                                        return dateB.compareTo(dateA);
                                      } catch (e) {
                                        return 0;
                                      }
                                    });
                                    filteredMeetings.sort((a, b) {
                                      try {
                                        final dateA = DateFormat('yyyy-MM-dd').parse(a['meetingDate']);
                                        final dateB = DateFormat('yyyy-MM-dd').parse(b['meetingDate']);
                                        return dateB.compareTo(dateA);
                                      } catch (e) {
                                        return 0;
                                      }
                                    });
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search Task..',
                                  hintStyle: TextStyle(
                                    fontSize: width * 0.038,
                                    color: Color.fromRGBO(153, 153, 153, 1),
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 25,
                                    color: Color.fromRGBO(165, 170, 178, 1),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showCalendar = !_showCalendar;
                                    });
                                  },
                                  child: Container(
                                    width: width * 0.35,
                                    height: height * 0.055,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(254, 254, 254, 1),
                                      border: Border.all(
                                        width: 2,
                                        color: Color.fromRGBO(207, 212, 219, 1),
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(9.25),
                                        topRight: Radius.circular(8.25),
                                        bottomLeft: Radius.circular(4.75),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: width * 0.037,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w300,
                                              color: Color.fromRGBO(127, 134, 144, 1),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/Arous_Sales_ERP_Images/Tasks/downArrow.png",
                                            width: width * 0.04,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Filter functionality not implemented yet.")),
                                    );
                                  },
                                  child: Container(
                                    width: width * 0.2,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      border: Border.all(
                                        width: 2,
                                        color: Color.fromRGBO(218, 220, 224, 1),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/Arous_Sales_ERP_Images/Tasks/filter.png",
                                            width: width * 0.03,
                                          ),
                                          SizedBox(width: width * 0.01),
                                          Text(
                                            "Filter",
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w300,
                                              color: Color.fromRGBO(131, 137, 147, 1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_showCalendar)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TableCalendar(
                                  firstDay: DateTime(2000),
                                  lastDay: DateTime(2100),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                      _showCalendar = false;
                                      _filterItems();
                                    });
                                  },
                                  calendarStyle: CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: Color.fromRGBO(106, 138, 181, 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Color.fromRGBO(106, 138, 181, 1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                  ),
                                ),
                              ),
                            SizedBox(height: height * 0.01),
                            if (filteredTakeOrders.isNotEmpty)
                              ...filteredTakeOrders.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: height * 0.01),
                                  child: Container(
                                    key: Key(item['orderId'] ?? item['meetingId'] ?? 'take-order-$index'),
                                    height: height * 0.15,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/Arous_Sales_ERP_Images/Tasks/blankImage.png"),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(width * 0.05),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['vendorName'] ?? 'Unknown Vendor',
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: width * 0.038,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(91, 96, 106, 1),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                width: width * 0.25,
                                                height: height * 0.037,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(243, 244, 246, 1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Take Order",
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: width * 0.033,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(99, 172, 126, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: height * 0.01),
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/Arous_Sales_ERP_Images/Tasks/location.png",
                                                height: height * 0.016,
                                              ),
                                              SizedBox(width: width * 0.01),
                                              Expanded(
                                                child: Text(
                                                  item['address'] ?? 'Unknown Address',
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(162, 167, 175, 1),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: height * 0.005),
                                          Text(
                                            item['contactPerson'] ?? 'Unknown Contact',
                                            style: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: width * 0.035,
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromRGBO(144, 150, 159, 1),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            
                            SizedBox(height: height * 0.01),
                            if (filteredMeetings.isNotEmpty)
                              ...filteredMeetings.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: height * 0.01),
                                  child: Container(
                                    key: Key(item['meetingId'] ?? 'meeting-$index'),
                                    height: height * 0.15,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/Arous_Sales_ERP_Images/Tasks/blankImage.png"),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(width * 0.05),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['vendorName'] ?? 'Unknown Vendor',
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: width * 0.038,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(91, 96, 106, 1),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                width: width * 0.25,
                                                height: height * 0.037,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(239, 246, 254, 1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Meeting",
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: width * 0.033,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(105, 138, 230, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: height * 0.01),
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/Arous_Sales_ERP_Images/Tasks/location.png",
                                                height: height * 0.016,
                                              ),
                                              SizedBox(width: width * 0.01),
                                              Expanded(
                                                child: Text(
                                                  item['address'] ?? 'Unknown Address',
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(162, 167, 175, 1),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: height * 0.005),
                                          Text(
                                            item['contactPerson'] ?? 'Unknown Contact',
                                            style: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: width * 0.035,
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromRGBO(144, 150, 159, 1),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}