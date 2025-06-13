import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Dashboard.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

class Apptour extends StatefulWidget {
  const Apptour({super.key});

  @override
  State<Apptour> createState() => _ApptourState();
}

class _ApptourState extends State<Apptour> {

  final PageController _controller = PageController();
  int index = 0;

  final List<String> images = [
    'assets/Arous_Sales_ERP_Images/App_Tour_Video/AppTourImage.png',
    'assets/Arous_Sales_ERP_Images/App_Tour_Video/AppTourImage.png',
    'assets/Arous_Sales_ERP_Images/App_Tour_Video/AppTourImage.png',
  ];


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.04,),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome to',
                      style: TextStyle(
                        fontSize: 22.6,
                        color: Color.fromRGBO(75, 82, 94, 1),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    TextSpan(
                      text: ' Arouse',
                      style: TextStyle(
                        fontSize: 22.8,
                        color: Color.fromRGBO(88, 124, 172, 1),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ]
                ),
              ),
            ),

            SizedBox(height: height * 0.01,),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    this.index = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),

                      Positioned(
                        child: Image.asset(
                          "assets/Arous_Sales_ERP_Images/App_Tour_Video/playImage.png",
                          width: width * 0.18,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: height * 0.02),

            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: images.length,
                axisDirection: Axis.horizontal,
                effect: SlideEffect(
                  spacing: 8.0,
                  radius: 10.0,
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  paintStyle: PaintingStyle.stroke,
                  strokeWidth: 1,
                  dotColor: Colors.grey,
                  activeDotColor: Colors.indigo,
                ),
              ),
            ),
            
            SizedBox(height: height * 0.04,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard Overview",
                      style: TextStyle(
                        fontSize: height * 0.023,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(106, 106, 106, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * 0.01,),
                    
                    Text(
                      "Learn to navigate through your sales data, analytics, and key metrics in one centralized dashboard.",
                      style: TextStyle(
                        fontSize: height * 0.017,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(106, 106, 106, 1),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: height * 0.01,),
                  ],
                ),
              )
            ),

            SizedBox(height: height * 0.03,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Management",
                      style: TextStyle(
                        fontSize: height * 0.023,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(106, 106, 106, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * 0.01,),
                    
                    Text(
                      "Discover how to efficiently process orders, track shipments, and manage inventory levels.",
                      style: TextStyle(
                        fontSize: height * 0.017,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(106, 106, 106, 1),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: height * 0.01,),
                
                  ],
                ),
              )
            ),

            SizedBox(height: height * 0.03,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Relations",
                      style: TextStyle(
                        fontSize: height * 0.023,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(106, 106, 106, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * 0.01,),
                    
                    Text(
                      "Access customer profiles, communication history, and manage relationships effectively.",
                      style: TextStyle(
                        fontSize: height * 0.017,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(106, 106, 106, 1),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              )
            ),

            SizedBox(height: height * 0.03,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: (){
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                  icon: Image.asset(
                    "assets/Arous_Sales_ERP_Images/App_Tour_Video/right_arrow.png",
                    height: height * 0.07,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}