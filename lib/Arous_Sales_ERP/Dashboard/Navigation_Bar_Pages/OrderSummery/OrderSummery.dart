import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/ConfirmOrder/confirmOrder.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Ordersummery extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  const Ordersummery({super.key, required this.selectedProducts});

  @override
  State<Ordersummery> createState() => _OrdersummeryState();
}

class _OrdersummeryState extends State<Ordersummery> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    calculateTotals();
  }

  double subtotal = 0;
  double tax = 0;
  double deliveryFee = 25;
  double totalAmount = 0;

  void calculateTotals() {
    subtotal = 0;
    for (var item in widget.selectedProducts) {
      subtotal += item['price'] * item['count'];
    }
    tax = subtotal * 0.10;
    totalAmount = subtotal + tax + deliveryFee;
    setState(() {});
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token != null && JwtDecoder.isExpired(token)) {
        print("Token expired. Refreshing token...");
        return await refreshToken();
      }
      print("Retrieved Token: $token");
      return token;
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
  }

  Future<String?> refreshToken() async {
    final String refreshTokenApiUrl = "http://10.0.2.2:7500/api/auth/refreshToken";
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

  String generateOrderId() {
    final random = Random();
    final number = random.nextInt(999999);
    return "#ORD-${number.toString().padLeft(6, '0')}";
  }

  Future<Map<String, dynamic>?> fetchClientData(String vendorId, String token) async {
    final String apiUrl = "http://10.0.2.2:7500/api/client/get/$vendorId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Fetched client data: ${responseData['client']}");
        return responseData['client'];
      } else {
        print("Failed to fetch client data: ${response.body}");
        return null;
      }
    } catch (error) {
      print("Error fetching client data: $error");
      return null;
    }
  }

  Future<String?> submitOrder(String orderId) async {
    final String apiUrl = "http://10.0.2.2:7500/api/order/add";
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorId = prefs.getString('vendorId');

    if (token == null || vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(token == null ? "No valid token found." : "No vendor selected."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    // Fetch vendor details from API
    Map<String, dynamic>? clientData = await fetchClientData(vendorId, token);
    if (clientData == null) {
      print("Failed to fetch client data for vendorId: $vendorId");
    }
    String vendorName = clientData?['vendorName'] ?? 'Unknown Vendor';
    String contactPerson = clientData?['contactPerson'] ?? 'Unknown Contact';
    String address = clientData?['address'] ?? 'Unknown Address';

    // Store vendor details in SharedPreferences for consistency
    await prefs.setString('vendorName', vendorName);
    await prefs.setString('contactPerson', contactPerson);
    await prefs.setString('vendorAddress', address);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({
          "clientOrderId": orderId,
          "vendorId": vendorId,
          "items": widget.selectedProducts.where((item) => item['count'] > 0).map((item) {
            return {...item, "quantity": item['count']};
          }).toList(),
          "subtotal": subtotal,
          "taxRate": 0.1,
          "taxAmount": tax,
          "deliveryFee": deliveryFee,
          "totalAmount": totalAmount,
          "paymentMethod": "Credit Card",
          "deliveryAddress": "120/5/501/A, Bangalore, Karnataka, 560010",
          "status": "Placed",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final backendOrderId = data['savedOrder']['_id'];

        final orderDetails = {
          'orderId': orderId,
          'backendOrderId': backendOrderId,
          'vendorId': vendorId,
          'vendorName': vendorName,
          'contactPerson': contactPerson,
          'address': address,
          'orderedItems': widget.selectedProducts.where((item) => item['count'] > 0).toList(),
          'subtotal': subtotal,
          'taxAmount': tax,
          'deliveryFee': deliveryFee,
          'totalAmount': totalAmount,
          'orderDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'timestamp': DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
          'status': 'Placed',
          'type': 'Purchase',
          'orderType': 'Take Order',
        };

        String? existingOrders = prefs.getString('orders');
        List<Map<String, dynamic>> orders = existingOrders != null
            ? List<Map<String, dynamic>>.from(jsonDecode(existingOrders))
            : [];
        orders.add(orderDetails);
        await prefs.setString('orders', jsonEncode(orders));

        // Save notification
        List<String> notifications = prefs.getStringList('notifications') ?? [];
        Map<String, dynamic> notificationData = {
          'id': 'NOTIF-$orderId',
          'vendorName': vendorName,
          'purpose': 'Order placed: $orderId',
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
          'type': 'Order',
        };
        notifications.add(jsonEncode(notificationData));
        await prefs.setStringList('notifications', notifications);

        print("Stored order: $orderDetails");
        print("Total orders stored: ${orders.length}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order placed successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        return backendOrderId;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonDecode(response.body)['message'] ?? "Failed to place order"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return null;
      }
    } catch (error) {
      print("Error submitting order: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
  }

  Future<bool> updateOrder(String orderId) async {
    final String apiUrl = "http://10.0.2.2:7500/api/order/update/$orderId";
    String? token = await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorId = prefs.getString('vendorId');

    if (token == null || vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(token == null ? "No valid token found." : "No vendor selected."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    // Fetch vendor details for update
    Map<String, dynamic>? clientData = await fetchClientData(vendorId, token);
    if (clientData == null) {
      print("Failed to fetch client data for vendorId: $vendorId");
    }
    String vendorName = clientData?['vendorName'] ?? 'Unknown Vendor';
    String contactPerson = clientData?['contactPerson'] ?? 'Unknown Contact';
    String address = clientData?['address'] ?? 'Unknown Address';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "items": widget.selectedProducts.where((item) => item['count'] > 0).map((item) {
            return {...item, "quantity": item['count']};
          }).toList(),
          "subtotal": subtotal,
          "taxRate": 0.1,
          "taxAmount": tax,
          "deliveryFee": deliveryFee,
          "totalAmount": totalAmount,
          "paymentMethod": "Credit Card",
          "deliveryAddress": "120/5/501/A, Bangalore, Karnataka, 560010",
          "status": "Placed",
        }),
      );

      if (response.statusCode == 200) {
        // Update stored order in SharedPreferences
        String? existingOrders = prefs.getString('orders');
        if (existingOrders != null) {
          List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(jsonDecode(existingOrders));
          int index = orders.indexWhere((order) => order['backendOrderId'] == orderId);
          if (index != -1) {
            orders[index] = {
              ...orders[index],
              'orderedItems': widget.selectedProducts.where((item) => item['count'] > 0).toList(),
              'subtotal': subtotal,
              'taxAmount': tax,
              'deliveryFee': deliveryFee,
              'totalAmount': totalAmount,
              'vendorName': vendorName,
              'contactPerson': contactPerson,
              'address': address,
              'status': 'Placed',
              'type': 'Purchase',
              'timestamp': DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
            };
            await prefs.setString('orders', jsonEncode(orders));
          }
        }

        // Update notification
        List<String> notifications = prefs.getStringList('notifications') ?? [];
        notifications = notifications.map((notification) {
          final data = jsonDecode(notification) as Map<String, dynamic>;
          if (data['id'] == 'NOTIF-$orderId') {
            data['purpose'] = 'Order updated: $orderId';
            data['timestamp'] = DateTime.now().toIso8601String();
            data['isRead'] = false;
          }
          return jsonEncode(data);
        }).toList();
        await prefs.setStringList('notifications', notifications);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order updated successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        return true;
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Failed to update order"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }
    } catch (error) {
      print("Error updating order: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred while updating the order."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final displayItems = widget.selectedProducts.where((item) => item['count'] > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Summary',
          style: TextStyle(
            color: Color.fromRGBO(76, 76, 76, 1),
            fontFamily: "Inter",
            fontSize: width * 0.05,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        elevation: 0.1,
        shadowColor: Color.fromRGBO(105, 138, 181, 1),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  child: displayItems.isEmpty
                      ? Center(
                          child: Text(
                            'No products selected',
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
                          itemCount: displayItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/Arous_Sales_ERP_Images/newOrders/blankImage1.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 15, top: 20, bottom: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          displayItems[index]['image'],
                                          width: width * 0.2,
                                        ),
                                        SizedBox(width: width * 0.05),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayItems[index]['name'],
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color: Color.fromRGBO(84, 84, 84, 1),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.006),
                                                Text(
                                                  displayItems[index]['color'],
                                                  style: TextStyle(
                                                    fontSize: width * 0.036,
                                                    color: Color.fromRGBO(144, 150, 159, 1),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "内核",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.01),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "₹${displayItems[index]['price']}",
                                                      style: TextStyle(
                                                        fontSize: width * 0.036,
                                                        color: Color.fromRGBO(80, 80, 80, 1),
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: "Inter",
                                                      ),
                                                    ),
                                                    SizedBox(width: width * 0.1),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromRGBO(255, 255, 255, 1),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Color.fromRGBO(218, 219, 225, 1),
                                                        ),
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (displayItems[index]['count'] > 0) displayItems[index]['count']--;
                                                                  calculateTotals();
                                                                });
                                                              },
                                                              icon: Image.asset("assets/Arous_Sales_ERP_Images/newOrders/minus.png", width: width * 0.02),
                                                            ),
                                                            SizedBox(width: width * 0.0),
                                                            Text(
                                                              "${displayItems[index]['count']}",
                                                              style: TextStyle(
                                                                fontSize: width * 0.04,
                                                                color: Color.fromRGBO(75, 75, 75, 1),
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: "Inter",
                                                              ),
                                                            ),
                                                            SizedBox(width: width * 0.0),
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  displayItems[index]['count']++;
                                                                  calculateTotals();
                                                                });
                                                              },
                                                              icon: Image.asset("assets/Arous_Sales_ERP_Images/newOrders/add.png", width: width * 0.02),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: height * 0.01),
                                                Text(
                                                  "Total: ₹${(displayItems[index]['count'] * displayItems[index]['price']).toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                    fontSize: width * 0.036,
                                                    color: Color.fromRGBO(141, 147, 156, 1),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                SizedBox(height: height * 0.05),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: width * 0.048,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(84, 84, 84, 1),
                            fontWeight: FontWeight.w400,
                          ),
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
                                color: Color.fromRGBO(141, 147, 156, 1),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "₹${subtotal.toStringAsFixed(2)}",
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
                              "Tax (10%)",
                              style: TextStyle(
                                fontSize: width * 0.044,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(141, 147, 156, 1),
                                fontWeight: FontWeight.w400,
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
                        Divider(
                          thickness: 1,
                          color: Color.fromRGBO(230, 232, 236, 1),
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
                                color: Color.fromRGBO(87, 87, 87, 1),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "₹${totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: width * 0.044,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(86, 86, 86, 1),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.07),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
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
                          String clientOrderId = generateOrderId();
                          String? backendOrderId = await submitOrder(clientOrderId);
                          if (backendOrderId != null) {
                            final orderedItems = widget.selectedProducts.where((item) => item['count'] > 0).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Confirmorder(
                                  itemCount: widget.selectedProducts.where((item) => item['count'] > 0).length,
                                  totalAmount: totalAmount,
                                  subtotal: subtotal,
                                  taxAmount: tax,
                                  clientOrderId: clientOrderId,
                                  backendOrderId: backendOrderId,
                                  orderDate: DateTime.now(),
                                  orderedItems: orderedItems,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Place Order",
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
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}