import 'package:flutter/material.dart';
import 'package:arouse_automotive_day1/loginpage_mobile.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        bool isWebOrDesktop = constraints.maxWidth >= 1024;

        double imageSize = isWebOrDesktop ? 300 : isTablet ? 250 : constraints.maxWidth * 0.6;
        double buttonWidth = isWebOrDesktop ? 400 : isTablet ? 350 : constraints.maxWidth * 0.8;
        double fontSize = isWebOrDesktop ? 20 : isTablet ? 18 : 16;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "assets/image.png",
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginpageMobile()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: fontSize,
                            color: const Color.fromRGBO(0, 76, 144, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account?",
                      style: TextStyle(color: Colors.black, fontSize: fontSize),
                      children: <TextSpan>[
                        TextSpan(
                          text: " Sign Up",
                          style: const TextStyle(
                            color: Color.fromRGBO(0, 76, 144, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
