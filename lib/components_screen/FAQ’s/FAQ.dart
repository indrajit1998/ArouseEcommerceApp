import 'package:arouse_automotive_day1/HomePage_Automotive.dart';
import 'package:arouse_automotive_day1/components_screen/FAQ%E2%80%99s/FAQBody.dart';
import 'package:flutter/material.dart';

class Faq extends StatelessWidget {
  const Faq({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            onPressed: (){
              Navigator.pop(
                context, MaterialPageRoute(builder: (context) => HomepageAutomotive()),
              );
            }, 
            icon: Icon(Icons.arrow_back_ios_new_outlined, size: 23, color: Color.fromRGBO(26, 76, 142, 1)),
          ),
          
        ),
        centerTitle: true,
        title: Text("FAQ’s", 
        style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 18, color: Color.fromRGBO(26, 76, 142, 1)),),
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.grey,
      ),
      body: Faqbody(),
    );
  }
}