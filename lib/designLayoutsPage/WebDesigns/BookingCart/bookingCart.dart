import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/ViewCarDetails/EMISemiCircleChart/emiSemiCircleChart.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/ViewCarDetails/viewCarDetails.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/ViewVariants/viewVariants.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/webdesign.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Bookingcart extends StatefulWidget {
  final String carName;
  final Map<String, dynamic> selectedColor;
  final Map<String, dynamic>? selectedVariant;
  final double totalPayable;

  const Bookingcart({
    super.key,
    required this.carName,
    required this.selectedColor,
    required this.selectedVariant,
    required this.totalPayable,
  });

  @override
  State<Bookingcart> createState() => _BookingcartState();
}

class _BookingcartState extends State<Bookingcart> {

  int isSelectedIndex = 0;

  String selectedCountryCode = '+91';
  final List<String> countryCodes = ['+91', '+1', '+44', '+81', '+86'];
  final _nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool isSearchVisible = false;

  bool _showNewContent = false;

  String? _selectedType;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedBranch;
  String? _selectedRto;
  String? _selectedLoanTerm;
  String? _selectedROI;
  String? _selectedInsurance;
  String? _selectedInsuranceType;
  
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _financeProviderController = TextEditingController();
  final TextEditingController _roiController = TextEditingController();
  final TextEditingController _carValueController = TextEditingController();

  late final List<DropdownMenuItem<String>> _stateItems;
  late final List<DropdownMenuItem<String>> _cityItems;
  late final List<DropdownMenuItem<String>> _branchItems;
  late final List<DropdownMenuItem<String>> _rtoItems;
  late final List<DropdownMenuItem<String>> _loanTermItems;

  final CarouselSliderController _carouselController = CarouselSliderController();

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Madhya Pradesh',
    'Delhi',
    'Telangana',
    'Tamilnadu',
    'Gujarat',
    'Kerala',
    'Karnataka'
  ];

  final List<String> _cities = ['Bengaluru', 'Hyderabad', 'Visakhapatnam', 'Itanagar', 'Bhopal', 'New Delhi', 'Chennai', 'Gandhinagar', 'Thiruvananthapuram'];
  final List<String> _branches = ['530001', '791111', '462001', '110001', '500001', '600001', '380001', '641001', '395003', '695001', '560001'];
  final List<String> _rto = ['KA01', 'KA03', 'KA04','TS-09 (Central/Khairatabad)', 'TS-10 (North/Trimul, gherry)','AP31', 'AP32', 'AP33', 'AR01', 'AR02', 'MP04', 'DL01', 'DL03', 'TN01 (Central)', 'TN02 (NW)', 'TN03 (NE)', 'GJ18', 'KL01', 'KL19', 'KL22'];
  final List<String> _loan = ["2 Year", "3 Year", "5 Year", "7 Year", "9 Year", "11 Year",  "15 Year", "20 Year"];
  final List<String> _roi = ["3%", "3.5%", "5%", "5.5%", "7%", "8%", "7.5%", "9%", "11%"];

  final Map<String, double> _insuranceCarValues = {
    'ICICI Lombard': 1200000,
    'Bajaj Allianz': 1000000,
    'HDFC ERGO': 1190000,
    'TATA AIG': 1179000,
    'New India Assurance': 1100000,
    "SBI" : 1150000, 
    "Go Digit": 1175000, 
    "Acko": 1189000, 
    "Kotak Mahindra": 1187000, 
    "Shriram": 1192000, 
    "Reliance": 1190000, 
    "Navi": 1170000, 
    "Agriculture": 1160000
  };

  List<DropdownMenuItem<String>> _insuranceItems = [];

  final List<Map<String, dynamic>> _insuranceTypes = [
    {'name': 'Third Party', 'cost': '+250', 'description': 'Approx'},
    {'name': 'Engine Cover', 'cost': '+250', 'description': 'Approx'},
    {'name': 'Zero Depreciation', 'cost': '+250', 'description': 'Approx'},
    {'name': 'Tyre Cover', 'cost': '+250', 'description': 'Approx'},
  ];

  final List<Map<String, dynamic>> insuranceOptions = [
    {
      'name': 'Alloy Wheels 1',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 2',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 3',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 4',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 5',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 6',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 7',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
    {
      'name': 'Alloy Wheels 8',
      'cost': '\$+250',
      'image': 'assets/Web_Images/BookOnline/Wheel.png'
    },
  ];

  void _updateInsurance() {
    double loanAmount = double.tryParse(_loanAmountController.text.replaceAll(',', '')) ?? 0.0;
    int loanTermYears = int.tryParse(_selectedLoanTerm?.split(' ').first ?? '0') ?? 0;

    String? calculatedROI;
    if (loanAmount > 0 && loanTermYears > 0) {
      if (loanAmount >= 1000000 && loanTermYears >= 5) {
        calculatedROI = "7%";
      } else if (loanAmount >= 500000 && loanTermYears >= 3) {
        calculatedROI = "5.5%";
      } else {
        calculatedROI = "3.5%";
      }
    } else {
      calculatedROI = null;
    }

    setState(() {
      _selectedROI = calculatedROI;
      _roiController.text = calculatedROI ?? '';
    });
  }

  void _updateCarValue() {
    double? carValue = _insuranceCarValues[_selectedInsurance];
    setState(() {
      _carValueController.text = carValue != null ? carValue.toStringAsFixed(0) : '';
    });
  }


void _updateROI() {
  double loanAmount = double.tryParse(_loanAmountController.text.replaceAll(',', '')) ?? 0.0;
  int loanTermYears = int.tryParse(_selectedLoanTerm?.split(' ').first ?? '0') ?? 0;

  String? calculatedROI;
  if (loanAmount > 0 && loanTermYears > 0) {
    if (loanAmount >= 1000000 && loanTermYears >= 5) {
      calculatedROI = "7%";
    } else if (loanAmount >= 500000 && loanTermYears >= 3) {
      calculatedROI = "5.5%"; 
    } else {
      calculatedROI = "3.5%";
    }
  } else {
    calculatedROI = null;
  }

  setState(() {
    _selectedROI = calculatedROI;
    _roiController.text = calculatedROI ?? '';
  });
}


  double calculateEMI(double principal, double annualRate, int years) {
    if (principal <= 0 || annualRate <= 0 || years <= 0) return 0.0;

    
    double monthlyRate = annualRate / (12 * 100);
    
    int months = years * 12;

    double emi = principal *
        monthlyRate *
        math.pow(1 + monthlyRate, months) /
        (math.pow(1 + monthlyRate, months) - 1);

    return emi.isFinite ? emi : 0.0;
  }

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



  final _formKey = GlobalKey<FormState>();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _testDriveDateController = TextEditingController();
  final _testDriveTimeController = TextEditingController();
  // final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternatePhoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _drivingLicenseController = TextEditingController();

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


  @override
  void initState() {
    super.initState();
    _stateItems = _states.map((String state) {
      return DropdownMenuItem<String>(
        value: state,
        child: Text(
          state,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 16,
            color: Color.fromRGBO(109, 109, 109, 1),
          ),
        ),
      );
    }).toList();
    _cityItems = _cities.map((String city) {
      return DropdownMenuItem<String>(
        value: city,
        child: Text(
          city,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 16,
            color: Color.fromRGBO(109, 109, 109, 1),
          ),
        ),
      );
    }).toList();
    _branchItems = _branches.map((String branch) {
      return DropdownMenuItem<String>(
        value: branch,
        child: Text(
          branch,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 16,
            color: Color.fromRGBO(109, 109, 109, 1),
          ),
        ),
      );
    }).toList();
    _rtoItems = _rto.map((String rto) {
      return DropdownMenuItem<String>(
        value: rto,
        child: Text(
          rto,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 16,
            color: Color.fromRGBO(109, 109, 109, 1),
          ),
        ),
      );
    }).toList();
    _loanTermItems = _loan.map((String loan) {
      return DropdownMenuItem<String>(
        value: loan,
        child: Text(
          loan,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 16,
            color: Color.fromRGBO(109, 109, 109, 1),
          ),
        ),
      );
    }).toList();
    _insuranceItems = _insuranceCarValues.keys.map((String provider) {
      return DropdownMenuItem<String>(
        value: provider,
        child: Text(
          provider,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 16,
            color: Color.fromRGBO(109, 109, 109, 1),
          ),
        ),
      );
    }).toList();
    _loanAmountController.addListener(_updateROI);
    _financeProviderController.addListener(_updateROI);
    _loanAmountController.addListener(_updateInsurance);
    _financeProviderController.addListener(_updateInsurance);
    _calculatePrincipal();
    _performBookings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    phoneController.dispose();
    _dateController.dispose();
    _loanAmountController.dispose();
    _financeProviderController.dispose();
    _loanAmountController.removeListener(_updateROI);
    _financeProviderController.removeListener(_updateROI);
    _roiController.dispose();
    _carValueController.dispose();
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

  Widget _headerButton(String title, int idx) {
    return TextButton(
      onPressed: () {
        setState(() {
          isSelectedIndex = idx;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: isSelectedIndex == idx ? 2 : 0,
              color: isSelectedIndex == idx
                  ? Color.fromRGBO(26, 76, 142, 1)
                  : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "DMSans",
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelectedIndex == idx ? Color(0xFF004C90) : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _headerElevatedButton(String title, VoidCallback onPressed, {bool isOutlined = false}) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        border: isOutlined
            ? Border.all(color: Color.fromRGBO(26, 76, 142, 1), width: 1)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : Color.fromRGBO(26, 76, 142, 1),
          padding: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontFamily: "DMSans",
            color: isOutlined ? Color.fromRGBO(26, 76, 142, 1) : Colors.white,
          ),
        ),
      ),
    );
  }


