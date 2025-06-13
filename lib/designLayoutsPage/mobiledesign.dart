import 'package:arouse_automotive_day1/components_screen/compare_cars/appBar.dart';
import 'package:arouse_automotive_day1/components_screen/compare_cars/twoCarsCompare.dart';
import 'package:arouse_automotive_day1/components_screen/help&support/helpPage.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/WebViewWidgetPage/webView_Page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/vechicleInfo_api.dart';
import '../api/bookOnline_api.dart';
import '../api/bookTestDrive_api.dart';

class Mobiledesign extends StatefulWidget {
  const Mobiledesign({Key? key}): super(key: key);

  @override
  State<Mobiledesign> createState() => _MobiledesignState();
}

class _MobiledesignState extends State<Mobiledesign> {
  final List<Map<String, dynamic>> carData = [
    {"make": "Kia", "model": "Seltos", "price": 1500000, "specifications": "SUV"},
    {"make": "Hyundai", "model": "Creta", "price": 37000000, "specifications": "SUV"},
    {"make": "Ford", "model": "Ecosport", "price": 1400000, "specifications": "Compact SUV"},
  ];
  List<Map<String, dynamic>> filteredCars= [];

  final ApiService apiService = ApiService();

  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }


  Widget buildBulletPoint(String text) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      leading: Icon(Icons.check_circle, color: Color(0xFF004C90), size: screenWidth * 0.05),
      title: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontFamily: "DMSans",
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget buildStatBox(String number, String label) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.05,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.w700,
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(5, 11, 32, 1),
              fontFamily: "DMSans",
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  final List<Map<String, String>> reviews = [
    {
      "name": "Neil",
      "date": "30th May 2023",
      "image": "assets/Home_Images/Customers_say_Images/ladyImage.jpeg",
      "review":
          "Lorem ipsum dolor sit amet consectetur. Diam nec faucibus molestie tortor mi. Orci risus turpis sagittis blandit id. Suspendisse enim pellentesque diam et orci nam pharetra dignissim. Netus dui dapibus quis porttitor eget tristique consectetur. Quisque eu at scelerisque scelerisque. Curabitur tempor consectetur ut neque."
    },
    {
      "name": "Neil",
      "date": "30th May 2023",
      "image": "assets/Home_Images/Customers_say_Images/ladyImage.jpeg",
      "review":
          "Lorem ipsum dolor sit amet consectetur. Diam nec faucibus molestie tortor mi. Orci risus turpis sagittis blandit id. Suspendisse enim pellentesque diam et orci nam pharetra dignissim. Netus dui dapibus quis porttitor eget tristique consectetur. Quisque eu at scelerisque scelerisque. Curabitur tempor consectetur ut neque."
    },
    {
      "name": "Neil",
      "date": "30th May 2023",
      "image": "assets/Home_Images/Customers_say_Images/ladyImage.jpeg",
      "review":
          "Lorem ipsum dolor sit amet consectetur. Diam nec faucibus molestie tortor mi. Orci risus turpis sagittis blandit id. Suspendisse enim pellentesque diam et orci nam pharetra dignissim. Netus dui dapibus quis porttitor eget tristique consectetur. Quisque eu at scelerisque scelerisque. Curabitur tempor consectetur ut neque."
    },
  ];

  final List<Map<String, String>> blogs = [
    {
      "name" : "Sound",
      "position" : "Admin",
      "date" : "November 22, \n2023",
      "image" : "assets/Home_Images/Blog_cars/blogCar1.jpeg",
      "description" : "2024 BMW ALPINA XB7 with exclusive details, extraordinary",
    },
    {
      "name" : "Accessories",
      "position" : "Admin",
      "date" : "November 22, \n2023",
      "image" : "assets/Home_Images/Blog_cars/blogCar2.jpeg",
      "description" : "BMW X6 M50i is designed to exceed your sportiest.",
    },
    {
      "name" : "Exterior",
      "position" : "Admin",
      "date" : "November 22, \n2023",
      "image" : "assets/Home_Images/Blog_cars/blogCar3.jpeg",
      "description" : "BMW X5 Gold 2024 Sport Review: Light on Sport",
    },
  ];


  List<Map<String, String>> comparedCars = [];

  void addToCompare(Map<String, String> car, BuildContext context) {
    bool isAlreadyAdded = comparedCars.any((item) => item["id"] == car["id"]);

    if (!isAlreadyAdded) {
      if (comparedCars.length < 2) {
        setState(() {
          comparedCars.add(car);
        });
        print("Car added to compare: ${car["name"]}");
      } else {
        print("You can only compare two cars at a time");
      }
    } else {
      print("${car["name"]} is already added for comparison.");
    }

    if(comparedCars.length <= 2){
      List<Map<String, String>> filteredCars = comparedCars.map((car) {
        return {
          "name": car["name"] ?? "",
          "image": car["image"] ?? "",
          "dieselImage": car["dieselImage"] ?? "",
          "details2": car["details2"] ?? "",
          "manualImage": car["manualImage"] ?? "",
          "details3": car["details3"] ?? "",
          "details1": car["details1"] ?? "",
          "details12": car["details12"] ?? "",
          "details13": car["details13"] ?? "",
        };
      }).toList();

      Future.delayed(Duration(milliseconds: 200), (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Twocarscompare(comparedCars: filteredCars),
          ),
        );
      });
      
    }
  }


  CarouselSliderController innerCarouselController = CarouselSliderController();
  int innerCurrentPage = 0;
  int index = 0;

  List<Map<String, String>> cars = [
    {
      "id" : "1",
      "name" : "E 200",
      "image" : "assets/blackCar.png",
      "viewImage" : "assets/degrees.png",
      "compareImage" : "assets/compare.png",
      "compareText" : "Add to compare",
      "moreDetails1" : "Starting at",
      "details1": "Rs. 3.07 Crore",
      "details12" : "onwards On-Road",
      "details13" : "Price, Mumbai",
      "moreDetails2" : "Engine Options",
      "dieselImage" : "assets/diesel.webp",
      "details2" : "Diesel",
      "moreDetails3" : "Transmission",
      "moreDetails31" : "Available",
      "manualImage" : "assets/manuel.png",
      "details3" : "Manual",
      "button1" : "Learn More",
      "button2" : "Book a Test Drive",
    },
    {
      "id" : "2",
      "name" : "E 300",
      "image" : "assets/whiteCar.png",
      "viewImage" : "assets/degrees.png",
      "compareImage" : "assets/compare.png",
      "compareText" : "Add to compare",
      "moreDetails1" : "Starting at",
      "details1": "Rs. 3.07 Crore",
      "details12" : "onwards On-Road",
      "details13" : "Price, Mumbai",
      "moreDetails2" : "Engine Options",
      "dieselImage" : "assets/diesel.webp",
      "details2" : "Diesel",
      "moreDetails3" : "Transmission",
      "moreDetails31" : "Available",
      "manualImage" : "assets/manuel.png",
      "details3" : "Manual",
      "button1" : "Learn More",
      "button2" : "Book a Test Drive",
    },
    {
      "id" : "3",
      "name" : "E 400",
      "image" : "assets/redCar.png",
      "viewImage" : "assets/degrees.png",
      "compareImage" : "assets/compare.png",
      "compareText" : "Add to compare",
      "moreDetails1" : "Starting at",
      "details1": "Rs. 3.07 Crore",
      "details12" : "onwards On-Road",
      "details13" : "Price, Mumbai",
      "moreDetails2" : "Engine Options",
      "dieselImage" : "assets/diesel.webp",
      "details2" : "Diesel",
      "moreDetails3" : "Transmission",
      "moreDetails31" : "Available",
      "manualImage" : "assets/manuel.png",
      "details3" : "Manual",
      "button1" : "Learn More",
      "button2" : "Book a Test Drive",
    },

  ];

  @override
  Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
  bool isWebOrDesktop = screenWidth >= 1024;

  // Dynamic Sizing
  double imageSize = isWebOrDesktop ? 40 : isTablet ? 30 : screenWidth * 0.075;
  double iconSize = isWebOrDesktop ? 30 : isTablet ? 20 : screenWidth * 0.08;
  double fontSize = isWebOrDesktop ? 20 : isTablet ? 18 : screenWidth * 0.03 + 4;
  double spacing = isWebOrDesktop ? 10 : isTablet ? 8 : screenWidth * 0.01;

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
    ),
    home: Scaffold(
      appBar: AppBar(
        elevation: 5.0,
        shadowColor: Colors.grey,
        leading: Padding(
          padding: EdgeInsets.all(screenHeight * 0.015),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Helppage()));
            },
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/menu.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image.png',
              height: imageSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: spacing),
            Text(
              'AROUSE',
              style: TextStyle(
                color: Color(0xFF004C90),
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DMSans",
              ),
            ),
            SizedBox(width: spacing),
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
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(spacing),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: Image.asset(
                'assets/wishlist.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: LayoutBuilder(
              builder: (context, constraints) {
                double searchBarHeight = isWebOrDesktop
                    ? screenHeight * 0.09
                    : isTablet
                        ? screenHeight * 0.07
                        : screenHeight * 0.06;

                double searchIconSize = searchBarHeight * 0.6;

                return SizedBox(
                  height: searchBarHeight,
                  child: SearchAnchor(
                    builder: (context, controller) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            filteredCars = List.from(carData);
                          });
                          controller.openView();
                        },
                        child: SearchBar(
                          controller: controller,
                          hintText: "Search by Make, Model, Price Range, or Specs",
                          hintStyle: MaterialStateProperty.all(
                            TextStyle(
                              color: Colors.grey,
                              fontSize: isWebOrDesktop ? 18 : isTablet ? 16 : screenWidth * 0.04,
                              fontFamily: "DMSans",
                            ),
                          ),
                          onChanged: (query) {
                            if (query.isEmpty) {
                              setState(() {
                                filteredCars = List.from(carData);
                              });
                              controller.openView();
                              return;
                            }

                            setState(() {
                              if (RegExp(r'^\d+-\d+$').hasMatch(query)) {
                                List<String> range = query.split("-");
                                int minPrice = int.tryParse(range[0].replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                                int maxPrice = int.tryParse(range[1].replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

                                filteredCars = carData.where((car) {
                                  final int carPrice = int.tryParse(car['price'].toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                                  return carPrice >= minPrice && carPrice <= maxPrice;
                                }).toList();
                              } else {
                                filteredCars = carData.where((car) {
                                  final make = car['make'].toString().toLowerCase();
                                  final model = car['model'].toString().toLowerCase();
                                  final price = car['price'].toString();
                                  final specs = car['specifications'].toString().toLowerCase();

                                  return make.contains(query.toLowerCase()) ||
                                      model.contains(query.toLowerCase()) ||
                                      price.contains(query) ||
                                      specs.contains(query.toLowerCase());
                                }).toList();
                              }
                            });
                            controller.openView();
                          },
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Image.asset(
                              'assets/search.png',
                              height: searchIconSize,
                              color: const Color.fromARGB(255, 28, 7, 7),
                            ),
                          ),
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          shadowColor: MaterialStateProperty.all(Colors.transparent),
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isWebOrDesktop ? 15 : 10),
                              side: const BorderSide(color: Color.fromRGBO(233, 233, 233, 1), width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                    suggestionsBuilder: (context, controller) {
                      if (filteredCars.isEmpty) {
                        return [
                          const ListTile(
                            title: Text(
                              "No results found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ];
                      }

                      return filteredCars.map((car) {
                        return ListTile(
                          title: Text(
                            "${car["make"]} - ${car["model"]}",
                            style: TextStyle(
                              fontSize: isWebOrDesktop ? 18 : isTablet ? 16 : screenWidth * 0.04,
                              fontFamily: "DMSans",
                            ),
                          ),
                          subtitle: Text(
                            "Price: ${car["price"]} | Specs: ${car["specifications"]}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          onTap: () async {
                            Map<String, dynamic> filteredCar = {
                              "make": car["make"],
                              "model": car["model"],
                              "price": car["price"],
                              "specifications": car["specifications"],
                            };

                            bool success = await apiService.saveSearchData(filteredCar);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Car data saved successfully: ${car["make"]} - ${car["model"]}",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to save car data."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }

                            controller.clear();

                            setState(() {
                              filteredCars = List.from(carData);
                            });
                          }

                        );
                      }).toList();
                    },
                  ),
                );
              },
            ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double imageHeight = screenWidth > 600
                        ? MediaQuery.of(context).size.height * 0.8
                        : MediaQuery.of(context).size.height * 0.35;

                    double textFontSize = screenWidth > 600 ? 50 : screenWidth * 0.1;
                    double buttonFontSize = screenWidth > 600 ? 18 : screenWidth * 0.035;
                    double buttonPaddingH = screenWidth > 600 ? 20 : screenWidth * 0.05;
                    double buttonPaddingV = screenWidth > 600 ? 14 : MediaQuery.of(context).size.height * 0.015;

                    return Stack(
                      children: [
                        SizedBox(
                          height: imageHeight,
                          width: double.infinity,
                          child: Image.asset(
                            "assets/carbackground.jpeg",
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          left: screenWidth > 800
                              ? MediaQuery.of(context).size.width * 0.08
                              : MediaQuery.of(context).size.width * 0.05,
                          bottom: MediaQuery.of(context).size.height * 0.05,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Find Your \nPerfect Car",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textFontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "DMSans",
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: buttonPaddingH,
                                    vertical: buttonPaddingV,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontFamily: "DMSans",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "Explore More",
                                  style: TextStyle(
                                    color: Color(0xFF004C90),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric( 
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      
                      double titleFontSize = screenWidth > 600 ? 40 : screenWidth * 0.08;
                      double buttonFontSize = screenWidth > 600 ? 18 : screenWidth * 0.04;
                      double iconSize = screenWidth > 600 ? 35 : screenWidth * 0.06;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.00,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Cars',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: "DMSans",
                              ),
                            ),

                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Color.fromRGBO(0, 147, 255, 1),
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "DMSans",
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Icon(
                                    Icons.arrow_outward,
                                    color: Color.fromRGBO(0, 147, 255, 1),
                                    size: iconSize,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  Divider(
                    color: Color.fromRGBO(219, 219, 219, 1),
                    thickness: MediaQuery.of(context).size.width * 0.005,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),


                  Stack(
                    children: [
                      CarouselSlider(
                        carouselController: innerCarouselController,
                        options: CarouselOptions(
                          
                          height: MediaQuery.of(context).size.height > 600
                              ? MediaQuery.of(context).size.height * 0.54
                              : MediaQuery.of(context).size.height * 0.95,
                          autoPlay: false,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 1000),
                          enableInfiniteScroll: false,
                          enlargeCenterPage: false,
                          viewportFraction: 1.0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              innerCurrentPage = index;
                            });
                          },
                        ),
                        items: cars.map((car) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              double padding = constraints.maxWidth * 0.025;
                              double buttonPadding = constraints.maxWidth * 0.03;
                              double buttonHeight = constraints.maxHeight * 0.05;
                              double fontSizeFactor = MediaQuery.of(context).size.width > 800 ? 1.2 : 1.0;

                              return Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(padding),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        width: 2,
                                        color: Color.fromRGBO(233, 233, 233, 1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Image.asset(car["image"]!, fit: BoxFit.cover),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: padding,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  
                                                  addToCompare(cars[index], context);
                                                  
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: buttonPadding,
                                                    vertical: buttonHeight * 0.3,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(car["compareImage"]!, width: 20, height: 20, fit: BoxFit.contain),
                                                    SizedBox(width: padding * 0.5),
                                                    Text(
                                                      car["compareText"]!,
                                                      style: TextStyle(fontFamily: "DMSans"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: constraints.maxHeight * 0.18,
                                              left: constraints.maxWidth * 0.5 - 60,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => WebViewPage(url: 
                                                      "https://virtualshowroom.hondacarindia.com/honda-amaze/?utm_source=hondacarindia&utm_medium=website&utm_campaign=explore_virtual_showroom#/car/amaze",
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child:Hero(
                                                  tag: 'carHeroTag_${car["id"]}_${index}_${UniqueKey()}',
                                                  child: Image.asset(
                                                    car["viewImage"]!,
                                                    width: constraints.maxWidth * 0.25,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.03),
                                        Flexible(
                                          child: Text(
                                            car["name"]!,
                                            style: TextStyle(
                                              fontSize: constraints.maxWidth * 0.05 * fontSizeFactor,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "DMSans",
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.02),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    car["moreDetails1"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.04 * fontSizeFactor - 0.9,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.05),
                                                  Text(
                                                    car["details1"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.03 * fontSizeFactor,
                                                      fontFamily: "DMSans",
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    car["details12"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.03 * fontSizeFactor,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  Text(
                                                    car["details13"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.03 * fontSizeFactor,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: constraints.maxWidth * 0.01),
                                            Container(
                                              color: Color.fromRGBO(219, 219, 219, 1),
                                              height: constraints.maxHeight * 0.18,
                                              width: constraints.maxWidth * 0.005,
                                            ),
                                            SizedBox(width: constraints.maxWidth * 0.02),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    car["moreDetails2"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.04 * fontSizeFactor - 0.9,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.05),
                                                  Image.asset(
                                                    car["dieselImage"]!,
                                                    height: constraints.maxHeight * 0.03,
                                                    width: constraints.maxWidth * 0.1,
                                                    color: Colors.black,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.02),
                                                  Text(
                                                    car["details2"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.03 * fontSizeFactor,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: constraints.maxWidth * 0.02),
                                            Container(
                                              color: Color.fromRGBO(219, 219, 219, 1),
                                              height: constraints.maxHeight * 0.18,
                                              width: constraints.maxWidth * 0.005,
                                            ),
                                            SizedBox(width: constraints.maxWidth * 0.02),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    car["moreDetails3"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.04 * fontSizeFactor - 0.9,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  Text(
                                                    car["moreDetails31"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.04 * fontSizeFactor - 0.9,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.02),

                                                  Image.asset(car["manualImage"]!,
                                                      height: constraints.maxHeight * 0.03,
                                                      width: constraints.maxWidth * 0.1,
                                                      color: Colors.black,
                                                      fit: BoxFit.contain,
                                                      ),
                                                  SizedBox(height: constraints.maxHeight * 0.02),
                                                  Text(
                                                    car["details3"]!,
                                                    style: TextStyle(
                                                      fontSize: constraints.maxWidth * 0.03 * fontSizeFactor,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.02),
                                        Divider(
                                          color: Color.fromRGBO(219, 219, 219, 1),
                                          thickness: 2.0,
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.02),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                side: BorderSide(color: Color(0xFF004C90)),
                                              ),
                                              onPressed: () {},
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.5),
                                                child: Text(
                                                  car["button1"]!,
                                                  style: TextStyle(
                                                    fontSize: constraints.maxWidth * 0.04 * fontSizeFactor,
                                                    color: Color(0xFF004C90),
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF004C90),
                                              ),
                                              onPressed: () async{
                                                Map<String, dynamic> testDriveData = {
                                                    "name": car["name"],
                                                    "image": car["image"],
                                                    "moreDetails1": car["moreDetails1"],
                                                    "details1": car["details1"],
                                                    "details2": car["details2"],
                                                    "moreDetails3": car["moreDetails3"],
                                                    "moreDetails31": car["moreDetails31"],
                                                    "details3": car["details3"],
                                                  };
                                                  final AddtoDriveApi driveApi = AddtoDriveApi();
                                                  await driveApi.saveTestDriveData(testDriveData);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.5),
                                                child: Text(
                                                  car["button2"]!,
                                                  style: TextStyle(
                                                    fontSize: constraints.maxWidth * 0.04 * fontSizeFactor,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }).toList(),
                      ),


                      if(innerCurrentPage >= 0)
                        Positioned(
                          left: -10,
                          top: 170,
                          child: FloatingActionButton(
                            onPressed: () {
                              innerCarouselController.animateToPage(innerCurrentPage - 1, curve: Curves.ease);
                            },
                            backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                            child: const Icon( Icons.arrow_back_ios_outlined, color: Colors.white,),
                            mini: true,
                          ),
                        ),
                        if(innerCurrentPage <= cars.length - 1)
                          Positioned(
                            right: -10,
                            top: 170,
                            child: FloatingActionButton(
                              onPressed: () {
                                innerCarouselController.animateToPage(innerCurrentPage + 1);
                              },
                              backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                              child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                              mini: true,
                            ),
                          ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05,),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = MediaQuery.of(context).size.width;
                      double screenHeight = MediaQuery.of(context).size.height;

                      double imageSize;
                      if (screenWidth > 1200) {
                        imageSize = (screenWidth / 6) - 100;
                      } else if (screenWidth > 600) {
                        imageSize = (screenWidth / 6) - 100; 
                      } else {
                        imageSize = (screenWidth / 3) - 60; 
                      }
                      imageSize = imageSize.clamp(30.0, 200.0);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Similar Brands',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        'Show all Brands',
                                        style: TextStyle(
                                          color: Color.fromRGBO(0, 147, 255, 1),
                                          fontSize: screenWidth*0.04,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      Icon(Icons.arrow_outward, color: Color.fromRGBO(0, 147, 255, 1)),
                                    ],
                                  ),
                                ),
                                
                              ],
                            ),
                            Divider(
                              color: Color.fromRGBO(219, 219, 219, 1),
                              thickness: 2.0,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Wrap(
                                spacing: screenWidth * 0.05,
                                runSpacing: screenHeight * 0.02,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          Image.asset("assets/audi.jpeg", width: imageSize, fit: BoxFit.contain),
                                          Text("Audi", style: TextStyle(fontFamily: "DMSans",)),
                                          SizedBox(height: screenHeight * 0.02,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          Image.asset("assets/bmw.jpeg", width: imageSize, fit: BoxFit.contain),
                                          Text("BMW", style: TextStyle(fontFamily: "DMSans",)),
                                          SizedBox(height: screenHeight * 0.02,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          Image.asset("assets/ford.jpeg", width: imageSize, fit: BoxFit.contain),
                                          Text("Ford", style: TextStyle(fontFamily: "DMSans",)),
                                          SizedBox(height: screenHeight * 0.02,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          Image.asset("assets/mercedes.jpeg", width: imageSize, fit: BoxFit.contain),
                                          Text("Mercedes Benz", style: TextStyle(fontFamily: "DMSans",)),
                                          SizedBox(height: screenHeight * 0.02,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          Image.asset("assets/peugeot.jpeg", width: imageSize, fit: BoxFit.contain),
                                          Text("Peugeot", style: TextStyle(fontFamily: "DMSans",)),
                                          SizedBox(height: screenHeight * 0.02,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          Image.asset("assets/volkswagan.jpeg", width: imageSize, fit: BoxFit.contain),
                                          Text("Volkswagan", style: TextStyle(fontFamily: "DMSans",)),
                                          SizedBox(height: screenHeight * 0.02),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double screenWidth = MediaQuery.of(context).size.width;
                                double imageWidth = screenWidth * 0.9;
                                double imageHeight = imageWidth * 9 / 16;
                                double playButtonSize = screenWidth * 0.12;
                                double sectionSpacing = screenWidth * 0.05;
                                double fontSizeTitle = screenWidth * 0.06;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: sectionSpacing),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          "assets/videoImage.jpeg",
                                          width: imageWidth,
                                          height: imageHeight,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: playButtonSize / 2,
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                        child: Icon(
                                          Icons.play_arrow,
                                          size: playButtonSize * 0.6,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: screenWidth * 0.9,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(238, 241, 251, 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Buying a car has never been this easy.",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.06,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily: "DMSans",
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Text(
                                            "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.grey[700],
                                              fontFamily: "DMSans",
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Column(
                                            children: [
                                              buildBulletPoint(
                                                  "We are the UK's largest provider, with more patrols in more places"),
                                              buildBulletPoint("You get 24/7 roadside assistance"),
                                              buildBulletPoint("We fix 4 out of 5 cars at the roadside"),
                                            ],
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF004C90),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.05,
                                                vertical: screenWidth * 0.03,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Book a test drive",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: screenWidth * 0.04,
                                                      fontFamily: "DMSans",
                                                    )),
                                                SizedBox(width: sectionSpacing),
                                                Icon(Icons.arrow_outward, color: Colors.white),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              SizedBox(height: sectionSpacing),
                              Table(
                                columnWidths: {
                                  0: FlexColumnWidth(),
                                  1: FlexColumnWidth(),
                                },
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                      color: Color.fromRGBO(219, 219, 219, 1), width: 1),
                                  verticalInside: BorderSide(
                                      color: Color.fromRGBO(219, 219, 219, 1), width: 1),
                                ),
                                children: [
                                  TableRow(
                                    children: [
                                      buildStatBox("836M", "CARS FOR SALE"),
                                      buildStatBox("738M", "DEALER REVIEWS"),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      buildStatBox("100M", "VISITORS PER DAY"),
                                      buildStatBox("238M", "VERIFIED DEALERS"),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: sectionSpacing),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Why Choose Us?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSizeTitle, fontFamily: "DMSans",),),
                                    Divider(
                                      thickness: 2,
                                      color: Color.fromRGBO(219, 219, 219, 1),
                                    )
                                  ],
                                ),
                                                    
                              ),
                              const SizedBox(height: 30),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double screenWidth = MediaQuery.of(context).size.width;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset("assets/financialOffer.png", height: screenWidth * 0.15),
                                        SizedBox(height: screenWidth * 0.06),
                                        Text("Special Financing Offers", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                        SizedBox(height: screenWidth * 0.04),
                                        Text("Our stress-free finance department that can find financial solutions to save you money.",
                                        style: TextStyle(fontFamily: "DMSans", fontSize: screenWidth * 0.035),),
                                      ],
                                    ),
                                  
                                  const SizedBox(height: 30),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset("assets/dealership.png", height: screenWidth * 0.15),
                                      SizedBox(height: screenWidth * 0.06),
                                      Text("Trusted Car Dealership", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                      SizedBox(height: screenWidth * 0.04),
                                      Text("Our stress-free finance department that can find financial solutions to save you money.",
                                      style: TextStyle(fontFamily: "DMSans", fontSize: screenWidth * 0.035),),
                                    ],
                                  ),
                                                        
                                  const SizedBox(height: 30),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset("assets/transparent.png", height: screenWidth * 0.15),
                                      SizedBox(height: screenWidth*0.06),
                                      Text("Transparent Pricing", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                      SizedBox(height: screenWidth * 0.04),
                                      Text("Our stress-free finance department that can find financial solutions to save you money.",
                                      style: TextStyle(fontFamily: "DMSans", fontSize: screenWidth * 0.035),),
                                    ],
                                  ),
                                                        
                                  const SizedBox(height: 30),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset("assets/expertCar.png", height: screenWidth * 0.15),
                                        SizedBox(height: screenWidth * 0.06),
                                        Text("Expert Car Service", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),),
                                        SizedBox(height: screenWidth * 0.04),
                                        Text("Our stress-free finance department that can find financial solutions to save you money.",
                                        style: TextStyle(fontFamily: "DMSans", fontSize: screenWidth * 0.035),),
                                      ],
                                    ),
                                  ],
                                  );
                                }
                              ),
                                const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double textSize = constraints.maxWidth > 600 ? 28 : 24;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "What our customers say",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: textSize,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        Divider(
                                          thickness: 2,
                                          color: Color.fromRGBO(219, 219, 219, 1),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                                                      
                              const SizedBox(height: 30),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double iconSize = constraints.maxWidth > 600 ? 40 : 30;
                                  double textSize = constraints.maxWidth > 600 ? 22 : 18;
                                  double spacing = constraints.maxWidth > 600 ? 15 : 8;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          children: [
                                            Icon(Icons.star, size: iconSize, color: Color.fromRGBO(241, 217, 0, 1)),
                                            SizedBox(width: spacing),
                                            Text(
                                              "4.5 · 306 reviews",
                                              style: TextStyle(
                                                fontSize: textSize,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(31, 56, 76, 1),
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double containerHeight = constraints.maxWidth > 600 ? 320 : 290;
                                    double containerWidth = constraints.maxWidth > 600 ? 400 : 370;
                                    double imageSize = constraints.maxWidth > 600 ? 75 : 65;
                                    double textSize = constraints.maxWidth > 600 ? 22 : 20;
                                    double dateSize = constraints.maxWidth > 600 ? 16 : 14;
                                    double reviewTextSize = constraints.maxWidth > 600 ? 16 : 14;

                                    return CarouselSlider(
                                      options: CarouselOptions(
                                        height: containerHeight,
                                        autoPlay: true,
                                        enlargeCenterPage: false,
                                        enableInfiniteScroll: false,
                                        viewportFraction: constraints.maxWidth > 600 ? 0.7 : 0.9,
                                      ),
                                      items: reviews.map((review) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            height: containerHeight,
                                            width: containerWidth,
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(10),
                                              strokeWidth: 2.5,
                                              dashPattern: [20, 5],
                                              color: const Color.fromRGBO(196, 196, 196, 1),
                                              child: Container(
                                                height: containerHeight,
                                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(50),
                                                          child: Image.asset(review["image"]!, height: imageSize),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              review["name"]!,
                                                              style: TextStyle(
                                                                fontSize: textSize,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            const SizedBox(height: 5),
                                                            Text(
                                                              review["date"]!,
                                                              style: TextStyle(
                                                                fontSize: dateSize,
                                                                color: Color.fromRGBO(139, 139, 139, 1),
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            color: Color.fromRGBO(62, 62, 62, 1),
                                                            fontSize: reviewTextSize,
                                                            fontFamily: "DMSans",
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: review["review"],
                                                            ),
                                                            const TextSpan(
                                                              text: " View More",
                                                              style: TextStyle(
                                                                color: Color.fromRGBO(13, 128, 212, 1),
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 10),
                              Divider(
                                color: Color.fromRGBO(219, 219, 219, 1),
                                thickness: 2,
                              ),
                              SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double fontSize = constraints.maxWidth > 600 ? 22 : 20;
                                  double paddingLeft = constraints.maxWidth > 600 ? 40.0 : 30.0;
                                  double paddingRight = constraints.maxWidth > 600 ? 15.0 : 10.0;
                                  double iconSize = constraints.maxWidth > 600 ? 24.0 : 20.0;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
                                            child: Text(
                                              "Show All Reviews",
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                color: Color.fromRGBO(0, 147, 255, 1),
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios_rounded, size: iconSize),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: 30),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double fontSize = constraints.maxWidth > 600 ? 28 : 25;
                                  double paddingValue = constraints.maxWidth > 600 ? 20.0 : 10.0;

                                  return Padding(
                                    padding: EdgeInsets.all(paddingValue),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Latest Blog Posts",
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        Divider(
                                          color: Color.fromRGBO(219, 219, 219, 1),
                                          thickness: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double screenWidth = constraints.maxWidth;
                                  double imageHeight = screenWidth > 600 ? 300 : 240;
                                  double textSize = screenWidth > 600 ? 20 : 18;
                                  double buttonPadding = screenWidth > 600 ? 25 : 20;

                                  return Padding(
                                    padding: EdgeInsets.all(0),
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        height: screenWidth > 600 ? 420 : 370,
                                        autoPlay: false,
                                        autoPlayInterval: Duration(seconds: 3),
                                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                                        enlargeCenterPage: false,
                                        enableInfiniteScroll: true,
                                        viewportFraction: screenWidth > 600 ? 0.8 : 0.9,
                                      ),
                                      items: blogs.map((blog) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Image.asset(
                                                      blog["image"]!,
                                                      height: imageHeight,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 5,
                                                    left: 5,
                                                    child: ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.white,
                                                        foregroundColor: Colors.black,
                                                        padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: 8),
                                                      ),
                                                      child: Text(
                                                        blog["name"]!,
                                                        style: TextStyle(fontSize: textSize - 3, fontFamily: "DMSans"),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      blog["position"]!,
                                                      style: TextStyle(
                                                        color: Color.fromRGBO(5, 11, 32, 1),
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Icon(Icons.circle, size: 8, color: Color.fromRGBO(225, 225, 225, 1)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      blog["date"]!,
                                                      style: TextStyle(
                                                        color: Color.fromRGBO(5, 11, 32, 1),
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                blog["description"]!,
                                                style: TextStyle(
                                                  fontSize: textSize,
                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "DMSans",
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double screenWidth = constraints.maxWidth;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(233, 242, 255, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth > 600 ? 50 : 40,
                                        top: screenWidth > 600 ? 60 : 50,
                                        bottom: screenWidth > 600 ? 50 : 40,
                                        right: screenWidth > 600 ? 50 : 40,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Are You Looking \nFor a Car?",
                                            style: TextStyle(
                                              fontFamily: "DMSans",
                                              fontWeight: FontWeight.w700,
                                              fontSize: screenWidth > 600 ? 20 : 16.73,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 0),
                                            child: Text(
                                              "We are committed to providing our customers with exceptional service.",
                                              style: TextStyle(
                                                fontFamily: "DMSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: screenWidth > 600 ? 14 : 12.36,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                                  foregroundColor: Color.fromRGBO(255, 255, 255, 1),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: screenWidth > 600 ? 20 : 15,
                                                    vertical: screenWidth > 600 ? 18 : 15,
                                                  ),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Get Started",
                                                      style: TextStyle(
                                                        fontSize: screenWidth > 600 ? 14 : 11.36,
                                                        fontWeight: FontWeight.w500,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Icon(Icons.arrow_outward_sharp, size: screenWidth > 600 ? 24 : 20),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 50),
                                              Image.asset(
                                                "assets/Home_Images/Footer_Images/lookingCar.png",
                                                height: screenWidth > 600 ? 100 : 75,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                                                    
                              SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double screenWidth = constraints.maxWidth;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 233, 243, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth > 600 ? 50 : 40,
                                        top: screenWidth > 600 ? 60 : 50,
                                        bottom: screenWidth > 600 ? 50 : 40,
                                        right: screenWidth > 600 ? 50 : 40,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Best place for \ncar financing",
                                            style: TextStyle(
                                              fontFamily: "DMSans",
                                              fontWeight: FontWeight.w700,
                                              fontSize: screenWidth > 600 ? 20 : 16.73,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 0),
                                            child: Text(
                                              "We are committed to providing our customers with exceptional service.",
                                              style: TextStyle(
                                                fontFamily: "DMSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: screenWidth > 600 ? 14 : 12.36,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromRGBO(5, 11, 32, 1),
                                                  foregroundColor: Color.fromRGBO(255, 255, 255, 1),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: screenWidth > 600 ? 20 : 15,
                                                    vertical: screenWidth > 600 ? 18 : 15,
                                                  ),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Get Started",
                                                      style: TextStyle(
                                                        fontSize: screenWidth > 600 ? 14 : 11.36,
                                                        fontWeight: FontWeight.w500,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Icon(Icons.arrow_outward_sharp, size: screenWidth > 600 ? 24 : 20),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 50),
                                              Image.asset(
                                                "assets/Home_Images/Footer_Images/carFinance.png",
                                                height: screenWidth > 600 ? 100 : 80,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                                                    
                              const SizedBox(height: 30),
                            ]
                          );
                        }
                        ),
                        ]
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}