import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/EditOrder/EditOrder.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/NewOrder/NewOrder.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Orders extends StatefulWidget {
  final Function(int) onNavigate;

  const Orders({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;
  String searchQuery = '';

  DateTime? selectedDate;
  TextEditingController dateController = TextEditingController();
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String get formattedDate {
    if (_selectedDay == null) return "Select Date";
    return DateFormat("MMM d").format(_selectedDay!);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = null; // Ensure no date is selected initially
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? existingOrders = prefs.getString('orders');
    print("Raw orders from SharedPreferences: $existingOrders");
    if (existingOrders != null) {
      try {
        List<Map<String, dynamic>> loadedOrders = List<Map<String, dynamic>>.from(jsonDecode(existingOrders));

        // Remove duplicates and invalid orders
        Map<String, Map<String, dynamic>> uniqueOrders = {};
        for (var order in loadedOrders) {
          // Check if order is valid
          bool isValid = order['orderId'] != null &&
              order['vendorName'] != null &&
              order['vendorName'] != 'Unknown Vendor' &&
              order['contactPerson'] != null &&
              order['contactPerson'] != 'Unknown Contact' &&
              order['address'] != null &&
              order['address'] != 'Unknown Address';

          if (!isValid) {
            print("Skipping invalid order: $order");
            continue;
          }

          String key = order['orderId'].toString();

          // If this is a duplicate, keep the most recent order
          if (uniqueOrders.containsKey(key)) {
            print("Duplicate order found for orderId: $key");
            var existingOrder = uniqueOrders[key]!;
            // Compare timestamps to keep the most recent
            var existingTimestamp = DateTime.tryParse(existingOrder['timestamp'] ?? '') ?? DateTime(1970);
            var newTimestamp = DateTime.tryParse(order['timestamp'] ?? '') ?? DateTime(1970);
            if (newTimestamp.isAfter(existingTimestamp)) {
              uniqueOrders[key] = order;
              print("Replacing duplicate with more recent order: $order");
            }
          } else {
            uniqueOrders[key] = order;
          }
        }

        setState(() {
          orders = uniqueOrders.values.toList();
          print("Loaded ${orders.length} unique and valid orders: $orders");

          // Initially show all orders (filtered by search query if any)
          _filterOrders();
          isLoading = false;
        });
      } catch (e) {
        print("Error decoding orders: $e");
        setState(() {
          isLoading = false;
          filteredOrders = [];
        });
      }
    } else {
      print("No orders found in SharedPreferences");
      setState(() {
        isLoading = false;
        filteredOrders = [];
      });
    }
  }

  void _filterOrders() {
    setState(() {
      if (_selectedDay == null) {
        // Show all orders, filtered by search query if provided
        filteredOrders = orders.where((order) {
          final vendorName = order['vendorName']?.toLowerCase() ?? '';
          return searchQuery.isEmpty || vendorName.contains(searchQuery.toLowerCase());
        }).toList();
      } else {
        // Show orders for the selected date, filtered by search query if provided
        final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
        filteredOrders = orders.where((order) {
          final vendorName = order['vendorName']?.toLowerCase() ?? '';
          return order['orderDate'] == selectedDateStr &&
              (searchQuery.isEmpty || vendorName.contains(searchQuery.toLowerCase()));
        }).toList();
      }

      // Sort orders by timestamp (newest first)
      filteredOrders.sort((a, b) {
        final aDate = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      print("Filtered orders after filtering: ${filteredOrders.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(247, 248, 249, 1),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 10),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                          ),
                          border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              _filterOrders();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search orders...',
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
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showCalendar = !_showCalendar;
                              });
                            },
                            child: Container(
                              width: width * 0.36,
                              height: height * 0.055,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(254, 254, 254, 1),
                                border: Border.all(
                                  width: 2,
                                  color: Color.fromRGBO(207, 212, 219, 1),
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(19),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(9),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      "assets/Arous_Sales_ERP_Images/Orders/calendar.png",
                                      width: width * 0.04,
                                    ),
                                    SizedBox(width: width * 0.008),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: width * 0.037,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w300,
                                        color: Color.fromRGBO(127, 134, 144, 1),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.01),
                                    Image.asset(
                                      "assets/Arous_Sales_ERP_Images/Tasks/downArrow.png",
                                      width: width * 0.03,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Implement filter functionality if needed
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
                        TableCalendar(
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2100),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _showCalendar = false;
                              _filterOrders();
                            });
                          },
                        ),
                      SizedBox(height: height * 0.01),
                      
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : filteredOrders.isEmpty
                              ? Center(
                                  child: Text(
                                    _selectedDay == null
                                        ? "No orders available"
                                        : "No orders for ${DateFormat('MMM d, yyyy').format(_selectedDay!)}",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: width * 0.04,
                                      color: Color.fromRGBO(91, 96, 106, 1),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = filteredOrders[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Editorder(
                                              amountDue: order['totalAmount']?.toDouble() ?? 0.0,
                                              orderId: order['orderId'] ?? '',
                                              vendorName: order['vendorName'] ?? 'Unknown',
                                              contactPerson: order['contactPerson'] ?? 'Unknown',
                                              address: order['address'] ?? 'Unknown',
                                              orderedItems: List<Map<String, dynamic>>.from(order['orderedItems'] ?? []),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        height: height * 0.15,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/Arous_Sales_ERP_Images/Orders/blankImage.png"),
                                            fit: BoxFit.cover,
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
                                                  Expanded(
                                                    child: Text(
                                                      order['vendorName'] ?? 'Unknown',
                                                      style: TextStyle(
                                                        fontFamily: "Inter",
                                                        fontSize: width * 0.038,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color.fromRGBO(91, 96, 106, 1),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    order['timestamp'] != null && DateTime.tryParse(order['timestamp']) != null
                                                        ? DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(order['timestamp']))
                                                        : 'N/A',
                                                    style: TextStyle(
                                                      fontFamily: "Inter",
                                                      fontSize: width * 0.031,
                                                      fontWeight: FontWeight.w400,
                                                      color: Color.fromRGBO(160, 165, 174, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: height * 0.01),
                                              Text(
                                                "#${order['orderId'] ?? 'N/A'}",
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: width * 0.035,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color.fromRGBO(161, 166, 175, 1),
                                                ),
                                              ),
                                              SizedBox(height: height * 0.005),
                                              Text(
                                                "₹${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: width * 0.035,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color.fromRGBO(84, 84, 84, 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Neworder()),
                ).then((_) {
                  setState(() {
                    _selectedDay = null; // Reset to show all orders
                    _loadOrderDetails();
                  });
                });
              },
              icon: Image.asset(
                "assets/Arous_Sales_ERP_Images/Orders/AddImage.png",
                width: width * 0.15,
              ),
            ),
          ),
          SizedBox(height: height * 0.01),
        ],
      ),
    );
  }
}