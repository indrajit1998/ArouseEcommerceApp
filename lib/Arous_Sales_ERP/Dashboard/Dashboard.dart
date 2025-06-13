import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar/NavigationBar.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Clients.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Home.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Orders.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/Task.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Notification/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 0;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Session expired. Please log in again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.148.185:7500/api/user/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final firstName = data['user']['firstName'] ?? '';
          final lastName = data['user']['lastName'] ?? '';
          userName = '$firstName $lastName'.trim();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch user details."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching user details: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void navigateToPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<String> appBarTitles = [
    'Home',
    'Task',
    'Clients',
    'Orders',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Home(onNavigate: navigateToPage),
      Task(onNavigate: navigateToPage),
      Clients(onNavigate: navigateToPage),
      Orders(onNavigate: navigateToPage),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        elevation: 0.2,
        shadowColor: Color.fromRGBO(128, 135, 145, 1),
        backgroundColor: Colors.white,
        title: Text(
          appBarTitles[selectedIndex],
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notificationpage()),
              );
            },
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: Navigationbar(
        onNavigate: navigateToPage,
        name: userName,
        image: null,
      ),
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
          onTap: (index) => navigateToPage(index),
          type: BottomNavigationBarType.fixed,
          elevation: 0.2,
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          selectedItemColor: Color.fromARGB(255, 0, 91, 165),
          unselectedItemColor: Color.fromRGBO(128, 135, 145, 1),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/home.png",
                width: 22,
                color: selectedIndex == 0
                    ? Color.fromARGB(255, 0, 91, 165)
                    : Color.fromRGBO(128, 135, 145, 1),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/tasks.png",
                width: 18,
                color: selectedIndex == 1
                    ? Color.fromARGB(255, 0, 91, 165)
                    : Color.fromRGBO(128, 135, 145, 1),
              ),
              label: 'Task',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/client.png",
                width: 22,
                color: selectedIndex == 2
                    ? Color.fromARGB(255, 0, 91, 165)
                    : Color.fromRGBO(128, 135, 145, 1),
              ),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/order.png",
                width: 22,
                color: selectedIndex == 3
                    ? Color.fromARGB(255, 0, 91, 165)
                    : Color.fromRGBO(128, 135, 145, 1),
              ),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}