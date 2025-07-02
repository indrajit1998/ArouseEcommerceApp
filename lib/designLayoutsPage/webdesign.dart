import 'package:arouse_automotive_day1/components_screen/compare_cars/twoCarsCompare_Web.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/ViewCarDetails/EMISemiCircleChart/emiSemiCircleChart.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/ViewCarDetails/viewCarDetails.dart';
// import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/Web_WebViewWidgetPage/Web_WebView_Page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/vechicleInfo_api.dart';

final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:7500/api';

class Webdesign extends StatefulWidget {
  const Webdesign({super.key});

  @override
  State<Webdesign> createState() => _WebdesignState();
}

class _WebdesignState extends State<Webdesign> {

  bool _showNewContent = false;
  

  int isSelectedIndex = 0;
  bool isLoadingReviews = true;
  String? errorMessageReviews;

  final List<Map<String, dynamic>> carData = [
    {"make": "Kia", "model": "Seltos", "price": 1500000, "specifications": "SUV"},
    {"make": "Hyundai Grand i10 NIOS", "model": "Creta", "price": 37000000, "specifications": "SUV"},
    {"make": "Ford", "model": "Ecosport", "price": 1400000, "specifications": "Compact SUV"},
    {"make": "Porsche 718 Cayman", "model": "718 Spyder", "price": 40700000, "specifications": "Convertible, 4.0L Flat-6, Manual/PDK"},
    {"make": "Audi TT RS", "model": "TT RS", "price": 7200000, "specifications": "Coupe, 2.5L Turbo, 7-Speed S tronic"},
    {"make": "BMW 6 Series Gran Coupe", "model": "6 Series Gran Coupe", "price": 6900000, "specifications": "Sedan, Inline-6/V8, Auto/Manual"},
    {"make": "Volkswagen Tiguan", "model": "Tiguan R-Line", "price": 3500000, "specifications": "SUV, 2.0L TSI, DSG/Manual"},
    {"make": "Toyota Tacoma TRD", "model": "Tacoma TRD Off-Road", "price": 3800000, "specifications": "Pickup, Inline-4/V6, Auto/Manual"},
    {"make": "Sedan Mercedes-Benz", "model": "Mercedes-Benz E-Class", "price": 3800000, "specifications": "Sedan, Inline-4/Inline-6, 9G-TRONIC 9-speed automatic"},
  ];

  List<Map<String, dynamic>> filteredCars= [];

  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  void _onChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _suggestions = [];
      } else {
        _suggestions = carData.where((car) {
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
  }

  final ApiService apiService = ApiService();

  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    fetchCars();
    getReviews();
    fetchBlogs();
    fetchBrands();
    _performBookings();
    filteredCars = carData;
  }

  Widget buildBulletPoint(String text, {double? fontSize}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      leading: Icon(Icons.check_circle, color: Color.fromRGBO(5, 11, 32, 1), size: screenWidth * 0.009, ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? screenWidth * 0.008,
          fontFamily: "DMSans",
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget buildStatBox(String number, String label, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double verticalPadding, horizontalPadding, numberFontSize, labelFontSize, boxWidth;
    if (isMobile) {
      verticalPadding = 16;
      horizontalPadding = 5;
      numberFontSize = 18;
      labelFontSize = 10;
      boxWidth = (screenWidth / 3) - 24;
    } else if (isTablet) {
      verticalPadding = 24;
      horizontalPadding = 16;
      numberFontSize = 24;
      labelFontSize = 14;
      boxWidth = (screenWidth / 3) - 32;
    } else {
      verticalPadding = 32;
      horizontalPadding = 30;
      numberFontSize = 32;
      labelFontSize = 16;
      boxWidth = (screenWidth / 4) - 60;
    }

    return Container(
      width: boxWidth,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.w700,
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
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

  List<Map<String, dynamic>> brands = [];
  bool isLoadingBrands = true;
  String? errorMessageBrands;

  Future<void> fetchBrands() async {
    try{
      final response = await http.get(
        Uri.parse("$apiUrl/brands/getAllBrands"),
        headers: {
          "Content-Type": "application/json"
        }
      );

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        if (data['success'] && data['brands'] != null) {
          setState(() {
            brands = List<Map<String, dynamic>>.from(data['brands']);
            isLoadingBrands = false;
          });
        } else {
          setState(() {
            errorMessageBrands = data['message'] ?? 'No brands found';
            isLoadingBrands = false;
          });
        }
      } else {
        setState(() {
          errorMessageBrands = 'Failed to load brands: ${response.statusCode}';
          isLoadingBrands = false;
        });
      }
    } catch (e) {
      print("Error fetching brands: $e");
    }
  }
  
  
  final CarouselSliderController reviewCarouselController = CarouselSliderController();
  int reviewCurrentPage = 0;

  List <Map<String, dynamic>> reviews = [];
  int totalReviews = 0;

  Future<void> getReviews() async {
    try{
      final response = await http.get(
        Uri.parse("$apiUrl/reviews/getHighRatedReviews"),
        headers: {
          "Content-Type": "application/json"
        }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['reviews'] != null) {
          setState(() {
            reviews = List<Map<String, dynamic>>.from(data['reviews']);
            totalReviews = data['totalReviews'] ?? 0;
            isLoadingReviews = false;
          });
        } else {
          setState(() {
            errorMessageReviews = data['message'] ?? 'No high-rated reviews found';
            isLoadingReviews = false;
          });
        }
      } else {
        setState(() {
          errorMessageReviews = 'Failed to load reviews: ${response.statusCode}';
          isLoadingReviews = false;
        });
      }
    } catch (e) {
      print("Error fetching reviews: $e");
      setState(() {
        errorMessageReviews = 'Error fetching reviews: $e';
        isLoadingReviews = false;
      });
    }
  }

  double calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double totalRating = reviews.fold(0, (sum, review) => sum + (review["rating"] ?? 0));
    return totalRating / reviews.length;
  }
  
  // final List<Map<String, String>> reviews = [
  //   {
  //     "name": "Ali TUFAN",
  //     "designation": "Designer",
  //     "image": "assets/Web_Images/Customer_Says/Customer1.jpeg",
  //     "review":
  //         "I'd suggest Macklin Motors Nissan Glasgow South to a friend \nbecause I had great service from my salesman Patrick and all of \nthe team."
  //   },
  //   {
  //     "name": "Ali TUFAN",
  //     "designation": "Designer",
  //     "image": "assets/Web_Images/Customer_Says/Customer1.jpeg",
  //     "review":
  //         "I'd suggest Macklin Motors Nissan Glasgow South to a friend \nbecause I had great service from my salesman Patrick and all of \nthe team."
  //   },
  //   {
  //     "name": "Ali TUFAN",
  //     "designation": "Designer",
  //     "image": "assets/Web_Images/Customer_Says/Customer1.jpeg",
  //     "review":
  //         "I'd suggest Macklin Motors Nissan Glasgow South to a friend \nbecause I had great service from my salesman Patrick and all of \nthe team."
  //   },
    
  // ];

  List <Map<String, dynamic>> blogs = [];

  Future<void> fetchBlogs() async {
    try{
      final response = await http.get(
        Uri.parse("$apiUrl/blogs/getAllBlogs"),
        headers: {
          "Content-Type": "application/json"
        }
      );

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        print('[fetchBlogs] Response data: $data');
        if (data['success'] && data['blogs'] != null) {
          setState(() {
            blogs = List<Map<String, dynamic>>.from(data['blogs']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'No blogs found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load blogs: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching blogs: $e");
      setState(() {
        errorMessage = 'Error fetching blogs: $e';
        isLoading = false;
      });
    }
  }


  // final List<Map<String, String>> blogs = [
  //   {
  //     "name" : "Sound",
  //     "position" : "Admin",
  //     "date" : "November 22, \n2023",
  //     "image" : "assets/Home_Images/Blog_cars/blogCar1.jpeg",
  //     "description" : "2024 BMW ALPINA XB7 with exclusive details, extraordinary",
  //   },
  //   {
  //     "name" : "Accessories",
  //     "position" : "Admin",
  //     "date" : "November 22, \n2023",
  //     "image" : "assets/Home_Images/Blog_cars/blogCar2.jpeg",
  //     "description" : "BMW X6 M50i is designed to exceed your sportiest.",
  //   },
  //   {
  //     "name" : "Exterior",
  //     "position" : "Admin",
  //     "date" : "November 22, \n2023",
  //     "image" : "assets/Home_Images/Blog_cars/blogCar3.jpeg",
  //     "description" : "BMW X5 Gold 2024 Sport Review: Light on Sport",
  //   },
  // ];

  final CarouselSliderController innerCarouselController = CarouselSliderController();
  int innerCurrentPage = 0;
  int index = 0;

  List<Map<String, dynamic>> cars = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchCars() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/carData/getAll'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication token if required by the backend
          // 'Authorization': 'Bearer <your-token-here>',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['cars'] != null) {
          setState(() {
            cars = List<Map<String, dynamic>>.from(data['cars']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'No cars found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load cars: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching cars: $e';
        isLoading = false;
      });
    }
  }

  // final List<Map<String, String>> cars = [
  //   {
  //     "name" : "E 200",
  //     "image" : "assets/blackCar.png",
  //     "viewImage" : "assets/degrees.png",
  //     "compareImage" : "assets/compare.png",
  //     "compareText" : "Add to compare",
  //     "moreDetails1" : "Starting at",
  //     "details1": "Rs. 3.07 Crore",
  //     "details12" : "onwards On-Road",
  //     "details13" : "Price, Mumbai",
  //     "moreDetails2" : "Engine Options",
  //     "dieselImage" : "assets/diesel.webp",
  //     "details2" : "Diesel",
  //     "moreDetails3" : "Transmission",
  //     "moreDetails31" : "Available",
  //     "manualImage" : "assets/manuel.png",
  //     "details3" : "Manual",
  //     "button1" : "Learn More",
  //     "button2" : "Book a Test Drive",
  //   },
  //   {
  //     "name" : "E 200",
  //     "image" : "assets/whiteCar.png",
  //     "viewImage" : "assets/degrees.png",
  //     "compareImage" : "assets/compare.png",
  //     "compareText" : "Add to compare",
  //     "moreDetails1" : "Starting at",
  //     "details1": "Rs. 3.07 Crore",
  //     "details12" : "onwards On-Road",
  //     "details13" : "Price, Mumbai",
  //     "moreDetails2" : "Engine Options",
  //     "dieselImage" : "assets/diesel.webp",
  //     "details2" : "Diesel",
  //     "moreDetails3" : "Transmission",
  //     "moreDetails31" : "Available",
  //     "manualImage" : "assets/manuel.png",
  //     "details3" : "Manual",
  //     "button1" : "Learn More",
  //     "button2" : "Book a Test Drive",
  //   },
  //   {
  //     "name" : "E 200",
  //     "image" : "assets/redCar.png",
  //     "viewImage" : "assets/degrees.png",
  //     "compareImage" : "assets/compare.png",
  //     "compareText" : "Add to compare",
  //     "moreDetails1" : "Starting at",
  //     "details1": "Rs. 3.07 Crore",
  //     "details12" : "onwards On-Road",
  //     "details13" : "Price, Mumbai",
  //     "moreDetails2" : "Engine Options",
  //     "dieselImage" : "assets/diesel.webp",
  //     "details2" : "Diesel",
  //     "moreDetails3" : "Transmission",
  //     "moreDetails31" : "Available",
  //     "manualImage" : "assets/manuel.png",
  //     "details3" : "Manual",
  //     "button1" : "Learn More",
  //     "button2" : "Book a Test Drive",
  //   },

  // ];

  String selectedCountryCode = '+91';
  final List<String> countryCodes = ['+91', '+1', '+44', '+81', '+86'];
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    phoneController.dispose();
    _dateController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _testDriveDateController.dispose();
    _testDriveTimeController.dispose();
    _phoneNumberController.dispose();
    _alternatePhoneNumberController.dispose();
    _emailController.dispose();
    _drivingLicenseController.dispose();
    super.dispose();
  }
  
  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isDesktop = screenWidth >= 1024;

        // Responsive dialog size
        double dialogWidth = isDesktop
            ? 500
            : isTablet
                ? screenWidth * 0.7
                : screenWidth * 0.99;
        double dialogHeight = isDesktop
            ? 375
            : isTablet
                ? screenHeight * 0.7
                : screenHeight * 0.65;

        return DefaultTabController(
          length: 2,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16.0),
              width: dialogWidth,
              height: dialogHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    labelColor: Color.fromRGBO(0, 76, 144, 1),
                    labelStyle: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: "DMSans",
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: "DMSans",
                    ),
                    unselectedLabelColor: Color.fromRGBO(189, 189, 189, 1),
                    indicatorColor: Color.fromRGBO(0, 76, 144, 1),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.zero,
                    indicatorWeight: 2,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2.0, color: Color.fromRGBO(0, 76, 144, 1)),
                      insets: EdgeInsets.zero,
                    ),
                    tabs: [
                      Tab(text: "Login"),
                      Tab(text: "Sign Up"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        LoginScreen(),
                        SignUpScreen(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOtpDialog() {
    Navigator.of(context).pop(); // Close the login dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isDesktop = screenWidth >= 1024;

        double dialogWidth = isDesktop
            ? 400
            : isTablet
                ? screenWidth * 0.7
                : screenWidth * 0.95;
        double dialogHeight = isDesktop
            ? 320
            : isTablet
                ? screenHeight * 0.5
                : screenHeight * 0.45;

        double titleFont = isMobile ? 20 : isTablet ? 24 : 26;
        double descFont = isMobile ? 12 : isTablet ? 13 : 14;
        double otpBox = isMobile ? 40 : isTablet ? 45 : 50;
        double buttonFont = isMobile ? 14 : 16;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16.0),
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(74, 74, 74, 1),
                    fontFamily: "DMSans",
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We have sent you an otp on your given phone number",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descFont,
                    color: Color.fromRGBO(81, 81, 81, 1),
                    fontFamily: "DMSans",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: otpBox,
                      height: otpBox,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(198, 198, 198, 1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Implement resend OTP logic
                    print("Resend OTP");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Didn't receive the OTP? ",
                              style: TextStyle(
                                fontSize: descFont,
                                color: Color.fromRGBO(124, 124, 124, 1),
                                fontFamily: "DMSans",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "Resend",
                              style: TextStyle(
                                fontSize: descFont,
                                color: Color.fromRGBO(0, 76, 144, 1),
                                fontFamily: "DMSans",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showVerificationSuccessDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 76, 144, 1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Verify & Proceed",
                      style: TextStyle(
                        fontSize: buttonFont,
                        color: Color.fromRGBO(255, 249, 255, 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: descFont + 2,
                          color: Color.fromRGBO(81, 81, 81, 1),
                          fontFamily: "DMSans",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget LoginScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double dialogWidth = isDesktop
        ? 400
        : isTablet
            ? screenWidth * 0.7
            : screenWidth * 0.95;
    double titleFont = isMobile ? 20 : isTablet ? 24 : 26;
    double descFont = isMobile ? 12 : isTablet ? 13 : 14;
    double labelFont = isMobile ? 12 : 14;
    double inputFont = isMobile ? 14 : 16;
    double buttonFont = isMobile ? 14 : 16;
    double verticalSpacing = isMobile ? 10 : 20;

    return SizedBox(
      width: dialogWidth,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Phone Number",
              style: TextStyle(
                fontSize: titleFont,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(74, 74, 74, 1),
                fontFamily: "DMSans",
              ),
            ),
            SizedBox(height: verticalSpacing / 2),
            Text(
              "Please enter your phone number to verify your identity",
              style: TextStyle(
                fontSize: descFont,
                color: Color.fromRGBO(81, 81, 81, 1),
                fontFamily: "DMSans",
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: verticalSpacing),
            Text(
              "Phone Number*",
              style: TextStyle(
                fontSize: labelFont,
                color: Color.fromRGBO(26, 76, 142, 1),
                fontFamily: "DMSans",
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: verticalSpacing / 2),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromRGBO(198, 198, 198, 1)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromRGBO(198, 198, 198, 1)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCountryCode,
                            items: countryCodes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: inputFont)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCountryCode = newValue!;
                              });
                            },
                            style: TextStyle(
                              color: Color.fromRGBO(31, 31, 31, 1),
                              fontSize: inputFont,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Enter your Phone Number",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(31, 31, 31, 0.43),
                        fontSize: inputFont,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isMobile ? 6 : 8,
                        horizontal: isMobile ? 8 : 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: verticalSpacing + 5),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showOtpDialog, // Trigger OTP dialog on Next click
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 76, 144, 1),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: buttonFont,
                    color: Color.fromRGBO(255, 249, 255, 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing / 2),
          ],
        ),
      ),
    );
  }

  void _showOtpDialog1() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isDesktop = screenWidth >= 1024;

        double dialogWidth = isDesktop
            ? 400
            : isTablet
                ? screenWidth * 0.7
                : screenWidth * 0.95;
        double dialogHeight = isDesktop
            ? 320
            : isTablet
                ? screenHeight * 0.5
                : screenHeight * 0.45;

        double titleFont = isMobile ? 20 : isTablet ? 24 : 26;
        double descFont = isMobile ? 12 : isTablet ? 13 : 14;
        double otpBox = isMobile ? 40 : isTablet ? 45 : 50;
        double buttonFont = isMobile ? 14 : 16;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16.0),
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(74, 74, 74, 1),
                    fontFamily: "DMSans",
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We have sent you an otp on your given phone number",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descFont,
                    color: Color.fromRGBO(81, 81, 81, 1),
                    fontFamily: "DMSans",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: otpBox,
                      height: otpBox,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(198, 198, 198, 1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    print("Resend OTP");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Didn't receive the OTP? ",
                              style: TextStyle(
                                fontSize: descFont,
                                color: Color.fromRGBO(124, 124, 124, 1),
                                fontFamily: "DMSans",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "Resend",
                              style: TextStyle(
                                fontSize: descFont,
                                color: Color.fromRGBO(0, 76, 144, 1),
                                fontFamily: "DMSans",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showVerificationSuccessDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 76, 144, 1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Verify & Proceed",
                      style: TextStyle(
                        fontSize: buttonFont,
                        color: Color.fromRGBO(255, 249, 255, 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: descFont + 2,
                          color: Color.fromRGBO(81, 81, 81, 1),
                          fontFamily: "DMSans",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget SignUpScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double dialogWidth = isDesktop
        ? 500
        : isTablet
            ? screenWidth * 0.7
            : screenWidth * 1;
    double titleFont = isMobile ? 20 : isTablet ? 24 : 26;
    double descFont = isMobile ? 12 : isTablet ? 13 : 14;
    double labelFont = isMobile ? 12 : 14;
    double inputFont = isMobile ? 14 : 16;
    double buttonFont = isMobile ? 14 : 16;
    double verticalSpacing = isMobile ? 10 : 20;

    return SizedBox(
      width: dialogWidth,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your details",
                style: TextStyle(
                  fontSize: titleFont,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(74, 74, 74, 1),
                  fontFamily: "DMSans",
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              Text(
                "Please enter your phone number to verify your identity",
                style: TextStyle(
                  fontSize: descFont,
                  color: Color.fromRGBO(81, 81, 81, 1),
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                "Full Name*",
                style: TextStyle(
                  fontSize: labelFont,
                  color: Color.fromRGBO(26, 76, 142, 1),
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              TextField(
                decoration: InputDecoration(
                  hintText: "Gaurish Banga",
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(31, 31, 31, 0.43),
                    fontSize: inputFont,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(198, 198, 198, 1),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMobile ? 8 : 12,
                    horizontal: isMobile ? 8 : 12,
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                "Email",
                style: TextStyle(
                  fontSize: labelFont,
                  color: Color.fromRGBO(26, 76, 142, 1),
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your Email Address",
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(31, 31, 31, 0.43),
                    fontSize: inputFont,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(198, 198, 198, 1),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMobile ? 8 : 12,
                    horizontal: isMobile ? 8 : 12,
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                "Phone Number*",
                style: TextStyle(
                  fontSize: labelFont,
                  color: Color.fromRGBO(26, 76, 142, 1),
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              Row(
                children: [
                  Container(
                    width: isMobile ? 75 : 100,
                    height: isMobile ? 40 : 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromRGBO(198, 198, 198, 1)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCountryCode,
                        isExpanded: true,
                        items: countryCodes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(value, style: TextStyle(fontSize: inputFont)),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        style: TextStyle(
                          color: Color.fromRGBO(31, 31, 31, 1),
                          fontSize: inputFont,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 6 : 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter your Phone Number",
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(31, 31, 31, 0.43),
                          fontSize: inputFont,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(198, 198, 198, 1),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 12,
                          horizontal: isMobile ? 8 : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing + 5),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showOtpDialog1,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 76, 144, 1),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: buttonFont,
                      color: Color.fromRGBO(255, 249, 255, 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerificationSuccessDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double dialogWidth = isDesktop
        ? 400
        : isTablet
            ? screenWidth * 0.7
            : screenWidth * 0.95;
    double dialogHeight = isDesktop
        ? 330
        : isTablet
            ? screenHeight * 0.45
            : screenHeight * 0.38;

    double titleFont = isMobile ? 16 : isTablet ? 18 : 20;
    double descFont = isMobile ? 11 : isTablet ? 13 : 14;
    double iconSize = isMobile ? 32 : isTablet ? 36 : 40;
    double padding = isMobile ? 10 : 15;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            padding: EdgeInsets.all(padding),
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color.fromRGBO(189, 189, 189, 1)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(height: isMobile ? 5 : 10),
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 20),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 76, 144, 1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(height: isMobile ? 18 : 30),
                Text(
                  "Thank you for sign up with Arouse Automotive",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(74, 74, 74, 1),
                    fontFamily: "DMSans",
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 10),
                Text(
                  "Please Verify your Email Address and Login Again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descFont,
                    color: Color.fromRGBO(81, 81, 81, 1),
                    fontFamily: "DMSans",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 20),
              ],
            ),
          ),
        );
      },
    );
  }


  final _formKey = GlobalKey<FormState>();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _testDriveDateController = TextEditingController();
  final _testDriveTimeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternatePhoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _drivingLicenseController = TextEditingController();

  Future<bool> _performBookings() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/book-test-drive'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'state': _stateController.text,
            'city': _cityController.text,
            'address': _addressController.text,
            'brand': _brandController.text,
            'model': _modelController.text,
            'testDriveDate': _testDriveDateController.text,
            'testDriveTime': _testDriveTimeController.text,
            'name': _nameController.text,
            'phoneNumber': '$selectedCountryCode${_phoneNumberController.text}',
            'alternatePhoneNumber': _alternatePhoneNumberController.text.isNotEmpty ? '$selectedCountryCode${_alternatePhoneNumberController.text}' : null,
            'email': _emailController.text,
            'drivingLicense': _drivingLicenseController.text,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking successful.'), backgroundColor: Colors.green,),
          );
          return true;
        } else {
          print('Booking failed: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed. Please try again.'), backgroundColor: Colors.red,),
          );
          return false;
        }
      } catch (e) {
        print('Error during booking: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.'), backgroundColor: Colors.red,),
        );
        return false;
      }
    }
    return false;
  }

  void _clearForm() {
    _stateController.clear();
    _cityController.clear();
    _addressController.clear();
    _brandController.clear();
    _modelController.clear();
    _testDriveDateController.clear();
    _testDriveTimeController.clear();
    _nameController.clear();
    _phoneNumberController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _drivingLicenseController.clear();
    setState(() {
    });
    _formKey.currentState?.reset();
  }

