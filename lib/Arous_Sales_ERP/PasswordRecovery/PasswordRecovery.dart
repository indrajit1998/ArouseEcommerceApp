import 'package:arouse_automotive_day1/Arous_Sales_ERP/LoginERP/LoginERP.dart';
import 'package:flutter/material.dart';

class Passwordrecovery extends StatelessWidget {
  const Passwordrecovery({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.help, size: width * 0.05),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.0),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Password Recovery", 
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.052, 
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(69, 77, 89, 1),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      "We'll help you reset your password", 
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(164, 168, 177, 1),
                      ),
                    ),
                    SizedBox(height: height * 0.01,),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
                          ),
                          onPressed: () {
                            print("ON Tap");
                          },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            border: Border.all(
                              width: 3,
                              color: Color.fromRGBO(164, 168, 177, 1).withOpacity(0.1),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.03, bottom: height * 0.045),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/Arous_Sales_ERP_Images/Password_Recovery/manager.png",
                                  height: width * 0.15,
                                ),
                                SizedBox(width: width * 0.04),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Contact Your Manager",
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: width * 0.037,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(106, 113, 122, 1),
                                      ),
                                    ),
                                    Text(
                                      "They will help verify your identity",
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: width * 0.031,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(165, 169, 178, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.01), 
              Divider(
                color: Color.fromRGBO(106, 113, 122, 1).withOpacity(0.08),
                thickness: 1,
              ),
              SizedBox(height: height * 0.04),
              SizedBox(
                width: width * 0.38,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => Loginerp()),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 15,),
                        SizedBox(width: 5,),
                        Text(
                          "Back to Login",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: width * 0.031,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(138, 144, 154, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}