
// import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Clients.dart';
// import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Home.dart';
// import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Orders.dart';
// import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Task.dart';
// import 'package:flutter/material.dart';

// class Bottomnavigationbar extends StatefulWidget {
//   const Bottomnavigationbar({super.key});

//   @override
//   State<Bottomnavigationbar> createState() => _BottomnavigationbarState();
// }

// class _BottomnavigationbarState extends State<Bottomnavigationbar> {

//   int selectedIndex = 0;

//   // final List<Widget> pages = [
//   //   Home(),
//   //   Task(),
//   //   Clients(),
//   //   Orders(),
//   // ];

//   void onItemTapped(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[selectedIndex],
//       bottomNavigationBar: Container(
//             height: 75,
//             child: BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               elevation: 0.2,
//               backgroundColor: Colors.white,
//               currentIndex: selectedIndex,
//               onTap: onItemTapped,
              
//               selectedItemColor: Color.fromARGB(255, 0, 91, 165),
//               unselectedItemColor: Color.fromRGBO(128, 135, 145, 1),
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Image.asset(
//                     "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/home.png",
//                     width: 22,
//                     color: selectedIndex == 0 ? Color.fromARGB(255, 0, 91, 165) : Color.fromRGBO(128, 135, 145, 1),
//                   ),
//                   label: 'Home',
//                  ),
            
//                 BottomNavigationBarItem(
//                   icon: Image.asset(
//                     "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/tasks.png",
//                     width: 20,
//                     height: 18,
//                     color: selectedIndex == 1 ? Color.fromARGB(255, 0, 91, 165) : Color.fromRGBO(128, 135, 145, 1),
//                   ),
//                   label: 'Task',
//                  ),
            
//                  BottomNavigationBarItem(
//                   icon: Image.asset(
//                     "assets/Arous_Sales_ERP_Images/Bottom_Bar/Dashboard.png",
//                     width: 22,
//                     color: selectedIndex == 2 ? Color.fromARGB(255, 0, 91, 165) : Color.fromRGBO(128, 135, 145, 1),
//                   ),
//                   label: 'Dashboard',
//                  ),
            
//                  BottomNavigationBarItem(
//                   icon: Image.asset(
//                     "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/client.png",
//                     width: 22,
//                     color: selectedIndex == 3 ? Color.fromARGB(255, 0, 91, 165) : Color.fromRGBO(128, 135, 145, 1),
//                   ),
//                   label: 'Clients',
//                  ),
            
            
//                  BottomNavigationBarItem(
//                   icon: Image.asset(
//                     "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/order.png",
//                     width: 22,
//                     color: selectedIndex == 4 ? Color.fromARGB(255, 0, 91, 165) : Color.fromRGBO(128, 135, 145, 1),
//                   ),
//                   label: 'Orders',
//                  ),
//               ]
//             ),
          
        
//       ),
//     );
//   }
// }