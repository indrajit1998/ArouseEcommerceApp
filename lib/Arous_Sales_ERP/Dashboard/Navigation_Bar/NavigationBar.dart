import 'package:arouse_automotive_day1/Arous_Sales_ERP/AppTour/AppTour.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar/Edit_Profile/EditProfile.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/LoginERP/LoginERP.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Navigationbar extends StatefulWidget {
  final Function(int) onNavigate;
  final String name;
  final File? image;

  const Navigationbar({
    Key? key,
    required this.onNavigate,
    required this.name,
    this.image,
  }) : super(key: key);

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  late String _name;
  File? _image;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _image = widget.image;
    _loadProfileData();
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? widget.name;
      final imagePath = prefs.getString('profileImage');
      if (imagePath != null && File(imagePath).existsSync()) {
        _image = File(imagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Drawer(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 51, 160, 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $_name' ?? 'Welcome',
                        style: const TextStyle(
                          color: Color.fromRGBO(193, 206, 224, 1),
                          fontSize: 20.8,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Editprofile(
                                initialName: _name,
                                initialImage: _image,
                              ),
                            ),
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            setState(() {
                              _name = result['name'] is String ? result['name'] : _name;
                              _image = result['image'] is File? ? result['image'] : _image;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('name', _name);
                            if (_image != null && _image!.existsSync()) {
                              await prefs.setString('profileImage', _image!.path);
                            }
                          }
                        },
                        child: Row(
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Color.fromRGBO(193, 206, 224, 1),
                                fontSize: 15.1,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                              ),
                            ),
                            SizedBox(width: width * 0.01),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color.fromRGBO(193, 206, 224, 1),
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 35.0,
                    backgroundImage: _image != null && _image!.existsSync()
                        ? FileImage(_image!)
                        : const AssetImage(
                            'assets/Arous_Sales_ERP_Images/Side_Bar_Menu/Side_bar_Image.png',
                          ) as ImageProvider,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Image.asset(
                    "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/home.png",
                    width: 22,
                  ),
                  title: const Text(
                    'Home',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 136, 146, 1),
                      fontSize: 18.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  onTap: () {
                    widget.onNavigate(0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/tasks.png",
                    width: 20,
                  ),
                  title: const Text(
                    'Tasks',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 136, 146, 1),
                      fontSize: 18.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  onTap: () {
                    widget.onNavigate(1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/order.png",
                    width: 22,
                  ),
                  title: const Text(
                    'Order',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 136, 146, 1),
                      fontSize: 18.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  onTap: () {
                    widget.onNavigate(3);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/client.png",
                    width: 22,
                  ),
                  title: const Text(
                    'Client',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 136, 146, 1),
                      fontSize: 18.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  onTap: () {
                    widget.onNavigate(2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/Map_location.png",
                    width: 22,
                  ),
                  title: const Text(
                    'App Tour',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 136, 146, 1),
                      fontSize: 18.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Apptour()),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/edit_square.png",
                    width: 22,
                  ),
                  title: const Text(
                    'Edit Order',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 136, 146, 1),
                      fontSize: 18.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  onTap: () {
                    widget.onNavigate(3);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const Divider(
            color: Color.fromRGBO(230, 232, 236, 1),
            thickness: 2,
          ),
          SizedBox(height: height * 0.02),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: width * 0.25,
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Loginerp()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/Arous_Sales_ERP_Images/Side_Bar_Menu/exit.png",
                        width: 22,
                      ),
                      SizedBox(width: width * 0.01),
                      const Text(
                        "Logout",
                        style: TextStyle(
                          color: Color.fromRGBO(244, 136, 136, 1),
                          fontSize: 15.1,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
        ],
      ),
    );
  }
}