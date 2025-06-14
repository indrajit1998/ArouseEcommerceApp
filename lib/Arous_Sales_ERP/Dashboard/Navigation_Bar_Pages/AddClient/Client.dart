import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/EditClient.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/mapDisplay.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddPlan/addPlan.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/History/History.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/NewOrder/NewOrder.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Client extends StatefulWidget {
  final Map<String, dynamic>? meeting;
  final String? vendorId;

  const Client({super.key, this.meeting, this.vendorId});

  @override
  State<Client> createState() => _ClientState();
}

class _ClientState extends State<Client> {
  
  String vendorName = '';
  String contactNumber = '';
  String address = '';
  String vendorCategory = '';
  String gstNumber = '';
  String email = '';
  String area = '';
  double longitude = 0.0;
  double latitude = 0.0;


  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> orders = [];
  Map<String, dynamic>? userData;
  Map<String, dynamic>? clientData;
  bool isFetchingClient = false;
  bool isFetchingUser = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.wait([
        _loadClientData(),
        _fetchClientData(),
        _fetchUserData(),
        _loadAndUpdateOrders(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to initialize data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _loadClientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorId = widget.vendorId ?? prefs.getString('vendorId');
    print('Retrieved Vendor ID in _loadClientData: $vendorId');

    if (vendorId == null || vendorId.isEmpty) {
      setState(() {
        errorMessage = 'Vendor ID not found in SharedPreferences';
      });
      return;
    }

    await prefs.setString('vendorId', vendorId);

    final String apiUrl = "http://127.0.0.1:7500/api/client/get/$vendorId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      print('Load Client Response Status: ${response.statusCode}');
      print('Load Client Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final clientData = responseData['client'];

        final location = clientData['location'];
        final coordinates = location != null ? location['coordinates'] : null;

        if (coordinates != null && coordinates is List && coordinates.length == 2) {
          longitude = coordinates[0].toDouble();
          latitude = coordinates[1].toDouble();
        }

        setState(() {
          vendorName = clientData['vendorName'] ?? 'Coca-Cola Beverages Ltd.';
          contactNumber = clientData['contactNumber'] ?? '+1 (555) 234-5678';
          address = clientData['address'] ?? '123 Business Park, Suite 456, New York, NY 10001';
          email = clientData['email'] ?? 'm.thompson@coca-cola.com';
          gstNumber = clientData['gstNumber'] ?? 'ABC123XYZ789';
          vendorCategory = (clientData['vendorCategory'] is List
                  ? clientData['vendorCategory'].join(', ')
                  : clientData['vendorCategory']) ??
              'Wholesaler';
          area = clientData['area'] ?? 'Unknown';
          this.clientData = clientData;
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          errorMessage = responseData['message'] ?? 'Failed to fetch client data';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching client data: $error';
      });
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token != null && JwtDecoder.isExpired(token)) {
        return await refreshToken();
      }
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<String?> refreshToken() async {
    const String refreshTokenApiUrl = "http://127.0.0.1:7500/api/auth/refreshToken";
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) {
        print('No refresh token found');
        return null;
      }

      final response = await http.post(
        Uri.parse(refreshTokenApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['accessToken'];
        await prefs.setString('authToken', newToken);
        return newToken;
      } else {
        print('Refresh token failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isFetchingUser = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      setState(() {
        errorMessage = "User ID not found. Please log in again.";
        isFetchingUser = false;
      });
      return;
    }

    final String apiUrl = "http://127.0.0.1:7500/api/user/$userId";
    String? token = await getToken();

    if (token == null) {
      setState(() {
        errorMessage = "No valid token found. Please log in again.";
        isFetchingUser = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("User API Response: $responseData");
        final user = responseData['user'];
        if (user == null) {
          setState(() {
            errorMessage = "User data not found in API response.";
            isFetchingUser = false;
          });
          return;
        }
        print("Parsed User Data: $user");
        print("User Address: ${user['address']}");
        setState(() {
          userData = user;
          isFetchingUser = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch user data: ${response.statusCode} - ${response.body}";
          isFetchingUser = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Error fetching user data: $error";
        isFetchingUser = false;
      });
    }
  }

  Future<void> _fetchClientData() async {
    setState(() {
      isFetchingClient = true;
      errorMessage = null;
    });

    const String apiUrl = "http://127.0.0.1:7500/api/client/getall";
    String? token = await getToken();

    if (token == null) {
      setState(() {
        errorMessage = "No valid token found. Please log in again.";
        isFetchingClient = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Client API Response: $responseData");
        final List<dynamic> clients = responseData['clients'] ?? [];

        String? vendorNameFromMeeting;
        final rawVendorName = widget.meeting?['vendorName'];
        if (rawVendorName is String && rawVendorName.isNotEmpty) {
          vendorNameFromMeeting = rawVendorName;
        } else if (rawVendorName is List && rawVendorName.isNotEmpty) {
          vendorNameFromMeeting = rawVendorName[0].toString();
        } else {
          vendorNameFromMeeting = vendorName;
        }

        Map<String, dynamic>? matchedClient;
        if (vendorNameFromMeeting.isNotEmpty) {
          matchedClient = clients.firstWhere(
            (client) => client['vendorName'] == vendorNameFromMeeting,
            orElse: () => null,
          );
        }

        setState(() {
          clientData = matchedClient ?? clientData;
          isFetchingClient = false;
          if (matchedClient == null) {
            errorMessage = "No client found for vendor: $vendorNameFromMeeting";
          }
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch client data: ${response.statusCode} - ${response.body}";
          isFetchingClient = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Error fetching client data: $error";
        isFetchingClient = false;
      });
    }
  }

  Future<Map<String, double>?> _geocodeAddress(String address) async {

    final queryAddress = Uri.encodeComponent(address);
    final String apiUrl = 'https://nominatim.openstreetmap.org/search?q=$queryAddress&format=json&limit=1';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'User-Agent': 'ArouseSalesERP/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Nominatim Response for '$queryAddress': $data");
        if (data.isNotEmpty) {
          final location = data[0];
          print("Geocoded Coordinates: ${location['lat']}, ${location['lon']}");
          return {
            'latitude': double.parse(location['lat']),
            'longitude': double.parse(location['lon']),
          };
        } else {
          print("Geocoding failed: No results for address '$queryAddress'");
          return null;
        }
      } else {
        print("Geocoding HTTP error: ${response.statusCode} for address '$queryAddress'");
        return null;
      }
    } catch (e) {
      print("Geocoding error for address '$queryAddress': $e");
      return null;
    }
  }

  void _showMap() async {
    if (!mounted) return;

    if (isFetchingClient || isFetchingUser || isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data is still loading. Please wait."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (clientData == null || userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ?? "Client or user data is not available. Please try again later.",
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _initializeData();
            },
          ),
        ),
      );
      return;
    }

    final vendorLocation = clientData!['location'] as Map<String, dynamic>?;
    final vendorCoordinates = vendorLocation != null ? vendorLocation['coordinates'] as List<dynamic>? : null;

    if (vendorCoordinates == null || vendorCoordinates.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vendor coordinates are not available."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vendorLongitude = vendorCoordinates[0].toDouble();
    final vendorLatitude = vendorCoordinates[1].toDouble();
    final vendorAddress = clientData!['address'] ?? 'Unknown Address';

    double? userLatitude;
    double? userLongitude;
    String userAddress = userData!['address'] ?? 'Unknown Address';

    if (userAddress != 'Unknown Address') {
      final userCoordinates = await _geocodeAddress(userAddress);
      if (!mounted) return;
      if (userCoordinates != null) {
        userLatitude = userCoordinates['latitude'];
        userLongitude = userCoordinates['longitude'];
      }
    }

    if (userLatitude == null || userLongitude == null) {
      userLatitude = 19.0760;
      userLongitude = 72.8777;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userAddress != 'Unknown Address'
                ? "Failed to geocode user address: $userAddress. Using default Mumbai coordinates."
                : "User address not available. Using default Mumbai coordinates.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Mapdisplay(
          latitude: vendorLatitude,
          longitude: vendorLongitude,
          vendorName: vendorName,
          userLatitude: userLatitude!,
          userLongitude: userLongitude!,
          userName: "${userData!['firstName']} ${userData!['lastName']}",
        ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  Future<void> _loadAndUpdateOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingOrders = prefs.getString('orders');

    if (existingOrders != null) {
      setState(() {
        orders = List<Map<String, dynamic>>.from(jsonDecode(existingOrders));
      });

      for (var order in orders) {
        if (order['status'] == null || order['status'] == 'Placed') {
          _simulateOrderStatusUpdate(order['orderId'], order['backendOrderId'] ?? order['orderId']);
        }
      }
    }
  }

  Future<void> _simulateOrderStatusUpdate(String orderId, String backendOrderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.delayed(Duration(seconds: 30));
    setState(() {
      var updatedOrders = List<Map<String, dynamic>>.from(orders);
      var order = updatedOrders.firstWhere((o) => o['orderId'] == orderId);
      order['status'] = 'Shipped';
      order['shippedTimestamp'] = DateTime.now().toIso8601String();
      orders = updatedOrders;
    });
    await prefs.setString('orders', jsonEncode(orders));

    await Future.delayed(Duration(seconds: 30));
    setState(() {
      var updatedOrders = List<Map<String, dynamic>>.from(orders);
      var order = updatedOrders.firstWhere((o) => o['orderId'] == orderId);
      order['status'] = 'Delivered';
      order['deliveredTimestamp'] = DateTime.now().toIso8601String();
      orders = updatedOrders;
    });
    await prefs.setString('orders', jsonEncode(orders));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null && clientData == null && userData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),
              ElevatedButton(
                onPressed: _initializeData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Main UI
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Client',
          style: TextStyle(
            fontSize: width * 0.05,
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(76, 76, 76, 1),
          ),
        ),
        elevation: 0.1,
        shadowColor: Color.fromRGBO(228, 229, 232, 1),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Editclient()),
              );
              if (result == true) {
                setState(() {
                  isLoading = true;
                });
                await _loadClientData();
              }
            },
            child: Text(
              "Edit",
              style: TextStyle(
                fontSize: width * 0.033,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(101, 187, 248, 1),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/Arous_Sales_ERP_Images/Client/client/blankImage.png",
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/Arous_Sales_ERP_Images/Client/client/companyImage.png",
                                  width: width * 0.18,
                                ),
                                SizedBox(width: width * 0.025),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendorName.isEmpty ? "Coca-Cola Beverages Ltd." : vendorName,
                                        style: TextStyle(
                                          fontSize: width * 0.047,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                          color: Color.fromRGBO(71, 71, 71, 1),
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                      Text(
                                        vendorCategory.isEmpty ? "Wholesaler" : vendorCategory,
                                        style: TextStyle(
                                          fontSize: width * 0.043,
                                          fontWeight: FontWeight.w400,
                                          color: Color.fromRGBO(164, 169, 178, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.03),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/Arous_Sales_ERP_Images/AddClients/call.png",
                                      width: width * 0.038,
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Text(
                                      contactNumber.isEmpty ? "+1 (555) 234-5678" : contactNumber,
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Color.fromRGBO(97, 97, 97, 1),
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/Arous_Sales_ERP_Images/AddClients/location.png",
                                      width: width * 0.038,
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Flexible(
                                      child: Text(
                                        address.isEmpty
                                            ? "123 Business Park, Suite 456, New York, NY 10001"
                                            : address,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Color.fromRGBO(97, 97, 97, 1),
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/Arous_Sales_ERP_Images/AddClients/email.png",
                                      width: width * 0.038,
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Text(
                                      email.isEmpty ? "m.thompson@coca-cola.com" : email,
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Color.fromRGBO(97, 97, 97, 1),
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/Arous_Sales_ERP_Images/AddClients/gst.png",
                                      width: width * 0.038,
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Text(
                                      gstNumber.isEmpty ? "GST: ABC123XYZ789" : gstNumber,
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Color.fromRGBO(97, 97, 97, 1),
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            GestureDetector(
                              // Disable Find on Map button while loading
                              onTap: (isFetchingClient || isFetchingUser || isLoading) ? null : _showMap,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/Arous_Sales_ERP_Images/AddClients/pinLocation.png",
                                            width: width * 0.038,
                                          ),
                                          SizedBox(width: width * 0.03),
                                          Text(
                                            "Find on Map",
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: (isFetchingClient || isFetchingUser || isLoading)
                                                  ? Colors.grey
                                                  : Color.fromRGBO(97, 97, 97, 1),
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(
                                        "assets/Arous_Sales_ERP_Images/Client/client/rightArrow.png",
                                        width: width * 0.025,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => History()),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "9",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              color: Color.fromRGBO(94, 129, 175, 1),
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(width: width * 0.03),
                                          Text(
                                            "View History",
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Color.fromRGBO(97, 97, 97, 1),
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(
                                        "assets/Arous_Sales_ERP_Images/Client/client/rightArrow.png",
                                        width: width * 0.025,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Addplan(
                                      vendorName: vendorName,
                                      address: address,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/Arous_Sales_ERP_Images/Client/client/plan.png",
                                            width: width * 0.038,
                                          ),
                                          SizedBox(width: width * 0.03),
                                          Text(
                                            "Create Plan",
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Color.fromRGBO(97, 97, 97, 1),
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(
                                        "assets/Arous_Sales_ERP_Images/Client/client/rightArrow.png",
                                        width: width * 0.025,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.04),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Recent Activity",
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Color.fromRGBO(95, 100, 110, 1),
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: height * 0.03),
                                () {
                                  var deliveredOrders = orders.where((o) => o['status'] == 'Delivered').toList();
                                  if (deliveredOrders.isNotEmpty) {
                                    deliveredOrders.sort((a, b) => DateTime.parse(b['deliveredTimestamp']).compareTo(DateTime.parse(a['deliveredTimestamp'])));
                                    var order = deliveredOrders.first;
                                    return Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(255, 255, 255, 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      "assets/Arous_Sales_ERP_Images/Client/client/tick.png",
                                                      width: width * 0.12,
                                                    ),
                                                    SizedBox(width: width * 0.03),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Order ${order['orderId']} Delivered",
                                                          style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Color.fromRGBO(88, 88, 88, 1),
                                                            fontFamily: "Inter",
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        Text(
                                                          _formatRelativeDate(DateTime.parse(order['deliveredTimestamp'])),
                                                          style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Color.fromRGBO(162, 167, 176, 1),
                                                            fontFamily: "Inter",
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                      ],
                                    );
                                  }
                                  return SizedBox(height: height * 0.01);
                                }(),
                                () {
                                  var shippedOrders = orders.where((o) => o['status'] == 'Shipped').toList();
                                  if (shippedOrders.isNotEmpty) {
                                    shippedOrders.sort((a, b) => DateTime.parse(b['shippedTimestamp']).compareTo(DateTime.parse(a['shippedTimestamp'])));
                                    var order = shippedOrders.first;
                                    return Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(255, 255, 255, 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      "assets/Arous_Sales_ERP_Images/Client/client/orderVehicle.png",
                                                      width: width * 0.12,
                                                    ),
                                                    SizedBox(width: width * 0.03),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Order ${order['orderId']} Shipped",
                                                          style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Color.fromRGBO(88, 88, 88, 1),
                                                            fontFamily: "Inter",
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        Text(
                                                          _formatRelativeDate(DateTime.parse(order['shippedTimestamp'])),
                                                          style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Color.fromRGBO(162, 167, 176, 1),
                                                            fontFamily: "Inter",
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                      ],
                                    );
                                  }
                                  return SizedBox(height: height * 0.01);
                                }(),
                                orders.isEmpty
                                    ? Text(
                                        "No recent activity",
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Color.fromRGBO(162, 167, 176, 1),
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    : SizedBox(height: height * 0.01),
                                  
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Neworder()),
                      );
                    },
                    icon: Image.asset(
                      "assets/Arous_Sales_ERP_Images/Tasks/AddImage.png",
                      width: width * 0.15,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
              ],
            );
          },
        ),
      ),
    );
  }
}