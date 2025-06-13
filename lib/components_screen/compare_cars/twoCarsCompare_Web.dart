import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TwocarscompareWeb extends StatefulWidget {
  const TwocarscompareWeb({super.key});

  @override
  State<TwocarscompareWeb> createState() => _TwocarscompareWebState();
}

class _TwocarscompareWebState extends State<TwocarscompareWeb> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  int isSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
     _searchController.dispose();
    super.dispose();
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _allItems = [
    'Engine',
    'Engine Type',
    'Fuel Type',
    'Max Power (bhp@rpm)',
    'Red Color',
    'Blue Color',
    'Automatic Transmission',
    'Leather Seats',
  ];
  List<String> _filteredItems = [];

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredItems = _allItems.where((item) => item.toLowerCase().contains(_searchQuery)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWebOrDesktop = screenWidth >= 1024;

    double imageHeight = isWebOrDesktop ? 70 : isTablet ? 30 : screenWidth * 0.075;
    double imageWidth = isWebOrDesktop ? 110 : isTablet ? 80 : screenWidth * 0.075;
    double fontSize = isWebOrDesktop ? 10 : isTablet ? 10 : screenWidth * 0.03 + 4;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
                    automaticallyImplyLeading: false,
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

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mercedes Benz vs Dezire Automatic",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(64, 64, 64, 1),
                              fontFamily: "DMSans",
                            ),
                          ),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              
                              GestureDetector(
                                onTap: () {
                                  // Handle share action here
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.share,
                                      color: Color.fromRGBO(26, 76, 142, 1),
                                      size: 23,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Share",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02), 
                  
                              GestureDetector(
                                onTap: () {
                                  // Handle save action here
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bookmark,
                                      color: Color.fromRGBO(26, 76, 142, 1),
                                      size: 23,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Save",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                  
                      Text(
                        """Mercedes-Benz car price starts at Rs 54.73 Lakh for the cheapest model which is A-Class Limousine and the price of most expensive model, which is AMG G-Class starts at Rs 4.26 Crore. Mercedes-Benz offers 32 car models in India, including 14 cars in SUV category, 12 cars in Sedan category, 1 car in Coupe category.""",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(57, 57, 57, 1),
                          fontFamily: "DMSans",
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04,),

                Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildCarCard(),
                      SizedBox(width: screenWidth * 0.01,),
                      Image.asset(
                        "assets/Home_Images/Compare_Cars/vs.png", 
                        height: 25
                      ),
                      SizedBox(width: screenWidth * 0.01,),
                      buildCarCard(),
                      SizedBox(width: screenWidth * 0.01,),
                      Image.asset(
                        "assets/Home_Images/Compare_Cars/vs.png", 
                        height: 25
                      ),
                      SizedBox(width: screenWidth * 0.01,),
                      addCarCard(),
                      SizedBox(width: screenWidth * 0.01,),
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                
                Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TabBar(
                            isScrollable: true,
                            labelColor: Color.fromRGBO(26, 76, 142, 1),
                            unselectedLabelColor: Color.fromRGBO(104, 104, 104, 1),
                            indicatorColor: Color.fromRGBO(26, 76, 142, 1),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                            labelPadding: EdgeInsets.symmetric(horizontal: 20),
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                width: 3,
                                color: Color.fromRGBO(26, 76, 142, 1),
                              ),
                              insets: EdgeInsets.only(
                                left: 10,
                                right: 15,
                              ),
                            ),
                            tabs: [
                              Tab(text: 'Specifications'),
                              Tab(text: 'Features'),
                              Tab(text: 'Brochure'),
                              Tab(text: 'Colours'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.25,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Features, Colors etc.',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(31, 56, 76, 1),
                                fontFamily: "DMSans",
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(233, 233, 233, 1),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 5),
                              prefixIcon: Icon(Icons.search, color: Color.fromRGBO(26, 76, 142, 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 30.0, bottom: 10.0),
                      child: SizedBox(
                        height: screenHeight * 1,
                        child: TabBarView(
                          children: [
                            SpecificationsTab(),
                            FeaturesTab(),
                            BrochureTab(),
                            ColorsTab(),
                          ]
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(5, 11, 32, 1),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:100, right: 100, top: 80, bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "AROUSE",
                                            style: TextStyle(
                                              fontFamily: "DMSans",
                                              fontSize: MediaQuery.of(context).size.width > 600 ? 30 : 23.4,
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromRGBO(26, 76, 142, 1),
                                            ),
                                          ),
                                          TextSpan(
                                            text: " AUTOMOTIVE",
                                            style: TextStyle(
                                              fontFamily: "DMSans",
                                              fontSize: MediaQuery.of(context).size.width > 600 ? 30 : 23.4,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Receive pricing updates, shopping tips & more!",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                                                   
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.13),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20, right: 10),
                                      child: TextField(
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: "Your email address",
                                          hintStyle: TextStyle(color: Colors.grey, fontFamily: "DMSans", fontSize: 15),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E65B6),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          "Sign Up",
                                          style: TextStyle(fontFamily: "DMSans",color: Colors.white, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ),
                                                         
                               ],
                              ),
                            ),
                                      
                          ]
                        )
                      ),
                                         
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                      Divider(
                        thickness: 2,
                        color: Color.fromRGBO(255, 255, 255, 0.13),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                                  
                                                
                      Padding(
                        padding: const EdgeInsets.only(left: 100, right: 50, top: 20, bottom: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 6,
                            mainAxisSpacing: 2.0,
                            crossAxisSpacing: 2.0,
                          ),
                          itemCount: 45,
                          itemBuilder: (context, index) {
                          List<List<dynamic>> data = [
                            ['Company', 'Quick Links', 'Our Brands', 'Vehicles Type', 'Connect With Us'],
                            ['About Us', 'Get in Touch', 'Toyota', 'Sedan', buildIcons()],
                            ['Blog', 'Help Center', 'Porsche', 'Hatchback', ''],
                            ['Services', 'Live Chat', 'Audi', 'SUV', ''],
                            ['FAQs', 'How it works', 'BMW', 'Hybrid', ''],
                            ['Terms', '', 'Ford', 'Electric', ''],
                            ['Contact Us', '', 'Nissan', 'Coupe', ''],
                            ['', '', 'Peugeot', 'Truck', ''],
                            ['', '', 'Volkswagen', 'Convertible', ''],
                          ];
                          int rowIndex = index ~/ 5;
                          int colIndex = index % 5;
                          var cellData = data[rowIndex][colIndex];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: cellData is Widget
                            ? cellData
                            : Text(
                              cellData.toString(),
                              style: TextStyle(
                                fontFamily: "DMSans",
                                fontWeight: rowIndex == 0 ? FontWeight.w500 : FontWeight.w400,
                                fontSize: rowIndex == 0 ? 20 : 15,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                    Divider(
                      thickness: 2,
                      color: Color.fromRGBO(255, 255, 255, 0.13),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04,),

                    Padding(
                      padding: const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("© 2024 exemple.com. All rights reserved.",
                          style: TextStyle(
                            fontFamily: "DMSans", 
                            fontWeight: FontWeight.w400, 
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Terms & Conditions . Privacy Notice",
                            style: TextStyle(
                              fontFamily: "DMSans",
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.04,),
                            CircleAvatar(
                              backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                              radius: 20,
                              child: IconButton(
                                icon: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                                onPressed: () {
                                  Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
                ],
                ),
               ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget SpecificationsTab(){
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(210.0),
              1: FixedColumnWidth(280.0),
              2: FixedColumnWidth(280.0),
            },
            children: [
              
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Fuel Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Power (bhp@rpm)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Torque (Nm@rpm)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Mileage (ARAI) (kmpl)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Driving Range (km)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget FeaturesTab(){
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(210.0),
              1: FixedColumnWidth(280.0),
              2: FixedColumnWidth(280.0),
            },
            children: [
              
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Fuel Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Power (bhp@rpm)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Torque (Nm@rpm)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Mileage (ARAI) (kmpl)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Driving Range (km)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget BrochureTab(){
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(210.0),
              1: FixedColumnWidth(280.0),
              2: FixedColumnWidth(280.0),
            },
            children: [
              
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Fuel Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Power (bhp@rpm)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Torque (Nm@rpm)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Mileage (ARAI) (kmpl)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Driving Range (km)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget ColorsTab(){
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(210.0),
              1: FixedColumnWidth(280.0),
              2: FixedColumnWidth(280.0),
            },
            children: [
              
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Engine Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Z12E'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Fuel Type', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('Petrol'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Power (bhp@rpm)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('80 bhp @ 5700 rpm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Max Torque (Nm@rpm)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('111.7 Nm'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Mileage (ARAI) (kmpl)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '24.79', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \nView Mileage Details',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Driving Range (km)', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              fontFamily: "DMSans"
                            ),
                          ),
                          
                          TextSpan(
                            text: ' \n(Know More)',
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('917'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCarCard() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2,color: Color.fromRGBO(233, 233, 233, 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    "assets/Home_Images/Compare_Cars/Ford_transit1.jpeg",
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/Home_Images/Compare_Cars/close.png",
                          color: Colors.grey,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),


              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ford Transit – 2021",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(5, 11, 32, 1),
                        fontWeight: FontWeight.w500,
                        fontFamily: "DMSans",
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "4.0 D5 PowerPulse Momentum 5dr AW…",
                            style: TextStyle(
                              color: Color.fromRGBO(5, 11, 32, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          children: [
                            Image.asset("assets/diesel.webp",
                                height: 11.62, color: Colors.black, fit: BoxFit.contain),
                            Text("Diesel", style: TextStyle(fontSize: 10, fontFamily: "DMSans")),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Image.asset("assets/manuel.png", height: 11.62, fit: BoxFit.contain),
                            Text("Manual", style: TextStyle(fontSize: 10, fontFamily: "DMSans")),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Rs. 3.07 Crore",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                            ),
                          ),
                          TextSpan(
                            text: " onwards",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                            ),
                          ),
                          TextSpan(
                            text: " \nOn-Road Price, Mumbai",
                            style: TextStyle(
                              color: Color.fromRGBO(157, 157, 157, 1),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    Row(
                      children: [
                        Text(
                          "Book a test Drive",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color.fromRGBO(26, 76, 142, 1),
                            fontWeight: FontWeight.w500,
                            fontFamily: "DMSans",
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                        Icon(Icons.arrow_outward, size: 15, color: Color.fromRGBO(26, 76, 142, 1),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        
      ],
    );
  }

  Widget addCarCard(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(width: 2,color: Color.fromRGBO(233, 233, 233, 1)),
      ),
      child: GestureDetector(
        onTap: () {
          // Handle add car action here
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(width: 1,color: Color.fromRGBO(26, 76, 142, 1)),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Color.fromRGBO(235, 239, 255, 1),
                child: Icon(
                  Icons.add,
                  color: Color.fromRGBO(26, 76, 142, 1),
                  size: 30,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Add Another Car',
              style: TextStyle(
                color: Color.fromRGBO(26, 76, 142, 1),
                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIcons(){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: (){}, 
                          icon: const FaIcon(
                            FontAwesomeIcons.facebook,
                            color: Colors.white,
                            size: 20,
                          )
                        ),
                        IconButton(
                          onPressed: (){}, 
                          icon: const FaIcon(
                            FontAwesomeIcons.twitter,
                            color: Colors.white,
                            size: 20,
                          )
                        ),
                        IconButton(
                          onPressed: (){}, 
                          icon: const FaIcon(
                            FontAwesomeIcons.instagram,
                            color: Colors.white,
                            size: 20,
                          )
                        ),
                        IconButton(
                          onPressed: (){}, 
                          icon: const FaIcon(
                            FontAwesomeIcons.linkedin,
                            color: Colors.white,
                            size: 20,
                          )
                        ),
                      ],
                    );
                  }
}