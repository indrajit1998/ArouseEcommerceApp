import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Meeting%20History/meetingHistory.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/ViewOrderDetails/ViewOrderDetails.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String searchText = "";
  String? userId;
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> meetings = [];
  String selectedFilter = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Load orders
    String? existingOrders = prefs.getString('orders');
    if (existingOrders != null) {
      try {
        List<dynamic> rawOrders = jsonDecode(existingOrders);

        
        Map<String, Map<String, dynamic>> uniqueOrders = {};
        for (var order in rawOrders) {
          if (order is! Map || order['orderId'] == null || order['timestamp'] == null) {
            print("Skipping invalid order: $order");
            continue;
          }

          bool isValid = order['vendorName'] != null &&
              order['vendorName'] != 'Unknown Vendor' &&
              order['contactPerson'] != null &&
              order['contactPerson'] != 'Unknown Contact' &&
              order['address'] != null &&
              order['address'] != 'Unknown Address';

          if (!isValid) {
            print("Skipping invalid order with unknown details: $order");
            continue;
          }

          String key = "${order['orderId']}_${order['timestamp']}";

          
          if (uniqueOrders.containsKey(key)) {
            print("Duplicate order found for key: $key");
            var existingOrder = uniqueOrders[key]!;
            
            if ((existingOrder['vendorName'] == 'Unknown Vendor' && order['vendorName'] != 'Unknown Vendor') ||
                (existingOrder['contactPerson'] == 'Unknown Contact' && order['contactPerson'] != 'Unknown Contact')) {
              uniqueOrders[key] = Map<String, dynamic>.from(order);
              print("Replacing duplicate with more complete order: $order");
            }
          } else {
            uniqueOrders[key] = Map<String, dynamic>.from(order);
          }
        }

        orders = uniqueOrders.values.toList();
        
        for (var order in orders) {
          order['orderedItems'] ??= [];
        }
      } catch (e) {
        orders = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Load meetings
    List<String>? meetingStrings = prefs.getStringList('meetings');
    if (meetingStrings != null) {
      try {
        meetings = meetingStrings
            .map((meeting) => jsonDecode(meeting) as Map<String, dynamic>)
            .where((meeting) =>
                meeting['meetingId'] != null &&
                meeting['vendorName'] != null &&
                meeting['meetingDate'] != null &&
                meeting['meetingTime'] != null)
            .toList();
      } catch (e) {
        meetings = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meetings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  String _formatDateTime(String date, String time) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      final formattedDate = DateFormat('MMM d, yyyy').format(parsedDate);
      return '$formattedDate - $time';
    } catch (e) {
      return '$date - $time';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  bool _isDayBeforeYesterday(DateTime date) {
    final dayBeforeYesterday = DateTime.now().subtract(Duration(days: 2));
    return date.year == dayBeforeYesterday.year &&
        date.month == dayBeforeYesterday.month &&
        date.day == dayBeforeYesterday.day;
  }

  String _getDateHeader(DateTime date) {
    if (_isToday(date)) return "Today";
    if (_isYesterday(date)) return "Yesterday";
    if (_isDayBeforeYesterday(date)) return "Day Before Yesterday";
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildOrderContainer(Map<String, dynamic> order, double width, double height) {
    if (order['deliveredTimestamp'] == null) {
      return SizedBox.shrink();
    }

    String status = order['status'] ?? 'Unknown';
    Color statusColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'Delivered':
        statusColor = Color.fromRGBO(220, 252, 231, 1);
        textColor = Color.fromRGBO(107, 201, 142, 1);
        statusText = 'Completed';
        break;
      default:
        return SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Vieworderdetails(order: order),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Arous_Sales_ERP_Images/History/blankImage.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Product Purchase",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(101, 135, 179, 1),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(3.25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: width * 0.031,
                              fontWeight: FontWeight.w400,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "${order['orderId']}",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(165, 169, 178, 1),
                    ),
                  ),
                  Text(
                    "Total: ₹${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(165, 169, 178, 1),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/Arous_Sales_ERP_Images/History/rightArrow.png",
                        height: width * 0.035,
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('MMM d, yyyy - h:mm a').format(DateTime.parse(order['deliveredTimestamp'])),
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.039,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(165, 169, 178, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }

  Widget _buildMeetingContainer(Map<String, dynamic> meeting, double width, double height) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meetinghistory(meeting: meeting),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Arous_Sales_ERP_Images/History/blankImage.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${meeting['vendorName']}",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(101, 135, 179, 1),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(254, 249, 195, 1),
                          borderRadius: BorderRadius.circular(3.25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Meeting",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: width * 0.031,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(221, 180, 78, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "${meeting['meetingId']}",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(165, 169, 178, 1),
                    ),
                  ),
                  
                  SizedBox(height: height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/Arous_Sales_ERP_Images/History/rightArrow.png",
                        height: width * 0.035,
                      ),
                    ],
                  ),
                  Text(
                    _formatDateTime(meeting['meetingDate'], meeting['meetingTime']),
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.039,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(165, 169, 178, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Filter orders
    var filteredOrders = orders.where((order) {
      bool matchesStatus = order['status'] == 'Delivered';
      bool matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Purchase' && order['type'] == 'Purchase');
      bool matchesSearch = order['orderId'].toString().toLowerCase().contains(searchText.toLowerCase());
      return matchesStatus && matchesFilter && matchesSearch;
    }).toList();

    var filteredMeetings = meetings.where((meeting) {
      bool matchesFilter = selectedFilter == 'All' || selectedFilter == 'Meeting';
      bool matchesSearch = meeting['meetingId'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
          meeting['vendorName'].toString().toLowerCase().contains(searchText.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    // Combine orders and meetings
    List<Map<String, dynamic>> allItems = [];

    for (var order in filteredOrders) {
      final date = DateTime.parse(order['deliveredTimestamp'] ?? order['timestamp']);
      allItems.add({
        'type': 'order',
        'data': order,
        'date': date,
      });
    }

    for (var meeting in filteredMeetings) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(meeting['meetingDate']);
        allItems.add({
          'type': 'meeting',
          'data': meeting,
          'date': date,
        });
      } catch (e) {
        // Skip invalid meeting dates
      }
    }

    // Sort items by date and type
    allItems.sort((a, b) {
      int dateComparison = b['date'].compareTo(a['date']);
      if (dateComparison != 0) return dateComparison;

      if (a['type'] != b['type']) {
        return a['type'] == 'meeting' ? -1 : 1;
      }

      if (a['type'] == 'order' && b['type'] == 'order') {
        String aTimestamp = a['data']['deliveredTimestamp'] ?? a['data']['timestamp'];
        String bTimestamp = b['data']['deliveredTimestamp'] ?? b['data']['timestamp'];
        return DateTime.parse(bTimestamp).compareTo(DateTime.parse(aTimestamp));
      } else if (a['type'] == 'meeting' && b['type'] == 'meeting') {
        String aDateTime = "${a['data']['meetingDate']} ${a['data']['meetingTime']}";
        String bDateTime = "${b['data']['meetingDate']} ${b['data']['meetingTime']}";
        try {
          final aParsed = DateFormat('yyyy-MM-dd h:mm a').parse(aDateTime);
          final bParsed = DateFormat('yyyy-MM-dd h:mm a').parse(bDateTime);
          return bParsed.compareTo(aParsed);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    });

    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in allItems) {
      String header = _getDateHeader(item['date']);
      if (!groupedItems.containsKey(header)) {
        groupedItems[header] = [];
      }
      groupedItems[header]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'History',
          style: TextStyle(color: Color.fromRGBO(76, 76, 76, 1)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(243, 244, 246, 1),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  width: 2,
                  color: Color.fromRGBO(202, 202, 202, 1),
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                style: TextStyle(fontSize: width * 0.038),
                decoration: InputDecoration(
                  hintText: 'Search orders or meetings...',
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
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: width * 0.2,
                      height: height * 0.05,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'All';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(216, 218, 224, 1),
                          ),
                          minimumSize: Size(100, 40),
                          backgroundColor: selectedFilter == 'All'
                              ? Color.fromRGBO(0, 51, 153, 1)
                              : Colors.white,
                        ),
                        child: Text(
                          'All',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            color: selectedFilter == 'All'
                                ? Colors.white
                                : Color.fromRGBO(107, 114, 128, 1),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    SizedBox(
                      width: width * 0.3,
                      height: height * 0.05,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Purchase';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(216, 218, 224, 1),
                          ),
                          minimumSize: Size(100, 40),
                          backgroundColor: selectedFilter == 'Purchase'
                              ? Color.fromRGBO(0, 51, 153, 1)
                              : Colors.white,
                        ),
                        child: Text(
                          'Purchase',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            color: selectedFilter == 'Purchase'
                                ? Colors.white
                                : Color.fromRGBO(107, 114, 128, 1),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    SizedBox(
                      width: width * 0.3,
                      height: height * 0.05,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Meeting';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(216, 218, 224, 1),
                          ),
                          minimumSize: Size(100, 40),
                          backgroundColor: selectedFilter == 'Meeting'
                              ? Color.fromRGBO(0, 51, 153, 1)
                              : Colors.white,
                        ),
                        child: Text(
                          'Meeting',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            color: selectedFilter == 'Meeting'
                                ? Colors.white
                                : Color.fromRGBO(107, 114, 128, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.03),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : groupedItems.isEmpty
                        ? Center(
                            child: Text(
                              'No history found',
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(107, 114, 128, 1),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groupedItems.entries.map((entry) {
                              String header = entry.key;
                              List<Map<String, dynamic>> items = entry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    header,
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(76, 76, 76, 1),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  ...items.map((item) {
                                    if (item['type'] == 'order') {
                                      return _buildOrderContainer(item['data'], width, height);
                                    } else {
                                      return _buildMeetingContainer(item['data'], width, height);
                                    }
                                  }).toList(),
                                  SizedBox(height: height * 0.03),
                                ],
                              );
                            }).toList(),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}