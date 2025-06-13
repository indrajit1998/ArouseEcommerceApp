import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/MapScreen.dart';

class Editclient extends StatefulWidget {
  const Editclient({super.key});

  @override
  State<Editclient> createState() => _EditclientState();
}

class _EditclientState extends State<Editclient> {

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
  String? vendorId;
  String? originalVendorName;

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
    _loadClientData();
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

  Future<void> _loadClientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    vendorId = prefs.getString('vendorId');
    print('Retrieved Vendor ID: $vendorId');

    if (vendorId == null || vendorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = "http://10.0.2.2:7500/api/client/get/$vendorId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final clientData = responseData['client'];

        setState(() {
          vendorNameController.text = clientData['vendorName'] ?? '';
          originalVendorName = clientData['vendorName'] ?? '';
          contactPersonController.text = clientData['contactPerson'] ?? '';
          contactNumberController.text = clientData['contactNumber'] ?? '';
          addressController.text = clientData['address'] ?? '';
          emailController.text = clientData['email'] ?? '';
          areaController.text = clientData['area'] ?? '';
          categoryController.text = clientData['vendorCategory'] ?? 'Select Vendor Category *';
          selectedValue = clientData['vendorCategory'] ?? 'Select Vendor Category *';
          gstController.text = clientData['gstNumber'] ?? '';
          final location = clientData['location'];
          if (location != null && location['coordinates'] != null) {
            selectedLocation = LatLng(
              location['coordinates'][1],
              location['coordinates'][0],
            );
            showLocationData = true;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load client data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading client data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateClientDetails() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    vendorId = prefs.getString('vendorId');
    print('Retrieved Vendor ID: $vendorId');

    if (vendorId == null || vendorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (vendorNameController.text.isEmpty ||
      contactPersonController.text.isEmpty ||
      contactNumberController.text.isEmpty ||
      addressController.text.isEmpty ||
      emailController.text.isEmpty ||
      areaController.text.isEmpty ||
      categoryController.text.isEmpty ||

      categoryController.text == 'Select Vendor Category *') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select correct Category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!validateCategory()) {
      return;
    }

      if (vendorNameController.text != originalVendorName) {
        final checkUrl = "http://10.0.2.2:7500/api/client/checkVendorName";
        try {
          final checkResponse = await http.post(
            Uri.parse(checkUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"vendorName": vendorNameController.text}),
          );

          if (checkResponse.statusCode == 200) {
            final checkData = jsonDecode(checkResponse.body);
            if (checkData['success'] && checkData['exists']) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vendor name already exists'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          } else {
            final checkData = jsonDecode(checkResponse.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(checkData['message'] ?? 'Failed to check vendor name'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking vendor name: $error'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    
    setState(() {
      isSaving = true;
    });


    final String apiUrl = "http://10.0.2.2:7500/api/client/update/$vendorId";

    try {
      final response = await http.put(
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Client updated successfully!"),
          backgroundColor: Colors.green,
          ),
        );

        setState(() {
          selectedLocation = null;
          showLocationData = false;
        });

        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to update client"),
          backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again."),
        backgroundColor: Colors.red,
        ),
      );
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromRGBO(254, 254, 254, 1),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Edit Client',
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
            onPressed: updateClientDetails,
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
                        hintText: "Coca Cola",
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
                        hintText: "Indrajit Sikder",
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
                        hintText: "6289166961",
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
                                  hintText: "Kolkata,700127",
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