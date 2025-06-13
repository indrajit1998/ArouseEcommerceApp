import 'package:arouse_automotive_day1/HomePage_Automotive.dart';
import 'package:arouse_automotive_day1/components_screen/compare_cars/twoCarsCompare.dart';
import 'package:flutter/material.dart';

class Appbar extends StatefulWidget {
  final List<Map<String, String>> comparedCars;
  const Appbar({Key? key, required this.comparedCars}) : super(key: key);

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text('Compare Cars', style: TextStyle(fontSize: 18, color: Color.fromRGBO(26, 76, 142, 1), fontWeight: FontWeight.w700,fontFamily: "DMSans"),),
          centerTitle: true,
          elevation: 5.0,
          shadowColor: Colors.grey,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined, size: 23, color: Color.fromRGBO(26, 76, 142, 1)),
              onPressed: (){
                Navigator.pop(context, MaterialPageRoute(builder: (context) => HomepageAutomotive()),);
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/search.png", height: 26, color: Color.fromRGBO(26, 76, 142, 1),),
            ),
          ],
          
        ),
        body: Twocarscompare(comparedCars: widget.comparedCars,),
      );
  }
}