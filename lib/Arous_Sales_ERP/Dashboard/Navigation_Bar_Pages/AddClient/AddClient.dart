import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/Client.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/MapScreen.dart';

class Addclient extends StatefulWidget {
  const Addclient({super.key});

  @override
  State<Addclient> createState() => _AddclientState();
}

class _AddclientState extends State<Addclient> {


  final List<String> items = ['Select Vendor Category *', 'Raw Materials Vendors', 'Service Vendors', 'Utility Vendors', 'Contract Vendors', 'Transportation & Logistics Vendors', ' Maintenance Vendors'];
  String selectedValue = 'Select Vendor Category *';

  @override
  void initState() {
    super.initState();
    categoryController.text = selectedValue ?? '';
    categoryController.addListener(() {
      setState(() {
        selectedValue = categoryController.text;
      });
    });
  }

  bool validateCategory() {
    if (selectedValue == 'Select Vendor Category *') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a valid vendor category'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  LatLng? selectedLocation;
  bool showLocationData = false;
  bool isSaving = false;

  Future<void> addClient() async {

    if (isSaving) return;
    if (!validateCategory()) return;

    setState(() {
      isSaving = true;
    });

    if (vendorNameController.text.isEmpty ||
      contactPersonController.text.isEmpty ||
      contactNumberController.text.isEmpty ||
      addressController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please fill all required fields"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isSaving = true;
  });

    final String apiUrl = "http://127.0.0.1:7500/api/client/add";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "vendorName": vendorNameController.text,
          "contactPerson": contactPersonController.text,
          "contactNumber": contactNumberController.text,
          "address": addressController.text,
          "email": emailController.text,
          "area": areaController.text,
          "vendorCategory": categoryController.text,
          "gstNumber": gstController.text,
          "location": {
            "type": "Point",
            "coordinates": selectedLocation != null
                ? [selectedLocation!.longitude, selectedLocation!.latitude]
                : [0.0, 0.0],
          }
        }),
      );

      print('Add Client Response Status: ${response.statusCode}');
      print('Add Client Response Body: ${response.body}');

      if (response.statusCode == 201) {

        final data = jsonDecode(response.body);
        
        final String vendorId = data['_id'] ?? data['client']['_id'];

        if (vendorId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to retrieve vendor ID"),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isSaving = false;
          });
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool saved = await prefs.setString('vendorId', vendorId);
        print('Vendor ID Saved: $vendorId, Success: $saved');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Client added successfully!"),
          backgroundColor: Colors.green,
          ),
        );

        setState(() {
          selectedLocation = null;
          showLocationData = false;
          isSaving = false;
        });

        vendorNameController.clear();
        contactPersonController.clear();
        contactNumberController.clear();
        addressController.clear();
        emailController.clear();
        areaController.clear();
        gstController.clear();
        categoryController.text = 'Select Vendor Category *';
        selectedValue = 'Select Vendor Category *';

        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => Client(),),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to add client"),
          backgroundColor: Colors.red,),
        );
        setState(() {
          isSaving = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again."),
        backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> openMap() async {
    final pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: selectedLocation ?? const LatLng(12.9716, 77.5946),
        ),
      ),
    );

    setState(() {
      if (pickedLocation != null) {
        selectedLocation = pickedLocation;
        showLocationData = true;
      } else {
        
        if (selectedLocation != null) {
          showLocationData = false;
          selectedLocation = null;
        }
      }
    });
  }

  @override
  void dispose() {
    vendorNameController.dispose();
    contactPersonController.dispose();
    contactNumberController.dispose();
    addressController.dispose();
    categoryController.dispose();
    gstController.dispose();
    emailController.dispose();
    areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromRGBO(254, 254, 254, 1),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Add Client',
          style: TextStyle(
            fontSize: width * 0.05,
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(71, 71, 71, 1),
          ),
        ),
        elevation: 0.1,
        shadowColor: Color.fromRGBO(228, 229, 232, 1),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: addClient,
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: width * 0.04,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(103, 188, 248, 1),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                      controller: vendorNameController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Vendor Name *",
                        hintStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontFamily: "Inter",
                          color: Color.fromRGBO(157, 161, 171, 1),
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
                            "assets/Arous_Sales_ERP_Images/AddClients/vendorName.png", 
                            height: height * 0.02,
                            width: width * 0.02,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    TextField(
                      controller: contactPersonController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Contact Person *",
                        hintStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontFamily: "Inter",
                          color: Color.fromRGBO(157, 161, 171, 1),
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
                            "assets/Arous_Sales_ERP_Images/AddClients/person.png", 
                            height: height * 0.02,
                            width: width * 0.02,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    TextField(
                      controller: contactNumberController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Contact Number *",
                        hintStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontFamily: "Inter",
                          color: Color.fromRGBO(157, 161, 171, 1),
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
                            "assets/Arous_Sales_ERP_Images/AddClients/call.png", 
                            height: height * 0.02,
                            width: width * 0.02,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(157, 161, 171, 1),
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5, right: 10),
                            child: Image.asset(
                              "assets/Arous_Sales_ERP_Images/AddClients/location.png",
                              height: height * 0.022,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextField(
                                controller: addressController,
                                autocorrect: true,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 4,
                                decoration: InputDecoration(
                                  hintText: "Address *",
                                  hintStyle: TextStyle(
                                    fontSize: width * 0.04,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(157, 161, 171, 1),
                                  ),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          
                          if (showLocationData && selectedLocation != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              "Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}",
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(239, 246, 255, 1),
                                border: Border.all(
                                  width: 1,
                                  color: const Color.fromRGBO(237, 242, 247, 1),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                              child: TextButton(
                                onPressed: openMap,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/Arous_Sales_ERP_Images/AddClients/pinLocation.png",
                                        height: height * 0.022,
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Text(
                                        "Pin Address on Map",
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromRGBO(98, 134, 180, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: height * 0.02),
                        ],
                      ),
                    ),

                    Container(
                      width: width * 1,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: Color.fromRGBO(157, 161, 171, 1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                        child: Row(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(right: 13),
                              child: Image.asset(
                                "assets/Arous_Sales_ERP_Images/AddClients/category.png",
                                height: height * 0.055,
                                width: width * 0.055,
                                fit: BoxFit.contain,
                              ),
                            ),

                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedValue,
                                  icon: Image.asset(
                                    "assets/Arous_Sales_ERP_Images/AddClients/downArrow.png",
                                    height: height * 0.05,
                                    width: width * 0.05,
                                    fit: BoxFit.contain,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedValue = newValue!;
                                      categoryController.text = newValue ?? '';
                                    });
                                  },
                                  items: items.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item, 
                                        style: TextStyle(
                                          color: Color.fromRGBO(92, 92, 92, 1),
                                          fontSize: width * 0.043,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    TextField(
                      controller: gstController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "GST Number",
                        hintStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontFamily: "Inter",
                          color: Color.fromRGBO(157, 161, 171, 1),
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
                            "assets/Arous_Sales_ERP_Images/AddClients/gst.png", 
                            height: height * 0.02,
                            width: width * 0.02,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    TextField(
                      controller: emailController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontFamily: "Inter",
                          color: Color.fromRGBO(157, 161, 171, 1),
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
                            "assets/Arous_Sales_ERP_Images/AddClients/email.png", 
                            height: height * 0.02,
                            width: width * 0.02,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02,),
              
                    TextField(
                      controller: areaController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Area",
                        hintStyle: TextStyle(
                          fontSize: width * 0.04,
                          fontFamily: "Inter",
                          color: Color.fromRGBO(157, 161, 171, 1),
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
                            "assets/Arous_Sales_ERP_Images/AddClients/area.png", 
                            height: height * 0.02,
                            width: width * 0.02,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}