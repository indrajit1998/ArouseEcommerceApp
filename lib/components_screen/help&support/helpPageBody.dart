import 'package:arouse_automotive_day1/components_screen/ContactUs/contactAppBar.dart';
import 'package:arouse_automotive_day1/components_screen/FAQ%E2%80%99s/FAQ.dart';
import 'package:arouse_automotive_day1/components_screen/PrivacyPolicy/privacyappBar.dart';
import 'package:arouse_automotive_day1/components_screen/RefundPolicy/refundAppBar.dart';
import 'package:arouse_automotive_day1/components_screen/Terms&Conditions/termsappBar.dart';
import 'package:flutter/material.dart';

class Helppagebody extends StatelessWidget {
  const Helppagebody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 40, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Faq()));
              }, 
              child: Text("FAQ’s", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1),),),
            ),
            Divider(
              thickness: 2,
              color: Color.fromRGBO(205, 209, 224, 1),
            ),
            const SizedBox(height: 10,),

            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Contactappbar()));
              }, 
              child: Text("Contact Us", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1)),),
            ),
            Divider(
              thickness: 2,
              color: Color.fromRGBO(205, 209, 224, 1),
            ),
            const SizedBox(height: 10,),

            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Termsappbar()));
              }, 
              child: Text("Terms & Conditions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1),),),
            ),
            Divider(
              thickness: 2,
              color: Color.fromRGBO(205, 209, 224, 1),
            ),
            const SizedBox(height: 10,),

            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Privacyappbar()));
              }, 
              child: Text("Privacy Policy", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1)),),
            ),
            Divider(
              thickness: 2,
              color: Color.fromRGBO(205, 209, 224, 1),
            ),
            const SizedBox(height: 10,),

            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Refundappbar()));
              }, 
              child: Text("Refund Policy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(31, 31, 31, 1)),),
            ),
            Divider(
              thickness: 2,
              color: Color.fromRGBO(205, 209, 224, 1),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}