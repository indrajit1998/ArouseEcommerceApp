import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/NewOrder/NewOrder.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Addnewproduct extends StatefulWidget {
  final List<Map<String, dynamic>>? existingProducts;

  const Addnewproduct({super.key, this.existingProducts});

  @override
  State<Addnewproduct> createState() => _AddnewproductState();
}

class _AddnewproductState extends State<Addnewproduct> {
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> selectedProducts = [];
  List<Map<String, dynamic>> items = [];

  double subtotal = 0;
  double tax = 0;
  double deliveryFee = 25;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    selectedProducts = widget.existingProducts != null ? List.from(widget.existingProducts!) : [];
    _getProducts();
    calculateTotals();
  }

  void calculateTotals() {
    subtotal = 0;
    for (var item in selectedProducts) {
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
      if (token == null) {
        print('[getToken] No auth token found in SharedPreferences');
        return null;
      }
      if (JwtDecoder.isExpired(token)) {
        print('[getToken] Token expired. Refreshing token...');
        return await refreshToken();
      }
      print('[getToken] Retrieved Token: $token');
      return token;
    } catch (e, stackTrace) {
      print('[getToken] Error retrieving token: $e\nStackTrace: $stackTrace');
      return null;
    }
  }

  Future<String?> refreshToken() async {
    final String refreshTokenApiUrl = "http://127.0.0.1:7500/api/auth/refreshToken";
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) {
        print('[refreshToken] No refresh token found in SharedPreferences');
        return null;
      }
      print('[refreshToken] Sending refresh token request to $refreshTokenApiUrl');
      final response = await http.post(
        Uri.parse(refreshTokenApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );
      print('[refreshToken] Response status: ${response.statusCode}');
      print('[refreshToken] Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['accessToken'];
        await prefs.setString('authToken', newToken);
        print('[refreshToken] New Token: $newToken');
        return newToken;
      } else {
        print('[refreshToken] Failed to refresh token: Status ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('[refreshToken] Error refreshing token: $e\nStackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _getProducts() async {
    final String apiUrl = "http://127.0.0.1:7500/api/product/getAll";
    try {
      print('[_getProducts] Starting product fetch from $apiUrl');
      final token = await getToken();
      if (token == null) {
        print('[_getProducts] No valid token available');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Authentication token not found. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      print('[_getProducts] Using token: $token');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print('[_getProducts] Request headers: $headers');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );
      print('[_getProducts] Response status: ${response.statusCode}');
      print('[_getProducts] Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[_getProducts] Parsed response data: $data');
        if (data['success']) {
          setState(() {
            items = data['products']
                .where((product) {
                  final variants = product['variants'] ?? product['variant'] ?? [];
                  return variants is List && variants.isNotEmpty;
                })
                .map<Map<String, dynamic>>((product) {
              var existingProduct = widget.existingProducts?.firstWhere(
                (p) => p['name'] == product['name'],
                orElse: () => {'count': 0},
              );
              final variants = product['variants'] ?? product['variant'] ?? [];
              return {
                'name': product['name'] ?? 'Unknown',
                'color': product['description'] ?? '',
                'price': variants.isNotEmpty ? (variants[0]['price'] ?? 0.0) : 0.0,
                'image': (product['images']?.isNotEmpty ?? false) ? product['images'][0] : '',
                'count': existingProduct?['count'] ?? 0,
                'variants': variants,
              };
            }).toList();
            filteredItems = List.from(items);
            calculateTotals();
          });
          print('[_getProducts] Loaded ${items.length} products');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Products loaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('[_getProducts] No products found in response');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No products found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('[_getProducts] Failed with status ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          print('[_getProducts] Error data: $errorData');
          String errorMessage = errorData['message'] ?? 'Unknown error';
          if (errorData['error'] is String) {
            errorMessage += ': ${errorData['error']}';
          } else if (errorData['error'] is Map) {
            errorMessage += ': ${errorData['error']['message'] ?? errorData['error'].toString()}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load products: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          print('[_getProducts] Failed to parse error response: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load products: Status ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      print('[_getProducts] Error loading products: $error\nStackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading products: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveOrder() async {
    final String apiUrl = "http://127.0.0.1:7500/api/order/add";
    try {
      print('[_saveOrder] Starting order save to $apiUrl');
      final token = await getToken();
      if (token == null) {
        print('[_saveOrder] No valid token available');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Authentication token not found. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      print('[_saveOrder] Using token: $token');
      final orderData = {
        'items': items
            .where((item) => (item['count'] ?? 0) > 0)
            .map((item) => {
                  'name': item['name'],
                  'quantity': item['count'],
                  'price': item['price'],
                  'total': item['count'] * item['price'],
                })
            .toList(),
        'subtotal': subtotal,
        'tax': tax,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
      };
      print('[_saveOrder] Order data: $orderData');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );
      print('[_saveOrder] Response status: ${response.statusCode}');
      print('[_saveOrder] Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[_saveOrder] Order saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('[_saveOrder] Failed with status ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save order: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error, stackTrace) {
      print('[_saveOrder] Error saving order: $error\nStackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving order: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: TextStyle(
            color: Color.fromRGBO(73, 73, 73, 1),
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
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        filteredItems = items
                            .where((item) => item['name'].toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search or select Product...',
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
                SizedBox(height: height * 0.02),
                Container(
                  height: height * 1,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final isSelected =
                          selectedProducts.any((item) => item['name'] == filteredItems[index]['name']);
                      final variants = filteredItems[index]['variants'] as List<dynamic>? ?? [];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedProducts
                                  .removeWhere((item) => item['name'] == filteredItems[index]['name']);
                            } else {
                              selectedProducts.add(Map<String, dynamic>.from(filteredItems[index]));
                            }
                            calculateTotals();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/Arous_Sales_ERP_Images/newOrders/blankImage1.png"),
                              fit: BoxFit.cover,
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 15, top: 20, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      filteredItems[index]['image'].isNotEmpty
                                          ? filteredItems[index]['image']
                                          : 'assets/Arous_Sales_ERP_Images/newOrders/placeholder.png',
                                      width: width * 0.2,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                                    ),
                                    SizedBox(width: width * 0.05),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            filteredItems[index]['name'],
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Color.fromRGBO(84, 84, 84, 1),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Inter",
                                            ),
                                          ),
                                          SizedBox(height: height * 0.006),
                                          Text(
                                            filteredItems[index]['color'],
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
                                                "${variants.isNotEmpty ? variants[0]['priceUnit'] : '₹'} : ${filteredItems[index]['price'].toStringAsFixed(2)}",
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
                                                          if (filteredItems[index]['count'] > 0) {
                                                            filteredItems[index]['count']--;
                                                            var selected = selectedProducts.firstWhere(
                                                              (item) => item['name'] == filteredItems[index]['name'],
                                                              orElse: () => {},
                                                            );
                                                            if (selected.isNotEmpty) {
                                                              selected['count'] = filteredItems[index]['count'];
                                                            }
                                                            if (filteredItems[index]['count'] == 0) {
                                                              selectedProducts.removeWhere(
                                                                  (item) => item['name'] == filteredItems[index]['name']);
                                                            }
                                                          }
                                                          calculateTotals();
                                                        });
                                                      },
                                                      icon: Image.asset(
                                                        "assets/Arous_Sales_ERP_Images/newOrders/minus.png",
                                                        width: width * 0.02,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${filteredItems[index]['count']}",
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
                                                          filteredItems[index]['count']++;
                                                          var selected = selectedProducts.firstWhere(
                                                            (item) => item['name'] == filteredItems[index]['name'],
                                                            orElse: () => Map<String, dynamic>.from(filteredItems[index]),
                                                          );
                                                          selected['count'] = filteredItems[index]['count'];
                                                          if (!selectedProducts.contains(selected)) {
                                                            selectedProducts.add(selected);
                                                          }
                                                          calculateTotals();
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
                                            "Total: ${variants.isNotEmpty ? variants[0]['priceUnit'] : '₹'}${(filteredItems[index]['count'] * filteredItems[index]['price']).toStringAsFixed(2)}",
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
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: height * 0.02),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/Arous_Sales_ERP_Images/newOrders/blueButton.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            selectedProducts = filteredItems
                                .where((item) => item['count'] > 0)
                                .map((item) => Map<String, dynamic>.from(item))
                                .toList();
                          });
                          if (selectedProducts.isNotEmpty) {
                            print("[Save Button] Selected Products: $selectedProducts");
                            Navigator.pop(context, selectedProducts);
                          } else {
                            print("[Save Button] No products selected");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select a product & count should be at least 1!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: width * 0.043,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(173, 191, 214, 1),
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