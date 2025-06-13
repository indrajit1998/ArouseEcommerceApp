import 'package:flutter/material.dart';

class Viewvariants extends StatelessWidget {
  final VoidCallback onBack;

  const Viewvariants({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder:(context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(45.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  SizedBox(
                    width: 160,
                    child: TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Color.fromRGBO(26, 76, 142, 1),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(46),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, left: 15, bottom: 10, right: 15),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios, size: 20),
                            Icon(Icons.arrow_back_ios, size: 20),
                            SizedBox(width: 5),
                            Text('Back', style: TextStyle(fontSize: 15, fontFamily: "DMSans", fontWeight: FontWeight.w600, color: Color.fromRGBO(26, 76, 142, 1))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
              
                  Text(
                    "Hyundai i10 NIOS Variants (3)",
                    style: TextStyle(
                      fontSize: 49,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/Web_Images/ViewVariants/variantDetails.png',
                  ),
              
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        )
      ),
    );
  }
}