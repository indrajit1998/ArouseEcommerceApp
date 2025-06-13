import 'package:arouse_automotive_day1/HomePage_Automotive.dart';
import 'package:flutter/material.dart';
import 'package:arouse_automotive_day1/loginpagedetails.dart';

class LoginpagefinalOtp extends StatefulWidget {
  @override
  _LoginpagefinalOtp createState() => _LoginpagefinalOtp();
}

class _LoginpagefinalOtp extends State<LoginpagefinalOtp> {
  final TextEditingController _otp1 = TextEditingController();
  final TextEditingController _otp2 = TextEditingController();
  final TextEditingController _otp3 = TextEditingController();
  final TextEditingController _otp4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          bool isTablet = screenWidth > 600 && screenWidth <= 1024;
          bool isWeb = screenWidth > 1024;

          double horizontalPadding = screenWidth * (isWeb ? 0.25 : isTablet ? 0.15 : 0.00);
          double verticalPadding = screenHeight * (isWeb ? 0.076 : isTablet ? 0.056 : 0.36);

          bool isLargeScreen = screenWidth > 600;

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/image.png",
                      width: screenWidth * (isWeb ? 0.3 : isTablet ? 0.5 : 0.7),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.020),
                    _buildOtpContainer(isLargeScreen),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpContainer(bool isLargeScreen) {
    return Container(
      width: isLargeScreen ? 400 : double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Enter OTP",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.010),
          const Text(
            "We have sent an OTP to your phone number",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.020),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOtpTextField(_otp1, isLargeScreen),
              _buildOtpTextField(_otp2, isLargeScreen),
              _buildOtpTextField(_otp3, isLargeScreen),
              _buildOtpTextField(_otp4, isLargeScreen),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Didn't receive OTP? ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  TextSpan(
                    text: " Resend OTP",
                    style: TextStyle(fontSize: 16, color: Color(0xFF004C90), fontWeight: FontWeight.bold)
                  ),
              ], 
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomepageAutomotive()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004C90),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Verify and Proceed", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          TextButton(
            onPressed: () {
              Navigator.pop(context, MaterialPageRoute(builder: (context) => LoginpageDetails()));
            },
            child: const Text("Back", style: TextStyle(color: Color(0xFF004C90), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpTextField(TextEditingController controller, bool isLargeScreen) {
    return Container(
      width: isLargeScreen ? 60 : 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: isLargeScreen ? 24 : 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF004C90), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
