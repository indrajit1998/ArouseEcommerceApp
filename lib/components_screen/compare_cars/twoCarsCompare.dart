import 'package:flutter/material.dart';

class Twocarscompare extends StatefulWidget {
  final List<Map<String, String>> comparedCars;
  const Twocarscompare({Key? key, required this.comparedCars}) : super(key: key);

  @override
  State<Twocarscompare> createState() => _TwocarscompareState();
}

class _TwocarscompareState extends State<Twocarscompare> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                if(widget.comparedCars.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCarCard(widget.comparedCars[0]),
                    if(widget.comparedCars.length == 2)...[
                      Image.asset("assets/Home_Images/Compare_Cars/vs.png", 
                      height: 25),
                      buildCarCard(widget.comparedCars[1]),
                    ]
                    
                  ],
                )
                else const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Plese add 2 Cars to compare.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Color.fromRGBO(26, 76, 142, 1)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ElevatedButton(
                    onPressed: (){},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/Home_Images/Compare_Cars/plus.png", 
                          color: Color.fromRGBO(26, 76, 142, 1), height: 25),
                        Text(" Add Car", 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900 ,color: Color.fromRGBO(26, 76, 142, 1),),),
                      ],
                    )
                  ),
                ),
                const SizedBox(height: 30,),
                Align(
                    alignment: Alignment.centerLeft,
                    child: const TabBar(
                      isScrollable: true,
                      labelColor: Color.fromRGBO(26, 76, 142, 1),
                      unselectedLabelColor: Color.fromRGBO(104, 104, 104, 1),
                      indicatorColor: Color.fromRGBO(26, 76, 142, 1),
                      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 3, 
                          color: Color.fromRGBO(26, 76, 142, 1),
                        ),
                        insets: EdgeInsets.only(
                          left:  10,
                          right: 15,
                          
                        ),
                      ),
                      tabs: [
                        Tab(text: 'Specifications'),
                        Tab(text: 'Features'),
                        Tab(text: 'Brochure'),
                        Tab(text: 'Colours'),
                      ],
                    ),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 30.0, bottom: 10.0),
                    child: SizedBox(
                      height: 350,
                      child: TabBarView(
                        children: [
                          SpecificationsTab(),
                          FeaturesTab(),
                          BrochureTab(),
                          ColorsTab(),
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget SpecificationsTab(){
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC", style: TextStyle(fontSize: 14),),
                        const SizedBox(width: 10,),
                        Container(
                          width: 2,
                          color: Color.fromRGBO(219, 219, 219, 1),
                          height: 60,
                        ),
                        const SizedBox(width: 10,),
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC"),
                      ],
                    ),
                  ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Z12E"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Z12E"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Petrol"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Petrol"),
                    ],
                  ),
                ),
              )

            ],
          )
        ],
      ),
    );
  }

    Widget FeaturesTab(){
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC", style: TextStyle(fontSize: 14),),
                        const SizedBox(width: 10,),
                        Container(
                          width: 2,
                          color: Color.fromRGBO(219, 219, 219, 1),
                          height: 60,
                        ),
                        const SizedBox(width: 10,),
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC"),
                      ],
                    ),
                  ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Z12E"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Z12E"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Petrol"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Petrol"),
                    ],
                  ),
                ),
              )

            ],
          )
        ],
      ),
    );
  }

    Widget BrochureTab(){
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC", style: TextStyle(fontSize: 14),),
                        const SizedBox(width: 10,),
                        Container(
                          width: 2,
                          color: Color.fromRGBO(219, 219, 219, 1),
                          height: 60,
                        ),
                        const SizedBox(width: 10,),
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC"),
                      ],
                    ),
                  ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Z12E"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Z12E"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Petrol"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Petrol"),
                    ],
                  ),
                ),
              )

            ],
          )
        ],
      ),
    );
  }

    Widget ColorsTab(){
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC", style: TextStyle(fontSize: 14),),
                        const SizedBox(width: 10,),
                        Container(
                          width: 2,
                          color: Color.fromRGBO(219, 219, 219, 1),
                          height: 60,
                        ),
                        const SizedBox(width: 10,),
                        Text("1197cc, 3 cylinder Inline, \n4 valves DHOC"),
                      ],
                    ),
                  ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Z12E"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Z12E"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30,),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Petrol"),
                      const SizedBox(width: 10,),
                      Container(
                        width: 2,
                        color: Color.fromRGBO(219, 219, 219, 1),
                        height: 60,
                      ),
                      const SizedBox(width: 10,),
                      Text("Petrol"),
                    ],
                  ),
                ),
              )

            ],
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: (){}, 
                  child: Text("Review", style: TextStyle(color: Color.fromRGBO(13, 128, 212, 1),),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCarCard(Map<String, String> car) {
    return Stack(
      children: [
        Container(
          width: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2,color: Color.fromRGBO(233, 233, 233, 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    car["image"] ?? "unknown",
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/Home_Images/Compare_Cars/close.png",
                          color: Colors.grey,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),


              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car["name"] ?? "Car Name",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(5, 11, 32, 1),
                        fontWeight: FontWeight.w600,
                        fontFamily: "DMSans",
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "4.0 D5 PowerPulse Momentum 5dr AW…",
                            style: TextStyle(
                              color: Color.fromRGBO(5, 11, 32, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: "DMSans",
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          children: [
                            Image.asset(car["dieselImage"] ?? "",
                                height: 11.62, color: Colors.black, fit: BoxFit.contain),
                            Text(car["details2"] ?? "" ,style: TextStyle(fontSize: 10, fontFamily: "DMSans")),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Image.asset(car["manualImage"] ?? "assets/manuel.png", height: 11.62, fit: BoxFit.contain),
                            Text(car["details3"] ?? "Manual", style: TextStyle(fontSize: 10, fontFamily: "DMSans")),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: car["details1"] ?? "Rs. 3.07 Crore",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                            ),
                          ),
                          TextSpan(
                            text: car["details12"] ?? "hi",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                            ),
                          ),
                          TextSpan(
                            text: car["\ndetails13"] ?? "Price, Mumbai",
                            style: TextStyle(
                              color: Color.fromRGBO(157, 157, 157, 1),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}