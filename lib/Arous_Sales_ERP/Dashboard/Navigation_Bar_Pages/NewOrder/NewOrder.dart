import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/EditClient.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddNewProduct/AddNewProduct.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/OrderSummery/OrderSummery.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Neworder extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedProducts;

  const Neworder({super.key, this.selectedProducts});

  @override
  State<Neworder> createState() => _NeworderState();
}

class _NeworderState extends State<Neworder> {
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> allSelectedItems = [];

  @override
  void initState() {
    super.initState();
    _loadClientData();
    if (widget.selectedProducts != null) {
      allSelectedItems = List.from(widget.selectedProducts!);
      filteredItems = List.from(widget.selectedProducts!);
    }
    calculateTotals();
  }

  double subtotal = 0;
  double tax = 0;
  double deliveryFee = 25;
  double totalAmount = 0;

  void calculateTotals() {
    subtotal = 0;
    for (var item in allSelectedItems) {
      subtotal += item['price'] * item['count'];
    }
    tax = subtotal * 0.10;
    totalAmount = subtotal + tax + deliveryFee;
    setState(() {});
  }

  String vendorName = '';
  String contactPerson = '';
  String address = '';
  String area = '';

  bool isLoading = true;
  String? errorMessage;

  Future<void> _loadClientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorId = prefs.getString('vendorId');
    print('Retrieved Vendor ID: $vendorId');

    if (vendorId == null || vendorId.isEmpty) {
      setState(() {
        errorMessage = 'Vendor ID not found in SharedPreferences';
        isLoading = false;
      });
      return;
    }

    final String apiUrl = "http://10.0.2.2:7500/api/client/get/$vendorId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final clientData = responseData['client'];

        setState(() {
          vendorName = clientData['vendorName'] ?? 'Coca-Cola Beverages Ltd.';
          contactPerson = clientData['contactPerson'] ?? 'John Anderson';
          address = clientData['address'] ?? '123 Business Park, Suite 456, New York, NY 10001';
          area = clientData['area'] ?? 'Unknown';
          isLoading = false;
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          errorMessage = responseData['message'] ?? 'Failed to fetch client data';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching client data: $error';
        isLoading = false;
      });
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
          'New Order',
          style: TextStyle(
            color: Color.fromRGBO(70, 70, 70, 1),
            fontFamily: "Inter",
            fontSize: width * 0.05,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        elevation: 0.1,
        shadowColor: Color.fromRGBO(105, 138, 181, 1),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Save",
              style: TextStyle(
                color: Color.fromRGBO(105, 138, 181, 1),
                fontFamily: "Inter",
                fontSize: width * 0.035,
              ),
            ),
          ),
        ],
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
                        if (value.isEmpty) {
                          filteredItems = List.from(allSelectedItems);
                        } else {
                          filteredItems = allSelectedItems
                              .where((item) => item['name'].toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }
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
                SizedBox(height: height * 0.02),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/Arous_Sales_ERP_Images/newOrders/blankImage.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vendorName.isEmpty ? "Acme Corporation Ltd." : vendorName,
                                  style: TextStyle(
                                    fontSize: width * 0.042,
                                    color: Color.fromRGBO(86, 86, 86, 1),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Editclient()));
                                  },
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Color.fromRGBO(103, 136, 180, 1),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.005),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.isEmpty ? "123 Business Park, Industrial Area" : address,
                                  style: TextStyle(
                                    fontSize: width * 0.039,
                                    color: Color.fromRGBO(161, 166, 175, 1),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                Text(
                                  contactPerson.isEmpty ? "John Anderson" : contactPerson,
                                  style: TextStyle(
                                    fontSize: width * 0.039,
                                    color: Color.fromRGBO(161, 166, 175, 1),
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
                  ),
                ),
                SizedBox(height: height * 0.02),
                Container(
                  child: filteredItems.isEmpty
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
                          itemCount: filteredItems.length,
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
                                          filteredItems[index]['image'],
                                          width: width * 0.2,
                                        ),
                                        SizedBox(width: width * 0.05),
                                        Row(
                                          children: [
                                            Column(
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
                                                      "₹${filteredItems[index]['price']}",
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
                                                                  if (filteredItems[index]['count'] > 0) {
                                                                    filteredItems[index]['count']--;
                                                                    allSelectedItems.firstWhere((item) =>
                                                                        item['name'] == filteredItems[index]['name'])['count']--;
                                                                  }
                                                                  calculateTotals();
                                                                });
                                                              },
                                                              icon: Image.asset(
                                                                "assets/Arous_Sales_ERP_Images/newOrders/minus.png",
                                                                width: width * 0.02,
                                                              ),
                                                            ),
                                                            SizedBox(width: width * 0.0),
                                                            Text(
                                                              "${filteredItems[index]['count']}",
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
                                                                  filteredItems[index]['count']++;
                                                                  allSelectedItems.firstWhere((item) =>
                                                                      item['name'] == filteredItems[index]['name'])['count']++;
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
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: height * 0.01),
                                                Text(
                                                  "Total: ₹${(filteredItems[index]['count'] * filteredItems[index]['price']).toStringAsFixed(2)}",
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
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Addnewproduct(
                                existingProducts: allSelectedItems,
                              ),
                            ),
                          );
                          if (result != null && result is List<Map<String, dynamic>>) {
                            setState(() {
                              // Merge new products with existing ones, updating counts
                              for (var newProduct in result) {
                                var existingProduct = allSelectedItems.firstWhere(
                                  (item) => item['name'] == newProduct['name'],
                                  orElse: () => Map<String, dynamic>.from(newProduct),
                                );
                                if (allSelectedItems.contains(existingProduct)) {
                                  existingProduct['count'] = newProduct['count'];
                                } else {
                                  allSelectedItems.add(newProduct);
                                }
                              }
                              // Remove products with count 0
                              allSelectedItems.removeWhere((item) => item['count'] == 0);
                              filteredItems = List.from(allSelectedItems);
                              calculateTotals();
                            });
                          }
                        },
                        icon: Text(
                          "Add New Product",
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
                            fontSize: width * 0.05,
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
                                  final selectedProducts =
                                      allSelectedItems.where((item) => item['count'] > 0).toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Ordersummery(selectedProducts: selectedProducts)),
                                  );
                                },
                                icon: Text(
                                  "Proceed",
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
                SizedBox(height: height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}