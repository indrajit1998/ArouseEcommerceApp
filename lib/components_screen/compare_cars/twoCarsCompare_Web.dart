import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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

  // Helper for header buttons (add this method in your State class)
Widget _buildHeaderButton(String title, int index) {
  return TextButton(
    onPressed: () {},
    child: GestureDetector(
      onTap: () {
        setState(() {
          isSelectedIndex = index;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "DMSans",
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isSelectedIndex == index ? Color(0xFF004C90) : Colors.black,
        ),
      ),
    ),
  );
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
              bool isWeb = constraints.maxWidth >= 1024;

              imageHeight = isMobile ? 30 : isTablet ? 40 : 70;
              imageWidth = isMobile ? 30 : isTablet ? 40 : 70;
              fontSize = isMobile ? 15 : isTablet ? 12 : 12;

              if (isMobile || isTablet) {
                // Mobile/Tablet: Use AppBar with Drawer and center title/logo
                return AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  elevation: 5,
                  toolbarHeight: 90,
                  centerTitle: true,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFF004C90)),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/image.png',
                        height: imageHeight,
                        width: imageWidth,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AROUSE ',
                        style: TextStyle(
                          color: Color(0xFF004C90),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: "DMSans",
                        ),
                      ),
                      Text(
                        'AUTOMOTIVE',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: "DMSans",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Web/Desktop: Show full header
                return AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  elevation: 5,
                  toolbarHeight: 100,
                  titleSpacing: 0,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/image.png',
                              height: imageHeight,
                              width: imageWidth,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'AROUSE',
                                  style: TextStyle(
                                    color: Color(0xFF004C90),
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                                Text(
                                  'AUTOMOTIVE',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.45),
                        // All header buttons
                        ...[
                          _buildHeaderButton("About Us", 0),
                          _buildHeaderButton("New Cars", 1),
                          _buildHeaderButton("review & News", 2),
                          _buildHeaderButton("Our Brands", 3),
                          SizedBox(width: 15),
                          Container(
                            width: 140,
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
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                "Contact Us",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "DMSans",
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
        drawer: (MediaQuery.of(context).size.width < 1024)
            ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image.png',
                            height: 40,
                            width: 40,
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
                    ),
                    ListTile(
                      title: Text("About Us", style: TextStyle(fontFamily: "DMSans")),
                      onTap: () {
                        setState(() { isSelectedIndex = 0; });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("New Cars", style: TextStyle(fontFamily: "DMSans")),
                      onTap: () {
                        setState(() { isSelectedIndex = 1; });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("review & News", style: TextStyle(fontFamily: "DMSans")),
                      onTap: () {
                        setState(() { isSelectedIndex = 2; });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("Our Brands", style: TextStyle(fontFamily: "DMSans")),
                      onTap: () {
                        setState(() { isSelectedIndex = 3; });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("Contact Us", style: TextStyle(fontFamily: "DMSans")),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              )
            : null,

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Responsive padding
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth < 600 ? 16 : screenWidth < 1024 ? 40 : 100,
                    right: screenWidth < 600 ? 16 : screenWidth < 1024 ? 40 : 100,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive title and actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Mercedes Benz vs Dezire Automatic",
                              style: TextStyle(
                                fontSize: screenWidth < 600 ? 20 : screenWidth < 1024 ? 28 : 36,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(64, 64, 64, 1),
                                fontFamily: "DMSans",
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (screenWidth >= 400)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.share,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        size: screenWidth < 600 ? 18 : 23,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Share",
                                        style: TextStyle(
                                          fontSize: screenWidth < 600 ? 11 : 15,
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
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bookmark,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        size: screenWidth < 600 ? 18 : 23,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Save",
                                        style: TextStyle(
                                          fontSize: screenWidth < 600 ? 11 : 15,
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
                      SizedBox(height: 12),
                      Text(
                        "Mercedes-Benz car price starts at Rs 54.73 Lakh for the cheapest model which is A-Class Limousine and the price of most expensive model, which is AMG G-Class starts at Rs 4.26 Crore. Mercedes-Benz offers 32 car models in India, including 14 cars in SUV category, 12 cars in Sedan category, 1 car in Coupe category.",
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 13 : screenWidth < 1024 ? 15 : 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(57, 57, 57, 1),
                          fontFamily: "DMSans",
                        ),
                        maxLines: screenWidth < 600 ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Responsive car compare row
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth < 600 ? 8 : screenWidth < 1024 ? 24 : 100,
                    right: screenWidth < 600 ? 8 : screenWidth < 1024 ? 24 : 100,
                    top: 10,
                    bottom: 10,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int carCount = 2;
                      if (screenWidth >= 1024) {
                        carCount = 4;
                      } else if (screenWidth >= 600) {
                        carCount = 3;
                      }
                      List<Widget> carWidgets = [];
                      for (int i = 0; i < carCount; i++) {
                        carWidgets.add(buildCarCard());
                        if (i < carCount - 1) {
                          carWidgets.add(SizedBox(width: screenWidth * 0.01));
                          carWidgets.add(Image.asset(
                            "assets/Home_Images/Compare_Cars/vs.png",
                            height: screenWidth < 600 ? 18 : 25,
                          ));
                          carWidgets.add(SizedBox(width: screenWidth * 0.01));
                        }
                      }
                      // Add the "Add Another Car" card if not at max
                      if (carCount < 4) {
                        carWidgets.add(addCarCard());
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: carWidgets,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenWidth < 600 ? 16 : 30),

                // Responsive TabBar and Search
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth < 600 ? 8 : screenWidth < 1024 ? 24 : 100,
                    right: screenWidth < 600 ? 8 : screenWidth < 1024 ? 24 : 100,
                    top: 10,
                    bottom: 10,
                  ),
                  child: screenWidth < 600
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              isScrollable: true,
                              labelColor: Color.fromRGBO(26, 76, 142, 1),
                              unselectedLabelColor: Color.fromRGBO(104, 104, 104, 1),
                              indicatorColor: Color.fromRGBO(26, 76, 142, 1),
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                              ),
                              labelPadding: EdgeInsets.symmetric(horizontal: 10),
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                ),
                                insets: EdgeInsets.only(left: 5, right: 8),
                              ),
                              tabs: [
                                Tab(text: 'Specifications'),
                                Tab(text: 'Features'),
                                Tab(text: 'Brochure'),
                                Tab(text: 'Colours'),
                              ],
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search Features, Colors etc.',
                                  hintStyle: TextStyle(
                                    fontSize: 11,
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
                                  prefixIcon: Icon(Icons.search, color: Color.fromRGBO(26, 76, 142, 1), size: 18),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TabBar(
                                isScrollable: true,
                                labelColor: Color.fromRGBO(26, 76, 142, 1),
                                unselectedLabelColor: Color.fromRGBO(104, 104, 104, 1),
                                indicatorColor: Color.fromRGBO(26, 76, 142, 1),
                                labelStyle: TextStyle(
                                  fontSize: screenWidth < 1024 ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                ),
                                labelPadding: EdgeInsets.symmetric(horizontal: 20),
                                indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                  ),
                                  insets: EdgeInsets.only(left: 10, right: 15),
                                ),
                                tabs: [
                                  Tab(text: 'Specifications'),
                                  Tab(text: 'Features'),
                                  Tab(text: 'Brochure'),
                                  Tab(text: 'Colours'),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            SizedBox(
                              height: screenHeight * 0.05,
                              width: screenWidth < 1024 ? screenWidth * 0.35 : screenWidth * 0.25,
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

                // TabBarView and rest of the content remain unchanged
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth < 600 ? 0 : screenWidth < 1024 ? 16 : 100,
                    right: screenWidth < 600 ? 0 : screenWidth < 1024 ? 16 : 100,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 20.0, bottom: 10.0),
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
                SizedBox(height: 10),
                buildResponsiveFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildResponsiveFooter(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Responsive values
  bool isMobile = screenWidth < 600;
  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
  bool isWeb = screenWidth >= 1024;

  double horizontalPadding = isWeb
      ? 100
      : isTablet
          ? 40
          : 16;
  double sectionSpacing = isWeb
      ? 32
      : isTablet
          ? 24
          : 16;
  double headingFont = isWeb
      ? 30
      : isTablet
          ? 24
          : 18;
  double cellFont = isWeb
      ? 20
      : isTablet
          ? 16
          : 13;
  double normalFont = isWeb
      ? 15
      : isTablet
          ? 13
          : 11;

  // Data columns
  final List<List<dynamic>> data = [
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

  // Helper to build a column
  Widget buildFooterColumn(String heading, List<String> cells, {Widget? lastWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontFamily: "DMSans",
            fontWeight: FontWeight.w500,
            fontSize: cellFont,
            color: Colors.white,
          ),
        ),
        ...cells.map((cell) => cell.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  cell,
                  style: TextStyle(
                    fontFamily: "DMSans",
                    fontWeight: FontWeight.w400,
                    fontSize: normalFont,
                    color: Colors.white,
                  ),
                ),
              )
            : SizedBox.shrink()),
        if (lastWidget != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: lastWidget),
      ],
    );
  }

  // Extract columns
  List<String> companyCol = List.generate(data.length - 1, (i) => data[i + 1][0]);
  List<String> quickLinksCol = List.generate(data.length - 1, (i) => data[i + 1][1]);
  List<String> brandsCol = List.generate(data.length - 1, (i) => data[i + 1][2]);
  List<String> vehiclesCol = List.generate(data.length - 1, (i) => data[i + 1][3]);
  List<String> connectCol = List.generate(data.length - 1, (i) => data[i + 1][4]).where((e) => e is String && e.isNotEmpty).cast<String>().toList();

  return Container(
    decoration: const BoxDecoration(
      color: Color.fromRGBO(5, 11, 32, 1),
    ),
    child: Column(
      children: [
        Padding(
  padding: EdgeInsets.symmetric(
    horizontal: horizontalPadding,
    vertical: isWeb ? 80 : isTablet ? 40 : 24,
  ).copyWith(bottom: isWeb ? 30 : isTablet ? 20 : 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Logo, tagline, and email field (always at the top)
      isMobile || isTablet
          ? Column(
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
                              fontSize: headingFont,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(26, 76, 142, 1),
                            ),
                          ),
                          TextSpan(
                            text: " AUTOMOTIVE",
                            style: TextStyle(
                              fontFamily: "DMSans",
                              fontSize: headingFont,
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
                const SizedBox(height: 16),
                // Email field
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.13),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Your email address",
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "DMSans",
                                  fontSize: 15),
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
                              style: TextStyle(
                                  fontFamily: "DMSans",
                                  color: Colors.white,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo and text
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
                                  fontSize: headingFont,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                ),
                              ),
                              TextSpan(
                                text: " AUTOMOTIVE",
                                style: TextStyle(
                                  fontFamily: "DMSans",
                                  fontSize: headingFont,
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
                // Email field
                Container(
                  width: screenWidth * (isTablet ? 0.4 : 0.25),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.13),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Your email address",
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "DMSans",
                                  fontSize: 15),
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
                              style: TextStyle(
                                  fontFamily: "DMSans",
                                  color: Colors.white,
                                  fontSize: 13),
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
        ),
      ),
        SizedBox(height: sectionSpacing / 2),
        const Divider(
          thickness: 2,
          color: Color.fromRGBO(255, 255, 255, 0.13),
        ),
        SizedBox(height: sectionSpacing / 2),

        // Company & Quick Links (side by side for mobile/tablet)
        if (isMobile || isTablet)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildFooterColumn(data[0][0], companyCol)),
                SizedBox(width: sectionSpacing),
                Expanded(child: buildFooterColumn(data[0][1], quickLinksCol)),
              ],
            ),
          ),

        // Our Brands & Vehicles Type (side by side for mobile/tablet)
        if (isMobile || isTablet)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: sectionSpacing,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildFooterColumn(data[0][2], brandsCol)),
                SizedBox(width: sectionSpacing),
                Expanded(child: buildFooterColumn(data[0][3], vehiclesCol)),
              ],
            ),
          ),

        // Connect With Us (full width)
        if (isMobile || isTablet)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: sectionSpacing,
            ),
            child: buildFooterColumn(data[0][4], connectCol, lastWidget: buildIcons()),
          ),

        // For web/desktop, keep your original layout
        if (isWeb) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildFooterColumn(data[0][0], companyCol)),
                SizedBox(width: sectionSpacing),
                Expanded(child: buildFooterColumn(data[0][1], quickLinksCol)),
                SizedBox(width: sectionSpacing),
                Expanded(child: buildFooterColumn(data[0][2], brandsCol)),
                SizedBox(width: sectionSpacing),
                Expanded(child: buildFooterColumn(data[0][3], vehiclesCol)),
                SizedBox(width: sectionSpacing),
                Expanded(child: buildFooterColumn(data[0][4], connectCol, lastWidget: buildIcons())),
              ],
            ),
          ),
        ],

        SizedBox(height: sectionSpacing),
        const Divider(
          thickness: 2,
          color: Color.fromRGBO(255, 255, 255, 0.13),
        ),
        SizedBox(height: sectionSpacing / 2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isWeb ? 20 : isTablet ? 16 : 10),
          child: isMobile || isTablet
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "© 2024 exemple.com. All rights reserved.",
                      style: TextStyle(
                        fontFamily: "DMSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: normalFont,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Terms & Conditions . Privacy Notice",
                      style: TextStyle(
                        fontFamily: "DMSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: normalFont,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "© 2024 exemple.com. All rights reserved.",
                      style: TextStyle(
                        fontFamily: "DMSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: normalFont,
                      ),
                    ),
                    Text(
                      "Terms & Conditions . Privacy Notice",
                      style: TextStyle(
                        fontFamily: "DMSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: normalFont,
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(height: sectionSpacing / 2),
      ],
    ),
  );
}


  Widget SpecificationsTab() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Example data (replace with your actual data)
  final List<Map<String, dynamic>> specs = [
    {
      'label': 'Engine',
      'value1': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'value2': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'more': '(Know More)'
    },
    {
      'label': 'Engine Type',
      'value1': 'Z12E',
      'value2': 'Z12E',
      'more': '(Know More)'
    },
    {
      'label': 'Fuel Type',
      'value1': 'Petrol',
      'value2': 'Petrol',
      'more': '(Know More)'
    },
    {
      'label': 'Max Power (bhp@rpm)',
      'value1': '80 bhp @ 5700 rpm',
      'value2': '80 bhp @ 5700 rpm',
      'more': '(Know More)'
    },
    {
      'label': 'Max Torque (Nm@rpm)',
      'value1': '111.7 Nm',
      'value2': '111.7 Nm',
      'more': '(Know More)'
    },
    {
      'label': 'Mileage (ARAI) (kmpl)',
      'value1': '24.79\nView Mileage Details',
      'value2': '24.79\nView Mileage Details',
      'more': ''
    },
    {
      'label': 'Driving Range (km)',
      'value1': '917',
      'value2': '917',
      'more': '(Know More)'
    },
  ];

  if (screenWidth < 600) {
    // MOBILE: Show as vertical list
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          ...specs.map((spec) => Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: spec['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: "DMSans",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            if (spec['more'] != null && spec['more'] != '')
                              TextSpan(
                                text: '  ${spec['more']}',
                                style: TextStyle(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              spec['value1'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              spec['value2'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  } else if (screenWidth < 1024) {
    // TABLET: Show as 3-column table but with smaller padding/font
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(120.0),
              1: FixedColumnWidth(150.0),
              2: FixedColumnWidth(150.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  } else {
    // WEB: Original 3-column table
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.05),
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
          SizedBox(height: screenHeight * 0.02),
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
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
  
  Widget FeaturesTab() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Example data (replace with your actual data)
  final List<Map<String, dynamic>> specs = [
    {
      'label': 'Engine',
      'value1': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'value2': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'more': '(Know More)'
    },
    {
      'label': 'Engine Type',
      'value1': 'Z12E',
      'value2': 'Z12E',
      'more': '(Know More)'
    },
    {
      'label': 'Fuel Type',
      'value1': 'Petrol',
      'value2': 'Petrol',
      'more': '(Know More)'
    },
    {
      'label': 'Max Power (bhp@rpm)',
      'value1': '80 bhp @ 5700 rpm',
      'value2': '80 bhp @ 5700 rpm',
      'more': '(Know More)'
    },
    {
      'label': 'Max Torque (Nm@rpm)',
      'value1': '111.7 Nm',
      'value2': '111.7 Nm',
      'more': '(Know More)'
    },
    {
      'label': 'Mileage (ARAI) (kmpl)',
      'value1': '24.79\nView Mileage Details',
      'value2': '24.79\nView Mileage Details',
      'more': ''
    },
    {
      'label': 'Driving Range (km)',
      'value1': '917',
      'value2': '917',
      'more': '(Know More)'
    },
  ];

  if (screenWidth < 600) {
    // MOBILE: Show as vertical list
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          ...specs.map((spec) => Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: spec['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: "DMSans",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            if (spec['more'] != null && spec['more'] != '')
                              TextSpan(
                                text: '  ${spec['more']}',
                                style: TextStyle(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              spec['value1'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              spec['value2'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  } else if (screenWidth < 1024) {
    // TABLET: Show as 3-column table but with smaller padding/font
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(120.0),
              1: FixedColumnWidth(150.0),
              2: FixedColumnWidth(150.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  } else {
    // WEB: Original 3-column table
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.05),
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
          SizedBox(height: screenHeight * 0.02),
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
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
  
  Widget BrochureTab() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Example data (replace with your actual data)
  final List<Map<String, dynamic>> specs = [
    {
      'label': 'Engine',
      'value1': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'value2': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'more': '(Know More)'
    },
    {
      'label': 'Engine Type',
      'value1': 'Z12E',
      'value2': 'Z12E',
      'more': '(Know More)'
    },
    {
      'label': 'Fuel Type',
      'value1': 'Petrol',
      'value2': 'Petrol',
      'more': '(Know More)'
    },
    {
      'label': 'Max Power (bhp@rpm)',
      'value1': '80 bhp @ 5700 rpm',
      'value2': '80 bhp @ 5700 rpm',
      'more': '(Know More)'
    },
    {
      'label': 'Max Torque (Nm@rpm)',
      'value1': '111.7 Nm',
      'value2': '111.7 Nm',
      'more': '(Know More)'
    },
    {
      'label': 'Mileage (ARAI) (kmpl)',
      'value1': '24.79\nView Mileage Details',
      'value2': '24.79\nView Mileage Details',
      'more': ''
    },
    {
      'label': 'Driving Range (km)',
      'value1': '917',
      'value2': '917',
      'more': '(Know More)'
    },
  ];

  if (screenWidth < 600) {
    // MOBILE: Show as vertical list
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          ...specs.map((spec) => Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: spec['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: "DMSans",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            if (spec['more'] != null && spec['more'] != '')
                              TextSpan(
                                text: '  ${spec['more']}',
                                style: TextStyle(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              spec['value1'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              spec['value2'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  } else if (screenWidth < 1024) {
    // TABLET: Show as 3-column table but with smaller padding/font
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(120.0),
              1: FixedColumnWidth(150.0),
              2: FixedColumnWidth(150.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  } else {
    // WEB: Original 3-column table
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.05),
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
          SizedBox(height: screenHeight * 0.02),
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
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

  Widget ColorsTab() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Example data (replace with your actual data)
  final List<Map<String, dynamic>> specs = [
    {
      'label': 'Engine',
      'value1': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'value2': '1197 cc, 3 Cylinders Inline, 4\nValves/Cylinder, DOHC',
      'more': '(Know More)'
    },
    {
      'label': 'Engine Type',
      'value1': 'Z12E',
      'value2': 'Z12E',
      'more': '(Know More)'
    },
    {
      'label': 'Fuel Type',
      'value1': 'Petrol',
      'value2': 'Petrol',
      'more': '(Know More)'
    },
    {
      'label': 'Max Power (bhp@rpm)',
      'value1': '80 bhp @ 5700 rpm',
      'value2': '80 bhp @ 5700 rpm',
      'more': '(Know More)'
    },
    {
      'label': 'Max Torque (Nm@rpm)',
      'value1': '111.7 Nm',
      'value2': '111.7 Nm',
      'more': '(Know More)'
    },
    {
      'label': 'Mileage (ARAI) (kmpl)',
      'value1': '24.79\nView Mileage Details',
      'value2': '24.79\nView Mileage Details',
      'more': ''
    },
    {
      'label': 'Driving Range (km)',
      'value1': '917',
      'value2': '917',
      'more': '(Know More)'
    },
  ];

  if (screenWidth < 600) {
    // MOBILE: Show as vertical list
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          ...specs.map((spec) => Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: spec['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: "DMSans",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            if (spec['more'] != null && spec['more'] != '')
                              TextSpan(
                                text: '  ${spec['more']}',
                                style: TextStyle(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              spec['value1'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              spec['value2'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "DMSans",
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  } else if (screenWidth < 1024) {
    // TABLET: Show as 3-column table but with smaller padding/font
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Engine & Transmission",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(64, 64, 64, 1),
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1,
            ),
            columnWidths: {
              0: FixedColumnWidth(120.0),
              1: FixedColumnWidth(150.0),
              2: FixedColumnWidth(150.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 12, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  } else {
    // WEB: Original 3-column table
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.05),
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
          SizedBox(height: screenHeight * 0.02),
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
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Specs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Car 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
              ...specs.map((spec) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: spec['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "DMSans",
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if (spec['more'] != null && spec['more'] != '')
                                TextSpan(
                                  text: '\n${spec['more']}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value1'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          spec['value2'],
                          style: TextStyle(fontSize: 14, fontFamily: "DMSans"),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
  
  Widget buildCarCard() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Responsive sizes
  double cardWidth = screenWidth < 600
      ? screenWidth * 0.7
      : screenWidth < 1024
          ? screenWidth * 0.28
          : screenWidth * 0.2;
  double imageHeight = screenWidth < 600
      ? screenHeight * 0.18
      : screenWidth < 1024
          ? screenHeight * 0.22
          : screenHeight * 0.3;
  double titleFont = screenWidth < 600 ? 12 : 13;
  double subtitleFont = screenWidth < 600 ? 10 : 11;
  double priceFont = screenWidth < 600 ? 10 : 11;
  double labelFont = screenWidth < 600 ? 9 : 10;
  double iconSize = screenWidth < 600 ? 13 : 15;
  double closeIconSize = screenWidth < 600 ? 20 : 25;
  double closeIconImg = screenWidth < 600 ? 15 : 20;

  return Stack(
    children: [
      Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 2, color: Color.fromRGBO(233, 233, 233, 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.asset(
                    "assets/Home_Images/Compare_Cars/Ford_transit1.jpeg",
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: closeIconSize,
                      width: closeIconSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/Home_Images/Compare_Cars/close.png",
                        color: Colors.grey,
                        height: closeIconImg,
                        width: closeIconImg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth < 600 ? 7.0 : 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ford Transit – 2021",
                    style: TextStyle(
                      fontSize: titleFont,
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
                            fontSize: subtitleFont,
                            fontWeight: FontWeight.w500,
                            fontFamily: "DMSans",
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth < 600 ? 6 : 10),
                  Row(
                    children: [
                      Column(
                        children: [
                          Image.asset("assets/diesel.webp",
                              height: screenWidth < 600 ? 10 : 11.62,
                              color: Colors.black,
                              fit: BoxFit.contain),
                          Text("Diesel", style: TextStyle(fontSize: labelFont, fontFamily: "DMSans")),
                        ],
                      ),
                      SizedBox(width: screenWidth < 600 ? 10 : 20),
                      Column(
                        children: [
                          Image.asset("assets/manuel.png",
                              height: screenWidth < 600 ? 10 : 11.62,
                              fit: BoxFit.contain),
                          Text("Manual", style: TextStyle(fontSize: labelFont, fontFamily: "DMSans")),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth < 600 ? 6 : 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Rs. 3.07 Crore",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: priceFont,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                          ),
                        ),
                        TextSpan(
                          text: " onwards",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: priceFont,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                          ),
                        ),
                        TextSpan(
                          text: " \nOn-Road Price, Mumbai",
                          style: TextStyle(
                            color: Color.fromRGBO(157, 157, 157, 1),
                            fontSize: labelFont,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenWidth < 600 ? 8 : screenHeight * 0.02),
                  Row(
                    children: [
                      Text(
                        "Book a test Drive",
                        style: TextStyle(
                          fontSize: labelFont,
                          color: Color.fromRGBO(26, 76, 142, 1),
                          fontWeight: FontWeight.w500,
                          fontFamily: "DMSans",
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(Icons.arrow_outward, size: iconSize, color: Color.fromRGBO(26, 76, 142, 1)),
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
  
  Widget addCarCard() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  double cardWidth = screenWidth < 600
      ? screenWidth * 0.7
      : screenWidth < 1024
          ? screenWidth * 0.28
          : screenWidth * 0.2;
  double cardHeight = screenWidth < 600
      ? screenHeight * 0.22
      : screenWidth < 1024
          ? screenHeight * 0.32
          : screenHeight * 0.5;
  double iconRadius = screenWidth < 600 ? 22 : 30;
  double iconSize = screenWidth < 600 ? 22 : 30;
  double fontSize = screenWidth < 600 ? 12 : screenWidth < 1024 ? 13 : 15;

  return Container(
    width: cardWidth,
    height: cardHeight,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(width: 2, color: Color.fromRGBO(233, 233, 233, 1)),
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
              borderRadius: BorderRadius.circular(iconRadius),
              border: Border.all(width: 1, color: Color.fromRGBO(26, 76, 142, 1)),
            ),
            child: CircleAvatar(
              radius: iconRadius,
              backgroundColor: Color.fromRGBO(235, 239, 255, 1),
              child: Icon(
                Icons.add,
                color: Color.fromRGBO(26, 76, 142, 1),
                size: iconSize,
              ),
            ),
          ),
          SizedBox(height: screenWidth < 600 ? 6 : 10),
          Text(
            'Add Another Car',
            style: TextStyle(
              color: Color.fromRGBO(26, 76, 142, 1),
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
  
  Widget buildIcons() {
  double screenWidth = MediaQuery.of(context).size.width;
  double iconSize = screenWidth < 600 ? 16 : screenWidth < 1024 ? 18 : 20;
  double spacing = screenWidth < 600 ? 2 : 6;

  return Wrap(
    spacing: spacing,
    children: [
      IconButton(
        onPressed: () {},
        icon: FaIcon(
          FontAwesomeIcons.facebook,
          color: Colors.white,
          size: iconSize,
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: FaIcon(
          FontAwesomeIcons.twitter,
          color: Colors.white,
          size: iconSize,
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: FaIcon(
          FontAwesomeIcons.instagram,
          color: Colors.white,
          size: iconSize,
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: FaIcon(
          FontAwesomeIcons.linkedin,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    ],
  );
}

}