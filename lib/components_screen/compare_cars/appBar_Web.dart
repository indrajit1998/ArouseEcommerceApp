import 'package:arouse_automotive_day1/HomePage_Automotive.dart';
import 'package:arouse_automotive_day1/components_screen/compare_cars/twoCarsCompare_Web.dart';
import 'package:flutter/material.dart';

class AppbarWeb extends StatefulWidget {
  const AppbarWeb({super.key});

  @override
  State<AppbarWeb> createState() => _AppbarWebState();
}

class _AppbarWebState extends State<AppbarWeb> {

  int isSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWebOrDesktop = screenWidth >= 1024;

    double imageHeight = isWebOrDesktop ? 70 : isTablet ? 30 : screenWidth * 0.075;
    double imageWidth = isWebOrDesktop ? 110 : isTablet ? 80 : screenWidth * 0.075;
    double fontSize = isWebOrDesktop ? 10 : isTablet ? 10 : screenWidth * 0.03 + 4;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        )
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;
              bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
      
              imageHeight = isMobile ? 30 : isTablet ? 40 : 50;
              imageWidth = isMobile ? 30 : isTablet ? 40 : 50;
              fontSize = isMobile ? 12 : isTablet ? 12 : 12;
      
              return Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    toolbarHeight: MediaQuery.of(context).size.width < 600 ? 80 : 100,
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width < 600 ? 20 : 50,
                        ),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/image.png',
                                  height: MediaQuery.of(context).size.width < 600 ? 40 : imageHeight,
                                  width: MediaQuery.of(context).size.width < 600 ? 40 : imageWidth,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'AROUSE',
                                      style: TextStyle(
                                        color: Color(0xFF004C90),
                                        fontSize: MediaQuery.of(context).size.width < 600 ? 12 : fontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                    Text(
                                      'AUTOMOTIVE',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width < 600 ? 12 : fontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.45),
                  
                            // Home Button
                            TextButton(
                              onPressed: () {},
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedIndex = 0;
                                  });
                                },
                                child: Text(
                                  "About Us",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 0 ? Color(0xFF004C90) : Color.fromRGBO(0, 0, 0, 1),
                                  ),
                                ),
                              ),
                            ),
                  
                            // About Us Button
                            TextButton(
                              onPressed: () {},
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedIndex = 1;
                                  });
                                },
                                child: Text(
                                  "New Cars",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 1 ? Color(0xFF004C90) : Color.fromRGBO(0, 0, 0, 1),
                                  ),
                                ),
                              ),
                            ),
                  
                            // Book a Test Drive Button
                            TextButton(
                              onPressed: () {},
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedIndex = 2;
                                  });
                                },
                                child: Text(
                                  "review & News",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 2 ? Color(0xFF004C90) : Color.fromRGBO(0, 0, 0, 1),
                                  ),
                                ),
                              ),
                            ),
                  
                            // Virtual Showroom Button
                            TextButton(
                              onPressed: () {},
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedIndex = 3;
                                  });
                                },
                                child: Text(
                                  "Our Brands",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 3 ? Color(0xFF004C90) : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                  
                            // Contact Us Button
                            Container(
                              width: MediaQuery.of(context).size.width < 600 ? 100 : 140,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  padding: EdgeInsets.symmetric(
                                    vertical: MediaQuery.of(context).size.width < 600 ? 6 : 10,
                                  ),
                                ),
                                child: Text(
                                  "Contact Us",
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12,
                                    fontFamily: "DMSans",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
        body: TwocarscompareWeb(),
      ),
    );
  }
}