@override
Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWebOrDesktop = screenWidth >= 1024;

    double imageHeight = isWebOrDesktop
      ? 70
      : isTablet
          ? 30
          : screenWidth * 0.075;
    double imageWidth = isWebOrDesktop
        ? 110
        : isTablet
            ? 80
            : screenWidth * 0.075;
    double fontSize = isWebOrDesktop
        ? 10
        : isTablet
            ? 10
            : screenWidth * 0.03 + 4;
    double textFontSize = screenWidth > 600 ? screenWidth * 0.033 : screenWidth * 0.1;


    double loanAmount = double.tryParse(_loanAmountController.text.replaceAll(',', '')) ?? 0.0;
    
    int loanTermYears = int.tryParse(_selectedLoanTerm?.split(' ').first ?? '0') ?? 0;
    
    double roi = double.tryParse(_selectedROI?.replaceAll('%', '') ?? '0') ?? 0.0;
    double emi = calculateEMI(loanAmount, roi, loanTermYears);

  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          bool isDesktop = constraints.maxWidth >= 1024;
          bool showMenu = isMobile || isTablet;

          imageHeight = isMobile ? 30 : isTablet ? 40 : 50;
          imageWidth = isMobile ? 30 : isTablet ? 40 : 50;
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
                        height: isMobile ? 30 : imageHeight,
                        width: isMobile ? 30 : imageWidth,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AROUSE',
                        style: TextStyle(
                          color: Color(0xFF004C90),
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
                                    _showNewContent = true;
                                  });
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => Viewcardetails(
                                  //       car: cars[index],
                                  //     ),
                                  //   ),
                                  // );
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
                      // innerCurrentPage = index;
                      _showNewContent = true;
                    });
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Viewcardetails(
                    //       car: cars[index],
                    //     ),
                    //   ),
                    // );
                    Navigator.pop(context);
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
    
    body: _showNewContent
              ? Viewvariants(
                onBack: () {
                  setState(() {
                    _showNewContent = false;
                  });
                },
              )
    : SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = MediaQuery.of(context).size.height;
            bool isMobile = screenWidth < 600;
            bool isTablet = screenWidth >= 600 && screenWidth < 1024;
            bool isDesktop = screenWidth >= 1024;

            double imageHeight = isDesktop
                ? screenHeight * 0.25
                : isTablet
                    ? screenHeight * 0.3
                    : screenHeight * 0.2;

            double textFontSize = isDesktop
                ? screenWidth * 0.033
                : isTablet
                    ? screenWidth * 0.045
                    : screenWidth * 0.08;

            double textTop = isDesktop
                ? screenHeight * 0.1
                : isTablet
                    ? screenHeight * 0.09
                    : screenHeight * 0.08;

            double textLeft = isDesktop
                ? screenWidth * 0.3
                : isTablet
                    ? screenWidth * 0.2
                    : screenWidth * 0.11;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                Padding(
                  padding: EdgeInsets.zero,
                  child: Stack(
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
                        top: textTop,
                        left: textLeft,
                        child: Text(
                          "Find Your Perfect Car",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: textFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: "DMSans",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                
                //Main content: Row with carousel (left) and price variants (right)       
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 8
                        : isTablet
                            ? 16
                            : 45,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (isMobile || isTablet) {
                        // MOBILE & TABLET: Stack all steps and right column in a single column
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step 1: Choose Type
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "1",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Choose Type",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // Radio buttons in a column for mobile/tablet
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "Standard Market",
                                        groupValue: _selectedType,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedType = value;
                                          });
                                        },
                                      ),
                                      Text("Standard Market"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "CSD",
                                        groupValue: _selectedType,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedType = value;
                                          });
                                        },
                                      ),
                                      Text("CSD"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "CPC",
                                        groupValue: _selectedType,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedType = value;
                                          });
                                        },
                                      ),
                                      Text("CPC"),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),

                              // Step 2: Select Branch
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "2",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Select Branch",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text("State"),
                              DropdownButton<String>(
                                value: _selectedState,
                                hint: Text('Choose a state'),
                                isExpanded: true,
                                items: _stateItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedState = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Text("City"),
                              DropdownButton<String>(
                                value: _selectedCity,
                                hint: Text('Choose a city'),
                                isExpanded: true,
                                items: _cityItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCity = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Text("Branch"),
                              DropdownButton<String>(
                                value: _selectedBranch,
                                hint: Text('Choose a branch'),
                                isExpanded: true,
                                items: _branchItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBranch = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Text("RTO"),
                              DropdownButton<String>(
                                value: _selectedRto,
                                hint: Text('Choose a RTO'),
                                isExpanded: true,
                                items: _rtoItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedRto = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 24),

                              // Step 3: Address Details
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "3",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Address Details",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Use from address book",
                                    style: TextStyle(
                                      color: Color.fromRGBO(13, 128, 212, 1),
                                      fontFamily: "Inter",
                                      fontSize: 13.1,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_right, size: 20, color: Color.fromRGBO(13, 128, 212, 1),)
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text("Current Address", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Address Line 1",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Address Line 2",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedState,
                                      hint: Text('Choose a state'),
                                      isExpanded: true,
                                      items: _stateItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedState = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedCity,
                                      hint: Text('Choose a city'),
                                      isExpanded: true,
                                      items: _cityItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCity = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              DropdownButton<String>(
                                value: _selectedBranch,
                                hint: Text('Choose a pincode'),
                                isExpanded: true,
                                items: _branchItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBranch = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Text("Permanent Address", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Address Line 1",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Address Line 2",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedState,
                                      hint: Text('Choose a state'),
                                      isExpanded: true,
                                      items: _stateItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedState = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedCity,
                                      hint: Text('Choose a city'),
                                      isExpanded: true,
                                      items: _cityItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCity = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              DropdownButton<String>(
                                value: _selectedBranch,
                                hint: Text('Choose a pincode'),
                                isExpanded: true,
                                items: _branchItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBranch = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 24),

                              // Step 4: Select RTO
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "4",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Select RTO",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              DropdownButton<String>(
                                value: _selectedRto,
                                hint: Text('Choose a RTO'),
                                isExpanded: true,
                                items: _rtoItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedRto = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 24),

                              // Step 5: Finance Details
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "5",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Finance Details",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text("Do you want to explore financing options for your vehicle?"),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "Yes",
                                        groupValue: _selectedType,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedType = value;
                                          });
                                        },
                                      ),
                                      Text("Yes"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "No",
                                        groupValue: _selectedType,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedType = value;
                                          });
                                        },
                                      ),
                                      Text("No"),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              if (_selectedType == "Yes") ...[
                                Text("Preferred Finance Provider"),
                                TextField(
                                  controller: _financeProviderController,
                                  decoration: InputDecoration(
                                    hintText: "Ex: HDFC Bank",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text("Loan Amount"),
                                TextField(
                                  controller: _loanAmountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Ex: 12,00,000",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text("Preferred Loan terms"),
                                DropdownButton<String>(
                                  value: _selectedLoanTerm,
                                  hint: Text('5 Years'),
                                  isExpanded: true,
                                  items: _loanTermItems,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedLoanTerm = newValue;
                                    });
                                  },
                                ),
                                SizedBox(height: 8),
                                Text("Rate of Interest"),
                                TextField(
                                  controller: _roiController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: "Auto Calculated",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 8),
                              ],

                              // Step 6: Insurance Details
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "6",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Insurance Details",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text("Preferred Insurance Provider"),
                              DropdownButton<String>(
                                value: _selectedInsurance,
                                hint: Text('ICICI Lombard'),
                                isExpanded: true,
                                items: _insuranceItems,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedInsurance = newValue;
                                    _updateCarValue();
                                  });
                                },
                              ),
                              SizedBox(height: 8),
                              Text("Car Value"),
                              TextField(
                                controller: _carValueController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Auto Calculated",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("Insurance Type"),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _insuranceTypes.map((insurance) {
                                    return Row(
                                      children: [
                                        Radio<String>(
                                          value: insurance['name'],
                                          groupValue: _selectedInsuranceType,
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedInsuranceType = value;
                                            });
                                          },
                                        ),
                                        Text(insurance['name']),
                                        SizedBox(width: 8),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Step 7: Accessories
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "7",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Accessories",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: isMobile ? 60 : 100,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: insuranceOptions.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isMobile ? 2 : 3,
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final insurance = insuranceOptions[index];
                                  return Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color.fromRGBO(13, 128, 212, 1)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          insurance['image'],
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                        Text(insurance['name']),
                                        Text(insurance['cost']),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 24),

                              // Right column content (after accessories)
                              Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.15),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Selected Variant",
                                      style: TextStyle(
                                        fontSize: 18.67,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(62, 62, 62, 1),
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Color.fromRGBO(198, 198, 198, 1)),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${widget.carName}",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromRGBO(62, 62, 62, 1),
                                              fontFamily: "DMSans",
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 25),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${widget.selectedVariant!["name"] ?? "Select Variant"}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color.fromRGBO(62, 62, 62, 1),
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "*Ex showroom price - ${widget.selectedVariant!["exShowroomPrice"] ?? "Should select it"}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(142, 142, 142, 1),
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    
                                                  (MediaQuery.of(context).size.width < 1024)
                                                    ? Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "*On-road price - ${widget.selectedVariant!["onRoadPrice"] ?? "Should select it"}",
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(context).size.width < 600 ? 13 : 15,
                                                              color: Color.fromRGBO(41, 88, 0, 1),
                                                              fontFamily: "DMSans",
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _showNewContent = true;
                                                              });
                                                            },
                                                            child: const Text(
                                                              "View price breakup >",
                                                              style: TextStyle(
                                                                fontSize: 9,
                                                                color: Color.fromRGBO(13, 128, 212, 1),
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "*On-road price - ${widget.selectedVariant!["onRoadPrice"] ?? "Should select it"}",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: Color.fromRGBO(41, 88, 0, 1),
                                                              fontFamily: "DMSans",
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _showNewContent = true;
                                                              });
                                                            },
                                                            child: const Text(
                                                              "View price breakup >",
                                                              style: TextStyle(
                                                                fontSize: 9,
                                                                color: Color.fromRGBO(13, 128, 212, 1),
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: "DMSans",
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Selected Color",
                                      style: TextStyle(
                                        fontSize: 18.67,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(62, 62, 62, 1),
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(241, 241, 241, 1),
                                        borderRadius: BorderRadius.circular(4.9),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: widget.selectedColor["color"] ?? Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Use Flexible to prevent overflow
                                          Flexible(
                                            child: Text(
                                              '${widget.selectedColor["name"] ?? "Unknown Color"}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromRGBO(62, 62, 62, 1),
                                                fontFamily: "DMSans",
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Dealer Details",
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18.67,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(62, 62, 62, 1),
                                        fontFamily: "DMSans",
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Color.fromRGBO(198, 198, 198, 1)),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Arouse Automotive",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 20,
                                              fontFamily: "DMSans",
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromRGBO(62, 62, 62, 1),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          // Use Wrap for responsive layout
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 5,
                                            runSpacing: 4,
                                            children: [
                                              Icon(Icons.location_on, size: 24, color: Color.fromRGBO(26, 76, 142, 1)),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width < 600 ? 180 : 300,
                                                ),
                                                child: Text(
                                                  "A big line of address for this",
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width < 600 ? 13 : 16,
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 5,
                                            runSpacing: 4,
                                            children: [
                                              Icon(Icons.email, size: 24, color: Color.fromRGBO(26, 76, 142, 1)),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width < 600 ? 180 : 300,
                                                ),
                                                child: Text(
                                                  "arouse a@ahmail,com",
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width < 600 ? 13 : 16,
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 5,
                                            runSpacing: 4,
                                            children: [
                                              Icon(Icons.call, size: 24, color: Color.fromRGBO(26, 76, 142, 1)),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width < 600 ? 180 : 300,
                                                ),
                                                child: Text(
                                                  "011-9271409124",
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width < 600 ? 13 : 16,
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(248, 249, 251, 1),
                                        border: Border.all(
                                          width: 0.95,
                                          color: Color.fromRGBO(248, 248, 248, 1),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: MediaQuery.of(context).size.width < 600
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Your Booking Amount is",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(142, 142, 142, 1),
                                                      fontSize: 15, // Mobile
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  Text(
                                                    "Rs. ${widget.totalPayable.toStringAsFixed(0)}",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(31, 31, 31, 1),
                                                      fontSize: 22, // Mobile
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: "Poppins",
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "Your Booking Amount is",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(142, 142, 142, 1),
                                                      fontSize: MediaQuery.of(context).size.width < 1024 ? 17 : 19.31, // Tablet/Web
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  Text(
                                                    "Rs. ${widget.totalPayable.toStringAsFixed(0)}",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(31, 31, 31, 1),
                                                      fontSize: MediaQuery.of(context).size.width < 1024 ? 26 : 30.67, // Tablet/Web
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: "Poppins",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
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
                                                        child: Icon(Icons.star, size: 10, color: Color(0xFF004C90)),
                                                      ),
                                                      Positioned(
                                                        top: 10,
                                                        right: 10,
                                                        child: Icon(Icons.star, size: 8, color: Color(0xFF004C90)),
                                                      ),
                                                      Positioned(
                                                        bottom: 10,
                                                        left: 10,
                                                        child: Icon(Icons.star, size: 8, color: Color(0xFF004C90)),
                                                      ),
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 20,
                                                        child: Icon(Icons.star, size: 10, color: Color(0xFF004C90)),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    "Thank you for booking your Car with \nArouse Automotive",
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
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        padding: const EdgeInsets.all(25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/Web_Images/ViewCarDetails/carBookOnline.png",
                                            height: 20,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Pay Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                      
                        // TABLET & DESKTOP: Use Row with left and right columns as before
                        return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column
                      Container(
                        width: screenWidth * 0.57,
                        padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Color.fromRGBO(198, 198, 198, 1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                      radius: 10,
                                    ),
                                    Positioned(
                                      child: Center(
                                        child: Text(
                                          "1",
                                          style: TextStyle(
                                            color: Color.fromRGBO(255, 255, 255, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.01,),
                        
                                Text(
                                  "Choose Type",
                                  style: TextStyle(
                                    color: Color.fromRGBO(109, 109, 109, 1),
                                    fontFamily: "DMSans",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 2,
                                  width: screenWidth * 0.1,
                                  color: Color.fromRGBO(0, 76, 144, 1),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: Color.fromRGBO(189, 189, 189, 1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03,),

                            Wrap(
                              spacing: screenWidth * 0.03,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: "Standard Market",
                                      groupValue: _selectedType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      },
                                      activeColor: Color.fromRGBO(0, 76, 144, 1),
                                      fillColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Color.fromRGBO(0, 76, 144, 1);
                                        }
                                        return Color.fromRGBO(189, 189, 189, 1);
                                      }),
                                    ),
                                    Text(
                                      "Standard Market",
                                      style: TextStyle(
                                        fontFamily: "DMSans",
                                        fontSize: 16,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: "CSD",
                                      groupValue: _selectedType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      },
                                      activeColor: Color.fromRGBO(0, 76, 144, 1),
                                      fillColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Color.fromRGBO(0, 76, 144, 1);
                                        }
                                        return Color.fromRGBO(189, 189, 189, 1);
                                      }),
                                    ),
                                    Text(
                                      "CSD",
                                      style: TextStyle(
                                        fontFamily: "DMSans",
                                        fontSize: 16,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: "CPC",
                                      groupValue: _selectedType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      },
                                      activeColor: Color.fromRGBO(0, 76, 144, 1),
                                      fillColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Color.fromRGBO(0, 76, 144, 1);
                                        }
                                        return Color.fromRGBO(189, 189, 189, 1);
                                      }),
                                    ),
                                    Text(
                                      "CPC",
                                      style: TextStyle(
                                        fontFamily: "DMSans",
                                        fontSize: 16,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03,),

                            //Select Branch
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                      radius: 10,
                                    ),
                                    Positioned(
                                      child: Center(
                                        child: Text(
                                          "2",
                                          style: TextStyle(
                                            color: Color.fromRGBO(255, 255, 255, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.01,),
                        
                                Text(
                                  "Select Branch",
                                  style: TextStyle(
                                    color: Color.fromRGBO(109, 109, 109, 1),
                                    fontFamily: "DMSans",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 2,
                                  width: screenWidth * 0.1,
                                  color: Color.fromRGBO(0, 76, 144, 1),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: Color.fromRGBO(189, 189, 189, 1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03,),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [

                                    //State
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "State",
                                            style: TextStyle(
                                              color: Color.fromRGBO(26, 76, 142, 1),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromRGBO(189, 189, 189, 1),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: DropdownButton<String>(
                                                value: _selectedState,
                                                hint: const Text(
                                                  'Choose a state',
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(109, 109, 109, 0.6),
                                                  ),
                                                ),
                                                items: _stateItems,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _selectedState = newValue;
                                                  });
                                                },
                                                dropdownColor: Colors.white,
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Color.fromRGBO(109, 109, 109, 1),
                                                ),
                                                underline: Container(),
                                                isDense: true,
                                                isExpanded: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),

                                    //City
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "City",
                                            style: TextStyle(
                                              color: Color.fromRGBO(26, 76, 142, 1),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02,),
                                      
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromRGBO(189, 189, 189, 1),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: DropdownButton<String>(
                                                value: _selectedCity,
                                                hint: const Text(
                                                  'Choose a city',
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(109, 109, 109, 0.6),
                                                  ),
                                                ),
                                                items: _cityItems,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _selectedCity = newValue;
                                                  });
                                                },
                                                dropdownColor: Colors.white,
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Color.fromRGBO(109, 109, 109, 1),
                                                ),
                                                underline: Container(),
                                                isDense: true,
                                                isExpanded: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ),
                                const SizedBox(height: 16),

                                //Branch
                                const Text(
                                  "Branch",
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(189, 189, 189, 1),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<String>(
                                      value: _selectedBranch,
                                      hint: const Text(
                                        'Choose a branch',
                                        style: TextStyle(
                                          fontFamily: "DMSans",
                                          fontSize: 16,
                                          color: Color.fromRGBO(109, 109, 109, 0.6),
                                        ),
                                      ),
                                      items: _branchItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedBranch = newValue;
                                        });
                                      },
                                      dropdownColor: Colors.white,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color.fromRGBO(109, 109, 109, 1),
                                      ),
                                      underline: Container(),
                                      isDense: true,
                                      isExpanded: true,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.04,),
                                
                                //Address Details
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                          radius: 10,
                                        ),
                                        Positioned(
                                          child: Center(
                                            child: Text(
                                              "3",
                                              style: TextStyle(
                                                color: Color.fromRGBO(255, 255, 255, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: screenWidth * 0.01,),
                            
                                    Text(
                                      "Address Details",
                                      style: TextStyle(
                                        color: Color.fromRGBO(109, 109, 109, 1),
                                        fontFamily: "DMSans",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),

                                    Text(
                                      "Use from address book",
                                      style: TextStyle(
                                        color: Color.fromRGBO(13, 128, 212, 1),
                                        fontFamily: "Inter",
                                        fontSize: 13.1,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_right, size: 20, color: Color.fromRGBO(13, 128, 212, 1),)
                                  ],
                                ),

                                Row(
                                  children: [
                                    Container(
                                      height: 2,
                                      width: screenWidth * 0.1,
                                      color: Color.fromRGBO(0, 76, 144, 1),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 2,
                                        color: Color.fromRGBO(189, 189, 189, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.03,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Current Address",
                                      style: TextStyle(
                                        color: Color.fromRGBO(109, 109, 109, 1),
                                        fontSize: 20,
                                        fontFamily: "DMSans",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02,),

                                    Text(
                                      "Address Line 1",
                                      style: TextStyle(
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromRGBO(189, 189, 189, 1),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Ex: D-43, 1st floor, West Patel Nagar",
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                                          hintStyle: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(31, 31, 31, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02,),


                                    Text(
                                      "Address Line 2",
                                      style: TextStyle(
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromRGBO(189, 189, 189, 1),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Ex: New Delhi, Delhi",
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                                          hintStyle: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(31, 31, 31, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02,),

                                    //State
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "State",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(26, 76, 142, 1),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  fontFamily: "Inter",
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color.fromRGBO(189, 189, 189, 1),
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: DropdownButton<String>(
                                                    value: _selectedState,
                                                    hint: const Text(
                                                      'Choose a state',
                                                      style: TextStyle(
                                                        fontFamily: "DMSans",
                                                        fontSize: 16,
                                                        color: Color.fromRGBO(109, 109, 109, 0.6),
                                                      ),
                                                    ),
                                                    items: _stateItems,
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        _selectedState = newValue;
                                                      });
                                                    },
                                                    dropdownColor: Colors.white,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color.fromRGBO(109, 109, 109, 1),
                                                    ),
                                                    underline: Container(),
                                                    isDense: true,
                                                    isExpanded: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),

                                        //City
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "City",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(26, 76, 142, 1),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  fontFamily: "Inter",
                                                ),
                                              ),
                                              SizedBox(width: screenWidth * 0.02,),
                                          
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color.fromRGBO(189, 189, 189, 1),
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: DropdownButton<String>(
                                                    value: _selectedCity,
                                                    hint: const Text(
                                                      'Choose a city',
                                                      style: TextStyle(
                                                        fontFamily: "DMSans",
                                                        fontSize: 16,
                                                        color: Color.fromRGBO(109, 109, 109, 0.6),
                                                      ),
                                                    ),
                                                    items: _cityItems,
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        _selectedCity = newValue;
                                                      });
                                                    },
                                                    dropdownColor: Colors.white,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color.fromRGBO(109, 109, 109, 1),
                                                    ),
                                                    underline: Container(),
                                                    isDense: true,
                                                    isExpanded: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.02,),

                                    //Branch
                                    const Text(
                                      "Pincode",
                                      style: TextStyle(
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                    Container(
                                      width: 400,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromRGBO(189, 189, 189, 1),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DropdownButton<String>(
                                          value: _selectedBranch,
                                          hint: const Text(
                                            'Choose a branch',
                                            style: TextStyle(
                                              fontFamily: "DMSans",
                                              fontSize: 16,
                                              color: Color.fromRGBO(109, 109, 109, 0.6),
                                            ),
                                          ),
                                          items: _branchItems,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedBranch = newValue;
                                            });
                                          },
                                          dropdownColor: Colors.white,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Color.fromRGBO(109, 109, 109, 1),
                                          ),
                                          underline: Container(),
                                          isDense: true,
                                          isExpanded: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.04,),

                                    //Permanent Details
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Permanent Address",
                                          style: TextStyle(
                                            color: Color.fromRGBO(109, 109, 109, 1),
                                            fontSize: 20,
                                            fontFamily: "DMSans",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02,),

                                        Text(
                                          "Address Line 1",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "Ex: D-43, 1st floor, West Patel Nagar",
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                                              hintStyle: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(31, 31, 31, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02,),


                                        Text(
                                          "Address Line 2",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "",
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                                              hintStyle: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(31, 31, 31, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02,),

                                        //State
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "State",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(26, 76, 142, 1),
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      fontFamily: "Inter",
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color.fromRGBO(189, 189, 189, 1),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: DropdownButton<String>(
                                                        value: _selectedState,
                                                        hint: const Text(
                                                          'Choose a state',
                                                          style: TextStyle(
                                                            fontFamily: "DMSans",
                                                            fontSize: 16,
                                                            color: Color.fromRGBO(109, 109, 109, 0.6),
                                                          ),
                                                        ),
                                                        items: _stateItems,
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            _selectedState = newValue;
                                                          });
                                                        },
                                                        dropdownColor: Colors.white,
                                                        icon: const Icon(
                                                          Icons.keyboard_arrow_down,
                                                          color: Color.fromRGBO(109, 109, 109, 1),
                                                        ),
                                                        underline: Container(),
                                                        isDense: true,
                                                        isExpanded: true,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.02),

                                            //City
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "City",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(26, 76, 142, 1),
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      fontFamily: "Inter",
                                                    ),
                                                  ),
                                                  SizedBox(width: screenWidth * 0.02,),
                                              
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color.fromRGBO(189, 189, 189, 1),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: DropdownButton<String>(
                                                        value: _selectedCity,
                                                        hint: const Text(
                                                          'Choose a city',
                                                          style: TextStyle(
                                                            fontFamily: "DMSans",
                                                            fontSize: 16,
                                                            color: Color.fromRGBO(109, 109, 109, 0.6),
                                                          ),
                                                        ),
                                                        items: _cityItems,
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            _selectedCity = newValue;
                                                          });
                                                        },
                                                        dropdownColor: Colors.white,
                                                        icon: const Icon(
                                                          Icons.keyboard_arrow_down,
                                                          color: Color.fromRGBO(109, 109, 109, 1),
                                                        ),
                                                        underline: Container(),
                                                        isDense: true,
                                                        isExpanded: true,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.02,),

                                        //Pincode
                                        const Text(
                                          "Pincode",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                        Container(
                                          width: 400,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButton<String>(
                                              value: _selectedBranch,
                                              hint: const Text(
                                                'Choose a pincode',
                                                style: TextStyle(
                                                  fontFamily: "DMSans",
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(109, 109, 109, 0.6),
                                                ),
                                              ),
                                              items: _branchItems,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedBranch = newValue;
                                                });
                                              },
                                              dropdownColor: Colors.white,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Color.fromRGBO(109, 109, 109, 1),
                                              ),
                                              underline: Container(),
                                              isDense: true,
                                              isExpanded: true,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.04,),

                                      ],
                                    ),

                                  ],
                                ),

                                //Select RTO
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                          radius: 10,
                                        ),
                                        Positioned(
                                          child: Center(
                                            child: Text(
                                              "4",
                                              style: TextStyle(
                                                color: Color.fromRGBO(255, 255, 255, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: screenWidth * 0.01,),
                            
                                    Text(
                                      "Select RTO",
                                      style: TextStyle(
                                        color: Color.fromRGBO(109, 109, 109, 1),
                                        fontFamily: "DMSans",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Container(
                                      height: 2,
                                      width: screenWidth * 0.1,
                                      color: Color.fromRGBO(0, 76, 144, 1),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 2,
                                        color: Color.fromRGBO(189, 189, 189, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.03,),

                                //RTO
                                const Text(
                                  "RTO",
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(189, 189, 189, 1),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<String>(
                                      value: _selectedRto,
                                      hint: const Text(
                                        'Choose a RTO',
                                        style: TextStyle(
                                          fontFamily: "DMSans",
                                          fontSize: 16,
                                          color: Color.fromRGBO(109, 109, 109, 0.6),
                                        ),
                                      ),
                                      items: _rtoItems,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRto = newValue;
                                        });
                                      },
                                      dropdownColor: Colors.white,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color.fromRGBO(109, 109, 109, 1),
                                      ),
                                      underline: Container(),
                                      isDense: true,
                                      isExpanded: true,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.04,),

                              ],
                            ),

                            //Finance Details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                      radius: 10,
                                    ),
                                    Positioned(
                                      child: Center(
                                        child: Text(
                                          "5",
                                          style: TextStyle(
                                            color: Color.fromRGBO(255, 255, 255, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.01,),
                          
                                Text(
                                  "Finance Details",
                                  style: TextStyle(
                                    color: Color.fromRGBO(109, 109, 109, 1),
                                    fontFamily: "DMSans",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 2,
                                  width: screenWidth * 0.1,
                                  color: Color.fromRGBO(0, 76, 144, 1),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: Color.fromRGBO(189, 189, 189, 1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03,),

                            Text(
                              "Do you want to explore financing options for your vehicle?",
                              style: TextStyle(
                                color: Color.fromRGBO(26, 76, 142, 1),
                                fontSize: 18,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Wrap(
                              spacing: screenWidth * 0.03,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: "Yes",
                                      groupValue: _selectedType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      },
                                      activeColor: Color.fromRGBO(0, 76, 144, 1),
                                      fillColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Color.fromRGBO(0, 76, 144, 1);
                                        }
                                        return Color.fromRGBO(189, 189, 189, 1);
                                      }),
                                    ),
                                    Text(
                                      "Yes",
                                      style: TextStyle(
                                        fontFamily: "DMSans",
                                        fontSize: 16,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: "No",
                                      groupValue: _selectedType,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      },
                                      activeColor: Color.fromRGBO(0, 76, 144, 1),
                                      fillColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Color.fromRGBO(0, 76, 144, 1);
                                        }
                                        return Color.fromRGBO(189, 189, 189, 1);
                                      }),
                                    ),
                                    Text(
                                      "No",
                                      style: TextStyle(
                                        fontFamily: "DMSans",
                                        fontSize: 16,
                                        color: Color.fromRGBO(26, 76, 142, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.04,),

                            if (_selectedType == "Yes") ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Preferred Finance Provider",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontFamily: "Inter",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "Ex: HDFC Bank",
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                                              hintStyle: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(31, 31, 31, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02,),
                                  
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Loan Amount",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontFamily: "Inter",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02,),
                                    
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Column(
                                            children: [
                                              TextField(
                                                decoration: InputDecoration(
                                                  hintText: "Ex: 12,00,000",
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                                                  hintStyle: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "Minimum 2,50,000 down payment is required",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Poppins",
                                            color: Color.fromRGBO(31, 31, 31, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.0,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: screenHeight * 0.02,),
                                        //Preferred Loan terms
                                        const Text(
                                          "Preferred Loan terms",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButton<String>(
                                              value: _selectedLoanTerm,
                                              hint: const Text(
                                                '5 Years',
                                                style: TextStyle(
                                                  fontFamily: "DMSans",
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(109, 109, 109, 0.6),
                                                ),
                                              ),
                                              items: _loanTermItems,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedLoanTerm = newValue;
                                                });
                                              },
                                              dropdownColor: Colors.white,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Color.fromRGBO(109, 109, 109, 1),
                                              ),
                                              underline: Container(),
                                              isDense: true,
                                              isExpanded: true,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.04,),
                                    
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02,),

                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //Preferred Loan terms
                                        const Text(
                                          "Rate of Interest",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(236, 236, 236, 1),
                                            border: Border.all(
                                              color: const Color.fromRGBO(198, 198, 198, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 3),
                                                  child: TextField(
                                                    controller: _roiController,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      hintText: "8.5%",
                                                      border: InputBorder.none,
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 14,
                                                        color: Color.fromRGBO(143, 143, 143, 1),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(right: 15.0),
                                                child: Text(
                                                  "Auto Calculated",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 14,
                                                    color: Color.fromRGBO(143, 143, 143, 1),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            //Insurance Details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "6",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.01,),
                            
                                  Text(
                                    "Insurance Details",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: screenWidth * 0.1,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: screenHeight * 0.02,),
                                        //Preferred Insurance Provider
                                        const Text(
                                          "Preferred Insurance Provider",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(189, 189, 189, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButton<String>(
                                              value: _selectedInsurance,
                                              hint: const Text(
                                                'ICICI Lomabard',
                                                style: TextStyle(
                                                  fontFamily: "DMSans",
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(109, 109, 109, 0.6),
                                                ),
                                              ),
                                              items: _insuranceItems,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedInsurance = newValue;
                                                  _updateCarValue();
                                                });
                                              },
                                              dropdownColor: Colors.white,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Color.fromRGBO(109, 109, 109, 1),
                                              ),
                                              underline: Container(),
                                              isDense: true,
                                              isExpanded: true,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.04,),
                                    
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02,),

                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //Car Value
                                        const Text(
                                          "Car Value",
                                          style: TextStyle(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(236, 236, 236, 1),
                                            border: Border.all(
                                              color: const Color.fromRGBO(198, 198, 198, 1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
                                                  child: TextField(
                                                    controller: _carValueController,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      hintText: "12,00,000",
                                                      border: InputBorder.none,
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 14,
                                                        color: Color.fromRGBO(143, 143, 143, 1),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(right: 15.0, bottom: 0, top: 0),
                                                child: Text(
                                                  "Auto Calculated",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 14,
                                                    color: Color.fromRGBO(143, 143, 143, 1),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.04,),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Preferred Add Once",
                                  style: TextStyle(
                                    color: Color.fromRGBO(26, 76, 142, 1),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                SizedBox(height: 10),

                                Stack(
                                  children: [
                                    CarouselSlider(
                                      carouselController: _carouselController,
                                      options: CarouselOptions(
                                        height: 80.0,
                                        viewportFraction: 0.3,
                                        enlargeCenterPage: false,
                                        enableInfiniteScroll: false,
                                        initialPage: 0,
                                        padEnds: false,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                          });
                                        },
                                      ),
                                      items: _insuranceTypes.map((insurance) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return Container(
                                              width: screenWidth * 0.6,
                                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromRGBO(13, 128, 212, 1),
                                                  width: 1.56,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Radio<String>(
                                                    value: insurance['name'],
                                                    groupValue: _selectedInsuranceType,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _selectedInsuranceType = value;
                                                      });
                                                    },
                                                    activeColor: Color.fromRGBO(13, 128, 212, 1),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          insurance['name'],
                                                          style: TextStyle(
                                                            fontFamily: "Poppins",
                                                            fontSize: 18.84,
                                                            fontWeight: FontWeight.w500,
                                                            color: Color.fromRGBO(100, 99, 99, 1),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              insurance['cost'],
                                                              style: TextStyle(
                                                                fontFamily: "Poppins",
                                                                fontSize: 23.76,
                                                                color: Color.fromRGBO(0, 0, 0, 1),
                                                              ),
                                                            ),
                                                            SizedBox(width: screenWidth * 0.01),
                                                            Text(
                                                              insurance['description'],
                                                              style: TextStyle(
                                                                fontFamily: "Poppins",
                                                                fontSize: 10.76,
                                                                color: Color.fromRGBO(100, 99, 99, 1),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),

                                    Positioned(
                                      top: 10,
                                      right: 0,
                                      child: IconButton(
                                        icon: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(26, 76, 142, 1),
                                            border: Border.all(
                                              color: Color.fromRGBO(26, 76, 142, 1),
                                            ),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        onPressed: () {
                                          _carouselController.nextPage(
                                            duration: Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03,),

                            //Insurance Details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                        radius: 10,
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: Text(
                                            "6",
                                            style: TextStyle(
                                              color: Color.fromRGBO(255, 255, 255, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.01,),
                            
                                  Text(
                                    "Accessories",
                                    style: TextStyle(
                                      color: Color.fromRGBO(109, 109, 109, 1),
                                      fontFamily: "DMSans",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Container(
                                    height: 2,
                                    width: screenWidth * 0.1,
                                    color: Color.fromRGBO(0, 76, 144, 1),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Color.fromRGBO(189, 189, 189, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03,),
                              
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.8,
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16.0),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: insuranceOptions.length,
                                itemBuilder: (context, index) {
                                  final insurance = insuranceOptions[index];
                                  return Container(
                                    padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromRGBO(13, 128, 212, 1),
                                      ),
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          insurance['image'],
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: insurance['name'],
                                              groupValue: _selectedInsuranceType,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _selectedInsuranceType = value;
                                                });
                                              },
                                              activeColor: const Color.fromRGBO(13, 128, 212, 1),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    insurance['name'],
                                                    style: const TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color.fromRGBO(100, 99, 99, 1),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        insurance['cost'],
                                                        style: const TextStyle(
                                                          fontFamily: "Poppins",
                                                          fontSize: 21.5,
                                                          color: Color.fromRGBO(0, 0, 0, 1),
                                                        ),
                                                      ),
                                                    ],
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),


                      // Right column: Price Variants Container
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Selected Variant",
                                        style: TextStyle(
                                          fontSize: 18.67,
                                          fontWeight: FontWeight.w700,
                                          color: Color.fromRGBO(62, 62, 62, 1),
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02,),

                                      //Select variant
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Color.fromRGBO(198, 198, 198, 1)),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${widget.carName}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromRGBO(62, 62, 62, 1),
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${widget.selectedVariant!["name"] ?? "Select Variant"}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color.fromRGBO(62, 62, 62, 1),
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "*Ex showroom price - ${widget.selectedVariant!["exShowroomPrice"] ?? "Should select it"}",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color.fromRGBO(142, 142, 142, 1),
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),

                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "*On-road price - ${widget.selectedVariant!["onRoadPrice"] ?? "Should select it"}",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color.fromRGBO(41, 88, 0, 1),
                                                          fontFamily: "DMSans",
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                              
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _showNewContent = true;
                                                          });
                                                        },
                                                        child: const Text(
                                                          "View price breakup >",
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            color: Color.fromRGBO(13, 128, 212, 1),
                                                            fontWeight: FontWeight.w400,
                                                            fontFamily: "DMSans",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      Text(
                                        "Selected Color",
                                        style: TextStyle(
                                          fontSize: 18.67,
                                          fontWeight: FontWeight.w700,
                                          color: Color.fromRGBO(62, 62, 62, 1),
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02,),

                                      Container(
                                        width: screenWidth * 0.13,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(241, 241, 241, 1),
                                          borderRadius: BorderRadius.circular(4.9),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: widget.selectedColor["color"] ?? Colors.grey,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '${widget.selectedColor["name"] ?? "Unknown Color"}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromRGBO(62, 62, 62, 1),
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                          ],
                                        ),
                                    
                                      ),
                                      SizedBox(height: screenHeight * 0.02),

                                      Text(
                                        "Dealer Details",
                                        style: TextStyle(
                                          fontSize: 18.67,
                                          fontWeight: FontWeight.w700,
                                          color: Color.fromRGBO(62, 62, 62, 1),
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.03,),

                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Color.fromRGBO(198, 198, 198, 1)),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Arouse Automotive",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: "DMSans",
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromRGBO(62, 62, 62, 1),
                                              ),
                                            ),
                                            SizedBox(height: screenHeight * 0.01,),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.location_on, size: 30, color: Color.fromRGBO(26, 76, 142, 1),),
                                                SizedBox(width: 5,),
                                                Text(
                                                  "A big line of address for this",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: screenHeight * 0.02,),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.email, size: 30, color: Color.fromRGBO(26, 76, 142, 1),),
                                                SizedBox(width: 5,),
                                                Text(
                                                  "arouse a@ahmail,com",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: screenHeight * 0.02,),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.call, size: 30, color: Color.fromRGBO(26, 76, 142, 1),),
                                                SizedBox(width: 5,),
                                                Text(
                                                  "011-9271409124",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(31, 31, 31, 1),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02,),

                              Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(248, 249, 251, 1),
                                  border: Border.all(
                                    width: 0.95,
                                    color: Color.fromRGBO(248, 248, 248, 1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Your Booking Amount is",
                                        style: TextStyle(
                                          color: Color.fromRGBO(142, 142, 142, 1),
                                          fontSize: 19.31,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      Text(
                                        "Rs. ${widget.totalPayable.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          color: Color.fromRGBO(31, 31, 31, 1),
                                          fontSize: 30.67,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02,),

                              ElevatedButton(
                                onPressed: (){
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
                                                  child: Icon(Icons.star, size: 10, color: Color(0xFF004C90)),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: Icon(Icons.star, size: 8, color: Color(0xFF004C90)),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  left: 10,
                                                  child: Icon(Icons.star, size: 8, color: Color(0xFF004C90)),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 20,
                                                  child: Icon(Icons.star, size: 10, color: Color(0xFF004C90)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              "Thank you for booking your Car with \nArouse Automotive",
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
                                }, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                  padding: const EdgeInsets.all(25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/Web_Images/ViewCarDetails/carBookOnline.png",
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: screenWidth * 0.01,),
                                    
                                    Text(
                                      "Pay Now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    ],
                  );
                  }
                }
                ),
                )
              ],
            );
          },
        ),
      ),
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