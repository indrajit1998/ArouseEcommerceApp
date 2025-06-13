import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Profilearouseautomotive extends StatefulWidget {
  const Profilearouseautomotive({super.key});

  @override
  State<Profilearouseautomotive> createState() => _ProfilearouseautomotiveState();
}

class _ProfilearouseautomotiveState extends State<Profilearouseautomotive> {

  int isSelectedIndex = 0;
  bool isLoggedIn = false;

  void _login() {
    setState(() {
      isLoggedIn = true;
    });
  }

  String selectedCountryCode = '+91';
  final List<String> countryCodes = ['+91', '+1', '+44', '+81', '+86'];

  // Define GlobalKey for Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables for EMI calculator (from previous questions)
  String selectedCity = 'Mumbai';
  final Map<String, double> cities = {
    'Mumbai': 13.89,
    'Delhi': 15.55,
    'Bangalore': 11.32,
    'Chennai': 10.99,
    'Kolkata': 12.22,
    'Tirupati': 9.00,
  };
  double _displayEMI = 60000;
  String _displayTenure = '5 YEARS';
  final TextEditingController _carPriceController = TextEditingController(text: '1879000');
  final TextEditingController _downPaymentController = TextEditingController(text: '500000');
  double _principal = 0;
  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayable = 0;
  String _selectedTenure = '5 YEARS';
  String _selectedInterestRate = '8%';
  final List<String> _tenureOptions = ['1 YEAR', '3 YEARS', '5 YEARS', '7 YEARS', '11 YEARS'];
  final List<String> _interestRateOptions = ['3%', '5%', '7%', '8%', '9%', '11%'];
  String? selectedColor;
  List<String> colors = ['Red', 'Blue', 'Green'];
  int? _selectedIndex;
  List<String> variants = ['Base', 'Mid', 'Top'];
  final List<Map<String, dynamic>> cars = [
    {"name": "Car Model 1"},
    {"name": "Car Model 2"},
  ];
  int innerCurrentPage = 0;

