import 'package:flutter/material.dart';
import 'package:arouse_automotive_day1/HomePage_Automotive.dart';
import 'package:arouse_automotive_day1/components_screen/ContactUs/contactAppBody.dart';

class Contactappbar extends StatefulWidget {
  const Contactappbar({super.key});

  @override
  State<Contactappbar> createState() => _ContactappbarState();
}

class _ContactappbarState extends State<Contactappbar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, MaterialPageRoute(builder: (context)=> HomepageAutomotive()));
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, size: MediaQuery.of(context).size.width * 0.06, color: Color.fromRGBO(26, 76, 142, 1)),
        ),
        centerTitle: true,
        title: Text(
          "Contact Us",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            color: Color.fromRGBO(26, 76, 142, 1),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.grey,
      ),
      body: Contactappbody(),
    );
  }
}
