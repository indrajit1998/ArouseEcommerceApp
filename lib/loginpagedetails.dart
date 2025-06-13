import 'package:arouse_automotive_day1/loginpage_final_otp.dart';
import 'package:arouse_automotive_day1/loginpage_otp.dart';
import 'package:flutter/material.dart';

class LoginpageDetails extends StatelessWidget {
  const LoginpageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        bool isTablet = screenWidth > 600 && screenWidth <= 1024;
        bool isWeb = screenWidth > 1024;

        double horizontalPadding = screenWidth * (isWeb ? 0.25 : isTablet ? 0.15 : 0.00);
        double verticalPadding = screenHeight * (isWeb ? 0.076 : isTablet ? 0.056 : 0.0);
        double padding = screenWidth * 0.05;
        double textFieldWidth = screenWidth > 900 ? 600 : screenWidth > 600 ? 400 : double.infinity;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                        child: Image.asset(
                          "assets/image.png",
                          width: screenWidth * (isWeb ? 0.3 : isTablet ? 0.5 : 0.7),
                          height: MediaQuery.of(context).size.height * 0.3,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter your details",
                            style: TextStyle(
                              fontSize: isWeb ? 24 : isTablet ? 24 : 22 ,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Please enter your phone number to verify your identity",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: textFieldWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Full Name"),
                              _buildTextField("Enter your Full Name", TextInputType.name),
                              const SizedBox(height: 16),
                              _buildLabel("Email"),
                              _buildTextField("Enter your Email Address", TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildLabel("Phone Number*"),
                              _buildPhoneNumberField(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: textFieldWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginpagefinalOtp()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004C90),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Next",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(builder: (context) => LoginpageOtp()),
                            );
                          },
                          child: const Text("Back", style: TextStyle(color: Color(0xFF004C90), fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF004C90)),
    );
  }

  Widget _buildTextField(String hintText, TextInputType keyboardType) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          DropdownButton<String>(
            value: "+91",
            onChanged: (value) {},
            underline: const SizedBox(),
            items: ["+91", "+1", "+44", "+61"]
                .map((code) => DropdownMenuItem(
                      value: code,
                      child: Text(code),
                    ))
                .toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "Enter your Phone Number",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
