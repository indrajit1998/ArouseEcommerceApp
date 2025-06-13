import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Vieworderdetails extends StatefulWidget {
  final Map<String, dynamic> order;
  const Vieworderdetails({super.key, required this.order});

  @override
  State<Vieworderdetails> createState() => _VieworderdetailsState();
}

class _VieworderdetailsState extends State<Vieworderdetails> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final order = widget.order;
    final items = (order['orderedItems'] as List<dynamic>?) ?? [];
    final vendorName = order['vendorName']?.toString() ?? 'Unknown Customer';
    final address = order['address']?.toString() ?? 'N/A';
    final contactPerson = order['contactPerson']?.toString() ?? 'N/A';

    // Calculate subtotal from items
    double subtotal = 0.0;
    for (var item in items) {
      final itemPrice = item['price']?.toDouble() ?? 0.0;
      final quantity = item['count']?.toInt() ?? 1;
      subtotal += itemPrice * quantity;
    }

    // Calculate tax (10% of subtotal)
    final tax = subtotal * 0.10;

    // Use stored delivery fee or default to 25.0
    final deliveryFee = order['deliveryFee']?.toDouble() ?? 25.0;

    // Calculate grand total
    final grandTotal = subtotal + tax + deliveryFee;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 249, 250, 1),
      appBar: AppBar(
        title: Text(
          'View Order Details',
          style: TextStyle(
            fontSize: width * 0.05,
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            color: const Color.fromRGBO(73, 73, 73, 1),
          ),
        ),
        centerTitle: true,
        elevation: 0.1,
        shadowColor: const Color.fromRGBO(228, 229, 232, 1),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor Details
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage(
                              "assets/Arous_Sales_ERP_Images/newOrders/blankImage.png"),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          width: 2,
                          color: const Color.fromRGBO(228, 229, 232, 1),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendorName,
                              style: TextStyle(
                                fontSize: width * 0.042,
                                color: const Color.fromRGBO(86, 86, 86, 1),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              address,
                              style: TextStyle(
                                fontSize: width * 0.039,
                                color: const Color.fromRGBO(161, 166, 175, 1),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              "Contact: $contactPerson",
                              style: TextStyle(
                                fontSize: width * 0.039,
                                color: const Color.fromRGBO(161, 166, 175, 1),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),

                    // Ordered Items
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          "No items in this order",
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: const Color.fromRGBO(165, 169, 178, 1),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    else
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final itemName = item['name']?.toString() ?? 'Unknown Item';
                        final itemPrice = item['price']?.toDouble() ?? 0.0;
                        final quantity = item['count']?.toInt() ?? 1;
                        final subtotalItem = itemPrice * quantity;
                        final imagePath = item['image']?.toString() ??
                            'assets/Arous_Sales_ERP_Images/ViewOrderDetails/default.png';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                    "assets/Arous_Sales_ERP_Images/newOrders/blankImage1.png"),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                width: 1,
                                color: const Color.fromRGBO(228, 229, 232, 1),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 30.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        imagePath,
                                        width: width * 0.2,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Image.asset(
                                          'assets/Arous_Sales_ERP_Images/ViewOrderDetails/default.png',
                                          width: width * 0.2,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.05),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemName,
                                              style: TextStyle(
                                                fontSize: width * 0.038,
                                                color: const Color.fromRGBO(118, 118, 118, 1),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Inter",
                                              ),
                                            ),
                                            SizedBox(height: height * 0.006),
                                            Text(
                                              "₹${itemPrice.toStringAsFixed(2)} per unit",
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: const Color.fromRGBO(144, 150, 159, 1),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Inter",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              "qty ",
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: const Color.fromRGBO(144, 150, 159, 1),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Inter",
                                              ),
                                            ),
                                            Text(
                                              "$quantity",
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: const Color.fromRGBO(122, 122, 122, 1),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Inter",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Subtotal: ₹${subtotalItem.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: width * 0.036,
                                        color: const Color.fromRGBO(141, 147, 156, 1),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                    // Underline after last item
                    if (items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Image.asset(
                          "assets/Arous_Sales_ERP_Images/ViewOrderDetails/underline.png",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    // Order Summary
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Summary",
                              style: TextStyle(
                                fontSize: width * 0.05,
                                fontFamily: "Inter",
                                color: const Color.fromRGBO(84, 84, 84, 1),
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
                                    color: const Color.fromRGBO(141, 147, 156, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${subtotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: const Color.fromRGBO(86, 86, 86, 1),
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
                                    color: const Color.fromRGBO(141, 147, 156, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${tax.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: const Color.fromRGBO(86, 86, 86, 1),
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
                                    color: const Color.fromRGBO(141, 147, 156, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${deliveryFee.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: const Color.fromRGBO(86, 86, 86, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            const Divider(
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
                                    color: const Color.fromRGBO(87, 87, 87, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "₹${grandTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: width * 0.044,
                                    fontFamily: "Inter",
                                    color: const Color.fromRGBO(86, 86, 86, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
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