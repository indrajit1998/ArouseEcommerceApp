import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/AddClient.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/Client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class Clients extends StatefulWidget {
  final Function(int) onNavigate;

  const Clients({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {

  List<String> searchText = ["Global Beverages Inc.", "Fresh Foods Market", "City Mart Stores"];

  bool isVendorListVisible = false;
  List<String> vendorNames = [];
  List<Map<String, dynamic>> allVendors = [];
  List<String> filteredVendorNames = [];
  OverlayEntry? _overlayEntry;
  FocusNode searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();
  bool isFetchingVendors = false;

  @override
  void initState() {
    super.initState();
    _fetchAllVendors();
    
    searchFocusNode.addListener(_handleSearchFocus);
  }

  @override
  void dispose() {
    searchFocusNode.removeListener(_handleSearchFocus);
    searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _fetchAllVendors() async {
    setState(() {
      isFetchingVendors = true;
    });
    const String apiUrl = "http://10.0.2.2:7500/api/client/getall";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> clients = responseData['clients'] ?? [];
        if (mounted) { 
          setState(() {
            allVendors = clients.cast<Map<String, dynamic>>();
            vendorNames = allVendors.map((client) => client['vendorName'] as String).toList();
            filteredVendorNames = vendorNames;
            isFetchingVendors = false;
          });
        }
        if (clients.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No vendors found in database'), backgroundColor: Colors.orange),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            isFetchingVendors = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch vendors: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isFetchingVendors = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching vendors: $error'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleSearchFocus() {
    if (searchFocusNode.hasFocus) {
      if (vendorNames.isEmpty) {
        _fetchAllVendors().then((_) {
          if (mounted && vendorNames.isNotEmpty) {
            setState(() {
              filteredVendorNames = vendorNames;
            });
            _showVendorList();
          }
        });
      } else if (mounted) {
        _showVendorList();
      }
    } else if (mounted) {
      _removeOverlay();
    }
  }

  void _showVendorList() {
    _removeOverlay();
    final RenderBox? renderBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 10,
        width: MediaQuery.of(context).size.width - 30,
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color.fromRGBO(230, 232, 236, 1), width: 2),
            ),
            child: filteredVendorNames.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'No vendors found',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Color.fromRGBO(164, 168, 177, 1),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredVendorNames.length,
                    itemBuilder: (context, index) {
                      final vendorName = filteredVendorNames[index];
                      final vendor = allVendors.firstWhere(
                        (v) => v['vendorName'] == vendorName,
                        orElse: () => {'address': ''},
                      );
                      final vendorAddress = vendor['address'] ?? '';
                      return ListTile(
                        title: Text(
                          vendorName,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(92, 92, 92, 1),
                          ),
                        ),
                        subtitle: Text(
                          vendorAddress,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(164, 168, 177, 1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async{
                          final selectedVendor = allVendors.firstWhere(
                            (v) => v['vendorName'] == vendorName,
                            orElse: () => {},
                          );
                          final vendorId = selectedVendor['_id']?.toString();
                          
                          if (vendorId != null && vendorId.isNotEmpty) {
                            
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('vendorId', vendorId);
                            print('Stored Vendor ID: $vendorId');
                            
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Client(vendorId: vendorId),
                              ),
                            );
                          }else {
                            print('Vendor ID is null or empty for $vendorName');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to load vendor details: Vendor ID not found'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          setState(() {
                            searchFocusNode.unfocus();
                            _removeOverlay();
                          });
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      isVendorListVisible = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      isVendorListVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/Arous_Sales_ERP_Images/Client/backgroundImage.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 10),
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              key: _searchBarKey,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                ),
                                border: Border.all(
                                  width: 2, 
                                  color: Color.fromRGBO(230, 232, 236, 1)
                                ),
                              ),
                              child: TextField(
                                focusNode: searchFocusNode,
                                autocorrect: true,
                                onTap: () {
                                  if (vendorNames.isEmpty && !isFetchingVendors) {
                                    _fetchAllVendors().then((_) {
                                      if (vendorNames.isNotEmpty) {
                                        setState(() {
                                          filteredVendorNames = vendorNames;
                                        });
                                        _showVendorList();
                                      }
                                    });
                                  } else if (!isFetchingVendors) {
                                    _showVendorList();
                                  }
                                },
                                onChanged: (value) {
                                  setState(() {
                                    filteredVendorNames = vendorNames
                                        .where((name) => name.toLowerCase().contains(value.toLowerCase()))
                                        .toList();
                                    if (isVendorListVisible) {
                                      _showVendorList();
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search clients..',
                                  hintStyle: TextStyle(
                                    fontSize: width * 0.038,
                                    color: Color.fromRGBO(153, 153, 153, 1),
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: isFetchingVendors
                                  ? Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      Icons.search, 
                                      size: 25, 
                                      color: Color.fromRGBO(165, 170, 178, 1),
                                    ),
                                  suffixIcon: IconButton(
                                    onPressed: (){},
                                    icon: Icon(
                                      Icons.filter_alt, 
                                      size: 25, 
                                      color: Color.fromRGBO(165, 170, 178, 1),
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01,),
                        
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => Client()),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/Arous_Sales_ERP_Images/Client/blankImage.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 25.0, right: 15, top: 30, bottom: 30),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Image.asset(
                                                "assets/Arous_Sales_ERP_Images/Client/windowsBackground.png",
                                                width: width * 0.1,
                                              ),
                                                      
                                              Image.asset(
                                                "assets/Arous_Sales_ERP_Images/Client/windows.png",
                                                width: width * 0.04,
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: width * 0.05,),
                                          
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Client()));
                                                },
                                                child: Text(
                                                  "Microsoft Corporation",
                                                  style: TextStyle(
                                                    fontSize: width * 0.035,
                                                    color: Color.fromRGBO(91, 91, 91, 1),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "Redmond, USA",
                                                    style: TextStyle(
                                                      fontSize: width * 0.033,
                                                      color: Color.fromRGBO(161, 166, 175, 1),
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: "Inter",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                                      
                                              Text(
                                                "Sarah Johnson - Account Manager",
                                                style: TextStyle(
                                                  fontSize: width * 0.032,
                                                  color: Color.fromRGBO(145, 151, 159, 1),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: "Inter",
                                                ),
                                              ),
                                            ],
                                          ),
                                                      
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "assets/Arous_Sales_ERP_Images/Client/call.png",
                                                width: width * 0.035,
                                              ),
                                              SizedBox(width: width * 0.06,),
                                              Image.asset(
                                                "assets/Arous_Sales_ERP_Images/Client/location.png",
                                                width: width * 0.033,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02,),
                        
                            
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(right: 0, bottom: 10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Addclient()),
                  );
                },
                icon: Image.asset(
                  "assets/Arous_Sales_ERP_Images/Tasks/AddImage.png",
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}