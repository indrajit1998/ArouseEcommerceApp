import 'package:flutter/material.dart';

class Faqbody extends StatelessWidget {
  const Faqbody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 40, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lorem ipsum dolor sit amet consectetur ?", 
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: "DMSans"),),
                  SizedBox(height: 20),
                  Text("Lorem ipsum dolor sit amet consectetur. Posuere sed odio elementum nunc volutpat egestas nunc ridiculus leo. Proin cras aenean eget sapien. Sollicitudin luctus vestibulum elit proin sit massa. Morbi duis eu amet nisi pulvinar mollis nulla sapien. Massa proin eros placerat posuere vestibulum ut magna hendrerit. Sem egestas nunc volutpat dictumst faucibus. Ultricies tristique netus vitae sagittis nulla velit integer.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color.fromRGBO(84, 84, 84, 1)),),
                  SizedBox(height: 40,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  )
                ],
              ),
              SizedBox(height: 10,),
        
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Lorem ipsum dolor sit amet consectetur ?", 
                      style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromRGBO(31, 31, 31, 1)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Lorem ipsum dolor sit amet consectetur ?", 
                      style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromRGBO(31, 31, 31, 1)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Lorem ipsum dolor sit amet consectetur ?", 
                      style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromRGBO(31, 31, 31, 1)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Lorem ipsum dolor sit amet consectetur ?", 
                      style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromRGBO(31, 31, 31, 1)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Lorem ipsum dolor sit amet consectetur ?", 
                      style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromRGBO(31, 31, 31, 1)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Lorem ipsum dolor sit amet consectetur ?", 
                      style: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromRGBO(31, 31, 31, 1)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    thickness: 2,
                    color: Color.fromRGBO(205, 209, 224, 1),
                  ),
                ],
              ),
              SizedBox(height: 10,),
        
            ],
          ),
        ),
      ),
    );
  }
}