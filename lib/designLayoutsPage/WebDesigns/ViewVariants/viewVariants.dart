import 'package:flutter/material.dart';

class Viewvariants extends StatelessWidget {
  final VoidCallback onBack;

  const Viewvariants({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            // Responsive padding
            double horizontalPadding = screenWidth < 600
                ? 12 // Mobile
                : screenWidth < 1024
                    ? 24 // Tablet
                    : 45; // Desktop

            // Responsive title font size
            double titleFontSize = screenWidth < 600
                ? 22 // Mobile
                : screenWidth < 1024
                    ? 32 // Tablet
                    : 49; // Desktop

            // Responsive image width
            double imageWidth = screenWidth < 600
                ? screenWidth * 1
                : screenWidth < 1024
                    ? screenWidth * 0.7
                    : screenWidth * 0.8;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
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
                        padding: EdgeInsets.only(
                          top: screenWidth < 600 ? 6 : 10,
                          left: screenWidth < 600 ? 8 : 15,
                          bottom: screenWidth < 600 ? 6 : 10,
                          right: screenWidth < 600 ? 8 : 15,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: screenWidth < 600
                                  ? 16 // Mobile
                                  : screenWidth < 1024
                                      ? 18 // Tablet
                                      : 20, // Desktop
                            ),
                            Icon(
                              Icons.arrow_back_ios,
                              size: screenWidth < 600
                                  ? 16
                                  : screenWidth < 1024
                                      ? 18
                                      : 20,
                            ),
                            SizedBox(width: screenWidth < 600 ? 3 : 5),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: screenWidth < 600
                                    ? 13 // Mobile
                                    : screenWidth < 1024
                                        ? 14 // Tablet
                                        : 15, // Desktop
                                fontFamily: "DMSans",
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(26, 76, 142, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Hyundai i10 NIOS Variants (3)",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/Web_Images/ViewVariants/variantDetails.png',
                    width: imageWidth,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}