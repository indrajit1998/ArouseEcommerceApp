import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Dashboard.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/EditOrder/EditOrder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Confirmorder extends StatefulWidget {
  final int itemCount;
  final double totalAmount;
  final double subtotal;
  final double taxAmount;
  final String clientOrderId;
  final DateTime orderDate;
  final String backendOrderId;
  final List<Map<String, dynamic>> orderedItems;

  const Confirmorder({
    Key? key,
    required this.itemCount,
    required this.totalAmount,
    required this.subtotal,
    required this.taxAmount,
    required this.clientOrderId,
    required this.orderDate,
    required this.backendOrderId,
    required this.orderedItems,
  }) : super(key: key);

  @override
  State<Confirmorder> createState() => _ConfirmorderState();
}

class _ConfirmorderState extends State<Confirmorder> {
  String vendorName = 'Unknown';
  String contactPerson = '';
  String address = '';

  @override
  void initState() {
    super.initState();
    _saveOrderDetails();
  }

  Future<void> _saveOrderDetails() async {
    final prefs = await SharedPreferences.getInstance();

    String? vendorId = prefs.getString('vendorId');

    if (vendorId != null) {
      final String apiUrl = "http://127.0.0.1:7500/api/client/get/$vendorId";
      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            vendorName = responseData['client']['vendorName'] ?? 'Unknown';
            contactPerson = responseData['client']['contactPerson'] ?? '';
            address = responseData['client']['address'] ?? '';
          });
        } else {
          print('Failed to fetch vendor details: ${response.body}');
        }
      } catch (error) {
        print('Error fetching vendor details: $error');
      }
    } else {
      print('Vendor ID not found in SharedPreferences');
    }

    List<Map<String, dynamic>> orders = [];
    String? existingOrders = prefs.getString('orders');
    if (existingOrders != null) {
      orders = List<Map<String, dynamic>>.from(jsonDecode(existingOrders));
    }

    final dateFormatter = DateFormat('yyyy-MM-dd');
    final orderDateStr = dateFormatter.format(widget.orderDate);

    orders.add({
      'orderId': widget.clientOrderId,
      'backendOrderId': widget.backendOrderId,
      'totalAmount': widget.totalAmount,
      'subtotal': widget.subtotal,
      'taxAmount': widget.taxAmount,
      'vendorName': vendorName,
      'contactPerson': contactPerson,
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
      'orderDate': orderDateStr,
      'estimatedDelivery': getEstimatedDeliveryRange(),
      'orderedItems': widget.orderedItems,
      'status': 'Placed',
      'type': 'Purchase',
    });

    await prefs.setString('orders', jsonEncode(orders));
  }

  String getEstimatedDeliveryRange() {
    final startDate = widget.orderDate.add(Duration(days: 3));
    final endDate = widget.orderDate.add(Duration(days: 5));
    final formatter = DateFormat('MMMdd');
    return "${formatter.format(startDate)}-${formatter.format(endDate)}";
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Arous_Sales_ERP_Images/ConfirmOrder/fullPaage.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Image.asset(
                    "assets/Arous_Sales_ERP_Images/ConfirmOrder/confirmOrder.png",
                    height: height * 0.25,
                    width: width * 1,
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    "Order Confirmed!",
                    style: TextStyle(
                      fontSize: width * 0.064,
                      color: Color.fromRGBO(57, 61, 72, 1),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    "Order ${widget.clientOrderId}",
                    style: TextStyle(
                      fontSize: width * 0.034,
                      color: Color.fromRGBO(143, 146, 152, 1),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.08),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontFamily: "Inter",
                              color: Color.fromRGBO(92, 97, 104, 1),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Items Total",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  color: Color.fromRGBO(141, 147, 156, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "${widget.itemCount} items",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  color: Color.fromRGBO(86, 86, 86, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order Total",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  color: Color.fromRGBO(141, 147, 156, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "₹${widget.totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  color: Color.fromRGBO(86, 86, 86, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Estimated Delivery",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  color: Color.fromRGBO(141, 147, 156, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                getEstimatedDeliveryRange(),
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  color: Color.fromRGBO(86, 86, 86, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.06),
                  GestureDetector(
                    onTap: () {
                      print("Navigating to Editorder with backendOrderId: ${widget.backendOrderId}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Editorder(
                            amountDue: widget.totalAmount,
                            orderId: widget.clientOrderId,
                            orderedItems: widget.orderedItems,
                            vendorName: vendorName,
                            contactPerson: contactPerson,
                            address: address,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(254, 254, 254, 1),
                        border: Border.all(
                          width: 3,
                          color: Color.fromRGBO(113, 138, 168, 1),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(13),
                        child: Center(
                          child: Text(
                            "Edit Order",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontFamily: "Inter",
                              color: Color.fromRGBO(109, 133, 165, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/Arous_Sales_ERP_Images/ConfirmOrder/backArrow.png",
                          width: width * 0.035,
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          "Back to Home",
                          style: TextStyle(
                            fontSize: width * 0.038,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(97, 121, 153, 1),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}