Future<void> _bookTestDrive() {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final isMobile = screenWidth < 600;
      final isTablet = screenWidth >= 600 && screenWidth < 1024;
      final isDesktop = screenWidth >= 1024;

      double dialogWidth = isDesktop
          ? screenWidth * 0.9
          : isTablet
              ? screenWidth * 0.9
              : screenWidth * 0.98;
      double dialogHeight = isDesktop
          ? screenHeight * 0.85
          : isTablet
              ? screenHeight * 0.95
              : screenHeight * 0.98;
      double alertWidth = isDesktop
          ? dialogWidth * 0.5
          : isTablet
              ? dialogWidth * 0.8
              : dialogWidth * 0.98;

      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/Web_Images/BookAtestDriveDialogue/dialogue_background.jpeg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Form(
                        key: _formKey,
                        child: AlertDialog(
                          contentPadding: const EdgeInsets.all(16),
                          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          title: SizedBox(
                            width: alertWidth,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Test Drive",
                                      style: TextStyle(
                                        color: Color.fromRGBO(0, 76, 144, 1),
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 16 : 20,
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        height: 2,
                                        margin: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              color: const Color.fromRGBO(0, 76, 144, 1),
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Color.fromRGBO(189, 189, 189, 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.015),
                                    Text(
                                      "Book a Test Drive",
                                      style: TextStyle(
                                        fontSize: isMobile ? 18 : 26,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "DMSans",
                                        color: Color.fromRGBO(74, 74, 74, 1),
                                      ),
                                    ),
                                    Text(
                                      "Please enter your details to schedule a test drive",
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Color.fromRGBO(81, 81, 81, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: Color.fromRGBO(0, 76, 144, 1),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: alertWidth,
                              ),
                              child: isMobile
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildDropdownField(
                                          label: "State",
                                          hint: "Select your State",
                                          items: [
                                            "Andhra Pradesh",
                                            "Telangana",
                                            "Delhi",
                                            "Maharashtra",
                                            "Uttar Pradesh",
                                            "Punjab",
                                            "Rajasthan",
                                            "Kerala",
                                            "Tamil Nadu",
                                            "Karnataka"
                                          ],
                                          controller: _stateController,
                                        ),
                                        _buildDropdownField(
                                          label: "City",
                                          hint: "Select your city",
                                          items: [
                                            "Tirupati",
                                            "Hyderabad",
                                            "Bangalore",
                                            "Delhi",
                                            "Mumbai",
                                            "Lucknow",
                                            "Chandigarh",
                                            "Jaipur",
                                            "Kochi",
                                            "Chennai"
                                          ],
                                          controller: _cityController,
                                        ),
                                        _buildTextField(
                                          label: "Address",
                                          hint: "Enter the full Address",
                                          controller: _addressController,
                                        ),
                                        _buildDropdownField(
                                          label: "Brand",
                                          hint: "Select your Brand",
                                          items: [
                                            "Tata",
                                            "Mahindra",
                                            "Honda",
                                            "Toyota",
                                            "Hyundai",
                                            "Nissan",
                                            "Kia",
                                            "Ford",
                                            "Volkswagen",
                                            "Skoda"
                                          ],
                                          controller: _brandController,
                                        ),
                                        _buildDropdownField(
                                          label: "Model",
                                          hint: "Select your Model",
                                          items: [
                                            "Tata Curvv",
                                            "Tata Zest",
                                            "Hyundai Creta",
                                            "Honda City",
                                            "Toyota Innova",
                                            "Mahindra Thar",
                                            "Kia Seltos",
                                            "Nissan Magnite",
                                            "Ford EcoSport",
                                            "Volkswagen Taigun"
                                          ],
                                          controller: _modelController,
                                        ),
                                        _buildDateField(
                                          label: "Test Drive Date Selection",
                                          hint: "Select your Date",
                                          suffixIcon: const Icon(
                                            Icons.calendar_month,
                                            color: Color.fromRGBO(0, 76, 144, 1),
                                          ),
                                          controller: _testDriveDateController,
                                        ),
                                        _buildDropdownField(
                                          label: "Select Time Slot",
                                          hint: "Select your time slot",
                                          items: [
                                            "10AM - 11AM",
                                            "11AM - 12PM",
                                            "12PM - 1PM",
                                            "1PM - 2PM",
                                            "2PM - 3PM",
                                            "3PM - 4PM",
                                            "4PM - 5PM"
                                          ],
                                          controller: _testDriveTimeController,
                                        ),
                                        _buildTextField(
                                          label: "Name",
                                          hint: "Enter your Name",
                                          controller: _nameController,
                                        ),
                                        _buildPhoneField(
                                          label: "Phone Number*",
                                          hint: "Enter your Phone Number",
                                          controller: _phoneNumberController,
                                        ),
                                        _buildPhoneField(
                                          label: "Alternate Phone Number",
                                          hint: "Enter your Phone Number",
                                          controller: _alternatePhoneNumberController,
                                        ),
                                        _buildTextField(
                                          label: "Email Address",
                                          hint: "Enter your email address",
                                          controller: _emailController,
                                        ),
                                        _buildDropdownField(
                                          label: "Do you have a driving License?",
                                          hint: "Yes or No",
                                          items: ["Yes", "No"],
                                          controller: _drivingLicenseController,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDropdownField(
                                                label: "State",
                                                hint: "Select your State",
                                                items: [
                                                  "Andhra Pradesh",
                                                  "Telangana",
                                                  "Delhi",
                                                  "Maharashtra",
                                                  "Uttar Pradesh",
                                                  "Punjab",
                                                  "Rajasthan",
                                                  "Kerala",
                                                  "Tamil Nadu",
                                                  "Karnataka"
                                                ],
                                                controller: _stateController,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDropdownField(
                                                label: "City",
                                                hint: "Select your city",
                                                items: [
                                                  "Tirupati",
                                                  "Hyderabad",
                                                  "Bangalore",
                                                  "Delhi",
                                                  "Mumbai",
                                                  "Lucknow",
                                                  "Chandigarh",
                                                  "Jaipur",
                                                  "Kochi",
                                                  "Chennai"
                                                ],
                                                controller: _cityController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildTextField(
                                          label: "Address",
                                          hint: "Enter the full Address",
                                          controller: _addressController,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDropdownField(
                                                label: "Brand",
                                                hint: "Select your Brand",
                                                items: [
                                                  "Tata",
                                                  "Mahindra",
                                                  "Honda",
                                                  "Toyota",
                                                  "Hyundai",
                                                  "Nissan",
                                                  "Kia",
                                                  "Ford",
                                                  "Volkswagen",
                                                  "Skoda"
                                                ],
                                                controller: _brandController,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDropdownField(
                                                label: "Model",
                                                hint: "Select your Model",
                                                items: [
                                                  "Tata Curvv",
                                                  "Tata Zest",
                                                  "Hyundai Creta",
                                                  "Honda City",
                                                  "Toyota Innova",
                                                  "Mahindra Thar",
                                                  "Kia Seltos",
                                                  "Nissan Magnite",
                                                  "Ford EcoSport",
                                                  "Volkswagen Taigun"
                                                ],
                                                controller: _modelController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDateField(
                                                label: "Test Drive Date Selection",
                                                hint: "Select your Date",
                                                suffixIcon: const Icon(
                                                  Icons.calendar_month,
                                                  color: Color.fromRGBO(0, 76, 144, 1),
                                                ),
                                                controller: _testDriveDateController,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDropdownField(
                                                label: "Select Time Slot",
                                                hint: "Select your time slot",
                                                items: [
                                                  "10AM - 11AM",
                                                  "11AM - 12PM",
                                                  "12PM - 1PM",
                                                  "1PM - 2PM",
                                                  "2PM - 3PM",
                                                  "3PM - 4PM",
                                                  "4PM - 5PM"
                                                ],
                                                controller: _testDriveTimeController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                label: "Name",
                                                hint: "Enter your Name",
                                                controller: _nameController,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: _buildPhoneField(
                                                label: "Phone Number*",
                                                hint: "Enter your Phone Number",
                                                controller: _phoneNumberController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildPhoneField(
                                          label: "Alternate Phone Number",
                                          hint: "Enter your Phone Number",
                                          controller: _alternatePhoneNumberController,
                                        ),
                                        _buildTextField(
                                          label: "Email Address",
                                          hint: "Enter your email address",
                                          controller: _emailController,
                                        ),
                                        _buildDropdownField(
                                          label: "Do you have a driving License?",
                                          hint: "Yes or No",
                                          items: ["Yes", "No"],
                                          controller: _drivingLicenseController,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          actions: [
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF004C90),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () async {
                                  bool isBookingSuccessful = await _performBookings();
                                  if (isBookingSuccessful) {
                                    _clearForm();
                                    Navigator.of(context).pop(); // Close the booking dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  icon: Icon(Icons.close, color: Colors.grey),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF004C90),
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    left: 20,
                                                    child: Icon(Icons.star,
                                                        size: 10, color: Color(0xFF004C90)),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: Icon(Icons.star,
                                                        size: 8, color: Color(0xFF004C90)),
                                                  ),
                                                  Positioned(
                                                    bottom: 10,
                                                    left: 10,
                                                    child: Icon(Icons.star,
                                                        size: 8, color: Color(0xFF004C90)),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 20,
                                                    child: Icon(Icons.star,
                                                        size: 10, color: Color(0xFF004C90)),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                "Thank you for booking your test\ndrive with Arouse Automotive",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Our Executive will call you for the confirmation",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromRGBO(143, 143, 143, 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  icon: Icon(Icons.close,
                                                      color: Color.fromRGBO(158, 158, 158, 1)),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color.fromRGBO(177, 25, 0, 1),
                                                    ),
                                                    child: Icon(
                                                      Icons.priority_high,
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    left: 20,
                                                    child: Icon(Icons.star,
                                                        size: 10, color: Color.fromRGBO(177, 25, 0, 1)),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: Icon(Icons.star,
                                                        size: 8, color: Color.fromRGBO(177, 25, 0, 1)),
                                                  ),
                                                  Positioned(
                                                    bottom: 10,
                                                    left: 10,
                                                    child: Icon(Icons.star,
                                                        size: 8, color: Color.fromRGBO(177, 25, 0, 1)),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 20,
                                                    child: Icon(Icons.star,
                                                        size: 10, color: Color.fromRGBO(177, 25, 0, 1)),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                "Oops! This vehicle is not available \nwith us for the test Drive",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Please try another vehicle, we will reach out to you if this \nvehicle is available with us in future.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromRGBO(143, 143, 143, 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 249, 255, 1),
                                    fontSize: isMobile ? 14 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

final TextEditingController _carPriceController =
      TextEditingController(text: '1879000');
  final TextEditingController _downPaymentController =
      TextEditingController(text: '500000');

  double _displayEMI = 60000;
  String _displayTenure = '5 Year';

  double _principal = 0;
  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayable = 0;
  String _selectedTenure = '5 YEARS';
  String _selectedInterestRate = '8%';
  final List<String> _tenureOptions = ['1 YEAR', '3 YEARS', '5 YEARS', '7 YEARS', '11 YEARS'];
  final List<String> _interestRateOptions = ['3%', '5%', '7%', '8%', '9%', '11%'];


void _calculatePrincipal() {
    double carPrice =
        double.tryParse(_carPriceController.text.replaceAll(',', '')) ?? 0;
    double downPayment =
        double.tryParse(_downPaymentController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _principal = carPrice - downPayment;
      _calculateEMI();
    });
  }

  void _calculateEMI() {
    double principal = _principal;
    double annualInterestRate =
        double.parse(_selectedInterestRate.replaceAll('%', '')) / 100;
    double monthlyInterestRate = annualInterestRate / 12;
    int tenureInYears = int.parse(_selectedTenure.split(' ')[0]);
    int tenureInMonths = tenureInYears * 12;

    if (principal > 0 && monthlyInterestRate > 0 && tenureInMonths > 0) {
      _emi = (principal *
              monthlyInterestRate * math.pow(1 + monthlyInterestRate, tenureInMonths)) /
          (math.pow(1 + monthlyInterestRate, tenureInMonths) - 1);
      _totalPayable = _emi * tenureInMonths;
      _totalInterest = _totalPayable - principal;
    } else {
      _emi = 0;
      _totalInterest = 0;
      _totalPayable = 0;
    }
    setState(() {
      _emi = _emi;
        _totalPayable = _totalPayable;
        _totalInterest = _totalInterest;
        _displayEMI = _emi;
        _displayTenure = _selectedTenure;
    });
  }

  void showEMICalculatorDialog({
    required BuildContext context,
    required TextEditingController carPriceController,
    required TextEditingController downPaymentController,
    required String selectedTenure,
    required List<String> tenureOptions,
    required String selectedInterestRate,
    required List<String> interestRateOptions,
    required double principal,
    required double emi,
    required double totalInterest,
    required double totalPayable,
    required VoidCallback calculatePrincipal,
    required VoidCallback calculateEMI,
    required double screenWidth,
    required double screenHeight,
  }) {
    showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Center(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              width: screenHeight * 1.2,
                                                              child: Dialog(
                                                                backgroundColor: Colors.white,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                            'Choose your EMI Options',
                                                                            style: TextStyle(
                                                                              fontSize: 26, 
                                                                              fontWeight: FontWeight.w700,
                                                                              color: Color.fromRGBO(74, 74, 74, 1),
                                                                              fontFamily: "DMSans",
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: (){
                                                                              Navigator.pop(context);
                                                                            },
                                                                            icon: Icon(
                                                                              Icons.close, 
                                                                              color: Color.fromRGBO(0, 0, 0, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 8),
                                                                      const Text(
                                                                        'Standard EMI',
                                                                        style: TextStyle(
                                                                          fontSize: 20, 
                                                                          fontWeight: FontWeight.w600,
                                                                          fontFamily: "DMSans",
                                                                          color: Color.fromRGBO(109, 109, 109, 1),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 8),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 100,
                                                                            height: 2,
                                                                            color: Color.fromRGBO(0, 76, 144, 1),
                                                                          ),
                                                                          Expanded(
                                                                            child: Container(
                                                                              height: 2,
                                                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 16),
                                                              
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          
                                                                          Expanded(
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                
                                                                                const Text(
                                                                                  'Enter Estimated Price of the Car', 
                                                                                  style: TextStyle(
                                                                                    fontSize: 14, 
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromRGBO(26, 76, 142, 1),
                                                                                    fontFamily: "Inter",
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                TextField(
                                                                                  controller: _carPriceController,
                                                                                  keyboardType: TextInputType.number,
                                                                                  decoration: InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Rs. 18,79,000',
                                                                                    prefixText: 'Rs. ',
                                                                                  ),
                                                                                  onChanged: (value) {
                                                                                    _calculatePrincipal();
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                const Text(
                                                                                  'Enter Down Payement',
                                                                                  style: TextStyle(
                                                                                      fontSize: 14, 
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color.fromRGBO(26, 76, 142, 1),
                                                                                      fontFamily: "Inter",
                                                                                    ),
                                                                                  ),
                                                                                const SizedBox(height: 8),
                                                                                TextField(
                                                                                  controller: _downPaymentController,
                                                                                  keyboardType: TextInputType.number,
                                                                                  decoration: const InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Rs. 5,00,000',
                                                                                    prefixText: 'Rs. ',
                                                                                  ),
                                                                                  onChanged: (value) {
                                                                                    _calculatePrincipal();
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                Text(
                                                                                  'Your loan amount will be Rs. ${_principal == 0 ? '13,79,000' : _principal.toStringAsFixed(0)}',
                                                                                  style: const TextStyle(fontSize: 12),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                const Text(
                                                                                  'Select Tenure',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14, 
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromRGBO(26, 76, 142, 1),
                                                                                    fontFamily: "Inter",
                                                                                  ),  
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                DropdownButton<String>(
                                                                                  isExpanded: true,
                                                                                  value: _selectedTenure,
                                                                                  items: _tenureOptions.map((String value) {
                                                                                    return DropdownMenuItem<String>(
                                                                                      value: value,
                                                                                      child: Text(value),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged: (newValue) {
                                                                                    setState(() {
                                                                                      _selectedTenure = newValue!;
                                                                                      _calculateEMI();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                const Text(
                                                                                  'Select Interest Rate',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14, 
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromRGBO(26, 76, 142, 1),
                                                                                    fontFamily: "Inter",
                                                                                  ),  
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                DropdownButton<String>(
                                                                                  isExpanded: true,
                                                                                  value: _selectedInterestRate,
                                                                                  items: _interestRateOptions.map((String value) {
                                                                                    return DropdownMenuItem<String>(
                                                                                      value: value,
                                                                                      child: Text(value),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged: (newValue) {
                                                                                    setState(() {
                                                                                      _selectedInterestRate = newValue!;
                                                                                      _calculateEMI();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                SizedBox(
                                                                                  width: double.infinity,
                                                                                  child: ElevatedButton(
                                                                                    onPressed: _calculateEMI,
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: Color.fromRGBO(0, 76, 144, 1),
                                                                                      foregroundColor: Colors.white,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(40),
                                                                                      ),
                                                                                    ),
                                                                                    child: const Text('Calculate EMI'),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 20),

                                                                          Container(
                                                                            width: 2,
                                                                            height: 450,
                                                                            color: Color.fromRGBO(189, 189, 189, 1),
                                                                          ),

                                                                          const SizedBox(width: 30,),
                                                                          
                                                                          // Right Section: EMI Results
                                                                          Expanded(
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Rs. ${_emi == 0 ? '60,000' : _emi.toStringAsFixed(0)} EMI FOR ${_selectedTenure.toLowerCase()}',
                                                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),

                                                                                const SizedBox(height: 11),
                                                                                Padding(
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Container(
                                                                                    width: 500,
                                                                                    height: 2,
                                                                                    color: Color.fromRGBO(189, 189, 189, 1),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 7),

                                                                                Container(
                                                                                  color: Color.fromRGBO(248, 249, 251, 1),
                                                                                  child: SizedBox(
                                                                                    height: MediaQuery.of(context).size.width < 600
                                                                                      ? 70 // Mobile height
                                                                                      : MediaQuery.of(context).size.width < 1024
                                                                                          ? 120 // Tablet height
                                                                                          : 180, // Desktop/Web height
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(10),
                                                                                      child: CustomPaint(
                                                                                        painter: EMISemiCircleChart(
                                                                                          principal: _principal,
                                                                                          totalInterest: _totalInterest,
                                                                                        ),
                                                                                        child: const SizedBox.expand(),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                
                                                                                Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      width: 10,
                                                                                      height: 10,
                                                                                      decoration: const BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                        color: Color.fromRGBO(34, 53, 119, 1),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 8),
                                                                                    const Text('Principal Loan Amount'),
                                                                                    const Spacer(),
                                                                                    Text('Rs. ${_principal == 0 ? '18,79,000' : _principal.toStringAsFixed(0)}'),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      width: 10,
                                                                                      height: 10,
                                                                                      decoration: const BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                        color: Color.fromRGBO(39, 153, 227, 1),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 8),
                                                                                    const Text('Total Interest Amount'),
                                                                                    const Spacer(),
                                                                                    Text('Rs. ${_totalInterest == 0 ? '5,00,000' : _totalInterest.toStringAsFixed(0)}'),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                Container(
                                                                                  color: Color.fromRGBO(248, 249, 251, 1),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(10.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        const Text(
                                                                                          'Total Amount Payable',
                                                                                          style: TextStyle(fontFamily: "DMSans",fontWeight: FontWeight.w400, color: Color.fromRGBO(0, 0, 0, 1)),
                                                                                        ),
                                                                                        const Spacer(),
                                                                                        Text(
                                                                                          'Rs. ${_totalPayable == 0 ? '23,79,000' : _totalPayable.toStringAsFixed(0)}',
                                                                                          style: const TextStyle(fontFamily: "Poppins",fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                SizedBox(
                                                                                  width: double.infinity,
                                                                                  child: OutlinedButton(
                                                                                    onPressed: () {},
                                                                                    style: OutlinedButton.styleFrom(
                                                                                      side: const BorderSide(width: 2, color: Color.fromRGBO(0, 76, 144, 1)),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(40),
                                                                                      ),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(5.0),
                                                                                      child: const Text(
                                                                                        'Get EMI Offers',
                                                                                        style: TextStyle(
                                                                                          fontSize: 16,
                                                                                          fontFamily: "DMSans",
                                                                                          color: Color.fromRGBO(0, 76, 144, 1),
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
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
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                );
                                              
  }


Widget _drawerItem(String title, int idx) {
    return ListTile(
      title: Text(title, style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w500)),
      selected: isSelectedIndex == idx,
      onTap: () {
        setState(() {
          isSelectedIndex = idx;
        });
        Navigator.pop(context);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  final bool isMobile = screenWidth < 600;
  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
  bool isWebOrDesktop = screenWidth >= 1024;

  double imageHeight = isWebOrDesktop ? 70 : isTablet ? 30 : screenWidth * 0.075;
  double imageWidth = isWebOrDesktop ? 110 : isTablet ? 80 : screenWidth * 0.075;
  double fontSize = isWebOrDesktop ? 10 : isTablet ? 10 : screenWidth * 0.03 + 4;

  EdgeInsets responsivePadding({double? desktop, double? tablet, double? mobile}) {
    if (isWebOrDesktop) return EdgeInsets.symmetric(horizontal: desktop ?? 100);
    if (isTablet) return EdgeInsets.symmetric(horizontal: tablet ?? 40);
    return EdgeInsets.symmetric(horizontal: mobile ?? 16);
  }

  double responsiveFont(double desktop, double tablet, double mobile) {
    if (isWebOrDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
    ),
    home: DefaultTabController(
      length: 5,
        child: Scaffold(
          appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;
              bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
              bool isDesktop = constraints.maxWidth >= 1024;
              bool showMenu = isMobile || isTablet;

              imageHeight = isMobile ? 30 : isTablet ? 40 : 70;
              imageWidth = isMobile ? 30 : isTablet ? 40 : 70;
              fontSize = isMobile ? 12 : isTablet ? 12 : 12;

              return AppBar(
                backgroundColor: Colors.white,
                elevation: 5,
                toolbarHeight: isMobile ? 90 : 100,
                automaticallyImplyLeading: showMenu,
                leading: showMenu
                    ? Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.menu, color: Color(0xFF004C90), size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      )
                    : null,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: isDesktop

                    ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image.png',
                        height: imageHeight,
                        width: imageWidth,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AROUSE ',
                            style: TextStyle(
                              color: Color(0xFF004C90),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: "DMSans",
                              height: 1.0, 
                            ),
                          ),
                          Text(
                            'AUTOMOTIVE',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: "DMSans",
                              height: 1.0, 
                            ),
                          ),
                        ],
                      ),
                    ],
                  )

                  : Row(
                    children: [
                      Image.asset(
                        'assets/image.png',
                        height: isMobile ? 40 : imageHeight,
                        width: isMobile ? 40 : imageWidth,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AROUSE',
                        style: TextStyle(
                          color: Color(0xFF004C90),
                          fontSize: isMobile ? 15 : fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: "DMSans",
                        ),
                      ),
                      Text(
                        'AUTOMOTIVE',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: "DMSans",
                        ),
                      ),
                    ],
                  ),
                ),


                actions: isDesktop
                    ? [
                        // Home Button
                            TextButton(
                              onPressed: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: isSelectedIndex == 0 ? 2 : 0,
                                      color: isSelectedIndex == 0
                                          ? Color.fromRGBO(26, 76, 142, 1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedIndex = 0;
                                    });
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Webdesign()));
                                  },
                                  child: Text(
                                    "Home",
                                    style: TextStyle(
                                      fontFamily: "DMSans",
                                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelectedIndex == 0 ? Color(0xFF004C90) : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                  
                            // About Us Button
                            TextButton(
                              onPressed: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: isSelectedIndex == 1 ? 2 : 0,
                                      color: isSelectedIndex == 1
                                          ? Color.fromRGBO(26, 76, 142, 1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedIndex = 1;
                                    });
                                  },
                                  child: Text(
                                    "About Us",
                                    style: TextStyle(
                                      fontFamily: "DMSans",
                                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelectedIndex == 1 ? Color(0xFF004C90) : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                  
                            // Book a Test Drive Button
                            TextButton(
                              onPressed: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: isSelectedIndex == 2 ? 2 : 0,
                                      color: isSelectedIndex == 2
                                          ? Color.fromRGBO(26, 76, 142, 1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedIndex = 2;
                                    });
                                    _bookTestDrive();
                                  },
                                  child: Text(
                                    "Book a test Drive",
                                    style: TextStyle(
                                      fontFamily: "DMSans",
                                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelectedIndex == 2 ? Color(0xFF004C90) : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                  
                            // Virtual Showroom Button
                            TextButton(
                              onPressed: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: isSelectedIndex == 3 ? 2 : 0,
                                      color: isSelectedIndex == 3
                                          ? Color.fromRGBO(26, 76, 142, 1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedIndex = 3;
                                    });
                                  },
                                  child: Text(
                                    "Virtual Showroom",
                                    style: TextStyle(
                                      fontFamily: "DMSans",
                                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelectedIndex == 3 ? Color(0xFF004C90) : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                  
                            // Luxury Cars Button
                            TextButton(
                              onPressed: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: isSelectedIndex == 4 ? 2 : 0,
                                      color: isSelectedIndex == 4
                                          ? Color.fromRGBO(26, 76, 142, 1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedIndex = 4;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/Web_Images/AppBar_Images/luxury_stars.png",
                                        height: MediaQuery.of(context).size.width < 600 ? 15 : 20,
                                        width: MediaQuery.of(context).size.width < 600 ? 15 : 20,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Luxury Cars",
                                        style: TextStyle(
                                          fontFamily: "DMSans",
                                          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                          fontWeight: FontWeight.w500,
                                          color: isSelectedIndex == 4 ? Color(0xFF004C90) : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                  
                            // EMI Calculator Button
                            TextButton(
                              onPressed: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: isSelectedIndex == 5 ? 2 : 0,
                                      color: isSelectedIndex == 5
                                          ? Color.fromRGBO(26, 76, 142, 1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedIndex = 5;
                                    });

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Center(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              width: screenHeight * 1.2,
                                                              child: Dialog(
                                                                backgroundColor: Colors.white,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                            'Choose your EMI Options',
                                                                            style: TextStyle(
                                                                              fontSize: 26, 
                                                                              fontWeight: FontWeight.w700,
                                                                              color: Color.fromRGBO(74, 74, 74, 1),
                                                                              fontFamily: "DMSans",
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: (){
                                                                              Navigator.pop(context);
                                                                            },
                                                                            icon: Icon(
                                                                              Icons.close, 
                                                                              color: Color.fromRGBO(0, 0, 0, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 8),
                                                                      const Text(
                                                                        'Standard EMI',
                                                                        style: TextStyle(
                                                                          fontSize: 20, 
                                                                          fontWeight: FontWeight.w600,
                                                                          fontFamily: "DMSans",
                                                                          color: Color.fromRGBO(109, 109, 109, 1),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 8),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 100,
                                                                            height: 2,
                                                                            color: Color.fromRGBO(0, 76, 144, 1),
                                                                          ),
                                                                          Expanded(
                                                                            child: Container(
                                                                              height: 2,
                                                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 16),
                                                              
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          
                                                                          Expanded(
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                
                                                                                const Text(
                                                                                  'Enter Estimated Price of the Car', 
                                                                                  style: TextStyle(
                                                                                    fontSize: 14, 
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromRGBO(26, 76, 142, 1),
                                                                                    fontFamily: "Inter",
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                TextField(
                                                                                  controller: _carPriceController,
                                                                                  keyboardType: TextInputType.number,
                                                                                  decoration: InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Rs. 18,79,000',
                                                                                    prefixText: 'Rs. ',
                                                                                  ),
                                                                                  onChanged: (value) {
                                                                                    _calculatePrincipal();
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                const Text(
                                                                                  'Enter Down Payement',
                                                                                  style: TextStyle(
                                                                                      fontSize: 14, 
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color.fromRGBO(26, 76, 142, 1),
                                                                                      fontFamily: "Inter",
                                                                                    ),
                                                                                  ),
                                                                                const SizedBox(height: 8),
                                                                                TextField(
                                                                                  controller: _downPaymentController,
                                                                                  keyboardType: TextInputType.number,
                                                                                  decoration: const InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Rs. 5,00,000',
                                                                                    prefixText: 'Rs. ',
                                                                                  ),
                                                                                  onChanged: (value) {
                                                                                    _calculatePrincipal();
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                Text(
                                                                                  'Your loan amount will be Rs. ${_principal == 0 ? '13,79,000' : _principal.toStringAsFixed(0)}',
                                                                                  style: const TextStyle(fontSize: 12),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                const Text(
                                                                                  'Select Tenure',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14, 
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromRGBO(26, 76, 142, 1),
                                                                                    fontFamily: "Inter",
                                                                                  ),  
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                DropdownButton<String>(
                                                                                  isExpanded: true,
                                                                                  value: _selectedTenure,
                                                                                  items: _tenureOptions.map((String value) {
                                                                                    return DropdownMenuItem<String>(
                                                                                      value: value,
                                                                                      child: Text(value),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged: (newValue) {
                                                                                    setState(() {
                                                                                      _selectedTenure = newValue!;
                                                                                      _calculateEMI();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                const Text(
                                                                                  'Select Interest Rate',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14, 
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromRGBO(26, 76, 142, 1),
                                                                                    fontFamily: "Inter",
                                                                                  ),  
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                DropdownButton<String>(
                                                                                  isExpanded: true,
                                                                                  value: _selectedInterestRate,
                                                                                  items: _interestRateOptions.map((String value) {
                                                                                    return DropdownMenuItem<String>(
                                                                                      value: value,
                                                                                      child: Text(value),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged: (newValue) {
                                                                                    setState(() {
                                                                                      _selectedInterestRate = newValue!;
                                                                                      _calculateEMI();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                SizedBox(
                                                                                  width: double.infinity,
                                                                                  child: ElevatedButton(
                                                                                    onPressed: _calculateEMI,
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: Color.fromRGBO(0, 76, 144, 1),
                                                                                      foregroundColor: Colors.white,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(40),
                                                                                      ),
                                                                                    ),
                                                                                    child: const Text('Calculate EMI'),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 20),

                                                                          Container(
                                                                            width: 2,
                                                                            height: 450,
                                                                            color: Color.fromRGBO(189, 189, 189, 1),
                                                                          ),

                                                                          const SizedBox(width: 30,),
                                                                          
                                                                          // Right Section: EMI Results
                                                                          Expanded(
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Rs. ${_emi == 0 ? '60,000' : _emi.toStringAsFixed(0)} EMI FOR ${_selectedTenure.toLowerCase()}',
                                                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),

                                                                                const SizedBox(height: 11),
                                                                                Padding(
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Container(
                                                                                    width: 500,
                                                                                    height: 2,
                                                                                    color: Color.fromRGBO(189, 189, 189, 1),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 7),

                                                                                Container(
                                                                                  color: Color.fromRGBO(248, 249, 251, 1),
                                                                                  child: SizedBox(
                                                                                    height: 190,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(10),
                                                                                      child: CustomPaint(
                                                                                        painter: EMISemiCircleChart(
                                                                                          principal: _principal,
                                                                                          totalInterest: _totalInterest,
                                                                                        ),
                                                                                        child: const SizedBox.expand(),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                
                                                                                Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      width: 10,
                                                                                      height: 10,
                                                                                      decoration: const BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                        color: Color.fromRGBO(34, 53, 119, 1),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 8),
                                                                                    const Text('Principal Loan Amount'),
                                                                                    const Spacer(),
                                                                                    Text('Rs. ${_principal == 0 ? '18,79,000' : _principal.toStringAsFixed(0)}'),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      width: 10,
                                                                                      height: 10,
                                                                                      decoration: const BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                        color: Color.fromRGBO(39, 153, 227, 1),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 8),
                                                                                    const Text('Total Interest Amount'),
                                                                                    const Spacer(),
                                                                                    Text('Rs. ${_totalInterest == 0 ? '5,00,000' : _totalInterest.toStringAsFixed(0)}'),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                Container(
                                                                                  color: Color.fromRGBO(248, 249, 251, 1),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(10.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        const Text(
                                                                                          'Total Amount Payable',
                                                                                          style: TextStyle(fontFamily: "DMSans",fontWeight: FontWeight.w400, color: Color.fromRGBO(0, 0, 0, 1)),
                                                                                        ),
                                                                                        const Spacer(),
                                                                                        Text(
                                                                                          'Rs. ${_totalPayable == 0 ? '23,79,000' : _totalPayable.toStringAsFixed(0)}',
                                                                                          style: const TextStyle(fontFamily: "Poppins",fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                SizedBox(
                                                                                  width: double.infinity,
                                                                                  child: OutlinedButton(
                                                                                    onPressed: () {},
                                                                                    style: OutlinedButton.styleFrom(
                                                                                      side: const BorderSide(width: 2, color: Color.fromRGBO(0, 76, 144, 1)),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(40),
                                                                                      ),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(5.0),
                                                                                      child: const Text(
                                                                                        'Get EMI Offers',
                                                                                        style: TextStyle(
                                                                                          fontSize: 16,
                                                                                          fontFamily: "DMSans",
                                                                                          color: Color.fromRGBO(0, 76, 144, 1),
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
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
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                );
                                              
                                  },
                                  child: Text(
                                    "EMI Calculator",
                                    style: TextStyle(
                                      fontFamily: "DMSans",
                                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelectedIndex == 5 ? Color(0xFF004C90) : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                  
                            const SizedBox(width: 20),
                  
                            // Login Button
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
                                onPressed: _showLoginDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: MediaQuery.of(context).size.width < 600 ? 6 : 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12,
                                    fontFamily: "DMSans",
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                  ),
                                ),
                              ),
                            ),
                  
                            SizedBox(width: 15),
                  
                            // Book Online Button
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
                                onPressed: () {
                                  setState(() {
                                    innerCurrentPage = index;
                                    _showNewContent = true;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Viewcardetails(
                                        car: cars[index],
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  padding: EdgeInsets.symmetric(
                                    vertical: MediaQuery.of(context).size.width < 600 ? 6 : 10,
                                  ),
                                ),
                                child: Text(
                                  "Book Online",
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12,
                                    fontFamily: "DMSans",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            
                            ),
                    SizedBox(width: 20),
                  ]
                : [],

              );
            },
          ),
        ),
        drawer: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
            if (isMobile || isTablet) {
              return Drawer(
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
                      leading: Icon(Icons.home, color: Color(0xFF004C90)),
                      title: Text('Home'),
                      onTap: () {
                        setState(() {
                          isSelectedIndex = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Webdesign()));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info_outline, color: Color(0xFF004C90)),
                      title: Text('About Us'),
                      onTap: () {
                        setState(() {
                          isSelectedIndex = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.directions_car, color: Color(0xFF004C90)),
                      title: Text('Book a test Drive'),
                      onTap: () {
                        setState(() {
                          isSelectedIndex = 2;
                        });
                        _bookTestDrive();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.store_mall_directory, color: Color(0xFF004C90)),
                      title: Text('Virtual Showroom'),
                      onTap: () {
                        setState(() {
                          isSelectedIndex = 3;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.star, color: Color(0xFF004C90)),
                      title: Text('Luxury Cars'),
                      onTap: () {
                        setState(() {
                          isSelectedIndex = 4;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calculate, color: Color(0xFF004C90)),
                      title: Text('EMI Calculator'),
                      onTap: () {
                        setState(() {
                          isSelectedIndex = 5;
                        });
                        showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          double dialogWidth = screenWidth * 0.98;
                                                          double dialogHeight = screenHeight * 0.98;
                                                          return Center(
                                                            child: SingleChildScrollView(
                                                              child: Dialog(
                                                                backgroundColor: Colors.white,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                child: Container(
                                                                  width: dialogWidth,
                                                                  height: dialogHeight,
                                                                  padding: EdgeInsets.all(12),
                                                                  child: SingleChildScrollView(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              'Choose your EMI Options',
                                                                              style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.w700,
                                                                                color: Color.fromRGBO(74, 74, 74, 1),
                                                                                fontFamily: "DMSans",
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.close,
                                                                                color: Color.fromRGBO(0, 0, 0, 1),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        Text(
                                                                          'Standard EMI',
                                                                          style: TextStyle(
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontFamily: "DMSans",
                                                                            color: Color.fromRGBO(109, 109, 109, 1),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              width: 60,
                                                                              height: 2,
                                                                              color: Color.fromRGBO(0, 76, 144, 1),
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                height: 2,
                                                                                color: const Color.fromRGBO(189, 189, 189, 1),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        // Input Section
                                                                        Text(
                                                                          'Enter Estimated Price of the Car',
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Color.fromRGBO(26, 76, 142, 1),
                                                                            fontFamily: "Inter",
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        TextField(
                                                                          controller: _carPriceController,
                                                                          keyboardType: TextInputType.number,
                                                                          decoration: InputDecoration(
                                                                            border: OutlineInputBorder(),
                                                                            hintText: 'Rs. 18,79,000',
                                                                            prefixText: 'Rs. ',
                                                                          ),
                                                                          onChanged: (value) {
                                                                            _calculatePrincipal();
                                                                          },
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        Text(
                                                                          'Enter Down Payment',
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Color.fromRGBO(26, 76, 142, 1),
                                                                            fontFamily: "Inter",
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        TextField(
                                                                          controller: _downPaymentController,
                                                                          keyboardType: TextInputType.number,
                                                                          decoration: const InputDecoration(
                                                                            border: OutlineInputBorder(),
                                                                            hintText: 'Rs. 5,00,000',
                                                                            prefixText: 'Rs. ',
                                                                          ),
                                                                          onChanged: (value) {
                                                                            _calculatePrincipal();
                                                                          },
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        Text(
                                                                          'Your loan amount will be Rs. ${_principal == 0 ? '13,79,000' : _principal.toStringAsFixed(0)}',
                                                                          style: TextStyle(fontSize: 10),
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        Text(
                                                                          'Select Tenure',
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Color.fromRGBO(26, 76, 142, 1),
                                                                            fontFamily: "Inter",
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        DropdownButton<String>(
                                                                          isExpanded: true,
                                                                          value: _selectedTenure,
                                                                          items: _tenureOptions.map((String value) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: value,
                                                                              child: Text(value),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged: (newValue) {
                                                                            setState(() {
                                                                              _selectedTenure = newValue!;
                                                                              _calculateEMI();
                                                                            });
                                                                          },
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        Text(
                                                                          'Select Interest Rate',
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Color.fromRGBO(26, 76, 142, 1),
                                                                            fontFamily: "Inter",
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        DropdownButton<String>(
                                                                          isExpanded: true,
                                                                          value: _selectedInterestRate,
                                                                          items: _interestRateOptions.map((String value) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: value,
                                                                              child: Text(value),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged: (newValue) {
                                                                            setState(() {
                                                                              _selectedInterestRate = newValue!;
                                                                              _calculateEMI();
                                                                            });
                                                                          },
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        SizedBox(
                                                                          width: double.infinity,
                                                                          child: ElevatedButton(
                                                                            onPressed: _calculateEMI,
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: Color.fromRGBO(0, 76, 144, 1),
                                                                              foregroundColor: Colors.white,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(40),
                                                                              ),
                                                                            ),
                                                                            child: const Text('Calculate EMI'),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 20),
                                                                        // Results Section
                                                                        Text(
                                                                          'Rs. ${_emi == 0 ? '60,000' : _emi.toStringAsFixed(0)} EMI FOR ${_selectedTenure.toLowerCase()}',
                                                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(height: 11),
                                                                        Container(
                                                                          width: double.infinity,
                                                                          height: 2,
                                                                          color: Color.fromRGBO(189, 189, 189, 1),
                                                                        ),
                                                                        const SizedBox(height: 7),
                                                                        Container(
                                                                          color: Color.fromRGBO(248, 249, 251, 1),
                                                                          child: SizedBox(
                                                                            height: 120,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: CustomPaint(
                                                                                painter: EMISemiCircleChart(
                                                                                  principal: _principal,
                                                                                  totalInterest: _totalInterest,
                                                                                ),
                                                                                child: const SizedBox.expand(),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              width: 10,
                                                                              height: 10,
                                                                              decoration: const BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Color.fromRGBO(34, 53, 119, 1),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 8),
                                                                            const Text('Principal Loan Amount'),
                                                                            const Spacer(),
                                                                            Text('Rs. ${_principal == 0 ? '18,79,000' : _principal.toStringAsFixed(0)}'),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              width: 10,
                                                                              height: 10,
                                                                              decoration: const BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Color.fromRGBO(39, 153, 227, 1),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 8),
                                                                            const Text('Total Interest Amount'),
                                                                            const Spacer(),
                                                                            Text('Rs. ${_totalInterest == 0 ? '5,00,000' : _totalInterest.toStringAsFixed(0)}'),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        Container(
                                                                          color: Color.fromRGBO(248, 249, 251, 1),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(10.0),
                                                                            child: Row(
                                                                              children: [
                                                                                const Text(
                                                                                  'Total Amount Payable',
                                                                                  style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w400, color: Color.fromRGBO(0, 0, 0, 1)),
                                                                                ),
                                                                                const Spacer(),
                                                                                Text(
                                                                                  'Rs. ${_totalPayable == 0 ? '23,79,000' : _totalPayable.toStringAsFixed(0)}',
                                                                                  style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 16),
                                                                        SizedBox(
                                                                          width: double.infinity,
                                                                          child: OutlinedButton(
                                                                            onPressed: () {},
                                                                            style: OutlinedButton.styleFrom(
                                                                              side: const BorderSide(width: 2, color: Color.fromRGBO(0, 76, 144, 1)),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(40),
                                                                              ),
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(5.0),
                                                                              child: const Text(
                                                                                'Get EMI Offers',
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontFamily: "DMSans",
                                                                                  color: Color.fromRGBO(0, 76, 144, 1),
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.login, color: Color(0xFF004C90)),
                      title: Text('Login'),
                      onTap: () {
                        _showLoginDialog();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.shopping_cart, color: Color(0xFF004C90)),
                      title: Text('Book Online'),
                      onTap: () {
                        setState(() {
                          innerCurrentPage = index;
                          _showNewContent = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Viewcardetails(
                              car: cars[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        
        body: 
          SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: responsivePadding(desktop: 0, tablet: 0, mobile: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      double screenHeight = MediaQuery.of(context).size.height;

                      final bool isMobile = screenWidth < 600;
                      final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                      final bool isWebOrDesktop = screenWidth >= 1024;

                      double heroImageHeight = isWebOrDesktop
                          ? screenHeight * 0.7
                          : isTablet
                              ? screenHeight * 0.5
                              : screenHeight * 0.3;

                      double heroFontSize = responsiveFont(48, 32, 22);

                      double searchBarHeight = isWebOrDesktop
                          ? screenHeight * 0.08
                          : isTablet
                              ? screenHeight * 0.07
                              : 48; // Fixed height for mobile

                      double searchBarWidth = isWebOrDesktop
                          ? screenWidth * 0.35
                          : isTablet
                              ? screenWidth * 0.3
                              : screenWidth; // Full width for mobile

                      double searchIconSize = isMobile ? 18 : searchBarHeight * 0.3;
                      double borderRadius = isMobile ? 16 : 32;
                      double fontSize = isMobile ? 12 : 16;

                      return Stack(
                        children: [
                          SizedBox(
                            height: heroImageHeight,
                            width: double.infinity,
                            child: Image.asset(
                              "assets/carbackground.jpeg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: heroImageHeight * 0.2, // Adjusted for better spacing
                            left: 0,
                            right: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Find Your Perfect Car",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: heroFontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "DMSans",
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),


                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isWebOrDesktop
                                          ? screenWidth * 0.1
                                          : isTablet
                                              ? screenWidth * 0.05
                                              : 0.03,
                                      vertical: 0,
                                    ),
                                    child: SizedBox(
                                      width: searchBarWidth,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: searchBarHeight,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(screenWidth > 600 ? 50 : 20),
                                              border: Border.all(
                                                color: const Color.fromRGBO(233, 233, 233, 1),
                                                width: 3,
                                              ),
                                            ),
                                            padding: const EdgeInsets.only(left: 20),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _controller,
                                                    onChanged: _onChanged,
                                                    decoration: InputDecoration(
                                                      hintText: "Search car by name, model, price, or specs",
                                                      hintStyle: TextStyle(
                                                        color: const Color.fromRGBO(127, 127, 127, 1),
                                                        fontSize: fontSize,
                                                        fontFamily: "DMSans",
                                                      ),
                                                      border: InputBorder.none,
                                                    ),
                                                    style: TextStyle(fontSize: fontSize),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 0.0, right: 8),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromRGBO(26, 76, 142, 1),
                                                      borderRadius: BorderRadius.circular(50),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: isMobile ? 10 : 23.0,
                                                        vertical: isMobile ? 6 : 10.0,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.search,
                                                              color: Colors.white, size: searchIconSize),
                                                          if (!isMobile)
                                                            Text(
                                                              "Search",
                                                              style: TextStyle(
                                                                fontSize: fontSize,
                                                                fontFamily: "DMSans",
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_suggestions.isNotEmpty)
                                            Container(
                                              margin: const EdgeInsets.only(top: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(color: Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                              ),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _suggestions.length,
                                                itemBuilder: (context, index) {
                                                  final car = _suggestions[index];
                                                  return ListTile(
                                                    title: Text(
                                                      "${car['make']} - ${car['model']}",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold, fontSize: fontSize),
                                                    ),
                                                    subtitle: Text(
                                                      "Price: ${car['price']} | Specs: ${car['specifications']}",
                                                      style: TextStyle(fontSize: fontSize - 2),
                                                    ),
                                                    onTap: () {
                                                      FocusScope.of(context).unfocus();
                                                      setState(() {
                                                        _controller.text = "${car['make']} - ${car['model']}";
                                                        _suggestions = [];
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
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
      
              SizedBox(height: screenHeight * 0.03,),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric( 
                      horizontal: MediaQuery.of(context).size.width * 0.0,
                    ),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double screenWidth = constraints.maxWidth;
                  
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Featured Cars',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.038,
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
                                            fontSize: screenHeight * 0.02,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_outward,
                                          color: Color.fromRGBO(0, 147, 255, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
      
                        TabBar(
                          tabs: [
                            Tab(text: 'All'),
                            Tab(text: 'Sedans'),
                            Tab(text: 'Hatchback'),
                            Tab(text: 'SUV’s'),
                            Tab(text: 'MUV’s'),
                          ],
                          labelColor: Color.fromRGBO(26, 76, 142, 1),
                          unselectedLabelColor: Color.fromRGBO(31, 56, 76, 1),
                          indicatorColor: Color.fromRGBO(26, 76, 142, 1),
                          isScrollable: true,
                          labelPadding: EdgeInsets.symmetric(horizontal: 10),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              width: 3, 
                              color: Color.fromRGBO(26, 76, 142, 1),
                            ),
                          ),
                        ),


                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: screenWidth >= 1024
                                  ? 60
                                  : screenWidth >= 600
                                      ? 40
                                      : 10,
                              right: screenWidth >= 1024
                                  ? 60
                                  : screenWidth >= 600
                                      ? 40
                                      : 10,
                              top: screenWidth >= 1024
                                  ? 30
                                  : screenWidth >= 600
                                      ? 30
                                      : 30,
                              bottom: screenWidth >= 1024
                                  ? 10
                                  : screenWidth >= 600
                                      ? 10
                                      : 10,
                            ),
                            child: SizedBox(
                              height: screenWidth >= 1024
                                ? screenHeight * 5.2 // Web/Desktop
                                : screenWidth >= 600
                                    ? screenHeight * 5.4 // Tablet
                                    : screenHeight * 5.6, // Mobile
                              child: TabBarView(
                                children: [
                                  All(),
                                  Sedan(),
                                  Hatchback(),
                                  SUV(),
                                  MUV(),
                                ]
                              ),
                            ),
                          ),
                        ),
                        buildResponsiveFooter(context),
                      ]
                    ),
                  ),
                ),
              ),

              

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

//brand cars
Widget buildBrandCards(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  // List of brand data
  final brands = [
    {"image": "assets/audi.jpeg", "name": "Audi"},
    {"image": "assets/bmw.jpeg", "name": "BMW"},
    {"image": "assets/ford.jpeg", "name": "Ford"},
    {"image": "assets/peugeot.jpeg", "name": "Peugeot"},
    {"image": "assets/volkswagan.jpeg", "name": "Volkswagan"},
  ];

  Widget brandCard(Map<String, String> brand) {
    return Container(
      width: screenWidth > 600 ? 90 : screenWidth * 0.4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.01,
        ),
        child: Row(
          children: [
            Image.asset(
              brand["image"]!,
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.07,
              fit: BoxFit.contain,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Expanded(
              child: Text(
                brand["name"]!,
                style: TextStyle(
                  fontFamily: "DMSans",
                  fontSize: screenWidth > 600
                      ? 20
                      : screenWidth > 400
                          ? 18
                          : 16,
                  color: Color.fromRGBO(5, 11, 32, 1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (screenWidth < 600) {
    // Mobile: vertical list
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: brands.map((b) => brandCard(b)).toList(),
      ),
    );
  } else if (screenWidth < 1024) {
    // Tablet: grid with 2 columns
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: brands.map((b) => brandCard(b)).toList(),
    );
  } else {
    // Web/Desktop: row
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: brands.map((b) => Expanded(child: brandCard(b))).toList(),
    );
  }
}
 
                      Widget All(){
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: buildBrandCards(context),
                            ),
                            const SizedBox(height: 20,),


                            //Featured Cars
                            Stack(
                              children: [
                                Container(
                                  child: CarouselSlider(
                                    carouselController: innerCarouselController,
                                    options: CarouselOptions(
                                      
                                      height: MediaQuery.of(context).size.height * 0.8,
                                      autoPlay: false,
                                      autoPlayInterval: Duration(seconds: 3),
                                      autoPlayAnimationDuration: Duration(milliseconds: 1000),
                                      enableInfiniteScroll: true,
                                      enlargeCenterPage: false,
                                      viewportFraction: 1,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          innerCurrentPage = index;
                                        });
                                      },
                                    ),
                                    items: cars.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> car = entry.value;
                                      return LayoutBuilder(
                                        builder: (context, constraints) {
                                          double padding = MediaQuery.of(context).size.width > 1200
                                              ? constraints.maxWidth * 0.023
                                              : MediaQuery.of(context).size.width > 600
                                                  ? constraints.maxWidth * 0.02
                                                  : constraints.maxWidth * 0.02;
                                  
                                          double buttonPadding = MediaQuery.of(context).size.width > 1200
                                              ? constraints.maxWidth * 0.02
                                              : MediaQuery.of(context).size.width > 800
                                                  ? constraints.maxWidth * 0.015
                                                  : constraints.maxWidth * 0.01;
                                  
                                          double buttonHeight = MediaQuery.of(context).size.height > 900
                                              ? constraints.maxHeight * 0.06
                                              : MediaQuery.of(context).size.height > 600
                                                  ? constraints.maxHeight * 0.06
                                                  : constraints.maxHeight * 0.04;
                                  
                                          double fontSizeFactor = MediaQuery.of(context).size.width > 1200
                                              ? 1.3
                                              : MediaQuery.of(context).size.width >= 800
                                                  ? 1.15
                                                  : 1.0;

                                          double fontSize = constraints.maxWidth < 600
                                            ? constraints.maxWidth * 0.03 // Mobile
                                            : constraints.maxWidth < 1024
                                                ? constraints.maxWidth * 0.02 // Tablet
                                                : constraints.maxWidth * 0.006 * fontSizeFactor; // Desktop/Web

                                          double viewImageWidth;
                                          if (constraints.maxWidth < 600) {
                                            // Mobile
                                            viewImageWidth = constraints.maxWidth * 0.20;
                                          } else if (constraints.maxWidth < 1024) {
                                            // Tablet
                                            viewImageWidth = constraints.maxWidth * 0.10;
                                          } else {
                                            // Desktop/Web
                                            viewImageWidth = constraints.maxWidth * 0.065;
                                          }

                                          return Stack(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width > 1200
                                                    ? constraints.maxWidth * 0.6
                                                    : MediaQuery.of(context).size.width > 800
                                                        ? constraints.maxWidth * 0.6
                                                        : constraints.maxWidth * 0.9,
                                  
                                                height: MediaQuery.of(context).size.height > 900
                                                    ? constraints.maxHeight * 1
                                                    : MediaQuery.of(context).size.height > 600
                                                        ? constraints.maxHeight * 1
                                                        : constraints.maxHeight * 0.9,
                                                padding: EdgeInsets.all(padding),
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(255, 255, 255, 1),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Color.fromRGBO(228, 228, 228, 1),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width > 1200
                                                              ? constraints.maxWidth * 0.98
                                                              : MediaQuery.of(context).size.width > 800
                                                                  ? constraints.maxWidth * 0.8
                                                                  : constraints.maxWidth * 0.8,
                                                          height: MediaQuery.of(context).size.height * 0.4,
                                                          child: Image.asset(car["image"]?? 'assets/placeholder.png', fit: BoxFit.contain),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          right: padding,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) => TwocarscompareWeb()),
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.grey,
                                                              foregroundColor: Colors.white,
                                                              padding: EdgeInsets.symmetric(
                                                                horizontal: buttonPadding,
                                                                vertical: buttonHeight * 0.2,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.all(5),
                                                                  child: Row(
                                                                    children: [
                                                                      Image.asset(car["compareImage"] ?? "comareImage", width: 17, height: 17, fit: BoxFit.contain),
                                                                      SizedBox(width: padding * 0.15),
                                                                      Text(
                                                                        car["compareText"] ?? "Comapare",
                                                                        style: TextStyle(fontFamily: "DMSans", fontSize: fontSize),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: (constraints.maxWidth < 600 // mobile
                                                                  ? constraints.maxHeight * 0.20
                                                                  : constraints.maxWidth < 1024 // tablet
                                                                      ? constraints.maxHeight * 0.20
                                                                      : constraints.maxHeight * 0.22), // web/desktop
                                                          left: (constraints.maxWidth < 600 // mobile
                                                                  ? constraints.maxWidth * 0.30
                                                                  : constraints.maxWidth < 1024 // tablet
                                                                      ? constraints.maxWidth * 0.30
                                                                      : constraints.maxWidth * 0.23), // web/desktop
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              print('Carousel: viewImage button pressed for car: ${car["name"]}');
                                                              print('Carousel: Navigating to WebWebviewPage with URL: https://virtualshowroom.hondacarindia.com/honda-amaze/...');
                                                              // Navigator.push(
                                                              //   context,
                                                              //   MaterialPageRoute(
                                                              //     builder: (context) => WebWebviewPage(
                                                              //       url: "https://virtualshowroom.hondacarindia.com/honda-amaze/?utm_source=hondacarindia&utm_medium=website&utm_campaign=explore_virtual_showroom#/car/amaze",
                                                              //     ),
                                                              //   ),
                                                              // ).then((_) {
                                                              //   print('Carousel: Returned from WebWebviewPage');
                                                              // });
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              padding: EdgeInsets.zero,
                                                              backgroundColor: Colors.transparent,
                                                              elevation: 0,
                                                            ),
                                                            child:Hero(
                                                              tag: 'carHeroTag_${car["id"]?.toString() ?? index}_${index}_${UniqueKey()}',
                                                              child: Image.asset(
                                                                car["viewImage"]?.toString() ?? "assets/degrees.png",
                                                                width: viewImageWidth ,
                                                                fit: BoxFit.contain,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: constraints.maxHeight * 0.0),
                                                    Container(
                                                      child: Text(
                                                        car["name"]?.toString() ?? "Car Name",
                                                        style: TextStyle(
                                                          fontSize: (constraints.maxWidth < 600 
                                                          ? constraints.maxWidth * 0.055
                                                          : constraints.maxWidth < 1024
                                                              ? constraints.maxWidth * 0.027
                                                              : constraints.maxWidth * 0.015
                                                          )* fontSizeFactor,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: constraints.maxHeight * 0.03),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                car["moreDetails1"]?.toString() ?? "Starting at",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.032
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017 
                                                                        : constraints.maxWidth * 0.009) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                              SizedBox(height: constraints.maxHeight * 0.02),
                                                              Text(
                                                                car["details1"]?.toString() ?? "N/A",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.03 
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017 
                                                                        : constraints.maxWidth * 0.007) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                              Text(
                                                                car["details12"]?.toString() ?? "N/A",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.03 
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017
                                                                        : constraints.maxWidth * 0.007) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                              Text(
                                                                car["details13"]?.toString() ?? "N/A",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.03 
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017
                                                                        : constraints.maxWidth * 0.007) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          color: Color.fromRGBO(219, 219, 219, 1),
                                                          height: constraints.maxHeight * 0.15,
                                                          width: constraints.maxWidth * 0.001,
                                                        ),
                                                        SizedBox(width: constraints.maxWidth * 0.02),
                                  
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                car["moreDetails2"]?.toString() ?? "Engine Options",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.032
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017 
                                                                        : constraints.maxWidth * 0.009) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                              SizedBox(height: constraints.maxHeight * 0.02),
                                                              Image.asset(
                                                                car["dieselImage"]?.toString() ?? "assets/diesel.webp",
                                                                height: (constraints.maxWidth < 600 // mobile
                                                                    ? constraints.maxHeight * 0.03
                                                                    : constraints.maxWidth < 1024 // tablet
                                                                        ? constraints.maxHeight * 0.03
                                                                        : constraints.maxHeight * 0.03), // web/desktop
                                                                width: (constraints.maxWidth < 600 // mobile
                                                                    ? constraints.maxWidth * 0.04
                                                                    : constraints.maxWidth < 1024 // tablet
                                                                        ? constraints.maxWidth * 0.04
                                                                        : constraints.maxWidth * 0.03), // web/desktop
                                                                color: Colors.black,
                                                                fit: BoxFit.contain,
                                                              ),
                                                              SizedBox(height: constraints.maxHeight * 0.01),
                                                              Text(
                                                                car["details2"]?.toString() ?? "N/A",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.03 
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017 
                                                                        : constraints.maxWidth * 0.007) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                  
                                                        Container(
                                                          color: Color.fromRGBO(219, 219, 219, 1),
                                                          height: constraints.maxHeight * 0.15,
                                                          width: constraints.maxWidth * 0.001,
                                                        ),
                                                        SizedBox(width: constraints.maxWidth * 0.02),
                                                        Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                car["moreDetails3"]?.toString() ?? "Transmission",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.032
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017 
                                                                        : constraints.maxWidth * 0.009) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                              Text(
                                                                car["moreDetails31"]?.toString() ?? "Available",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.032
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017 
                                                                        : constraints.maxWidth * 0.009) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                              SizedBox(height: constraints.maxHeight * 0.01),
                                                
                                                              Image.asset(
                                                                car["manualImage"]?.toString() ?? "assets/manuel.png",
                                                                height: (constraints.maxWidth < 600 // mobile
                                                                    ? constraints.maxHeight * 0.03
                                                                    : constraints.maxWidth < 1024 // tablet
                                                                        ? constraints.maxHeight * 0.03
                                                                        : constraints.maxHeight * 0.03), // web/desktop
                                                                width: (constraints.maxWidth < 600 // mobile
                                                                    ? constraints.maxWidth * 0.04
                                                                    : constraints.maxWidth < 1024 // tablet
                                                                        ? constraints.maxWidth * 0.04
                                                                        : constraints.maxWidth * 0.03), // web/desktop
                                                                color: Colors.black,
                                                                fit: BoxFit.contain,
                                                              ),
                                                              SizedBox(height: constraints.maxHeight * 0.01),
                                                              Text(
                                                                car["details3"]?.toString() ?? "N/A",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 
                                                                    ? constraints.maxWidth * 0.03 
                                                                    : constraints.maxWidth < 1024 
                                                                        ? constraints.maxWidth * 0.017
                                                                        : constraints.maxWidth * 0.007) * fontSizeFactor,
                                                                  fontFamily: "DMSans",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: constraints.maxHeight * 0.05),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Flexible(
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              side: BorderSide(color: Color(0xFF004C90)),
                                                              backgroundColor: Colors.white,
                                                              minimumSize: Size(
                                                                MediaQuery.of(context).size.width > 1200
                                                                    ? constraints.maxWidth * 0.2
                                                                    : MediaQuery.of(context).size.width > 800
                                                                        ? constraints.maxWidth * 0.3
                                                                        : constraints.maxWidth * 0.9,
                                                                buttonHeight * 0.45,
                                                              ),
                                                              padding: EdgeInsets.symmetric(
                                                                vertical: buttonHeight * 0.2,
                                                                horizontal: MediaQuery.of(context).size.width * 0.02,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                innerCurrentPage = index;
                                                              });
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => Viewcardetails(
                                                                    car: car,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(5.0),
                                                              child: Text(
                                                                car["button1"]?.toString() ?? "Learn More",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 // mobile
                                                                    ? constraints.maxWidth * 0.028
                                                                    : constraints.maxWidth < 1024 // tablet
                                                                        ? constraints.maxWidth * 0.018
                                                                        : constraints.maxWidth * 0.01) * fontSizeFactor, // web/desktop
                                                                  color: Color(0xFF004C90),
                                                                  fontWeight: FontWeight.w700,
                                                                  fontFamily: "WorkSans",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                        Flexible(
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Color(0xFF004C90),
                                                              minimumSize: Size(
                                                                MediaQuery.of(context).size.width > 1200
                                                                    ? constraints.maxWidth * 0.2
                                                                    : MediaQuery.of(context).size.width > 800
                                                                        ? constraints.maxWidth * 0.3
                                                                        : constraints.maxWidth * 0.9,
                                                                buttonHeight * 0.45,
                                                              ),
                                                              padding: EdgeInsets.symmetric(
                                                                vertical: buttonHeight * 0.2,
                                                                horizontal: MediaQuery.of(context).size.width * 0.02,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              _bookTestDrive();
                                                              _clearForm();
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(5.0),
                                                              child: Text(
                                                                car["button2"]?.toString() ?? "Book a Test Drive",
                                                                style: TextStyle(
                                                                  fontSize: (constraints.maxWidth < 600 // mobile
                                                                    ? constraints.maxWidth * 0.028
                                                                    : constraints.maxWidth < 1024 // tablet
                                                                        ? constraints.maxWidth * 0.018
                                                                        : constraints.maxWidth * 0.01) * fontSizeFactor, // web/desktop
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontFamily: "WorkSans",
                                                                ),
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
                                ),
                                  
                                if(innerCurrentPage >= 0)
                                Positioned(
                                  height: (MediaQuery.of(context).size.width < 600 // mobile
                                      ? 30.0
                                      : MediaQuery.of(context).size.width < 1024 // tablet
                                          ? 50.0
                                          : 60.0), // web/desktop
                                  left: (MediaQuery.of(context).size.width < 600 // mobile
                                      ? -5.0
                                      : MediaQuery.of(context).size.width < 1024 // tablet
                                          ? -6.0
                                          : -10.0), // web/desktop
                                  top: (MediaQuery.of(context).size.width < 600 // mobile
                                      ? MediaQuery.of(context).size.height * 0.35
                                      : MediaQuery.of(context).size.width < 1024 // tablet
                                          ? MediaQuery.of(context).size.height * 0.30
                                          : MediaQuery.of(context).size.height * 0.22), // web/desktop
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      innerCarouselController.animateToPage(innerCurrentPage - 1, curve: Curves.easeIn);
                                    },
                                    backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                    child: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                                    mini: true,
                                  ),
                                ),
                              if(innerCurrentPage <= cars.length - 1)
                                Positioned(
                                  height: (MediaQuery.of(context).size.width < 600 // mobile
                                      ? 30.0
                                      : MediaQuery.of(context).size.width < 1024 // tablet
                                          ? 50.0
                                          : 60.0), // web/desktop
                                  right: (MediaQuery.of(context).size.width < 600 // mobile
                                      ? -5.0
                                      : MediaQuery.of(context).size.width < 1024 // tablet
                                          ? -6.0
                                          : -10.0), // web/desktop
                                  top: (MediaQuery.of(context).size.width < 600 // mobile
                                      ? MediaQuery.of(context).size.height * 0.35
                                      : MediaQuery.of(context).size.width < 1024 // tablet
                                          ? MediaQuery.of(context).size.height * 0.30
                                          : MediaQuery.of(context).size.height * 0.22), // web/desktop
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      innerCarouselController.animateToPage(innerCurrentPage + 1, curve: Curves.easeIn);
                                    },
                                    backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                    child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                                    mini: true,
                                  ),
                                ),
                              ]
                            ),

                            SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
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
                                  imageSize = (screenWidth / 3) - 30; 
                                }
                                imageSize = imageSize.clamp(80.0, 300.0);

                                double titleFontSize = screenWidth > 600 ? 40 : screenWidth * 0.08;
                                
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
                                                    fontSize: screenHeight * 0.038,
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
                                                    fontSize: screenHeight * 0.02,
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
                                      SizedBox(height: screenHeight * 0.05),

                                      //Similar Brands Section
                                      Column(
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Builder(
                                                builder: (context) {
                                                  print('[buildBrands] isLoadingBrands: $isLoadingBrands, errorMessageBrands: $errorMessageBrands, brands: $brands');
                                                  if (isLoadingBrands) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }
                                                  if (errorMessageBrands != null) {
                                                    return Center(child: Text(errorMessageBrands!));
                                                  }
                                                  if (brands.isEmpty) {
                                                    return const Center(child: Text('No brands available'));
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.all(0.0),
                                                    child: Wrap(
                                                      spacing: screenWidth * 0.05,
                                                      runSpacing: screenHeight * 0.02,
                                                      children: brands.map((brand) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(width: 1, color: const Color.fromRGBO(233, 233, 233, 1)),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Column(
                                                              children: [
                                                                Image.asset(
                                                                  brand["image"] ?? 'assets/placeholder.png',
                                                                  width: imageSize,
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                    'assets/placeholder.png',
                                                                    width: imageSize,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  brand["name"] ?? 'Unknown Brand',
                                                                  style: const TextStyle(fontFamily: "DMSans"),
                                                                  textAlign: TextAlign.center,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                  maxLines: 2, // Allow up to 2 lines
                                                                ),
                                                                SizedBox(height: screenHeight * 0.02),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      ),


                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          double screenWidth = MediaQuery.of(context).size.width;
                                          double imageWidth = screenWidth * 0.40;
                                          double imageHeight = (imageWidth * 9 / 16) * 1.49;
                                          double playButtonSize = screenWidth * 0.052;
                                          double sectionSpacing = screenWidth * 0.01;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: sectionSpacing),

                                          // Responsive "video + info" section
                                          Builder(
                                            builder: (context) {
                                              final screenWidth = MediaQuery.of(context).size.width;
                                              final isMobile = screenWidth < 800;
                                              final isTablet = screenWidth >= 800 && screenWidth < 1024;
                                              final isDesktop = screenWidth >= 1024;

                                              // Responsive sizes
                                              double imageWidth, imageHeight, playButtonSize, infoPadding, titleFontSize, descFontSize, bulletFontSize, buttonFontSize, sectionSpacing;
                                              if (isMobile) {
                                                imageWidth = screenWidth * 0.9;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 40;
                                                infoPadding = 16;
                                                titleFontSize = 18;
                                                descFontSize = 12;
                                                bulletFontSize = 12;
                                                buttonFontSize = 14;
                                                sectionSpacing = 10;
                                              } else if (isTablet) {
                                                imageWidth = screenWidth * 0.4;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 50;
                                                infoPadding = 32;
                                                titleFontSize = 24;
                                                descFontSize = 14;
                                                bulletFontSize = 14;
                                                buttonFontSize = 16;
                                                sectionSpacing = 16;
                                              } else {
                                                imageWidth = screenWidth * 0.35;
                                                imageHeight = screenWidth * 0.33;
                                                playButtonSize = 60;
                                                infoPadding = 70;
                                                titleFontSize = 32;
                                                descFontSize = 16;
                                                bulletFontSize = 16;
                                                buttonFontSize = 18;
                                                sectionSpacing = 24;
                                              }

                                              Widget imageStack = Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      bottomLeft: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      topRight: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      bottomRight: Radius.circular(0),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/videoImage.jpeg",
                                                      width: imageWidth,
                                                      height: imageHeight,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: playButtonSize / 2,
                                                    backgroundColor: Colors.white,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      size: playButtonSize * 0.5,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              );

                                              Widget infoSection = Container(
                                                width: isMobile ? double.infinity : screenWidth * 0.48,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(238, 241, 251, 1),
                                                  borderRadius: isMobile
                                                      ? BorderRadius.only(
                                                          bottomLeft: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        )
                                                      : null,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(infoPadding),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Buying a car has never been this easy.",
                                                        style: TextStyle(
                                                          fontSize: titleFontSize,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Text(
                                                        "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                                        style: TextStyle(
                                                          fontSize: descFontSize,
                                                          color: Color.fromRGBO(5, 11, 32, 1),
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          buildBulletPoint(
                                                            "We are the UK's largest provider, with more patrols in more places",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "You get 24/7 roadside assistance",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "We fix 4 out of 5 cars at the roadside",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _bookTestDrive();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color(0xFF004C90),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: infoPadding,
                                                            vertical: infoPadding / 2.5,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "Book a test drive",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: buttonFontSize,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            SizedBox(width: sectionSpacing / 2),
                                                            Icon(Icons.arrow_outward, color: Colors.white, size: buttonFontSize + 2),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );

                                              if (isMobile) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              }
                                            },
                                          ),

                                          SizedBox(height: sectionSpacing),
                                          Builder(
                                            builder: (context) {
                                              double screenWidth = MediaQuery.of(context).size.width;
                                              int crossAxisCount;
                                              if (screenWidth < 600) {
                                                crossAxisCount = 2;
                                              } else if (screenWidth < 1024) {
                                                crossAxisCount = 4;
                                              } else {
                                                crossAxisCount = 4;
                                              }
                                              return Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  buildStatBox("836M", "CARS FOR SALE", context),
                                                  buildStatBox("738M", "DEALER REVIEWS", context),
                                                  buildStatBox("100M", "VISITORS PER DAY", context),
                                                  buildStatBox("238M", "VERIFIED DEALERS", context),
                                                ],
                                              );
                                            },
                                          ),

                                          Divider(
                                            thickness: 1,
                                            color: Color.fromRGBO(223, 223, 223, 1),
                                          ),
                                          SizedBox(height: sectionSpacing),

                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Why Choose Us?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenHeight * 0.038, fontFamily: "DMSans",),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double screenWidth = MediaQuery.of(context).size.width;
                                                bool isMobile = screenWidth < 600;

                                                double imageSize;
                                                double titleFontSize;
                                                double descFontSize;
                                                if (screenWidth >= 1024) {
                                                  // Desktop
                                                  imageSize = 52;
                                                  titleFontSize = 22;
                                                  descFontSize = 15;
                                                } else if (screenWidth >= 600) {
                                                  // Tablet
                                                  imageSize = 40;
                                                  titleFontSize = 19;
                                                  descFontSize = 15;
                                                } else {
                                                  // Mobile
                                                  imageSize = 33;
                                                  titleFontSize = 15;
                                                  descFontSize = 13;
                                                }

                                                List<Widget> infoBlocks = [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/financialOffer.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Special Financing Offers", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/dealership.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Trusted Car Dealership", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/transparent.png", height: imageSize),
                                                      SizedBox(height: screenWidth*0.02),
                                                      Text("Transparent Pricing", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/expertCar.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Expert Car Service", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                ];

                                                if (isMobile) {
                                                  // Display vertically for mobile
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                } else {
                                                  // Display horizontally for tablet/desktop
                                                  return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(right: screenWidth * 0.02),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                }
                                              }
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.1),
                                          
                                          Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(249, 251, 252, 1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  right: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  top: screenWidth >= 1024
                                                      ? screenHeight * 0.10
                                                      : screenWidth >= 600
                                                          ? screenHeight * 0.06
                                                          : 16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // You can adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          double textSize;
                                                          double subTextSize;
                                                          if (constraints.maxWidth >= 1024) {
                                                            textSize = 28;
                                                            subTextSize = 14;
                                                          } else if (constraints.maxWidth >= 600) {
                                                            textSize = 24;
                                                            subTextSize = 12;
                                                          } else {
                                                            textSize = 18;
                                                            subTextSize = 10;
                                                          }

                                                          bool isMobile = constraints.maxWidth < 600;

                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              isMobile
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // Adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          bool isDesktop = constraints.maxWidth >= 1024;
                                                          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                                                          bool isMobile = constraints.maxWidth < 600;

                                                          double containerHeight = isDesktop
                                                              ? 490
                                                              : isTablet
                                                                  ? 420
                                                                  : 320;
                                                          double containerWidth = isDesktop
                                                              ? screenWidth * 0.9
                                                              : isTablet
                                                                  ? screenWidth * 0.95
                                                                  : screenWidth * 0.98;
                                                          double imageWidth = isDesktop
                                                              ? 480
                                                              : isTablet
                                                                  ? 300
                                                                  : containerWidth;
                                                          double imageHeight = isDesktop
                                                              ? 550
                                                              : isTablet
                                                                  ? 380
                                                                  : 180;
                                                          double nameSize = isDesktop
                                                              ? 18
                                                              : isTablet
                                                                  ? 16
                                                                  : 14;
                                                          double designationSize = isDesktop
                                                              ? 15
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                                                          double reviewTextSize = isDesktop
                                                              ? 22
                                                              : isTablet
                                                                  ? 16
                                                                  : 12;
                                                          double starSize = isDesktop
                                                              ? 16
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;

                                                          return Builder(
                                                            builder: (context) {
                                                              if (isLoadingReviews) {
                                                                return Center(child: CircularProgressIndicator());
                                                              }
                                                              if (errorMessageReviews != null) {
                                                                return Center(child: Text(errorMessageReviews!));
                                                              }
                                                              if (reviews.isEmpty) {
                                                                return Center(child: Text('No high-rated reviews available'));
                                                              }
                                                              return CarouselSlider(
                                                                carouselController: reviewCarouselController,
                                                                options: CarouselOptions(
                                                                  height: containerHeight,
                                                                  autoPlay: false,
                                                                  enlargeCenterPage: false,
                                                                  enableInfiniteScroll: false,
                                                                  viewportFraction: 1,
                                                                  onPageChanged: (index, reason) {
                                                                    setState(() {
                                                                      reviewCurrentPage = index;
                                                                    });
                                                                  },
                                                                ),
                                                                items: reviews.asMap().entries.map((entry) {
                                                                  int index = entry.key;
                                                                  Map<String, dynamic> review = entry.value;
                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(0.0),
                                                                    child: Container(
                                                                      height: containerHeight,
                                                                      width: containerWidth,
                                                                      child: isMobile
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Row(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: List.generate(5, (starIndex) {
                                                                                        return Icon(
                                                                                          starIndex < (review["rating"] ?? 0)
                                                                                              ? Icons.star
                                                                                              : Icons.star_border,
                                                                                          color: Color.fromRGBO(225, 192, 63, 1),
                                                                                          size: starSize.toDouble(),
                                                                                        );
                                                                                      }),
                                                                                    ),
                                                                                    SizedBox(width: 6),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color.fromRGBO(225, 192, 63, 1),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 10, vertical: 2),
                                                                                        child: Text(
                                                                                          (review["rating"] ?? 0).toStringAsFixed(1),
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  review["name"] ?? 'Anonymous',
                                                                                  style: TextStyle(
                                                                                    fontSize: nameSize,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 4),
                                                                                Text(
                                                                                  review["designation"] ?? 'Reviewer',
                                                                                  style: TextStyle(
                                                                                    fontSize: designationSize,
                                                                                    color: Color.fromRGBO(139, 139, 139, 1),
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Text(
                                                                                  review["review"] ?? 'No review provided',
                                                                                  style: TextStyle(fontSize: reviewTextSize),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 24),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: List.generate(5, (starIndex) {
                                                                                                return Icon(
                                                                                                  starIndex < (review["rating"] ?? 0)
                                                                                                      ? Icons.star
                                                                                                      : Icons.star_border,
                                                                                                  color:
                                                                                                      Color.fromRGBO(225, 192, 63, 1),
                                                                                                  size: starSize.toDouble(),
                                                                                                );
                                                                                              }),
                                                                                            ),
                                                                                            SizedBox(width: 10),
                                                                                            Container(
                                                                                              decoration: BoxDecoration(
                                                                                                color:
                                                                                                    Color.fromRGBO(225, 192, 63, 1),
                                                                                                borderRadius:
                                                                                                    BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.symmetric(
                                                                                                    horizontal: 10, vertical: 2),
                                                                                                child: Text(
                                                                                                  (review["rating"] ?? 0)
                                                                                                      .toStringAsFixed(1),
                                                                                                  style: TextStyle(
                                                                                                    fontSize: designationSize,
                                                                                                    color: Colors.white,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: 16),
                                                                                        Text(
                                                                                          review["name"] ?? 'Anonymous',
                                                                                          style: TextStyle(
                                                                                            fontSize: nameSize,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 8),
                                                                                        Text(
                                                                                          review["designation"] ?? 'Reviewer',
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Color.fromRGBO(139, 139, 139, 1),
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 24),
                                                                                        Text(
                                                                                          review["review"] ?? 'No review provided',
                                                                                          style: TextStyle(fontSize: reviewTextSize),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Left button
                                          if (reviewCurrentPage >= 0)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              left: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage - 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  highlightElevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_back_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          // Right button
                                          if (reviewCurrentPage <= reviews.length - 1)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              right: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage + 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                              
                                        SizedBox(height: 40),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double fontSize = constraints.maxWidth > 600 ? 28 : 23;
                                            double paddingValue = constraints.maxWidth > 600 ? 20.0 : 10.0;
                                              
                                            return Padding(
                                              padding: EdgeInsets.all(paddingValue),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Latest Blog Posts",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
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
                                                                fontSize: screenHeight * 0.02,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_outward,
                                                              color: Color.fromRGBO(0, 147, 255, 1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                              
                                        
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double screenWidth = constraints.maxWidth;

                                            if (screenWidth < 600) {
                                              // Mobile: Use CarouselSlider
                                              return CarouselSlider(
                                                options: CarouselOptions(
                                                  height: 420, // Adjust as needed
                                                  enableInfiniteScroll: true,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.9,
                                                ),
                                                items: blogs.map((blog) {
                                                  double imageHeight = 220;
                                                  double textSize = 13;
                                                  double buttonPadding = 20;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            } else {
                                              // Tablet/Web: Use GridView
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: screenWidth > 900
                                                      ? 3
                                                      : screenWidth > 600
                                                          ? 2
                                                          : 1,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: screenWidth > 900
                                                      ? 1.2
                                                      : screenWidth > 600
                                                          ? 1.1
                                                          : 0.9,
                                                ),
                                                itemCount: blogs.length,
                                                itemBuilder: (context, index) {
                                                  final blog = blogs[index];
                                                  double imageHeight = screenWidth > 900
                                                      ? 360
                                                      : screenWidth > 600
                                                          ? 280
                                                          : 220;
                                                  double textSize = screenWidth > 900
                                                      ? 22
                                                      : screenWidth > 600
                                                          ? 16
                                                          : 13;
                                                  double buttonPadding = screenWidth > 900
                                                      ? 30
                                                      : screenWidth > 600
                                                          ? 25
                                                          : 20;

                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),


                                        //responsive SizedBox for spacing
                                        Builder(
                                          builder: (context) {
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double offsetY = screenWidth < 600
                                                ? -70
                                                : screenWidth < 1024
                                                    ? 40
                                                    : 120;
                                            return Transform.translate(
                                              offset: Offset(0, offsetY),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double screenWidth = constraints.maxWidth;
                                                  bool isMobile = screenWidth < 600;
                                                  bool isTablet = screenWidth >= 600 && screenWidth < 1024;

                                                  double cardWidth = isMobile
                                                      ? double.infinity
                                                      : isTablet
                                                          ? (screenWidth / 2) - 32
                                                          : 650;
                                                  double imageHeight = isMobile
                                                      ? 60
                                                      : isTablet
                                                          ? 80
                                                          : 100;
                                                  double fontSizeTitle = isMobile ? 16 : 20;
                                                  double fontSizeDesc = isMobile ? 12 : 14;
                                                  double buttonFontSize = isMobile ? 11.36 : 14;
                                                  double buttonPaddingH = isMobile ? 15 : 20;
                                                  double buttonPaddingV = isMobile ? 15 : 18;
                                                  double cardPadding = isMobile ? 20 : 40;

                                                  Widget buildCard({
                                                    required Color color,
                                                    required String title,
                                                    required String desc,
                                                    required String imagePath,
                                                    required Color buttonColor,
                                                    required Color buttonTextColor,
                                                    required double imageHeight,
                                                  }) {
                                                    return Container(
                                                      width: cardWidth,
                                                      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0, right: isMobile ? 0 : 16),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(cardPadding),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: fontSizeTitle,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Text(
                                                              desc,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: fontSizeDesc,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {},
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: buttonColor,
                                                                    foregroundColor: buttonTextColor,
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: buttonPaddingH,
                                                                      vertical: buttonPaddingV,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Get Started",
                                                                        style: TextStyle(
                                                                          fontSize: buttonFontSize,
                                                                          fontWeight: FontWeight.w500,
                                                                          fontFamily: "DMSans",
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 5),
                                                                      Icon(Icons.arrow_outward_sharp, size: isMobile ? 20 : 24),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Image.asset(
                                                                  imagePath,
                                                                  height: imageHeight,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  final card1 = buildCard(
                                                    color: Color.fromRGBO(233, 242, 255, 1),
                                                    title: "Are You Looking \nFor a Car?",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/lookingCar.png",
                                                    buttonColor: Color.fromRGBO(26, 76, 142, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );

                                                  final card2 = buildCard(
                                                    color: Color.fromRGBO(255, 233, 243, 1),
                                                    title: "Best place for \ncar financing",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/carFinance.png",
                                                    buttonColor: Color.fromRGBO(5, 11, 32, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );

                                                  if (isMobile) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [card1, card2],
                                                    );
                                                  } else {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [card1, card2],
                                                    );
                                                  }
                                                },
                                              ), // Wrap the widget you want to shift upward
                                            );
                                          },
                                        ),
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
                  );
                }

                  Widget Sedan() {
                    // List of keywords to match sedan cars
                    final List<String> sedanKeywords = [
                      "camry", "accord", "elantra", "3 series", "c-class", "e-class", "sedan",
                      "avalon", "crown", "yaris sedan", "etios", "city", "amaze", "civic", "verna", "aura",
                      "dzire", "ciaz", "slavia", "octavia", "superb", "virtus", "vento", "passat",
                      "tigor", "zest", "sunny", "altima", "k5", "optima", "rio sedan", "aspire",
                      "fiesta sedan", "mondeo", "taurus", "cruze", "malibu", "aveo", "logan", "taliant",
                      "mazda6", "mazda3 sedan", "a3 sedan", "a4", "a6", "a8", "es", "is", "ls", "xe", "xf",
                      "g70", "g80", "g90", "5 series", "7 series", "s-class", "legend", "insight", "forenza",
                      "verona", "pegas", "sonata", "coupe", "cayman", "bmw", "gran coupe", "mercedes", "audi", 
                      "tt", "lexus", "infiniti", "volvo", "jaguar", "porsche", "tesla", "6 series"
                    ];

                    // Filter cars for sedans using keywords (case-insensitive)
                    List<Map<String, dynamic>> sedanCars = cars.where((car) {
                      final name = (car["name"] ?? "").toString().toLowerCase();
                      // Check if any keyword is in the car name
                      return sedanKeywords.any((keyword) => name.contains(keyword));
                    }).toList();

                    // If no sedan cars found, show a message
                    if (sedanCars.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: const [
                            Text("Sedan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                            SizedBox(height: 20),
                            Text("No sedan cars available.", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    // If only one sedan, show as a single card (reuse your card UI)
                    if (sedanCars.length == 1) {
                      final car = sedanCars.first;
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: [
                            const Text("Sedan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 20),
                            // Use the same card UI as in your All() carousel
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Copy the card UI from your All() carousel here, using `car`
                                // For brevity, you can call a helper widget if you want
                                return _buildCarCard(car, constraints, context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    // If more than one sedan, show as a carousel (same as All() tab)
                    return Column(
                        children: [
                    
                          Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: buildBrandCards(context),
                            ),
                            const SizedBox(height: 20,),
                            
                            Stack(
                              children: [
                                CarouselSlider(
                                  carouselController: innerCarouselController,
                                  options: CarouselOptions(
                                    height: MediaQuery.of(context).size.height * 0.8,
                                    autoPlay: false,
                                    enableInfiniteScroll: true,
                                    enlargeCenterPage: false,
                                    viewportFraction: 1,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        innerCurrentPage = index;
                                      });
                                    },
                                  ),
                                  items: sedanCars.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Map<String, dynamic> car = entry.value;
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Copy the card UI from your All() carousel here, using `car`
                                        return _buildCarCard(car, constraints, context);
                                      },
                                    );
                                  }).toList(),
                                ),
                                if (innerCurrentPage >= 0)
                                  Positioned(
                                    height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                    left: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                    top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        innerCarouselController.animateToPage(innerCurrentPage - 1, curve: Curves.easeIn);
                                      },
                                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                      child: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                                      mini: true,
                                    ),
                                  ),
                                if (innerCurrentPage <= sedanCars.length - 1)
                                  Positioned(
                                    height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                    right: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                    top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        innerCarouselController.animateToPage(innerCurrentPage + 1, curve: Curves.easeIn);
                                      },
                                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                      child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                                      mini: true,
                                    ),
                                  ),
                              ],
                            ),
                        
                            SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
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
                                  imageSize = (screenWidth / 3) - 30; 
                                }
                                imageSize = imageSize.clamp(80.0, 300.0);
                    
                                double titleFontSize = screenWidth > 600 ? 40 : screenWidth * 0.08;
                                
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
                                                    fontSize: screenHeight * 0.038,
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
                                                    fontSize: screenHeight * 0.02,
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
                                      SizedBox(height: screenHeight * 0.05),
                    
                                      //Similar Brands Section
                                      Column(
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Builder(
                                                builder: (context) {
                                                  print('[buildBrands] isLoadingBrands: $isLoadingBrands, errorMessageBrands: $errorMessageBrands, brands: $brands');
                                                  if (isLoadingBrands) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }
                                                  if (errorMessageBrands != null) {
                                                    return Center(child: Text(errorMessageBrands!));
                                                  }
                                                  if (brands.isEmpty) {
                                                    return const Center(child: Text('No brands available'));
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.all(0.0),
                                                    child: Wrap(
                                                      spacing: screenWidth * 0.05,
                                                      runSpacing: screenHeight * 0.02,
                                                      children: brands.map((brand) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(width: 1, color: const Color.fromRGBO(233, 233, 233, 1)),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Column(
                                                              children: [
                                                                Image.asset(
                                                                  brand["image"] ?? 'assets/placeholder.png',
                                                                  width: imageSize,
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                    'assets/placeholder.png',
                                                                    width: imageSize,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  brand["name"] ?? 'Unknown Brand',
                                                                  style: const TextStyle(fontFamily: "DMSans"),
                                                                  textAlign: TextAlign.center,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                  maxLines: 2, // Allow up to 2 lines
                                                                ),
                                                                SizedBox(height: screenHeight * 0.02),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      ),
                    
                    
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          double screenWidth = MediaQuery.of(context).size.width;
                                          double imageWidth = screenWidth * 0.40;
                                          double imageHeight = (imageWidth * 9 / 16) * 1.49;
                                          double playButtonSize = screenWidth * 0.052;
                                          double sectionSpacing = screenWidth * 0.01;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: sectionSpacing),
                    
                                          // Responsive "video + info" section
                                          Builder(
                                            builder: (context) {
                                              final screenWidth = MediaQuery.of(context).size.width;
                                              final isMobile = screenWidth < 800;
                                              final isTablet = screenWidth >= 800 && screenWidth < 1024;
                                              final isDesktop = screenWidth >= 1024;
                    
                                              // Responsive sizes
                                              double imageWidth, imageHeight, playButtonSize, infoPadding, titleFontSize, descFontSize, bulletFontSize, buttonFontSize, sectionSpacing;
                                              if (isMobile) {
                                                imageWidth = screenWidth * 0.9;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 40;
                                                infoPadding = 16;
                                                titleFontSize = 18;
                                                descFontSize = 12;
                                                bulletFontSize = 12;
                                                buttonFontSize = 14;
                                                sectionSpacing = 10;
                                              } else if (isTablet) {
                                                imageWidth = screenWidth * 0.4;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 50;
                                                infoPadding = 32;
                                                titleFontSize = 24;
                                                descFontSize = 14;
                                                bulletFontSize = 14;
                                                buttonFontSize = 16;
                                                sectionSpacing = 16;
                                              } else {
                                                imageWidth = screenWidth * 0.35;
                                                imageHeight = screenWidth * 0.33;
                                                playButtonSize = 60;
                                                infoPadding = 70;
                                                titleFontSize = 32;
                                                descFontSize = 16;
                                                bulletFontSize = 16;
                                                buttonFontSize = 18;
                                                sectionSpacing = 24;
                                              }
                    
                                              Widget imageStack = Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      bottomLeft: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      topRight: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      bottomRight: Radius.circular(0),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/videoImage.jpeg",
                                                      width: imageWidth,
                                                      height: imageHeight,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: playButtonSize / 2,
                                                    backgroundColor: Colors.white,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      size: playButtonSize * 0.5,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              );
                    
                                              Widget infoSection = Container(
                                                width: isMobile ? double.infinity : screenWidth * 0.48,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(238, 241, 251, 1),
                                                  borderRadius: isMobile
                                                      ? BorderRadius.only(
                                                          bottomLeft: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        )
                                                      : null,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(infoPadding),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Buying a car has never been this easy.",
                                                        style: TextStyle(
                                                          fontSize: titleFontSize,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Text(
                                                        "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                                        style: TextStyle(
                                                          fontSize: descFontSize,
                                                          color: Color.fromRGBO(5, 11, 32, 1),
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          buildBulletPoint(
                                                            "We are the UK's largest provider, with more patrols in more places",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "You get 24/7 roadside assistance",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "We fix 4 out of 5 cars at the roadside",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _bookTestDrive();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color(0xFF004C90),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: infoPadding,
                                                            vertical: infoPadding / 2.5,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "Book a test drive",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: buttonFontSize,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            SizedBox(width: sectionSpacing / 2),
                                                            Icon(Icons.arrow_outward, color: Colors.white, size: buttonFontSize + 2),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                    
                                              if (isMobile) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                    
                                          SizedBox(height: sectionSpacing),
                                          Builder(
                                            builder: (context) {
                                              double screenWidth = MediaQuery.of(context).size.width;
                                              int crossAxisCount;
                                              if (screenWidth < 600) {
                                                crossAxisCount = 2;
                                              } else if (screenWidth < 1024) {
                                                crossAxisCount = 4;
                                              } else {
                                                crossAxisCount = 4;
                                              }
                                              return Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  buildStatBox("836M", "CARS FOR SALE", context),
                                                  buildStatBox("738M", "DEALER REVIEWS", context),
                                                  buildStatBox("100M", "VISITORS PER DAY", context),
                                                  buildStatBox("238M", "VERIFIED DEALERS", context),
                                                ],
                                              );
                                            },
                                          ),
                    
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromRGBO(223, 223, 223, 1),
                                          ),
                                          SizedBox(height: sectionSpacing),
                    
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Why Choose Us?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenHeight * 0.038, fontFamily: "DMSans",),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double screenWidth = MediaQuery.of(context).size.width;
                                                bool isMobile = screenWidth < 600;
                    
                                                double imageSize;
                                                double titleFontSize;
                                                double descFontSize;
                                                if (screenWidth >= 1024) {
                                                  // Desktop
                                                  imageSize = 52;
                                                  titleFontSize = 22;
                                                  descFontSize = 15;
                                                } else if (screenWidth >= 600) {
                                                  // Tablet
                                                  imageSize = 40;
                                                  titleFontSize = 19;
                                                  descFontSize = 15;
                                                } else {
                                                  // Mobile
                                                  imageSize = 33;
                                                  titleFontSize = 15;
                                                  descFontSize = 13;
                                                }
                    
                                                List<Widget> infoBlocks = [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/financialOffer.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Special Financing Offers", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/dealership.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Trusted Car Dealership", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/transparent.png", height: imageSize),
                                                      SizedBox(height: screenWidth*0.02),
                                                      Text("Transparent Pricing", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/expertCar.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Expert Car Service", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                ];
                    
                                                if (isMobile) {
                                                  // Display vertically for mobile
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                } else {
                                                  // Display horizontally for tablet/desktop
                                                  return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(right: screenWidth * 0.02),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                }
                                              }
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.1),
                                          
                                          Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(249, 251, 252, 1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  right: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  top: screenWidth >= 1024
                                                      ? screenHeight * 0.10
                                                      : screenWidth >= 600
                                                          ? screenHeight * 0.06
                                                          : 16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // You can adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          double textSize;
                                                          double subTextSize;
                                                          if (constraints.maxWidth >= 1024) {
                                                            textSize = 28;
                                                            subTextSize = 14;
                                                          } else if (constraints.maxWidth >= 600) {
                                                            textSize = 24;
                                                            subTextSize = 12;
                                                          } else {
                                                            textSize = 18;
                                                            subTextSize = 10;
                                                          }
                    
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              isMobile
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // Adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          bool isDesktop = constraints.maxWidth >= 1024;
                                                          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          double containerHeight = isDesktop
                                                              ? 490
                                                              : isTablet
                                                                  ? 420
                                                                  : 320;
                                                          double containerWidth = isDesktop
                                                              ? screenWidth * 0.9
                                                              : isTablet
                                                                  ? screenWidth * 0.95
                                                                  : screenWidth * 0.98;
                                                          double imageWidth = isDesktop
                                                              ? 480
                                                              : isTablet
                                                                  ? 300
                                                                  : containerWidth;
                                                          double imageHeight = isDesktop
                                                              ? 550
                                                              : isTablet
                                                                  ? 380
                                                                  : 180;
                                                          double nameSize = isDesktop
                                                              ? 18
                                                              : isTablet
                                                                  ? 16
                                                                  : 14;
                                                          double designationSize = isDesktop
                                                              ? 15
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                                                          double reviewTextSize = isDesktop
                                                              ? 22
                                                              : isTablet
                                                                  ? 16
                                                                  : 12;
                                                          double starSize = isDesktop
                                                              ? 16
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                    
                                                          return Builder(
                                                            builder: (context) {
                                                              if (isLoadingReviews) {
                                                                return Center(child: CircularProgressIndicator());
                                                              }
                                                              if (errorMessageReviews != null) {
                                                                return Center(child: Text(errorMessageReviews!));
                                                              }
                                                              if (reviews.isEmpty) {
                                                                return Center(child: Text('No high-rated reviews available'));
                                                              }
                                                              return CarouselSlider(
                                                                carouselController: reviewCarouselController,
                                                                options: CarouselOptions(
                                                                  height: containerHeight,
                                                                  autoPlay: false,
                                                                  enlargeCenterPage: false,
                                                                  enableInfiniteScroll: false,
                                                                  viewportFraction: 1,
                                                                  onPageChanged: (index, reason) {
                                                                    setState(() {
                                                                      reviewCurrentPage = index;
                                                                    });
                                                                  },
                                                                ),
                                                                items: reviews.asMap().entries.map((entry) {
                                                                  int index = entry.key;
                                                                  Map<String, dynamic> review = entry.value;
                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(0.0),
                                                                    child: Container(
                                                                      height: containerHeight,
                                                                      width: containerWidth,
                                                                      child: isMobile
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Row(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: List.generate(5, (starIndex) {
                                                                                        return Icon(
                                                                                          starIndex < (review["rating"] ?? 0)
                                                                                              ? Icons.star
                                                                                              : Icons.star_border,
                                                                                          color: Color.fromRGBO(225, 192, 63, 1),
                                                                                          size: starSize.toDouble(),
                                                                                        );
                                                                                      }),
                                                                                    ),
                                                                                    SizedBox(width: 6),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color.fromRGBO(225, 192, 63, 1),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 10, vertical: 2),
                                                                                        child: Text(
                                                                                          (review["rating"] ?? 0).toStringAsFixed(1),
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  review["name"] ?? 'Anonymous',
                                                                                  style: TextStyle(
                                                                                    fontSize: nameSize,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 4),
                                                                                Text(
                                                                                  review["designation"] ?? 'Reviewer',
                                                                                  style: TextStyle(
                                                                                    fontSize: designationSize,
                                                                                    color: Color.fromRGBO(139, 139, 139, 1),
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Text(
                                                                                  review["review"] ?? 'No review provided',
                                                                                  style: TextStyle(fontSize: reviewTextSize),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 24),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: List.generate(5, (starIndex) {
                                                                                                return Icon(
                                                                                                  starIndex < (review["rating"] ?? 0)
                                                                                                      ? Icons.star
                                                                                                      : Icons.star_border,
                                                                                                  color:
                                                                                                      Color.fromRGBO(225, 192, 63, 1),
                                                                                                  size: starSize.toDouble(),
                                                                                                );
                                                                                              }),
                                                                                            ),
                                                                                            SizedBox(width: 10),
                                                                                            Container(
                                                                                              decoration: BoxDecoration(
                                                                                                color:
                                                                                                    Color.fromRGBO(225, 192, 63, 1),
                                                                                                borderRadius:
                                                                                                    BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.symmetric(
                                                                                                    horizontal: 10, vertical: 2),
                                                                                                child: Text(
                                                                                                  (review["rating"] ?? 0)
                                                                                                      .toStringAsFixed(1),
                                                                                                  style: TextStyle(
                                                                                                    fontSize: designationSize,
                                                                                                    color: Colors.white,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: 16),
                                                                                        Text(
                                                                                          review["name"] ?? 'Anonymous',
                                                                                          style: TextStyle(
                                                                                            fontSize: nameSize,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 8),
                                                                                        Text(
                                                                                          review["designation"] ?? 'Reviewer',
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Color.fromRGBO(139, 139, 139, 1),
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 24),
                                                                                        Text(
                                                                                          review["review"] ?? 'No review provided',
                                                                                          style: TextStyle(fontSize: reviewTextSize),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Left button
                                          if (reviewCurrentPage >= 0)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              left: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage - 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  highlightElevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_back_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          // Right button
                                          if (reviewCurrentPage <= reviews.length - 1)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              right: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage + 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                              
                                        SizedBox(height: 40),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double fontSize = constraints.maxWidth > 600 ? 28 : 23;
                                            double paddingValue = constraints.maxWidth > 600 ? 20.0 : 10.0;
                                              
                                            return Padding(
                                              padding: EdgeInsets.all(paddingValue),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Latest Blog Posts",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
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
                                                                fontSize: screenHeight * 0.02,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_outward,
                                                              color: Color.fromRGBO(0, 147, 255, 1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                              
                                        
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double screenWidth = constraints.maxWidth;
                    
                                            if (screenWidth < 600) {
                                              // Mobile: Use CarouselSlider
                                              return CarouselSlider(
                                                options: CarouselOptions(
                                                  height: 420, // Adjust as needed
                                                  enableInfiniteScroll: true,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.9,
                                                ),
                                                items: blogs.map((blog) {
                                                  double imageHeight = 220;
                                                  double textSize = 13;
                                                  double buttonPadding = 20;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            } else {
                                              // Tablet/Web: Use GridView
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: screenWidth > 900
                                                      ? 3
                                                      : screenWidth > 600
                                                          ? 2
                                                          : 1,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: screenWidth > 900
                                                      ? 1.2
                                                      : screenWidth > 600
                                                          ? 1.1
                                                          : 0.9,
                                                ),
                                                itemCount: blogs.length,
                                                itemBuilder: (context, index) {
                                                  final blog = blogs[index];
                                                  double imageHeight = screenWidth > 900
                                                      ? 360
                                                      : screenWidth > 600
                                                          ? 280
                                                          : 220;
                                                  double textSize = screenWidth > 900
                                                      ? 22
                                                      : screenWidth > 600
                                                          ? 16
                                                          : 13;
                                                  double buttonPadding = screenWidth > 900
                                                      ? 30
                                                      : screenWidth > 600
                                                          ? 25
                                                          : 20;
                    
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                    
                    
                                        //responsive SizedBox for spacing
                                        Builder(
                                          builder: (context) {
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double offsetY = screenWidth < 600
                                                ? -70
                                                : screenWidth < 1024
                                                    ? 40
                                                    : 120;
                                            return Transform.translate(
                                              offset: Offset(0, offsetY),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double screenWidth = constraints.maxWidth;
                                                  bool isMobile = screenWidth < 600;
                                                  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                    
                                                  double cardWidth = isMobile
                                                      ? double.infinity
                                                      : isTablet
                                                          ? (screenWidth / 2) - 32
                                                          : 650;
                                                  double imageHeight = isMobile
                                                      ? 60
                                                      : isTablet
                                                          ? 80
                                                          : 100;
                                                  double fontSizeTitle = isMobile ? 16 : 20;
                                                  double fontSizeDesc = isMobile ? 12 : 14;
                                                  double buttonFontSize = isMobile ? 11.36 : 14;
                                                  double buttonPaddingH = isMobile ? 15 : 20;
                                                  double buttonPaddingV = isMobile ? 15 : 18;
                                                  double cardPadding = isMobile ? 20 : 40;
                    
                                                  Widget buildCard({
                                                    required Color color,
                                                    required String title,
                                                    required String desc,
                                                    required String imagePath,
                                                    required Color buttonColor,
                                                    required Color buttonTextColor,
                                                    required double imageHeight,
                                                  }) {
                                                    return Container(
                                                      width: cardWidth,
                                                      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0, right: isMobile ? 0 : 16),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(cardPadding),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: fontSizeTitle,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Text(
                                                              desc,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: fontSizeDesc,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {},
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: buttonColor,
                                                                    foregroundColor: buttonTextColor,
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: buttonPaddingH,
                                                                      vertical: buttonPaddingV,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Get Started",
                                                                        style: TextStyle(
                                                                          fontSize: buttonFontSize,
                                                                          fontWeight: FontWeight.w500,
                                                                          fontFamily: "DMSans",
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 5),
                                                                      Icon(Icons.arrow_outward_sharp, size: isMobile ? 20 : 24),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Image.asset(
                                                                  imagePath,
                                                                  height: imageHeight,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                    
                                                  final card1 = buildCard(
                                                    color: Color.fromRGBO(233, 242, 255, 1),
                                                    title: "Are You Looking \nFor a Car?",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/lookingCar.png",
                                                    buttonColor: Color.fromRGBO(26, 76, 142, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  final card2 = buildCard(
                                                    color: Color.fromRGBO(255, 233, 243, 1),
                                                    title: "Best place for \ncar financing",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/carFinance.png",
                                                    buttonColor: Color.fromRGBO(5, 11, 32, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  if (isMobile) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [card1, card2],
                                                    );
                                                  } else {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [card1, card2],
                                                    );
                                                  }
                                                },
                                              ), // Wrap the widget you want to shift upward
                                            );
                                          },
                                        ),
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
                    );
                  }

              
                  Widget Hatchback() {
                    final List<String> hatchbackKeywords = [
                      "golf", "polo", "id.3", "fit", "jazz", "civic hatchback", "focus", "fiesta", "puma",
                      "yaris", "corolla hatchback", "aqua", "i10", "nios", "i20", "i30", "veloster", "rio", "ceed", "picanto",
                      "mazda 2", "mazda2", "mazda3 hatchback", "swift", "baleno", "celerio", "spark", "aveo hatchback",
                      "clio", "zoe", "sandero", "208", "308", "micra", "leaf", "note", "fabia", "scala", "citigo",
                      "ibiza", "leon hatchback", "mini", "clubman", "mini electric", "fiat 500", "panda", "punto",
                      "dacia sandero", "corsa", "astra hatchback", "mirage", "c3", "c4", "impreza hatchback",
                      "xv", "crosstrek", "hatchback"
                    ];

                    List<Map<String, dynamic>> hatchbackCars = cars.where((car) {
                      final name = (car["name"] ?? "").toString().toLowerCase();
                      return hatchbackKeywords.any((keyword) => name.contains(keyword));
                    }).toList();

                    if (hatchbackCars.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: const [
                            Text("Hatchback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                            SizedBox(height: 20),
                            Text("No hatchback cars available.", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    if (hatchbackCars.length == 1) {
                      final car = hatchbackCars.first;
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildCarCard(car, constraints, context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: buildBrandCards(context),
                          ),
                          const SizedBox(height: 20,),
                    
                        Stack(
                          children: [
                            CarouselSlider(
                              carouselController: innerCarouselController,
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.height * 0.8,
                                autoPlay: false,
                                enableInfiniteScroll: true,
                                enlargeCenterPage: false,
                                viewportFraction: 1,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    innerCurrentPage = index;
                                  });
                                },
                              ),
                              items: hatchbackCars.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, dynamic> car = entry.value;
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return _buildCarCard(car, constraints, context);
                                  },
                                );
                              }).toList(),
                            ),
                            if (innerCurrentPage >= 0)
                              Positioned(
                                height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                left: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    innerCarouselController.animateToPage(innerCurrentPage - 1, curve: Curves.easeIn);
                                  },
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  child: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                                  mini: true,
                                ),
                              ),
                            if (innerCurrentPage <= hatchbackCars.length - 1)
                              Positioned(
                                height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                right: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    innerCarouselController.animateToPage(innerCurrentPage + 1, curve: Curves.easeIn);
                                  },
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                                  mini: true,
                                ),
                              ),
                          ],
                        ),
                      
                            SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
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
                                  imageSize = (screenWidth / 3) - 30; 
                                }
                                imageSize = imageSize.clamp(80.0, 300.0);
                    
                                double titleFontSize = screenWidth > 600 ? 40 : screenWidth * 0.08;
                                
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
                                                    fontSize: screenHeight * 0.038,
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
                                                    fontSize: screenHeight * 0.02,
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
                                      SizedBox(height: screenHeight * 0.05),
                    
                                      //Similar Brands Section
                                      Column(
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Builder(
                                                builder: (context) {
                                                  print('[buildBrands] isLoadingBrands: $isLoadingBrands, errorMessageBrands: $errorMessageBrands, brands: $brands');
                                                  if (isLoadingBrands) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }
                                                  if (errorMessageBrands != null) {
                                                    return Center(child: Text(errorMessageBrands!));
                                                  }
                                                  if (brands.isEmpty) {
                                                    return const Center(child: Text('No brands available'));
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.all(0.0),
                                                    child: Wrap(
                                                      spacing: screenWidth * 0.05,
                                                      runSpacing: screenHeight * 0.02,
                                                      children: brands.map((brand) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(width: 1, color: const Color.fromRGBO(233, 233, 233, 1)),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Column(
                                                              children: [
                                                                Image.asset(
                                                                  brand["image"] ?? 'assets/placeholder.png',
                                                                  width: imageSize,
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                    'assets/placeholder.png',
                                                                    width: imageSize,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  brand["name"] ?? 'Unknown Brand',
                                                                  style: const TextStyle(fontFamily: "DMSans"),
                                                                  textAlign: TextAlign.center,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                  maxLines: 2, // Allow up to 2 lines
                                                                ),
                                                                SizedBox(height: screenHeight * 0.02),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      ),
                    
                    
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          double screenWidth = MediaQuery.of(context).size.width;
                                          double imageWidth = screenWidth * 0.40;
                                          double imageHeight = (imageWidth * 9 / 16) * 1.49;
                                          double playButtonSize = screenWidth * 0.052;
                                          double sectionSpacing = screenWidth * 0.01;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: sectionSpacing),
                    
                                          // Responsive "video + info" section
                                          Builder(
                                            builder: (context) {
                                              final screenWidth = MediaQuery.of(context).size.width;
                                              final isMobile = screenWidth < 800;
                                              final isTablet = screenWidth >= 800 && screenWidth < 1024;
                                              final isDesktop = screenWidth >= 1024;
                    
                                              // Responsive sizes
                                              double imageWidth, imageHeight, playButtonSize, infoPadding, titleFontSize, descFontSize, bulletFontSize, buttonFontSize, sectionSpacing;
                                              if (isMobile) {
                                                imageWidth = screenWidth * 0.9;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 40;
                                                infoPadding = 16;
                                                titleFontSize = 18;
                                                descFontSize = 12;
                                                bulletFontSize = 12;
                                                buttonFontSize = 14;
                                                sectionSpacing = 10;
                                              } else if (isTablet) {
                                                imageWidth = screenWidth * 0.4;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 50;
                                                infoPadding = 32;
                                                titleFontSize = 24;
                                                descFontSize = 14;
                                                bulletFontSize = 14;
                                                buttonFontSize = 16;
                                                sectionSpacing = 16;
                                              } else {
                                                imageWidth = screenWidth * 0.35;
                                                imageHeight = screenWidth * 0.33;
                                                playButtonSize = 60;
                                                infoPadding = 70;
                                                titleFontSize = 32;
                                                descFontSize = 16;
                                                bulletFontSize = 16;
                                                buttonFontSize = 18;
                                                sectionSpacing = 24;
                                              }
                    
                                              Widget imageStack = Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      bottomLeft: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      topRight: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      bottomRight: Radius.circular(0),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/videoImage.jpeg",
                                                      width: imageWidth,
                                                      height: imageHeight,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: playButtonSize / 2,
                                                    backgroundColor: Colors.white,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      size: playButtonSize * 0.5,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              );
                    
                                              Widget infoSection = Container(
                                                width: isMobile ? double.infinity : screenWidth * 0.48,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(238, 241, 251, 1),
                                                  borderRadius: isMobile
                                                      ? BorderRadius.only(
                                                          bottomLeft: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        )
                                                      : null,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(infoPadding),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Buying a car has never been this easy.",
                                                        style: TextStyle(
                                                          fontSize: titleFontSize,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Text(
                                                        "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                                        style: TextStyle(
                                                          fontSize: descFontSize,
                                                          color: Color.fromRGBO(5, 11, 32, 1),
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          buildBulletPoint(
                                                            "We are the UK's largest provider, with more patrols in more places",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "You get 24/7 roadside assistance",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "We fix 4 out of 5 cars at the roadside",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _bookTestDrive();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color(0xFF004C90),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: infoPadding,
                                                            vertical: infoPadding / 2.5,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "Book a test drive",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: buttonFontSize,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            SizedBox(width: sectionSpacing / 2),
                                                            Icon(Icons.arrow_outward, color: Colors.white, size: buttonFontSize + 2),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                    
                                              if (isMobile) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                    
                                          SizedBox(height: sectionSpacing),
                                          Builder(
                                            builder: (context) {
                                              double screenWidth = MediaQuery.of(context).size.width;
                                              int crossAxisCount;
                                              if (screenWidth < 600) {
                                                crossAxisCount = 2;
                                              } else if (screenWidth < 1024) {
                                                crossAxisCount = 4;
                                              } else {
                                                crossAxisCount = 4;
                                              }
                                              return Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  buildStatBox("836M", "CARS FOR SALE", context),
                                                  buildStatBox("738M", "DEALER REVIEWS", context),
                                                  buildStatBox("100M", "VISITORS PER DAY", context),
                                                  buildStatBox("238M", "VERIFIED DEALERS", context),
                                                ],
                                              );
                                            },
                                          ),
                    
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromRGBO(223, 223, 223, 1),
                                          ),
                                          SizedBox(height: sectionSpacing),
                    
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Why Choose Us?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenHeight * 0.038, fontFamily: "DMSans",),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double screenWidth = MediaQuery.of(context).size.width;
                                                bool isMobile = screenWidth < 600;
                    
                                                double imageSize;
                                                double titleFontSize;
                                                double descFontSize;
                                                if (screenWidth >= 1024) {
                                                  // Desktop
                                                  imageSize = 52;
                                                  titleFontSize = 22;
                                                  descFontSize = 15;
                                                } else if (screenWidth >= 600) {
                                                  // Tablet
                                                  imageSize = 40;
                                                  titleFontSize = 19;
                                                  descFontSize = 15;
                                                } else {
                                                  // Mobile
                                                  imageSize = 33;
                                                  titleFontSize = 15;
                                                  descFontSize = 13;
                                                }
                    
                                                List<Widget> infoBlocks = [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/financialOffer.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Special Financing Offers", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/dealership.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Trusted Car Dealership", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/transparent.png", height: imageSize),
                                                      SizedBox(height: screenWidth*0.02),
                                                      Text("Transparent Pricing", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/expertCar.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Expert Car Service", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                ];
                    
                                                if (isMobile) {
                                                  // Display vertically for mobile
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                } else {
                                                  // Display horizontally for tablet/desktop
                                                  return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(right: screenWidth * 0.02),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                }
                                              }
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.1),
                                          
                                          Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(249, 251, 252, 1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  right: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  top: screenWidth >= 1024
                                                      ? screenHeight * 0.10
                                                      : screenWidth >= 600
                                                          ? screenHeight * 0.06
                                                          : 16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // You can adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          double textSize;
                                                          double subTextSize;
                                                          if (constraints.maxWidth >= 1024) {
                                                            textSize = 28;
                                                            subTextSize = 14;
                                                          } else if (constraints.maxWidth >= 600) {
                                                            textSize = 24;
                                                            subTextSize = 12;
                                                          } else {
                                                            textSize = 18;
                                                            subTextSize = 10;
                                                          }
                    
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              isMobile
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // Adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          bool isDesktop = constraints.maxWidth >= 1024;
                                                          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          double containerHeight = isDesktop
                                                              ? 490
                                                              : isTablet
                                                                  ? 420
                                                                  : 320;
                                                          double containerWidth = isDesktop
                                                              ? screenWidth * 0.9
                                                              : isTablet
                                                                  ? screenWidth * 0.95
                                                                  : screenWidth * 0.98;
                                                          double imageWidth = isDesktop
                                                              ? 480
                                                              : isTablet
                                                                  ? 300
                                                                  : containerWidth;
                                                          double imageHeight = isDesktop
                                                              ? 550
                                                              : isTablet
                                                                  ? 380
                                                                  : 180;
                                                          double nameSize = isDesktop
                                                              ? 18
                                                              : isTablet
                                                                  ? 16
                                                                  : 14;
                                                          double designationSize = isDesktop
                                                              ? 15
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                                                          double reviewTextSize = isDesktop
                                                              ? 22
                                                              : isTablet
                                                                  ? 16
                                                                  : 12;
                                                          double starSize = isDesktop
                                                              ? 16
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                    
                                                          return Builder(
                                                            builder: (context) {
                                                              if (isLoadingReviews) {
                                                                return Center(child: CircularProgressIndicator());
                                                              }
                                                              if (errorMessageReviews != null) {
                                                                return Center(child: Text(errorMessageReviews!));
                                                              }
                                                              if (reviews.isEmpty) {
                                                                return Center(child: Text('No high-rated reviews available'));
                                                              }
                                                              return CarouselSlider(
                                                                carouselController: reviewCarouselController,
                                                                options: CarouselOptions(
                                                                  height: containerHeight,
                                                                  autoPlay: false,
                                                                  enlargeCenterPage: false,
                                                                  enableInfiniteScroll: false,
                                                                  viewportFraction: 1,
                                                                  onPageChanged: (index, reason) {
                                                                    setState(() {
                                                                      reviewCurrentPage = index;
                                                                    });
                                                                  },
                                                                ),
                                                                items: reviews.asMap().entries.map((entry) {
                                                                  int index = entry.key;
                                                                  Map<String, dynamic> review = entry.value;
                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(0.0),
                                                                    child: Container(
                                                                      height: containerHeight,
                                                                      width: containerWidth,
                                                                      child: isMobile
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Row(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: List.generate(5, (starIndex) {
                                                                                        return Icon(
                                                                                          starIndex < (review["rating"] ?? 0)
                                                                                              ? Icons.star
                                                                                              : Icons.star_border,
                                                                                          color: Color.fromRGBO(225, 192, 63, 1),
                                                                                          size: starSize.toDouble(),
                                                                                        );
                                                                                      }),
                                                                                    ),
                                                                                    SizedBox(width: 6),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color.fromRGBO(225, 192, 63, 1),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 10, vertical: 2),
                                                                                        child: Text(
                                                                                          (review["rating"] ?? 0).toStringAsFixed(1),
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  review["name"] ?? 'Anonymous',
                                                                                  style: TextStyle(
                                                                                    fontSize: nameSize,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 4),
                                                                                Text(
                                                                                  review["designation"] ?? 'Reviewer',
                                                                                  style: TextStyle(
                                                                                    fontSize: designationSize,
                                                                                    color: Color.fromRGBO(139, 139, 139, 1),
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Text(
                                                                                  review["review"] ?? 'No review provided',
                                                                                  style: TextStyle(fontSize: reviewTextSize),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 24),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: List.generate(5, (starIndex) {
                                                                                                return Icon(
                                                                                                  starIndex < (review["rating"] ?? 0)
                                                                                                      ? Icons.star
                                                                                                      : Icons.star_border,
                                                                                                  color:
                                                                                                      Color.fromRGBO(225, 192, 63, 1),
                                                                                                  size: starSize.toDouble(),
                                                                                                );
                                                                                              }),
                                                                                            ),
                                                                                            SizedBox(width: 10),
                                                                                            Container(
                                                                                              decoration: BoxDecoration(
                                                                                                color:
                                                                                                    Color.fromRGBO(225, 192, 63, 1),
                                                                                                borderRadius:
                                                                                                    BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.symmetric(
                                                                                                    horizontal: 10, vertical: 2),
                                                                                                child: Text(
                                                                                                  (review["rating"] ?? 0)
                                                                                                      .toStringAsFixed(1),
                                                                                                  style: TextStyle(
                                                                                                    fontSize: designationSize,
                                                                                                    color: Colors.white,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: 16),
                                                                                        Text(
                                                                                          review["name"] ?? 'Anonymous',
                                                                                          style: TextStyle(
                                                                                            fontSize: nameSize,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 8),
                                                                                        Text(
                                                                                          review["designation"] ?? 'Reviewer',
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Color.fromRGBO(139, 139, 139, 1),
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 24),
                                                                                        Text(
                                                                                          review["review"] ?? 'No review provided',
                                                                                          style: TextStyle(fontSize: reviewTextSize),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Left button
                                          if (reviewCurrentPage >= 0)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              left: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage - 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  highlightElevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_back_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          // Right button
                                          if (reviewCurrentPage <= reviews.length - 1)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              right: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage + 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                              
                                        SizedBox(height: 40),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double fontSize = constraints.maxWidth > 600 ? 28 : 23;
                                            double paddingValue = constraints.maxWidth > 600 ? 20.0 : 10.0;
                                              
                                            return Padding(
                                              padding: EdgeInsets.all(paddingValue),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Latest Blog Posts",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
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
                                                                fontSize: screenHeight * 0.02,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_outward,
                                                              color: Color.fromRGBO(0, 147, 255, 1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                              
                                        
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double screenWidth = constraints.maxWidth;
                    
                                            if (screenWidth < 600) {
                                              // Mobile: Use CarouselSlider
                                              return CarouselSlider(
                                                options: CarouselOptions(
                                                  height: 420, // Adjust as needed
                                                  enableInfiniteScroll: true,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.9,
                                                ),
                                                items: blogs.map((blog) {
                                                  double imageHeight = 220;
                                                  double textSize = 13;
                                                  double buttonPadding = 20;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            } else {
                                              // Tablet/Web: Use GridView
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: screenWidth > 900
                                                      ? 3
                                                      : screenWidth > 600
                                                          ? 2
                                                          : 1,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: screenWidth > 900
                                                      ? 1.2
                                                      : screenWidth > 600
                                                          ? 1.1
                                                          : 0.9,
                                                ),
                                                itemCount: blogs.length,
                                                itemBuilder: (context, index) {
                                                  final blog = blogs[index];
                                                  double imageHeight = screenWidth > 900
                                                      ? 360
                                                      : screenWidth > 600
                                                          ? 280
                                                          : 220;
                                                  double textSize = screenWidth > 900
                                                      ? 22
                                                      : screenWidth > 600
                                                          ? 16
                                                          : 13;
                                                  double buttonPadding = screenWidth > 900
                                                      ? 30
                                                      : screenWidth > 600
                                                          ? 25
                                                          : 20;
                    
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                    
                    
                                        //responsive SizedBox for spacing
                                        Builder(
                                          builder: (context) {
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double offsetY = screenWidth < 600
                                                ? -70
                                                : screenWidth < 1024
                                                    ? 40
                                                    : 120;
                                            return Transform.translate(
                                              offset: Offset(0, offsetY),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double screenWidth = constraints.maxWidth;
                                                  bool isMobile = screenWidth < 600;
                                                  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                    
                                                  double cardWidth = isMobile
                                                      ? double.infinity
                                                      : isTablet
                                                          ? (screenWidth / 2) - 32
                                                          : 650;
                                                  double imageHeight = isMobile
                                                      ? 60
                                                      : isTablet
                                                          ? 80
                                                          : 100;
                                                  double fontSizeTitle = isMobile ? 16 : 20;
                                                  double fontSizeDesc = isMobile ? 12 : 14;
                                                  double buttonFontSize = isMobile ? 11.36 : 14;
                                                  double buttonPaddingH = isMobile ? 15 : 20;
                                                  double buttonPaddingV = isMobile ? 15 : 18;
                                                  double cardPadding = isMobile ? 20 : 40;
                    
                                                  Widget buildCard({
                                                    required Color color,
                                                    required String title,
                                                    required String desc,
                                                    required String imagePath,
                                                    required Color buttonColor,
                                                    required Color buttonTextColor,
                                                    required double imageHeight,
                                                  }) {
                                                    return Container(
                                                      width: cardWidth,
                                                      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0, right: isMobile ? 0 : 16),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(cardPadding),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: fontSizeTitle,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Text(
                                                              desc,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: fontSizeDesc,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {},
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: buttonColor,
                                                                    foregroundColor: buttonTextColor,
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: buttonPaddingH,
                                                                      vertical: buttonPaddingV,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Get Started",
                                                                        style: TextStyle(
                                                                          fontSize: buttonFontSize,
                                                                          fontWeight: FontWeight.w500,
                                                                          fontFamily: "DMSans",
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 5),
                                                                      Icon(Icons.arrow_outward_sharp, size: isMobile ? 20 : 24),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Image.asset(
                                                                  imagePath,
                                                                  height: imageHeight,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                    
                                                  final card1 = buildCard(
                                                    color: Color.fromRGBO(233, 242, 255, 1),
                                                    title: "Are You Looking \nFor a Car?",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/lookingCar.png",
                                                    buttonColor: Color.fromRGBO(26, 76, 142, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  final card2 = buildCard(
                                                    color: Color.fromRGBO(255, 233, 243, 1),
                                                    title: "Best place for \ncar financing",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/carFinance.png",
                                                    buttonColor: Color.fromRGBO(5, 11, 32, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  if (isMobile) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [card1, card2],
                                                    );
                                                  } else {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [card1, card2],
                                                    );
                                                  }
                                                },
                                              ), // Wrap the widget you want to shift upward
                                            );
                                          },
                                        ),
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
                    );
                  }

                  Widget SUV() {
                    final List<String> suvKeywords = [
                      "fortuner", "rav4", "highlander", "land cruiser", "urban cruiser", "corolla cross",
                      "creta", "tucson", "santa fe", "venue", "palisade", "seltos", "sonet", "sportage", "telluride",
                      "ecosport", "bronco", "escape", "edge", "explorer", "cr-v", "hr-v", "br-v", "pilot", "elevate",
                      "xuv700", "xuv300", "scorpio", "thar", "nexon", "harrier", "safari", "punch",
                      "taigun", "tiguan", "t-roc", "kushaq", "kodiaq", "kicks", "rogue", "pathfinder",
                      "compass", "grand cherokee", "wrangler", "renegade", "suv", "toyota tacoma", "pickup", "truck", "toyota"
                    ];

                    List<Map<String, dynamic>> suvCars = cars.where((car) {
                      final name = (car["name"] ?? "").toString().toLowerCase();
                      return suvKeywords.any((keyword) => name.contains(keyword));
                    }).toList();

                    if (suvCars.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: const [
                            Text("No SUV cars available.", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    if (suvCars.length == 1) {
                      final car = suvCars.first;
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: [
                            const Text("SUV's", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildCarCard(car, constraints, context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: buildBrandCards(context),
                        ),
                        const SizedBox(height: 20,),
                    
                        Stack(
                          children: [
                            CarouselSlider(
                              carouselController: innerCarouselController,
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.height * 0.8,
                                autoPlay: false,
                                enableInfiniteScroll: true,
                                enlargeCenterPage: false,
                                viewportFraction: 1,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    innerCurrentPage = index;
                                  });
                                },
                              ),
                              items: suvCars.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, dynamic> car = entry.value;
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return _buildCarCard(car, constraints, context);
                                  },
                                );
                              }).toList(),
                            ),
                            if (innerCurrentPage >= 0)
                              Positioned(
                                height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                left: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    innerCarouselController.animateToPage(innerCurrentPage - 1, curve: Curves.easeIn);
                                  },
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  child: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                                  mini: true,
                                ),
                              ),
                            if (innerCurrentPage <= suvCars.length - 1)
                              Positioned(
                                height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                right: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    innerCarouselController.animateToPage(innerCurrentPage + 1, curve: Curves.easeIn);
                                  },
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                                  mini: true,
                                ),
                              ),
                          ],
                        ),
                      
                          SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
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
                                  imageSize = (screenWidth / 3) - 30; 
                                }
                                imageSize = imageSize.clamp(80.0, 300.0);
                    
                                double titleFontSize = screenWidth > 600 ? 40 : screenWidth * 0.08;
                                
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
                                                    fontSize: screenHeight * 0.038,
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
                                                    fontSize: screenHeight * 0.02,
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
                                      SizedBox(height: screenHeight * 0.05),
                    
                                      //Similar Brands Section
                                      Column(
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Builder(
                                                builder: (context) {
                                                  print('[buildBrands] isLoadingBrands: $isLoadingBrands, errorMessageBrands: $errorMessageBrands, brands: $brands');
                                                  if (isLoadingBrands) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }
                                                  if (errorMessageBrands != null) {
                                                    return Center(child: Text(errorMessageBrands!));
                                                  }
                                                  if (brands.isEmpty) {
                                                    return const Center(child: Text('No brands available'));
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.all(0.0),
                                                    child: Wrap(
                                                      spacing: screenWidth * 0.05,
                                                      runSpacing: screenHeight * 0.02,
                                                      children: brands.map((brand) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(width: 1, color: const Color.fromRGBO(233, 233, 233, 1)),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Column(
                                                              children: [
                                                                Image.asset(
                                                                  brand["image"] ?? 'assets/placeholder.png',
                                                                  width: imageSize,
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                    'assets/placeholder.png',
                                                                    width: imageSize,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  brand["name"] ?? 'Unknown Brand',
                                                                  style: const TextStyle(fontFamily: "DMSans"),
                                                                  textAlign: TextAlign.center,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                  maxLines: 2, // Allow up to 2 lines
                                                                ),
                                                                SizedBox(height: screenHeight * 0.02),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      ),
                    
                    
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          double screenWidth = MediaQuery.of(context).size.width;
                                          double imageWidth = screenWidth * 0.40;
                                          double imageHeight = (imageWidth * 9 / 16) * 1.49;
                                          double playButtonSize = screenWidth * 0.052;
                                          double sectionSpacing = screenWidth * 0.01;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: sectionSpacing),
                    
                                          // Responsive "video + info" section
                                          Builder(
                                            builder: (context) {
                                              final screenWidth = MediaQuery.of(context).size.width;
                                              final isMobile = screenWidth < 800;
                                              final isTablet = screenWidth >= 800 && screenWidth < 1024;
                                              final isDesktop = screenWidth >= 1024;
                    
                                              // Responsive sizes
                                              double imageWidth, imageHeight, playButtonSize, infoPadding, titleFontSize, descFontSize, bulletFontSize, buttonFontSize, sectionSpacing;
                                              if (isMobile) {
                                                imageWidth = screenWidth * 0.9;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 40;
                                                infoPadding = 16;
                                                titleFontSize = 18;
                                                descFontSize = 12;
                                                bulletFontSize = 12;
                                                buttonFontSize = 14;
                                                sectionSpacing = 10;
                                              } else if (isTablet) {
                                                imageWidth = screenWidth * 0.4;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 50;
                                                infoPadding = 32;
                                                titleFontSize = 24;
                                                descFontSize = 14;
                                                bulletFontSize = 14;
                                                buttonFontSize = 16;
                                                sectionSpacing = 16;
                                              } else {
                                                imageWidth = screenWidth * 0.35;
                                                imageHeight = screenWidth * 0.33;
                                                playButtonSize = 60;
                                                infoPadding = 70;
                                                titleFontSize = 32;
                                                descFontSize = 16;
                                                bulletFontSize = 16;
                                                buttonFontSize = 18;
                                                sectionSpacing = 24;
                                              }
                    
                                              Widget imageStack = Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      bottomLeft: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      topRight: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      bottomRight: Radius.circular(0),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/videoImage.jpeg",
                                                      width: imageWidth,
                                                      height: imageHeight,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: playButtonSize / 2,
                                                    backgroundColor: Colors.white,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      size: playButtonSize * 0.5,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              );
                    
                                              Widget infoSection = Container(
                                                width: isMobile ? double.infinity : screenWidth * 0.48,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(238, 241, 251, 1),
                                                  borderRadius: isMobile
                                                      ? BorderRadius.only(
                                                          bottomLeft: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        )
                                                      : null,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(infoPadding),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Buying a car has never been this easy.",
                                                        style: TextStyle(
                                                          fontSize: titleFontSize,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Text(
                                                        "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                                        style: TextStyle(
                                                          fontSize: descFontSize,
                                                          color: Color.fromRGBO(5, 11, 32, 1),
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          buildBulletPoint(
                                                            "We are the UK's largest provider, with more patrols in more places",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "You get 24/7 roadside assistance",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "We fix 4 out of 5 cars at the roadside",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _bookTestDrive();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color(0xFF004C90),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: infoPadding,
                                                            vertical: infoPadding / 2.5,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "Book a test drive",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: buttonFontSize,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            SizedBox(width: sectionSpacing / 2),
                                                            Icon(Icons.arrow_outward, color: Colors.white, size: buttonFontSize + 2),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                    
                                              if (isMobile) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                    
                                          SizedBox(height: sectionSpacing),
                                          Builder(
                                            builder: (context) {
                                              double screenWidth = MediaQuery.of(context).size.width;
                                              int crossAxisCount;
                                              if (screenWidth < 600) {
                                                crossAxisCount = 2;
                                              } else if (screenWidth < 1024) {
                                                crossAxisCount = 4;
                                              } else {
                                                crossAxisCount = 4;
                                              }
                                              return Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  buildStatBox("836M", "CARS FOR SALE", context),
                                                  buildStatBox("738M", "DEALER REVIEWS", context),
                                                  buildStatBox("100M", "VISITORS PER DAY", context),
                                                  buildStatBox("238M", "VERIFIED DEALERS", context),
                                                ],
                                              );
                                            },
                                          ),
                    
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromRGBO(223, 223, 223, 1),
                                          ),
                                          SizedBox(height: sectionSpacing),
                    
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Why Choose Us?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenHeight * 0.038, fontFamily: "DMSans",),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double screenWidth = MediaQuery.of(context).size.width;
                                                bool isMobile = screenWidth < 600;
                    
                                                double imageSize;
                                                double titleFontSize;
                                                double descFontSize;
                                                if (screenWidth >= 1024) {
                                                  // Desktop
                                                  imageSize = 52;
                                                  titleFontSize = 22;
                                                  descFontSize = 15;
                                                } else if (screenWidth >= 600) {
                                                  // Tablet
                                                  imageSize = 40;
                                                  titleFontSize = 19;
                                                  descFontSize = 15;
                                                } else {
                                                  // Mobile
                                                  imageSize = 33;
                                                  titleFontSize = 15;
                                                  descFontSize = 13;
                                                }
                    
                                                List<Widget> infoBlocks = [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/financialOffer.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Special Financing Offers", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/dealership.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Trusted Car Dealership", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/transparent.png", height: imageSize),
                                                      SizedBox(height: screenWidth*0.02),
                                                      Text("Transparent Pricing", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/expertCar.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Expert Car Service", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                ];
                    
                                                if (isMobile) {
                                                  // Display vertically for mobile
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                } else {
                                                  // Display horizontally for tablet/desktop
                                                  return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(right: screenWidth * 0.02),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                }
                                              }
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.1),
                                          
                                          Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(249, 251, 252, 1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  right: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  top: screenWidth >= 1024
                                                      ? screenHeight * 0.10
                                                      : screenWidth >= 600
                                                          ? screenHeight * 0.06
                                                          : 16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // You can adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          double textSize;
                                                          double subTextSize;
                                                          if (constraints.maxWidth >= 1024) {
                                                            textSize = 28;
                                                            subTextSize = 14;
                                                          } else if (constraints.maxWidth >= 600) {
                                                            textSize = 24;
                                                            subTextSize = 12;
                                                          } else {
                                                            textSize = 18;
                                                            subTextSize = 10;
                                                          }
                    
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              isMobile
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // Adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          bool isDesktop = constraints.maxWidth >= 1024;
                                                          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          double containerHeight = isDesktop
                                                              ? 490
                                                              : isTablet
                                                                  ? 420
                                                                  : 320;
                                                          double containerWidth = isDesktop
                                                              ? screenWidth * 0.9
                                                              : isTablet
                                                                  ? screenWidth * 0.95
                                                                  : screenWidth * 0.98;
                                                          double imageWidth = isDesktop
                                                              ? 480
                                                              : isTablet
                                                                  ? 300
                                                                  : containerWidth;
                                                          double imageHeight = isDesktop
                                                              ? 550
                                                              : isTablet
                                                                  ? 380
                                                                  : 180;
                                                          double nameSize = isDesktop
                                                              ? 18
                                                              : isTablet
                                                                  ? 16
                                                                  : 14;
                                                          double designationSize = isDesktop
                                                              ? 15
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                                                          double reviewTextSize = isDesktop
                                                              ? 22
                                                              : isTablet
                                                                  ? 16
                                                                  : 12;
                                                          double starSize = isDesktop
                                                              ? 16
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                    
                                                          return Builder(
                                                            builder: (context) {
                                                              if (isLoadingReviews) {
                                                                return Center(child: CircularProgressIndicator());
                                                              }
                                                              if (errorMessageReviews != null) {
                                                                return Center(child: Text(errorMessageReviews!));
                                                              }
                                                              if (reviews.isEmpty) {
                                                                return Center(child: Text('No high-rated reviews available'));
                                                              }
                                                              return CarouselSlider(
                                                                carouselController: reviewCarouselController,
                                                                options: CarouselOptions(
                                                                  height: containerHeight,
                                                                  autoPlay: false,
                                                                  enlargeCenterPage: false,
                                                                  enableInfiniteScroll: false,
                                                                  viewportFraction: 1,
                                                                  onPageChanged: (index, reason) {
                                                                    setState(() {
                                                                      reviewCurrentPage = index;
                                                                    });
                                                                  },
                                                                ),
                                                                items: reviews.asMap().entries.map((entry) {
                                                                  int index = entry.key;
                                                                  Map<String, dynamic> review = entry.value;
                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(0.0),
                                                                    child: Container(
                                                                      height: containerHeight,
                                                                      width: containerWidth,
                                                                      child: isMobile
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Row(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: List.generate(5, (starIndex) {
                                                                                        return Icon(
                                                                                          starIndex < (review["rating"] ?? 0)
                                                                                              ? Icons.star
                                                                                              : Icons.star_border,
                                                                                          color: Color.fromRGBO(225, 192, 63, 1),
                                                                                          size: starSize.toDouble(),
                                                                                        );
                                                                                      }),
                                                                                    ),
                                                                                    SizedBox(width: 6),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color.fromRGBO(225, 192, 63, 1),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 10, vertical: 2),
                                                                                        child: Text(
                                                                                          (review["rating"] ?? 0).toStringAsFixed(1),
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  review["name"] ?? 'Anonymous',
                                                                                  style: TextStyle(
                                                                                    fontSize: nameSize,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 4),
                                                                                Text(
                                                                                  review["designation"] ?? 'Reviewer',
                                                                                  style: TextStyle(
                                                                                    fontSize: designationSize,
                                                                                    color: Color.fromRGBO(139, 139, 139, 1),
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Text(
                                                                                  review["review"] ?? 'No review provided',
                                                                                  style: TextStyle(fontSize: reviewTextSize),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 24),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: List.generate(5, (starIndex) {
                                                                                                return Icon(
                                                                                                  starIndex < (review["rating"] ?? 0)
                                                                                                      ? Icons.star
                                                                                                      : Icons.star_border,
                                                                                                  color:
                                                                                                      Color.fromRGBO(225, 192, 63, 1),
                                                                                                  size: starSize.toDouble(),
                                                                                                );
                                                                                              }),
                                                                                            ),
                                                                                            SizedBox(width: 10),
                                                                                            Container(
                                                                                              decoration: BoxDecoration(
                                                                                                color:
                                                                                                    Color.fromRGBO(225, 192, 63, 1),
                                                                                                borderRadius:
                                                                                                    BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.symmetric(
                                                                                                    horizontal: 10, vertical: 2),
                                                                                                child: Text(
                                                                                                  (review["rating"] ?? 0)
                                                                                                      .toStringAsFixed(1),
                                                                                                  style: TextStyle(
                                                                                                    fontSize: designationSize,
                                                                                                    color: Colors.white,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: 16),
                                                                                        Text(
                                                                                          review["name"] ?? 'Anonymous',
                                                                                          style: TextStyle(
                                                                                            fontSize: nameSize,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 8),
                                                                                        Text(
                                                                                          review["designation"] ?? 'Reviewer',
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Color.fromRGBO(139, 139, 139, 1),
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 24),
                                                                                        Text(
                                                                                          review["review"] ?? 'No review provided',
                                                                                          style: TextStyle(fontSize: reviewTextSize),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Left button
                                          if (reviewCurrentPage >= 0)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              left: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage - 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  highlightElevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_back_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          // Right button
                                          if (reviewCurrentPage <= reviews.length - 1)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              right: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage + 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                              
                                        SizedBox(height: 40),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double fontSize = constraints.maxWidth > 600 ? 28 : 23;
                                            double paddingValue = constraints.maxWidth > 600 ? 20.0 : 10.0;
                                              
                                            return Padding(
                                              padding: EdgeInsets.all(paddingValue),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Latest Blog Posts",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
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
                                                                fontSize: screenHeight * 0.02,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_outward,
                                                              color: Color.fromRGBO(0, 147, 255, 1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                              
                                        
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double screenWidth = constraints.maxWidth;
                    
                                            if (screenWidth < 600) {
                                              // Mobile: Use CarouselSlider
                                              return CarouselSlider(
                                                options: CarouselOptions(
                                                  height: 420, // Adjust as needed
                                                  enableInfiniteScroll: true,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.9,
                                                ),
                                                items: blogs.map((blog) {
                                                  double imageHeight = 220;
                                                  double textSize = 13;
                                                  double buttonPadding = 20;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            } else {
                                              // Tablet/Web: Use GridView
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: screenWidth > 900
                                                      ? 3
                                                      : screenWidth > 600
                                                          ? 2
                                                          : 1,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: screenWidth > 900
                                                      ? 1.2
                                                      : screenWidth > 600
                                                          ? 1.1
                                                          : 0.9,
                                                ),
                                                itemCount: blogs.length,
                                                itemBuilder: (context, index) {
                                                  final blog = blogs[index];
                                                  double imageHeight = screenWidth > 900
                                                      ? 360
                                                      : screenWidth > 600
                                                          ? 280
                                                          : 220;
                                                  double textSize = screenWidth > 900
                                                      ? 22
                                                      : screenWidth > 600
                                                          ? 16
                                                          : 13;
                                                  double buttonPadding = screenWidth > 900
                                                      ? 30
                                                      : screenWidth > 600
                                                          ? 25
                                                          : 20;
                    
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                    
                    
                                        //responsive SizedBox for spacing
                                        Builder(
                                          builder: (context) {
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double offsetY = screenWidth < 600
                                                ? -70
                                                : screenWidth < 1024
                                                    ? 40
                                                    : 120;
                                            return Transform.translate(
                                              offset: Offset(0, offsetY),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double screenWidth = constraints.maxWidth;
                                                  bool isMobile = screenWidth < 600;
                                                  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                    
                                                  double cardWidth = isMobile
                                                      ? double.infinity
                                                      : isTablet
                                                          ? (screenWidth / 2) - 32
                                                          : 650;
                                                  double imageHeight = isMobile
                                                      ? 60
                                                      : isTablet
                                                          ? 80
                                                          : 100;
                                                  double fontSizeTitle = isMobile ? 16 : 20;
                                                  double fontSizeDesc = isMobile ? 12 : 14;
                                                  double buttonFontSize = isMobile ? 11.36 : 14;
                                                  double buttonPaddingH = isMobile ? 15 : 20;
                                                  double buttonPaddingV = isMobile ? 15 : 18;
                                                  double cardPadding = isMobile ? 20 : 40;
                    
                                                  Widget buildCard({
                                                    required Color color,
                                                    required String title,
                                                    required String desc,
                                                    required String imagePath,
                                                    required Color buttonColor,
                                                    required Color buttonTextColor,
                                                    required double imageHeight,
                                                  }) {
                                                    return Container(
                                                      width: cardWidth,
                                                      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0, right: isMobile ? 0 : 16),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(cardPadding),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: fontSizeTitle,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Text(
                                                              desc,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: fontSizeDesc,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {},
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: buttonColor,
                                                                    foregroundColor: buttonTextColor,
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: buttonPaddingH,
                                                                      vertical: buttonPaddingV,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Get Started",
                                                                        style: TextStyle(
                                                                          fontSize: buttonFontSize,
                                                                          fontWeight: FontWeight.w500,
                                                                          fontFamily: "DMSans",
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 5),
                                                                      Icon(Icons.arrow_outward_sharp, size: isMobile ? 20 : 24),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Image.asset(
                                                                  imagePath,
                                                                  height: imageHeight,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                    
                                                  final card1 = buildCard(
                                                    color: Color.fromRGBO(233, 242, 255, 1),
                                                    title: "Are You Looking \nFor a Car?",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/lookingCar.png",
                                                    buttonColor: Color.fromRGBO(26, 76, 142, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  final card2 = buildCard(
                                                    color: Color.fromRGBO(255, 233, 243, 1),
                                                    title: "Best place for \ncar financing",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/carFinance.png",
                                                    buttonColor: Color.fromRGBO(5, 11, 32, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  if (isMobile) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [card1, card2],
                                                    );
                                                  } else {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [card1, card2],
                                                    );
                                                  }
                                                },
                                              ), // Wrap the widget you want to shift upward
                                            );
                                          },
                                        ),
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
                    );
                  }

                  Widget MUV() {
                    final List<String> muvKeywords = [
                      "innova", "avanza", "veloz", "ertiga", "eeco", "carens", "carnival", "marazzo",
                      "bolero neo", "triber", "stargazer", "alcazar", "mobilio", "odyssey", "xpander", "go+", "mpv", "muv"
                    ];

                    List<Map<String, dynamic>> muvCars = cars.where((car) {
                      final name = (car["name"] ?? "").toString().toLowerCase();
                      final nameWords = name.split(RegExp(r'\s+'));
                      return muvKeywords.any((keyword) {
                        final kw = keyword.toLowerCase();
                        return nameWords.any((word) => word.contains(kw) || kw.contains(word)) ||
                              name.replaceAll(' ', '').contains(kw.replaceAll(' ', ''));
                      });
                    }).toList();

                    if (muvCars.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: const [
                            Text("No MUV cars available.", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        
                        Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: buildBrandCards(context),
                          ),
                          const SizedBox(height: 20,),
                    
                        if (muvCars.length == 1)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return _buildCarCard(muvCars.first, constraints, context);
                            },
                          )
                        else
                          Stack(
                            children: [
                              CarouselSlider(
                                carouselController: innerCarouselController,
                                options: CarouselOptions(
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  autoPlay: false,
                                  enableInfiniteScroll: true,
                                  enlargeCenterPage: false,
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      innerCurrentPage = index;
                                    });
                                  },
                                ),
                                items: muvCars.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> car = entry.value;
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return _buildCarCard(car, constraints, context);
                                    },
                                  );
                                }).toList(),
                              ),
                              if (innerCurrentPage >= 0)
                                Positioned(
                                  height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                  left: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                  top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      innerCarouselController.animateToPage(innerCurrentPage - 1, curve: Curves.easeIn);
                                    },
                                    backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                    child: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                                    mini: true,
                                  ),
                                ),
                              if (innerCurrentPage <= muvCars.length - 1)
                                Positioned(
                                  height: (MediaQuery.of(context).size.width < 600 ? 30.0 : MediaQuery.of(context).size.width < 1024 ? 50.0 : 60.0),
                                  right: (MediaQuery.of(context).size.width < 600 ? -5.0 : MediaQuery.of(context).size.width < 1024 ? -6.0 : -10.0),
                                  top: (MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.width < 1024 ? MediaQuery.of(context).size.height * 0.30 : MediaQuery.of(context).size.height * 0.22),
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      innerCarouselController.animateToPage(innerCurrentPage + 1, curve: Curves.easeIn);
                                    },
                                    backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                    child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                                    mini: true,
                                  ),
                                ),
                            ],
                          ),
                      
                          SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
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
                                  imageSize = (screenWidth / 3) - 30; 
                                }
                                imageSize = imageSize.clamp(80.0, 300.0);
                    
                                double titleFontSize = screenWidth > 600 ? 40 : screenWidth * 0.08;
                                
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
                                                    fontSize: screenHeight * 0.038,
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
                                                    fontSize: screenHeight * 0.02,
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
                                      SizedBox(height: screenHeight * 0.05),
                    
                                      //Similar Brands Section
                                      Column(
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Builder(
                                                builder: (context) {
                                                  print('[buildBrands] isLoadingBrands: $isLoadingBrands, errorMessageBrands: $errorMessageBrands, brands: $brands');
                                                  if (isLoadingBrands) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }
                                                  if (errorMessageBrands != null) {
                                                    return Center(child: Text(errorMessageBrands!));
                                                  }
                                                  if (brands.isEmpty) {
                                                    return const Center(child: Text('No brands available'));
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.all(0.0),
                                                    child: Wrap(
                                                      spacing: screenWidth * 0.05,
                                                      runSpacing: screenHeight * 0.02,
                                                      children: brands.map((brand) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(width: 1, color: const Color.fromRGBO(233, 233, 233, 1)),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Column(
                                                              children: [
                                                                Image.asset(
                                                                  brand["image"] ?? 'assets/placeholder.png',
                                                                  width: imageSize,
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                    'assets/placeholder.png',
                                                                    width: imageSize,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  brand["name"] ?? 'Unknown Brand',
                                                                  style: const TextStyle(fontFamily: "DMSans"),
                                                                  textAlign: TextAlign.center,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                  maxLines: 2, // Allow up to 2 lines
                                                                ),
                                                                SizedBox(height: screenHeight * 0.02),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      ),
                    
                    
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          double screenWidth = MediaQuery.of(context).size.width;
                                          double imageWidth = screenWidth * 0.40;
                                          double imageHeight = (imageWidth * 9 / 16) * 1.49;
                                          double playButtonSize = screenWidth * 0.052;
                                          double sectionSpacing = screenWidth * 0.01;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: sectionSpacing),
                    
                                          // Responsive "video + info" section
                                          Builder(
                                            builder: (context) {
                                              final screenWidth = MediaQuery.of(context).size.width;
                                              final isMobile = screenWidth < 800;
                                              final isTablet = screenWidth >= 800 && screenWidth < 1024;
                                              final isDesktop = screenWidth >= 1024;
                    
                                              // Responsive sizes
                                              double imageWidth, imageHeight, playButtonSize, infoPadding, titleFontSize, descFontSize, bulletFontSize, buttonFontSize, sectionSpacing;
                                              if (isMobile) {
                                                imageWidth = screenWidth * 0.9;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 40;
                                                infoPadding = 16;
                                                titleFontSize = 18;
                                                descFontSize = 12;
                                                bulletFontSize = 12;
                                                buttonFontSize = 14;
                                                sectionSpacing = 10;
                                              } else if (isTablet) {
                                                imageWidth = screenWidth * 0.4;
                                                imageHeight = screenWidth * 0.5;
                                                playButtonSize = 50;
                                                infoPadding = 32;
                                                titleFontSize = 24;
                                                descFontSize = 14;
                                                bulletFontSize = 14;
                                                buttonFontSize = 16;
                                                sectionSpacing = 16;
                                              } else {
                                                imageWidth = screenWidth * 0.35;
                                                imageHeight = screenWidth * 0.33;
                                                playButtonSize = 60;
                                                infoPadding = 70;
                                                titleFontSize = 32;
                                                descFontSize = 16;
                                                bulletFontSize = 16;
                                                buttonFontSize = 18;
                                                sectionSpacing = 24;
                                              }
                    
                                              Widget imageStack = Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      bottomLeft: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      topRight: isMobile ? Radius.circular(10) : Radius.circular(0),
                                                      bottomRight: Radius.circular(0),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/videoImage.jpeg",
                                                      width: imageWidth,
                                                      height: imageHeight,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: playButtonSize / 2,
                                                    backgroundColor: Colors.white,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      size: playButtonSize * 0.5,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              );
                    
                                              Widget infoSection = Container(
                                                width: isMobile ? double.infinity : screenWidth * 0.48,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(238, 241, 251, 1),
                                                  borderRadius: isMobile
                                                      ? BorderRadius.only(
                                                          bottomLeft: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        )
                                                      : null,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(infoPadding),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Buying a car has never been this easy.",
                                                        style: TextStyle(
                                                          fontSize: titleFontSize,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Text(
                                                        "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                                        style: TextStyle(
                                                          fontSize: descFontSize,
                                                          color: Color.fromRGBO(5, 11, 32, 1),
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          buildBulletPoint(
                                                            "We are the UK's largest provider, with more patrols in more places",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "You get 24/7 roadside assistance",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                          buildBulletPoint(
                                                            "We fix 4 out of 5 cars at the roadside",
                                                            fontSize: bulletFontSize,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: sectionSpacing),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _bookTestDrive();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color(0xFF004C90),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: infoPadding,
                                                            vertical: infoPadding / 2.5,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "Book a test drive",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: buttonFontSize,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            SizedBox(width: sectionSpacing / 2),
                                                            Icon(Icons.arrow_outward, color: Colors.white, size: buttonFontSize + 2),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                    
                                              if (isMobile) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    imageStack,
                                                    infoSection,
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                    
                                          SizedBox(height: sectionSpacing),
                                          Builder(
                                            builder: (context) {
                                              double screenWidth = MediaQuery.of(context).size.width;
                                              int crossAxisCount;
                                              if (screenWidth < 600) {
                                                crossAxisCount = 2;
                                              } else if (screenWidth < 1024) {
                                                crossAxisCount = 4;
                                              } else {
                                                crossAxisCount = 4;
                                              }
                                              return Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  buildStatBox("836M", "CARS FOR SALE", context),
                                                  buildStatBox("738M", "DEALER REVIEWS", context),
                                                  buildStatBox("100M", "VISITORS PER DAY", context),
                                                  buildStatBox("238M", "VERIFIED DEALERS", context),
                                                ],
                                              );
                                            },
                                          ),
                    
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromRGBO(223, 223, 223, 1),
                                          ),
                                          SizedBox(height: sectionSpacing),
                    
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Why Choose Us?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenHeight * 0.038, fontFamily: "DMSans",),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: sectionSpacing),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth >= 1024
                                                  ? 100
                                                  : screenWidth >= 600
                                                      ? 40
                                                      : 10,
                                              right: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 24
                                                      : 10,
                                              top: screenWidth >= 1024
                                                  ? 50
                                                  : screenWidth >= 600
                                                      ? 30
                                                      : 16,
                                              bottom: screenWidth >= 1024
                                                  ? 20
                                                  : screenWidth >= 600
                                                      ? 16
                                                      : 8,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double screenWidth = MediaQuery.of(context).size.width;
                                                bool isMobile = screenWidth < 600;
                    
                                                double imageSize;
                                                double titleFontSize;
                                                double descFontSize;
                                                if (screenWidth >= 1024) {
                                                  // Desktop
                                                  imageSize = 52;
                                                  titleFontSize = 22;
                                                  descFontSize = 15;
                                                } else if (screenWidth >= 600) {
                                                  // Tablet
                                                  imageSize = 40;
                                                  titleFontSize = 19;
                                                  descFontSize = 15;
                                                } else {
                                                  // Mobile
                                                  imageSize = 33;
                                                  titleFontSize = 15;
                                                  descFontSize = 13;
                                                }
                    
                                                List<Widget> infoBlocks = [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/financialOffer.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Special Financing Offers", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/dealership.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Trusted Car Dealership", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/transparent.png", height: imageSize),
                                                      SizedBox(height: screenWidth*0.02),
                                                      Text("Transparent Pricing", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: "DMSans",),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Image.asset("assets/expertCar.png", height: imageSize),
                                                      SizedBox(height: screenWidth * 0.02),
                                                      Text("Expert Car Service", style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),),
                                                      SizedBox(height: screenWidth * 0.01),
                                                      Text("Our stress-free finance department that can \nfind financial solutions to save you money.",
                                                        style: TextStyle(fontFamily: "DMSans", fontSize: descFontSize),),
                                                    ],
                                                  ),
                                                ];
                    
                                                if (isMobile) {
                                                  // Display vertically for mobile
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                } else {
                                                  // Display horizontally for tablet/desktop
                                                  return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: infoBlocks
                                                        .map((block) => Padding(
                                                              padding: EdgeInsets.only(right: screenWidth * 0.02),
                                                              child: block,
                                                            ))
                                                        .toList(),
                                                  );
                                                }
                                              }
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.1),
                                          
                                          Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(249, 251, 252, 1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  right: screenWidth >= 1024
                                                      ? screenWidth * 0.15
                                                      : screenWidth >= 600
                                                          ? screenWidth * 0.08
                                                          : 16,
                                                  top: screenWidth >= 1024
                                                      ? screenHeight * 0.10
                                                      : screenWidth >= 600
                                                          ? screenHeight * 0.06
                                                          : 16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // You can adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          double textSize;
                                                          double subTextSize;
                                                          if (constraints.maxWidth >= 1024) {
                                                            textSize = 28;
                                                            subTextSize = 14;
                                                          } else if (constraints.maxWidth >= 600) {
                                                            textSize = 24;
                                                            subTextSize = 12;
                                                          } else {
                                                            textSize = 18;
                                                            subTextSize = 10;
                                                          }
                    
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              isMobile
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "What our customers say",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: textSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rated ${calculateAverageRating().toStringAsFixed(1)} / 5 based on $totalReviews reviews Showing our 4 & 5 star reviews",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: subTextSize,
                                                                            fontFamily: "DMSans",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth >= 1024
                                                            ? 0
                                                            : screenWidth >= 600
                                                                ? 0
                                                                : 0, // Adjust if you want more padding on mobile
                                                      ),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          bool isDesktop = constraints.maxWidth >= 1024;
                                                          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                                                          bool isMobile = constraints.maxWidth < 600;
                    
                                                          double containerHeight = isDesktop
                                                              ? 490
                                                              : isTablet
                                                                  ? 420
                                                                  : 320;
                                                          double containerWidth = isDesktop
                                                              ? screenWidth * 0.9
                                                              : isTablet
                                                                  ? screenWidth * 0.95
                                                                  : screenWidth * 0.98;
                                                          double imageWidth = isDesktop
                                                              ? 480
                                                              : isTablet
                                                                  ? 300
                                                                  : containerWidth;
                                                          double imageHeight = isDesktop
                                                              ? 550
                                                              : isTablet
                                                                  ? 380
                                                                  : 180;
                                                          double nameSize = isDesktop
                                                              ? 18
                                                              : isTablet
                                                                  ? 16
                                                                  : 14;
                                                          double designationSize = isDesktop
                                                              ? 15
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                                                          double reviewTextSize = isDesktop
                                                              ? 22
                                                              : isTablet
                                                                  ? 16
                                                                  : 12;
                                                          double starSize = isDesktop
                                                              ? 16
                                                              : isTablet
                                                                  ? 13
                                                                  : 11;
                    
                                                          return Builder(
                                                            builder: (context) {
                                                              if (isLoadingReviews) {
                                                                return Center(child: CircularProgressIndicator());
                                                              }
                                                              if (errorMessageReviews != null) {
                                                                return Center(child: Text(errorMessageReviews!));
                                                              }
                                                              if (reviews.isEmpty) {
                                                                return Center(child: Text('No high-rated reviews available'));
                                                              }
                                                              return CarouselSlider(
                                                                carouselController: reviewCarouselController,
                                                                options: CarouselOptions(
                                                                  height: containerHeight,
                                                                  autoPlay: false,
                                                                  enlargeCenterPage: false,
                                                                  enableInfiniteScroll: false,
                                                                  viewportFraction: 1,
                                                                  onPageChanged: (index, reason) {
                                                                    setState(() {
                                                                      reviewCurrentPage = index;
                                                                    });
                                                                  },
                                                                ),
                                                                items: reviews.asMap().entries.map((entry) {
                                                                  int index = entry.key;
                                                                  Map<String, dynamic> review = entry.value;
                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(0.0),
                                                                    child: Container(
                                                                      height: containerHeight,
                                                                      width: containerWidth,
                                                                      child: isMobile
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Row(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: List.generate(5, (starIndex) {
                                                                                        return Icon(
                                                                                          starIndex < (review["rating"] ?? 0)
                                                                                              ? Icons.star
                                                                                              : Icons.star_border,
                                                                                          color: Color.fromRGBO(225, 192, 63, 1),
                                                                                          size: starSize.toDouble(),
                                                                                        );
                                                                                      }),
                                                                                    ),
                                                                                    SizedBox(width: 6),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color.fromRGBO(225, 192, 63, 1),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 10, vertical: 2),
                                                                                        child: Text(
                                                                                          (review["rating"] ?? 0).toStringAsFixed(1),
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  review["name"] ?? 'Anonymous',
                                                                                  style: TextStyle(
                                                                                    fontSize: nameSize,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 4),
                                                                                Text(
                                                                                  review["designation"] ?? 'Reviewer',
                                                                                  style: TextStyle(
                                                                                    fontSize: designationSize,
                                                                                    color: Color.fromRGBO(139, 139, 139, 1),
                                                                                    fontFamily: "DMSans",
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12),
                                                                                Text(
                                                                                  review["review"] ?? 'No review provided',
                                                                                  style: TextStyle(fontSize: reviewTextSize),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  review["image"] ?? 'assets/placeholder.png',
                                                                                  height: imageHeight,
                                                                                  width: imageWidth,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Image.asset(
                                                                                    'assets/placeholder.png',
                                                                                    height: imageHeight,
                                                                                    width: imageWidth,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 24),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: List.generate(5, (starIndex) {
                                                                                                return Icon(
                                                                                                  starIndex < (review["rating"] ?? 0)
                                                                                                      ? Icons.star
                                                                                                      : Icons.star_border,
                                                                                                  color:
                                                                                                      Color.fromRGBO(225, 192, 63, 1),
                                                                                                  size: starSize.toDouble(),
                                                                                                );
                                                                                              }),
                                                                                            ),
                                                                                            SizedBox(width: 10),
                                                                                            Container(
                                                                                              decoration: BoxDecoration(
                                                                                                color:
                                                                                                    Color.fromRGBO(225, 192, 63, 1),
                                                                                                borderRadius:
                                                                                                    BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.symmetric(
                                                                                                    horizontal: 10, vertical: 2),
                                                                                                child: Text(
                                                                                                  (review["rating"] ?? 0)
                                                                                                      .toStringAsFixed(1),
                                                                                                  style: TextStyle(
                                                                                                    fontSize: designationSize,
                                                                                                    color: Colors.white,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: 16),
                                                                                        Text(
                                                                                          review["name"] ?? 'Anonymous',
                                                                                          style: TextStyle(
                                                                                            fontSize: nameSize,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 8),
                                                                                        Text(
                                                                                          review["designation"] ?? 'Reviewer',
                                                                                          style: TextStyle(
                                                                                            fontSize: designationSize,
                                                                                            color: Color.fromRGBO(139, 139, 139, 1),
                                                                                            fontFamily: "DMSans",
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 24),
                                                                                        Text(
                                                                                          review["review"] ?? 'No review provided',
                                                                                          style: TextStyle(fontSize: reviewTextSize),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Left button
                                          if (reviewCurrentPage >= 0)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              left: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage - 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  highlightElevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_back_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          // Right button
                                          if (reviewCurrentPage <= reviews.length - 1)
                                            Positioned(
                                              height: screenWidth >= 1024
                                                  ? screenHeight * 0.05
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.045
                                                      : 36,
                                              right: screenWidth >= 1024
                                                  ? screenWidth * 0.03
                                                  : screenWidth >= 600
                                                      ? screenWidth * 0.02
                                                      : 8,
                                              top: screenWidth >= 1024
                                                  ? screenHeight * 0.38
                                                  : screenWidth >= 600
                                                      ? screenHeight * 0.36
                                                      : screenHeight * 0.33,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    reviewCarouselController.animateToPage(reviewCurrentPage + 1, curve: Curves.easeIn);
                                                  },
                                                  backgroundColor: Colors.white,
                                                  elevation: 0.0,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios_outlined,
                                                    size: screenWidth >= 1024
                                                        ? 18
                                                        : screenWidth >= 600
                                                            ? 14
                                                            : 12,
                                                  ),
                                                  mini: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                              
                                        SizedBox(height: 40),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double fontSize = constraints.maxWidth > 600 ? 28 : 23;
                                            double paddingValue = constraints.maxWidth > 600 ? 20.0 : 10.0;
                                              
                                            return Padding(
                                              padding: EdgeInsets.all(paddingValue),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Latest Blog Posts",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
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
                                                                fontSize: screenHeight * 0.02,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_outward,
                                                              color: Color.fromRGBO(0, 147, 255, 1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                              
                                        
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double screenWidth = constraints.maxWidth;
                    
                                            if (screenWidth < 600) {
                                              // Mobile: Use CarouselSlider
                                              return CarouselSlider(
                                                options: CarouselOptions(
                                                  height: 420, // Adjust as needed
                                                  enableInfiniteScroll: true,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.9,
                                                ),
                                                items: blogs.map((blog) {
                                                  double imageHeight = 220;
                                                  double textSize = 13;
                                                  double buttonPadding = 20;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            } else {
                                              // Tablet/Web: Use GridView
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: screenWidth > 900
                                                      ? 3
                                                      : screenWidth > 600
                                                          ? 2
                                                          : 1,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: screenWidth > 900
                                                      ? 1.2
                                                      : screenWidth > 600
                                                          ? 1.1
                                                          : 0.9,
                                                ),
                                                itemCount: blogs.length,
                                                itemBuilder: (context, index) {
                                                  final blog = blogs[index];
                                                  double imageHeight = screenWidth > 900
                                                      ? 360
                                                      : screenWidth > 600
                                                          ? 280
                                                          : 220;
                                                  double textSize = screenWidth > 900
                                                      ? 22
                                                      : screenWidth > 600
                                                          ? 16
                                                          : 13;
                                                  double buttonPadding = screenWidth > 900
                                                      ? 30
                                                      : screenWidth > 600
                                                          ? 25
                                                          : 20;
                    
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: buttonPadding,
                                                                    vertical: 8,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  blog["name"]!,
                                                                  style: TextStyle(
                                                                    fontSize: textSize - 3,
                                                                    fontFamily: "DMSans",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                blog["position"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              const Icon(
                                                                Icons.circle,
                                                                size: 8,
                                                                color: Color.fromRGBO(225, 225, 225, 1),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                blog["date"]!,
                                                                style: const TextStyle(
                                                                  color: Color.fromRGBO(5, 11, 32, 1),
                                                                  fontFamily: "DMSans",
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                          child: Text(
                                                            blog["description"]!,
                                                            style: TextStyle(
                                                              fontSize: textSize,
                                                              color: const Color.fromRGBO(5, 11, 32, 1),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "DMSans",
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                    
                    
                                        //responsive SizedBox for spacing
                                        Builder(
                                          builder: (context) {
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double offsetY = screenWidth < 600
                                                ? -70
                                                : screenWidth < 1024
                                                    ? 40
                                                    : 120;
                                            return Transform.translate(
                                              offset: Offset(0, offsetY),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double screenWidth = constraints.maxWidth;
                                                  bool isMobile = screenWidth < 600;
                                                  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                    
                                                  double cardWidth = isMobile
                                                      ? double.infinity
                                                      : isTablet
                                                          ? (screenWidth / 2) - 32
                                                          : 650;
                                                  double imageHeight = isMobile
                                                      ? 60
                                                      : isTablet
                                                          ? 80
                                                          : 100;
                                                  double fontSizeTitle = isMobile ? 16 : 20;
                                                  double fontSizeDesc = isMobile ? 12 : 14;
                                                  double buttonFontSize = isMobile ? 11.36 : 14;
                                                  double buttonPaddingH = isMobile ? 15 : 20;
                                                  double buttonPaddingV = isMobile ? 15 : 18;
                                                  double cardPadding = isMobile ? 20 : 40;
                    
                                                  Widget buildCard({
                                                    required Color color,
                                                    required String title,
                                                    required String desc,
                                                    required String imagePath,
                                                    required Color buttonColor,
                                                    required Color buttonTextColor,
                                                    required double imageHeight,
                                                  }) {
                                                    return Container(
                                                      width: cardWidth,
                                                      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0, right: isMobile ? 0 : 16),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(cardPadding),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: fontSizeTitle,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Text(
                                                              desc,
                                                              style: TextStyle(
                                                                fontFamily: "DMSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: fontSizeDesc,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {},
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: buttonColor,
                                                                    foregroundColor: buttonTextColor,
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: buttonPaddingH,
                                                                      vertical: buttonPaddingV,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Get Started",
                                                                        style: TextStyle(
                                                                          fontSize: buttonFontSize,
                                                                          fontWeight: FontWeight.w500,
                                                                          fontFamily: "DMSans",
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 5),
                                                                      Icon(Icons.arrow_outward_sharp, size: isMobile ? 20 : 24),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Image.asset(
                                                                  imagePath,
                                                                  height: imageHeight,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                    
                                                  final card1 = buildCard(
                                                    color: Color.fromRGBO(233, 242, 255, 1),
                                                    title: "Are You Looking \nFor a Car?",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/lookingCar.png",
                                                    buttonColor: Color.fromRGBO(26, 76, 142, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  final card2 = buildCard(
                                                    color: Color.fromRGBO(255, 233, 243, 1),
                                                    title: "Best place for \ncar financing",
                                                    desc: "We are committed to providing our customers with \nexceptional service.",
                                                    imagePath: "assets/Home_Images/Footer_Images/carFinance.png",
                                                    buttonColor: Color.fromRGBO(5, 11, 32, 1),
                                                    buttonTextColor: Colors.white,
                                                    imageHeight: imageHeight,
                                                  );
                    
                                                  if (isMobile) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [card1, card2],
                                                    );
                                                  } else {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [card1, card2],
                                                    );
                                                  }
                                                },
                                              ), // Wrap the widget you want to shift upward
                                            );
                                          },
                                        ),
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
                    );
                  }

                  Widget _buildCarCard(Map<String, dynamic> car, BoxConstraints constraints, BuildContext context) {
                    double padding = MediaQuery.of(context).size.width > 1200
                        ? constraints.maxWidth * 0.023
                        : MediaQuery.of(context).size.width > 600
                            ? constraints.maxWidth * 0.02
                            : constraints.maxWidth * 0.02;

                    double buttonPadding = MediaQuery.of(context).size.width > 1200
                        ? constraints.maxWidth * 0.02
                        : MediaQuery.of(context).size.width > 800
                            ? constraints.maxWidth * 0.015
                            : constraints.maxWidth * 0.01;

                    double buttonHeight = MediaQuery.of(context).size.height > 900
                        ? constraints.maxHeight * 0.06
                        : MediaQuery.of(context).size.height > 600
                            ? constraints.maxHeight * 0.06
                            : constraints.maxHeight * 0.04;

                    double fontSizeFactor = MediaQuery.of(context).size.width > 1200
                        ? 1.3
                        : MediaQuery.of(context).size.width >= 800
                            ? 1.15
                            : 1.0;

                    double fontSize = constraints.maxWidth < 600
                        ? constraints.maxWidth * 0.03 // Mobile
                        : constraints.maxWidth < 1024
                            ? constraints.maxWidth * 0.02 // Tablet
                            : constraints.maxWidth * 0.006 * fontSizeFactor; // Desktop/Web

                    double viewImageWidth;
                    if (constraints.maxWidth < 600) {
                      viewImageWidth = constraints.maxWidth * 0.20;
                    } else if (constraints.maxWidth < 1024) {
                      viewImageWidth = constraints.maxWidth * 0.10;
                    } else {
                      viewImageWidth = constraints.maxWidth * 0.065;
                    }

                    return Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width > 1200
                              ? constraints.maxWidth * 0.6
                              : MediaQuery.of(context).size.width > 800
                                  ? constraints.maxWidth * 0.6
                                  : constraints.maxWidth * 0.9,
                          height: MediaQuery.of(context).size.height > 900
                              ? constraints.maxHeight * 1
                              : MediaQuery.of(context).size.height > 600
                                  ? constraints.maxHeight * 1
                                  : constraints.maxHeight * 0.9,
                          padding: EdgeInsets.all(padding),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(228, 228, 228, 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width > 1200
                                        ? constraints.maxWidth * 0.98
                                        : MediaQuery.of(context).size.width > 800
                                            ? constraints.maxWidth * 0.8
                                            : constraints.maxWidth * 0.8,
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: Image.asset(car["image"] ?? 'assets/placeholder.png', fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: padding,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TwocarscompareWeb()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: buttonPadding,
                                          vertical: buttonHeight * 0.2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Image.asset(car["compareImage"] ?? "comareImage", width: 17, height: 17, fit: BoxFit.contain),
                                                SizedBox(width: padding * 0.15),
                                                Text(
                                                  car["compareText"] ?? "Comapare",
                                                  style: TextStyle(fontFamily: "DMSans", fontSize: fontSize),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: (constraints.maxWidth < 600
                                            ? constraints.maxHeight * 0.20
                                            : constraints.maxWidth < 1024
                                                ? constraints.maxHeight * 0.20
                                                : constraints.maxHeight * 0.22),
                                    left: (constraints.maxWidth < 600
                                            ? constraints.maxWidth * 0.30
                                            : constraints.maxWidth < 1024
                                                ? constraints.maxWidth * 0.30
                                                : constraints.maxWidth * 0.23),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Add your view image logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                      ),
                                      child: Hero(
                                        tag: 'carHeroTag_${car["id"]?.toString() ?? car["name"]}_${car["name"]}_${UniqueKey()}',
                                        child: Image.asset(
                                          car["viewImage"]?.toString() ?? "assets/degrees.png",
                                          width: viewImageWidth,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.0),
                              Container(
                                child: Text(
                                  car["name"]?.toString() ?? "Car Name",
                                  style: TextStyle(
                                    fontSize: (constraints.maxWidth < 600
                                            ? constraints.maxWidth * 0.055
                                            : constraints.maxWidth < 1024
                                                ? constraints.maxWidth * 0.027
                                                : constraints.maxWidth * 0.015) *
                                        fontSizeFactor,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight * 0.03),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          car["moreDetails1"]?.toString() ?? "Starting at",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.032
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.009) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.02),
                                        Text(
                                          car["details1"]?.toString() ?? "N/A",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.03
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.007) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          car["details12"]?.toString() ?? "N/A",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.03
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.007) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        Text(
                                          car["details13"]?.toString() ?? "N/A",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.03
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.007) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Color.fromRGBO(219, 219, 219, 1),
                                    height: constraints.maxHeight * 0.15,
                                    width: constraints.maxWidth * 0.001,
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.02),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          car["moreDetails2"]?.toString() ?? "Engine Options",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.032
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.009) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.02),
                                        Image.asset(
                                          car["dieselImage"]?.toString() ?? "assets/diesel.webp",
                                          height: (constraints.maxWidth < 600
                                              ? constraints.maxHeight * 0.03
                                              : constraints.maxWidth < 1024
                                                  ? constraints.maxHeight * 0.03
                                                  : constraints.maxHeight * 0.03),
                                          width: (constraints.maxWidth < 600
                                              ? constraints.maxWidth * 0.04
                                              : constraints.maxWidth < 1024
                                                  ? constraints.maxWidth * 0.04
                                                  : constraints.maxWidth * 0.03),
                                          color: Colors.black,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.01),
                                        Text(
                                          car["details2"]?.toString() ?? "N/A",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.03
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.007) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Color.fromRGBO(219, 219, 219, 1),
                                    height: constraints.maxHeight * 0.15,
                                    width: constraints.maxWidth * 0.001,
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.02),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          car["moreDetails3"]?.toString() ?? "Transmission",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.032
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.009) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        Text(
                                          car["moreDetails31"]?.toString() ?? "Available",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.032
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.009) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.01),
                                        Image.asset(
                                          car["manualImage"]?.toString() ?? "assets/manuel.png",
                                          height: (constraints.maxWidth < 600
                                              ? constraints.maxHeight * 0.03
                                              : constraints.maxWidth < 1024
                                                  ? constraints.maxHeight * 0.03
                                                  : constraints.maxHeight * 0.03),
                                          width: (constraints.maxWidth < 600
                                              ? constraints.maxWidth * 0.04
                                              : constraints.maxWidth < 1024
                                                  ? constraints.maxWidth * 0.04
                                                  : constraints.maxWidth * 0.03),
                                          color: Colors.black,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.01),
                                        Text(
                                          car["details3"]?.toString() ?? "N/A",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.03
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.017
                                                        : constraints.maxWidth * 0.007) *
                                                fontSizeFactor,
                                            fontFamily: "DMSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.05),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        side: BorderSide(color: Color(0xFF004C90)),
                                        backgroundColor: Colors.white,
                                        minimumSize: Size(
                                          MediaQuery.of(context).size.width > 1200
                                              ? constraints.maxWidth * 0.2
                                              : MediaQuery.of(context).size.width > 800
                                                  ? constraints.maxWidth * 0.3
                                                  : constraints.maxWidth * 0.9,
                                          buttonHeight * 0.45,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: buttonHeight * 0.2,
                                          horizontal: MediaQuery.of(context).size.width * 0.02,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Viewcardetails(
                                              car: car,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          car["button1"]?.toString() ?? "Learn More",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.028
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.018
                                                        : constraints.maxWidth * 0.01) *
                                                fontSizeFactor,
                                            color: Color(0xFF004C90),
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "WorkSans",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                  Flexible(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF004C90),
                                        minimumSize: Size(
                                          MediaQuery.of(context).size.width > 1200
                                              ? constraints.maxWidth * 0.2
                                              : MediaQuery.of(context).size.width > 800
                                                  ? constraints.maxWidth * 0.3
                                                  : constraints.maxWidth * 0.9,
                                          buttonHeight * 0.45,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: buttonHeight * 0.2,
                                          horizontal: MediaQuery.of(context).size.width * 0.02,
                                        ),
                                      ),
                                      onPressed: () {
                                        _bookTestDrive();
                                        _clearForm();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          car["button2"]?.toString() ?? "Book a Test Drive",
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth < 600
                                                    ? constraints.maxWidth * 0.028
                                                    : constraints.maxWidth < 1024
                                                        ? constraints.maxWidth * 0.018
                                                        : constraints.maxWidth * 0.01) *
                                                fontSizeFactor,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "WorkSans",
                                          ),
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

                  Widget _buildDropdownField({required String label, required String hint, required List<String> items, required TextEditingController controller,}) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: TextStyle(color: Color.fromRGBO(31, 31, 31, 0.43)),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(198, 198, 198, 1)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: items.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                controller.text = value ?? '';
                              });
                            },
                            validator: (value) => value == null || value.isEmpty ? 'Please select $label' : null,
                            value: controller.text.isNotEmpty ? controller.text : null,
                          ),
                        ],
                      ),
                    );
                  }

                  Widget _buildDateField({
                    required String label,
                    required String hint,
                    required TextEditingController controller,
                    String? prefix,
                    Widget? suffixIcon,
                  }) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your Date of Birth";
                              }
                              return null;
                            },
                            controller: controller,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                controller.text = formattedDate;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: const TextStyle(color: Color.fromRGBO(31, 31, 31, 0.43)),
                              prefix: prefix != null
                                  ? Text(
                                      prefix,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(31, 31, 31, 1),
                                      ),
                                    )
                                  : null,
                              suffixIcon: suffixIcon ?? const Icon(Icons.calendar_today),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(31, 31, 31, 0.43)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, String? prefix}) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: controller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your name";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: const TextStyle(color: Color.fromRGBO(31, 31, 31, 0.43)),
                              prefix: prefix != null
                                  ? Text(
                                      prefix,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(31, 31, 31, 1),
                                      ),
                                    )
                                  : null,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(31, 31, 31, 0.43)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  Widget _buildPhoneField({required String label, required String hint, required TextEditingController controller}) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(26, 76, 142, 1),
                                fontWeight: FontWeight.w500,
                                fontFamily: "DMSans",
                              ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: DropdownButton<String>(
                                    value: selectedCountryCode,
                                    items: countryCodes.map((String code) {
                                      return DropdownMenuItem<String>(
                                        value: code,
                                        child: Text(
                                          code,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCountryCode = newValue!;
                                      });
                                    },
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                ),
                                
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                // Phone number text field
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: hint,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

}