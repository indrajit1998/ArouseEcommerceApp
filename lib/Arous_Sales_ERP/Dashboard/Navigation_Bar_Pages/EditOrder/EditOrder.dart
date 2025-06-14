import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddNewProduct/AddNewProduct.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/OrderSummery/OrderSummery.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Editorder extends StatefulWidget {
  final double amountDue;
  final String orderId;
  final String vendorName;
  final String contactPerson;
  final String address;
  final List<Map<String, dynamic>> orderedItems;

  const Editorder({
    required this.amountDue,
    required this.orderId,
    required this.orderedItems,
    this.vendorName = 'Unknown',
    this.contactPerson = '',
    this.address = '',
    Key? key,
  }) : super(key: key);

  @override
  State<Editorder> createState() => _EditorderState();
}

class _EditorderState extends State<Editorder> {
  List<Map<String, dynamic>> orderedItems = [];
  double subtotal = 0;
  double tax = 0;
  double deliveryFee = 25;
  double totalAmount = 0;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Deep copy to avoid modifying the original list
    orderedItems = widget.orderedItems.map((item) => Map<String, dynamic>.from(item)).toList();
    calculateTotals();
  }

  void calculateTotals() {
    subtotal = 0;
    for (var item in orderedItems) {
      double price = (item['price'] is String ? double.parse(item['price']) : item['price']) ?? 0.0;
      int count = item['count'] ?? 0;
      subtotal += price * count;
    }
    tax = subtotal * 0.10;
    totalAmount = subtotal + tax + deliveryFee;
    setState(() {});
  }

  Future<void> _updateOrderInSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? existingOrders = prefs.getString('orders');
    if (existingOrders != null) {
      List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(jsonDecode(existingOrders));
      int orderIndex = orders.indexWhere((order) => order['orderId'] == widget.orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = {
          ...orders[orderIndex],
          'totalAmount': totalAmount,
          'subtotal': subtotal,
          'taxAmount': tax,
          'deliveryFee': deliveryFee,
          'orderedItems': orderedItems,
          'vendorName': widget.vendorName,
          'contactPerson': widget.contactPerson,
          'address': widget.address,
        };
        await prefs.setString('orders', jsonEncode(orders));
      }
    }
  }

  Future<String?> refreshToken() async {
    final String refreshTokenApiUrl = "http://127.0.0.1:7500/api/auth/refreshToken";
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) {
        print("No refresh token found. Please log in again.");
        return null;
      }
      final response = await http.post(
        Uri.parse(refreshTokenApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newToken = data['accessToken'];
        await prefs.setString('authToken', newToken);
        print("New Token: $newToken");
        return newToken;
      } else {
        print("Failed to refresh token: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 249, 250, 1),
      appBar: AppBar(
        title: Text(
          widget.orderId.isEmpty ? '#S00001' : widget.orderId,
          style: TextStyle(
            fontFamily: "Inter",
            fontSize: width * 0.04,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(136, 142, 152, 1),
          ),
        ),
        elevation: 0.1,
        shadowColor: Color.fromRGBO(105, 138, 181, 1),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                final newProducts = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addnewproduct()),
                );
                if (newProducts != null && newProducts is List<Map<String, dynamic>>) {
                  setState(() {
                    for (var newProduct in newProducts) {
                      if (!orderedItems.any((item) => item['name'] == newProduct['name'])) {
                        orderedItems.add({...newProduct, 'count': newProduct['count'] ?? 1});
                      } else {
                        var existingItem = orderedItems.firstWhere((item) => item['name'] == newProduct['name']);
                        existingItem['count'] = (existingItem['count'] ?? 0) + (newProduct['count'] ?? 1);
                      }
                    }
                    calculateTotals();
                    _updateOrderInSharedPreferences();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(25, 75, 141, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.75),
                  side: BorderSide(color: Color.fromRGBO(59, 102, 158, 1)),
                ),
              ),
              child: Text(
                "Add Product",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(167, 186, 211, 1),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vendorName,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: width * 0.043,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(72, 72, 72, 1),
                              ),
                            ),
                            SizedBox(height: height * 0.008),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/Arous_Sales_ERP_Images/EditOrder/location.png",
                                  width: width * 0.03,
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  widget.address,
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(144, 150, 159, 1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.005),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/Arous_Sales_ERP_Images/EditOrder/person.png",
                                  width: width * 0.03,
                                ),
                                SizedBox(width: width * 0.02),

                                Text(
                                  widget.contactPerson,
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(144, 150, 159, 1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      child: orderedItems.isEmpty
                          ? Center(
                              child: Text(
                                'No items found',
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Colors.red,
                                  fontFamily: "Inter",
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: orderedItems.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/Arous_Sales_ERP_Images/newOrders/blankImage1.png"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0, right: 15, top: 20, bottom: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              orderedItems[index]['image'] ?? 'assets/placeholder.png',
                                              width: width * 0.2,
                                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                                            ),
                                            SizedBox(width: width * 0.05),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    orderedItems[index]['name'] ?? 'Unknown Item',
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      color: Color.fromRGBO(84, 84, 84, 1),
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: "Inter",
                                                    ),
                                                  ),
                                                  SizedBox(height: height * 0.006),
                                                  Text(
                                                    orderedItems[index]['color'] ?? 'N/A',
                                                    style: TextStyle(
                                                      fontSize: width * 0.036,
                                                      color: Color.fromRGBO(144, 150, 159, 1),
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: "Inter",
                                                    ),
                                                  ),
                                                  SizedBox(height: height * 0.01),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "₹${(orderedItems[index]['price'] ?? 0).toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                          fontSize: width * 0.036,
                                                          color: Color.fromRGBO(80, 80, 80, 1),
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: "Inter",
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Color.fromRGBO(255, 255, 255, 1),
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Color.fromRGBO(218, 219, 225, 1),
                                                          ),
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (orderedItems[index]['count'] > 0) {
                                                                    orderedItems[index]['count']--;
                                                                    if (orderedItems[index]['count'] == 0) {
                                                                      orderedItems.removeAt(index);
                                                                    }
                                                                    calculateTotals();
                                                                    _updateOrderInSharedPreferences();
                                                                  }
                                                                });
                                                              },
                                                              icon: Image.asset(
                                                                "assets/Arous_Sales_ERP_Images/newOrders/minus.png",
                                                                width: width * 0.02,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${orderedItems[index]['count'] ?? 0}",
                                                              style: TextStyle(
                                                                fontSize: width * 0.04,
                                                                color: Color.fromRGBO(75, 75, 75, 1),
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: "Inter",
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  orderedItems[index]['count']++;
                                                                  calculateTotals();
                                                                  _updateOrderInSharedPreferences();
                                                                });
                                                              },
                                                              icon: Image.asset(
                                                                "assets/Arous_Sales_ERP_Images/newOrders/add.png",
                                                                width: width * 0.02,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: height * 0.01),
                                                  Text(
                                                    "Total: ₹${((orderedItems[index]['count'] ?? 0) * (orderedItems[index]['price'] ?? 0)).toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                      fontSize: width * 0.036,
                                                      color: Color.fromRGBO(141, 147, 156, 1),
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: "Inter",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: height * 0.02),
                    Divider(
                      thickness: 1,
                      color: Color.fromRGBO(248, 249, 250, 1),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Previous Order Value",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(142, 149, 157, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${widget.amountDue.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(83, 83, 83, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(143, 149, 158, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${subtotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(82, 82, 82, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tax (10%)",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(147, 153, 161, 1),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  "₹${tax.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(86, 86, 86, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Delivery Fee",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(141, 147, 156, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${deliveryFee.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(86, 86, 86, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(141, 147, 156, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${totalAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(93, 93, 93, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/Arous_Sales_ERP_Images/newOrders/blueButton.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      await _updateOrderInSharedPreferences();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Ordersummery(
                                            selectedProducts: orderedItems.where((item) => item['count'] > 0).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Update Order",
                                      style: TextStyle(
                                        fontSize: width * 0.043,
                                        fontFamily: "Inter",
                                        color: Color.fromRGBO(178, 195, 217, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}