  void _calculatePrincipal() {
    double carPrice = double.tryParse(_carPriceController.text.replaceAll(',', '')) ?? 0;
    double downPayment = double.tryParse(_downPaymentController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _principal = carPrice - downPayment;
      _calculateEMI();
    });
  }

  void _calculateEMI() {
    double principal = _principal;
    double annualInterestRate = double.parse(_selectedInterestRate.replaceAll('%', '')) / 100;
    double monthlyInterestRate = annualInterestRate / 12;
    int tenureInYears = int.parse(_selectedTenure.split(' ')[0]);
    int tenureInMonths = tenureInYears * 12;

    if (principal > 0 && monthlyInterestRate > 0 && tenureInMonths > 0) {
      _emi = (principal * monthlyInterestRate * pow(1 + monthlyInterestRate, tenureInMonths)) /
          (pow(1 + monthlyInterestRate, tenureInMonths) - 1);
      _totalPayable = _emi * tenureInMonths;
      _totalInterest = _totalPayable - principal;
    } else {
      _emi = 0;
      _totalInterest = 0;
      _totalPayable = 0;
    }
    setState(() {
      _displayEMI = _emi;
      _displayTenure = _selectedTenure;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedColor = colors[0];
    _carPriceController.text = (cities[selectedCity]! * 100000).toStringAsFixed(0);
    _calculatePrincipal();
  }

  @override
  void dispose() {
    _carPriceController.dispose();
    _downPaymentController.dispose();
    super.dispose();
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
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
                  toolbarHeight: isMobile ? 80 : 100,
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: isMobile ? 20 : 50),
                      child: Row(
                        children: [
                          // Logo and Title
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/image.png',
                                height: isMobile ? 40 : imageHeight,
                                width: isMobile ? 40 : imageWidth,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'AROUSE',
                                    style: TextStyle(
                                      color: const Color(0xFF004C90),
                                      fontSize: isMobile ? 12 : fontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "DMSans",
                                    ),
                                  ),
                                  Text(
                                    'AUTOMOTIVE',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : fontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "DMSans",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: screenWidth * 0.18),

                          // Home Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectedIndex = 0;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isSelectedIndex == 0 ? 2 : 0,
                                    color: isSelectedIndex == 0
                                        ? const Color.fromRGBO(26, 76, 142, 1)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                                child: Text(
                                  "Home",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: isMobile ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 0 ? const Color(0xFF004C90) : Colors.black,
                                  ),
                                ),
                            ),
                          ),

                          // About Us Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectedIndex = 1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isSelectedIndex == 1 ? 2 : 0,
                                    color: isSelectedIndex == 1
                                        ? const Color.fromRGBO(26, 76, 142, 1)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                                child: Text(
                                  "About Us",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: isMobile ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 1 ? const Color(0xFF004C90) : Colors.black,
                                  ),
                                ),
                            ),
                          ),

                          // Book a Test Drive Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectedIndex = 2;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isSelectedIndex == 2 ? 2 : 0,
                                    color: isSelectedIndex == 2
                                        ? const Color.fromRGBO(26, 76, 142, 1)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                                child: Text(
                                  "Book a Test Drive",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: isMobile ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 2 ? const Color(0xFF004C90) : Colors.black,
                                  ),
                                ),
                            ),
                          ),

                          // Virtual Showroom Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectedIndex = 3;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isSelectedIndex == 3 ? 2 : 0,
                                    color: isSelectedIndex == 3
                                        ? const Color.fromRGBO(26, 76, 142, 1)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                                child: Text(
                                  "Virtual Showroom",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: isMobile ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 3 ? const Color(0xFF004C90) : Colors.black,
                                  ),
                                ),
                            ),
                          ),

                          // Luxury Cars Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectedIndex = 4;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isSelectedIndex == 4 ? 2 : 0,
                                    color: isSelectedIndex == 4
                                        ? const Color.fromRGBO(26, 76, 142, 1)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/Web_Images/AppBar_Images/luxury_stars.png",
                                      height: isMobile ? 15 : 20,
                                      width: isMobile ? 15 : 20,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Luxury Cars",
                                      style: TextStyle(
                                        fontFamily: "DMSans",
                                        fontSize: isMobile ? 12 : 15,
                                        fontWeight: FontWeight.w500,
                                        color: isSelectedIndex == 4 ? const Color(0xFF004C90) : Colors.black,
                                      ),
                                    ),
                                  ],
                              ),
                            ),
                          ),

                          // EMI Calculator Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectedIndex = 5;
                                _showEMICalculatorDialog(context, screenWidth, screenHeight);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isSelectedIndex == 5 ? 2 : 0,
                                    color: isSelectedIndex == 5
                                        ? const Color.fromRGBO(26, 76, 142, 1)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                                child: Text(
                                  "EMI Calculator",
                                  style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: isMobile ? 12 : 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelectedIndex == 5 ? const Color(0xFF004C90) : Colors.black,
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Book Online Button
                          Container(
                            width: isMobile ? 100 : 140,
                            decoration: BoxDecoration(
                              border: const Border.fromBorderSide(
                                BorderSide(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  width: 1,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Bookingcart(
                                      carName: cars[innerCurrentPage]["name"] ?? "Unknown Car",
                                      selectedColor: selectedColor!,
                                      selectedVariant: _selectedIndex != null ? variants[_selectedIndex!] : null,
                                      totalPayable: _totalPayable == 0 ? 2379000 : _totalPayable,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(26, 76, 142, 1),
                                padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 10),
                              ),
                              child: Text(
                                "Book Online",
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                  fontFamily: "DMSans",
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),

                          // Profile Avatar
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2.05,
                                color: const Color.fromRGBO(26, 76, 142, 1),
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: const Color.fromRGBO(239, 246, 255, 1),
                              child: const Text(
                                'GB',
                                style: TextStyle(
                                  color: Color.fromRGBO(26, 76, 142, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.003),
                          Text(
                            "Hi Gaurish",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: "DMSans",
                              color: Color.fromRGBO(26, 76, 142, 1),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.005),

                          // Drawer Toggle Button
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      endDrawer: isLoggedIn ? _userDrawer(context) : _loginDrawer(context),
      
      body: const Center(
        child: Text('Profile Page Content'),
      ),
    );
  }

  Widget _loginDrawer(BuildContext context){
    final screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
        shape: const Border(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [

            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(26, 76, 142, 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Hey!",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
                        
            
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 20,),
                    title: const Text('Your Bookings', style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600),),
                    onTap: () {
                      setState(() {
                        isSelectedIndex = 0;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline, color: Colors.grey, size: 20,),
                    title: const Text('My Docments', style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600),),
                    onTap: () {
                      setState(() {
                        isSelectedIndex = 1;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03,),
            
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.share_outlined, size: 20,),
                    title: const Text('Refer & Earn', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600),),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 2;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),

                  ListTile(
                    leading: const Icon(Icons.error_outline, size: 20,),
                    title: const Text('About Us', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600),),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 0;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.help_outline, size: 20,),
                    title: const Text('Help & Support', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 1;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined, size: 20,),
                    title: const Text('Feedback Form', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
                        
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: (){
                      _login();
                      Navigator.pop(context);
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Login/Register",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontSize: 15.94,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015,),
          ],
        ),
      );
  }

  Widget _userDrawer(BuildContext context){
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
        shape: const Border(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [

            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(26, 76, 142, 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi Gaurish Banga!",
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        GestureDetector(
                          onTap: () {
                            
                          },
                          child: Row(
                            children: [
                              const Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Color.fromRGBO(190, 190, 190, 1),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Inter",
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.002),
                              const Icon(
                                Icons.keyboard_arrow_right,
                                size: 15,
                                color: Color.fromRGBO(190, 190, 190, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.05,
                          color: const Color.fromRGBO(26, 76, 142, 1),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color.fromRGBO(239, 246, 255, 1),
                      ),
                    ),
              
                  ],
                ),
              ),
            ),
                        
            
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, size: 20,),
                    title: const Text('Your Bookings', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 0;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline, size: 20,),
                    title: const Text('My Docments', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 1;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.share_outlined, size: 20,),
                    title: const Text('Refer & Earn', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03,),
            
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.error_outline, size: 20,),
                    title: const Text('About Us', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 0;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.help_outline, size: 20,),
                    title: const Text('Help & Support', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 1;
                      });
                    },
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                        
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined, size: 20,),
                    title: const Text('Feedback Form', style: TextStyle(fontSize: 14, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isSelectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
                        
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login_outlined, color: Color.fromRGBO(251, 52, 79, 1),),
                    title: const Text('Logout', style: TextStyle(color: Color.fromRGBO(251, 52, 79, 1), fontSize: 16, fontFamily: "Inter", fontWeight: FontWeight.w500),),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        isLoggedIn = false;
                        isSelectedIndex = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }


  void _showEMICalculatorDialog(BuildContext context, double screenWidth, double screenHeight) {
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
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
                                color: const Color.fromRGBO(0, 76, 144, 1),
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
                                      decoration: const InputDecoration(
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
                                      'Enter Down Payment',
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
                                      'Your loan amount will be Rs. ${_principal == 0 ? '13,79,000' : NumberFormat("#,##0").format(_principal)}',
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
                                          backgroundColor: const Color.fromRGBO(0, 76, 144, 1),
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
                                color: const Color.fromRGBO(189, 189, 189, 1),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rs. ${_emi == 0 ? '60,000' : NumberFormat("#,##0").format(_emi)} EMI FOR ${_selectedTenure.toLowerCase()}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 11),
                                    Padding(
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        width: 500,
                                        height: 2,
                                        color: const Color.fromRGBO(189, 189, 189, 1),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Container(
                                      color: const Color.fromRGBO(248, 249, 251, 1),
                                      child: const SizedBox(
                                        height: 200,
                                        child: Placeholder(),
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
                                        Text(
                                          'Rs. ${_principal == 0 ? '18,79,000' : NumberFormat("#,##0").format(_principal)}',
                                        ),
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
                                        Text(
                                          'Rs. ${_totalInterest == 0 ? '5,00,000' : NumberFormat("#,##0").format(_totalInterest)}',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      color: const Color.fromRGBO(248, 249, 251, 1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Total Amount Payable',
                                              style: TextStyle(
                                                fontFamily: "DMSans",
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(0, 0, 0, 1),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Rs. ${_totalPayable == 0 ? '23,79,000' : NumberFormat("#,##0").format(_totalPayable)}',
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(31, 31, 31, 1),
                                              ),
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
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
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
      },
    );
  }
}

class Bookingcart extends StatelessWidget {
  final String carName;
  final String selectedColor;
  final String? selectedVariant;
  final double totalPayable;

  const Bookingcart({
    Key? key,
    required this.carName,
    required this.selectedColor,
    this.selectedVariant,
    required this.totalPayable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Cart'),
        backgroundColor: const Color.fromRGBO(26, 76, 142, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Car: $carName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Color: $selectedColor',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (selectedVariant != null)
              Text(
                'Variant: $selectedVariant',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 8),
            Text(
              'Total Amount Payable: Rs. ${NumberFormat("#,##0").format(totalPayable)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}