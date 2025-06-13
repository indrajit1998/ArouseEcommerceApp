import 'package:arouse_automotive_day1/Arous_Sales_ERP/AppTour/AppTour.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/PasswordRecovery/PasswordRecovery.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Loginerp extends StatefulWidget {
  const Loginerp({super.key});

  @override
  State<Loginerp> createState() => _LoginerpState();
}

class _LoginerpState extends State<Loginerp> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

Future<void> loginUser() async {
  final String apiUrl = "http://10.0.2.2:7500/api/user/login";

  try {
    print("Sending login request...");
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response Data: $data");

      if (data['success']) {
        // Extract fields from response
        final token = data['token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        if (user != null) {
          await prefs.setString('userId', user['id'] ?? '');
          await prefs.setString('email', user['email'] ?? '');
          print("User info saved: $user");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Apptour()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials. Please try again."), backgroundColor: Colors.red),
      );
    }
  } catch (error) {
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred. Please try again."), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Welcome to",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.053,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(69, 69, 69, 1),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Sales ERP",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.073,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(51, 95, 154, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.045),
                  Text(
                    "Email/Mobile Number",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.031,
                      color: Color.fromRGBO(128, 135, 145, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Color.fromRGBO(128, 135, 145, 1),
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      hintText: "Enter your email or mobile number",
                      hintStyle: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.033,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(128, 135, 145, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Text(
                    "Password",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.034,
                      color: Color.fromRGBO(128, 135, 145, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Color.fromRGBO(128, 135, 145, 1),
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      hintText: "Enter your password",
                      hintStyle: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.031,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(128, 135, 145, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => Passwordrecovery(),),
                      );
                    },
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.033,
                        color: Color.fromRGBO(128, 135, 145, 1),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    height: height * 0.06,
                    child: ElevatedButton(
                      
                      onPressed:  loginUser,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: "inter",
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: height * 0.01), 
            SizedBox(
              width: width * 0.33,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 19, color: Color.fromRGBO(128, 135, 145, 1)),
                  SizedBox(width: 5,),
                  Text(
                    "App Tour",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(152, 158, 166, 1),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
