import 'dart:math';

import 'package:flutter/material.dart';

class Meetingschedule extends StatefulWidget {
  const Meetingschedule({super.key});

  @override
  State<Meetingschedule> createState() => _MeetingscheduleState();
}

class _MeetingscheduleState extends State<Meetingschedule> {

  final sheet = GlobalKey();
  final controller = DraggableScrollableController();

  @override
  void initState(){
    super.initState();
  }

  void onChanged(){
    final currentSize = controller.size;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return DraggableScrollableSheet(
            controller: controller,
            initialChildSize: 0.8,
            minChildSize: 0,
            maxChildSize: 0.9,
            expand: true,
            snap: true,
            
            builder: (context, ScrollController){
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  controller: ScrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.02,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reschedule Meeting",
                              style: TextStyle(
                                fontSize: width * 0.05, 
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(77, 77, 77, 1),
                                fontFamily: "Inter",
                              ),
                            ),
                  
                            Text(
                              "Done",
                              style: TextStyle(
                                fontSize: width * 0.04, 
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(110, 142, 183, 1),
                                fontFamily: "Inter",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02,),
                  
                        Text(
                          "Meeting Date",
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(124, 130, 141, 1),
                            fontFamily: "Inter",
                          ),
                        ),
                        SizedBox(height: height * 0.005,),
                  
                        TextField(
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: "-/--",
                          hintStyle: TextStyle(
                            fontSize: width * 0.04,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(167, 171, 179, 1),
                          ),
                      
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(157, 161, 171, 1),
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(13),
                            child: Image.asset(
                              "assets/Arous_Sales_ERP_Images/AddClients/calendar.png", 
                              height: height * 0.02,
                              width: width * 0.02,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02,),
                  
                      ],
                    ),
                  ),
                ),
              );
            }
          );
        }
      ),
    );
  }
}