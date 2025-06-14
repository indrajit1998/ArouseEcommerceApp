import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddClient/mapDisplay.dart';
import 'package:arouse_automotive_day1/Arous_Sales_ERP/Dashboard/Navigation_Bar_Pages/AddPlan/addPlan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class Meetinghistory extends StatefulWidget {
  final Map<String, dynamic>? meeting;
  final bool showBottomSheetOnLoad;

  const Meetinghistory({Key? key, this.meeting, this.showBottomSheetOnLoad = false}) : super(key: key);

  @override
  State<Meetinghistory> createState() => _MeetinghistoryState();
}

class _MeetinghistoryState extends State<Meetinghistory> {
  final List<String> items = ['Select a reason', 'Not Understand', 'Doubt Clarification', 'Discussion'];
  String selectedValue = 'Select a reason';
  Map<String, dynamic>? clientData;
  Map<String, dynamic>? userData;
  bool isFetchingClient = false;
  bool isFetchingUser = false;
  String? errorMessage;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController additionalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      dateController.text = widget.meeting!['meetingDate'] ?? '';
      timeController.text = widget.meeting!['meetingTime'] ?? '';
      _fetchClientData();
      _fetchUserData();
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    reasonController.dispose();
    additionalNotesController.dispose();
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('MMMM d, yyyy').format(parsedDate);
    } catch (e) {
      return date;
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
      return null;
    }
  }

  Future<String?> refreshToken() async {
    const String refreshTokenApiUrl = "http://127.0.0.1:7500/api/auth/refreshToken";
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) return null;

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
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isFetchingUser = true;
      errorMessage = null;
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
        final vendorName = widget.meeting!['vendorName'] ?? '';

        final matchedClient = clients.firstWhere(
          (client) => client['vendorName'] == vendorName,
          orElse: () => null,
        );

        setState(() {
          clientData = matchedClient != null ? Map<String, dynamic>.from(matchedClient) : null;
          isFetchingClient = false;
          if (matchedClient == null) {
            errorMessage = "No client found for vendor: $vendorName";
          } else {
            print("Matched Client Data: $clientData");
            print("Vendor Location: ${clientData!['location']}");
            print("Vendor Address: ${clientData!['address']}");
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

  Future<void> updateMeeting(String meetingId) async {
    final String apiUrl = "http://127.0.0.1:7500/api/meeting/$meetingId/updatemeeting";
    String? token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid token found. Please log in again."), backgroundColor: Colors.red),
      );
      return;
    }

    if (dateController.text.isEmpty || timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields."), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "meetingDate": dateController.text,
          "meetingTime": timeController.text,
          "resdulingPurpose": reasonController.text,
          "resdulingNotes": additionalNotesController.text,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        List<String>? meetings = prefs.getStringList('meetings');
        if (meetings != null) {
          meetings = meetings.map((meeting) {
            final meetingData = jsonDecode(meeting) as Map<String, dynamic>;
            if (meetingData['meetingId'] == meetingId) {
              meetingData['meetingDate'] = dateController.text;
              meetingData['meetingTime'] = timeController.text;
              meetingData['resdulingPurpose'] = reasonController.text;
              meetingData['resdulingNotes'] = additionalNotesController.text;
            }
            return jsonEncode(meetingData);
          }).toList();
          await prefs.setStringList('meetings', meetings);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meeting updated successfully!"), backgroundColor: Colors.green),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to update meeting"), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while updating: $error"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final meeting = widget.meeting ?? {};
    final vendorName = meeting['vendorName'] ?? 'Unknown Vendor';
    final address = clientData != null ? clientData!['address'] ?? 'Add address' : 'Loading...';
    final contactPerson = clientData != null ? clientData!['contactPerson'] ?? 'Add Contact Person' : 'Loading...';
    final contactNumber = clientData != null ? clientData!['contactNumber'] ?? 'Add Number' : 'Loading...';
    final meetingDate = _formatDate(meeting['meetingDate']);
    final meetingTime = meeting['meetingTime'] ?? 'Select Time';
    final purpose = meeting['meetingPurpose'] ?? 'Annual contract renewal discussion and new product line introduction';
    final importantNotes = meeting['meetingImportantNotes'] ?? 'Add Important Note';
    final notesFile = meeting['notesFile'] ?? 'Indrajit.pdf';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 249, 250, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(254, 254, 254, 1),
        title: const Text(
          'Meeting History',
          style: TextStyle(
            color: Color.fromRGBO(76, 76, 76, 1),
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Meet $vendorName",
                  style: TextStyle(
                    fontSize: width * 0.05,
                    color: const Color.fromRGBO(44, 44, 45, 1),
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * 0.005),
                TextButton(
                  onPressed: () {
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
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                      "Take Order",
                      style: TextStyle(
                        fontSize: width * 0.032,
                        color: const Color.fromRGBO(96, 96, 97, 1),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                if (isFetchingClient)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: Colors.red,
                      fontFamily: "Inter",
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vendorName,
                        style: TextStyle(
                          fontSize: width * 0.042,
                          color: const Color.fromRGBO(102, 109, 121, 1),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (!mounted) return;

                          if (clientData == null || userData == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Client or user data is not available."),
                                backgroundColor: Colors.red,
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

                          final vendorLongitude = vendorCoordinates[0] as double;
                          final vendorLatitude = vendorCoordinates[1] as double;

                          double? userLatitude;
                          double? userLongitude;

                          final userAddress = userData!['address'] as String?;
                          if (userAddress != null && userAddress.isNotEmpty) {
                            final userCoordinates = await _geocodeAddress(userAddress);
                            if (!mounted) return;
                            if (userCoordinates != null) {
                              userLatitude = userCoordinates['latitude'];
                              userLongitude = userCoordinates['longitude'];
                            }
                          }

                          if (userLatitude == null || userLongitude == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  userAddress != null && userAddress.isNotEmpty
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
                        },
                        child: Text(
                          "View Map",
                          style: TextStyle(
                            fontSize: width * 0.044,
                            color: const Color.fromRGBO(67, 108, 162, 1),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    address,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.042,
                      color: const Color.fromRGBO(114, 122, 133, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    contactPerson,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.042,
                      color: const Color.fromRGBO(113, 121, 133, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "Contact Number: $contactNumber",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.042,
                      color: const Color.fromRGBO(113, 121, 133, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Text(
                    "Meeting Date: $meetingDate",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.042,
                      color: const Color.fromRGBO(98, 106, 118, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "Meeting Time: $meetingTime",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.042,
                      color: const Color.fromRGBO(99, 107, 119, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Text(
                    "Purpose of Plan",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.045,
                      color: const Color.fromRGBO(50, 50, 50, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    purpose,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.042,
                      color: const Color.fromRGBO(114, 122, 133, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Important Notes",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.045,
                          color: const Color.fromRGBO(58, 58, 59, 1),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Important Notes'),
                              content: Text(
                                importantNotes,
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: width * 0.04,
                                  color: const Color.fromRGBO(58, 58, 59, 1),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          "View",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: width * 0.04,
                            color: const Color.fromRGBO(77, 115, 167, 1),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(230, 232, 236, 1),
                      ),
                      color: const Color.fromRGBO(249, 250, 251, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notesFile,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: width * 0.04,
                              color: const Color.fromRGBO(162, 167, 176, 1),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Image.asset(
                            "assets/Arous_Sales_ERP_Images/History/attachFile.png",
                            width: width * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  SizedBox(
                    width: width * 1,
                    height: height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
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
                      style: TextButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color.fromRGBO(134, 134, 134, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        "Create Order",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(213, 213, 213, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: width * 1,
                    height: height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement Recorded functionality
                      },
                      style: TextButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color.fromRGBO(253, 242, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(13),
                            topRight: const Radius.circular(7),
                            bottomLeft: const Radius.circular(16),
                            bottomRight: const Radius.circular(10),
                          ),
                          side: const BorderSide(
                            width: 1,
                            color: Color.fromRGBO(249, 248, 249, 1),
                          ),
                        ),
                      ),
                      child: Text(
                        "Recorded",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(189, 184, 184, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  SizedBox(
                    width: width * 1,
                    height: height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setModalState) {
                                  return DraggableScrollableSheet(
                                    initialChildSize: 0.78,
                                    minChildSize: 0.2,
                                    maxChildSize: 0.9,
                                    builder: (context, scrollController) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15.0, right: 15, top: 0, bottom: 15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: SizedBox(
                                                    width: width * 0.2,
                                                    child: const Divider(
                                                      thickness: 4,
                                                      color: Color.fromRGBO(77, 77, 77, 1),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Reschedule Meeting",
                                                      style: TextStyle(
                                                        fontSize: width * 0.05,
                                                        fontWeight: FontWeight.w400,
                                                        color: const Color.fromRGBO(77, 77, 77, 1),
                                                        fontFamily: "Inter",
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Done",
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color.fromRGBO(110, 142, 183, 1),
                                                          fontFamily: "Inter",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1,
                                                  color: Colors.black12,
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Text(
                                                  "Meeting Date",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(124, 130, 141, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                TextField(
                                                  controller: dateController,
                                                  autocorrect: true,
                                                  decoration: InputDecoration(
                                                    hintText: "-/--",
                                                    hintStyle: TextStyle(
                                                      fontSize: width * 0.05,
                                                      fontFamily: "Inter",
                                                      color: const Color.fromRGBO(167, 171, 179, 1),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                        color: Color.fromRGBO(157, 161, 171, 1),
                                                      ),
                                                      borderRadius: BorderRadius.circular(9),
                                                    ),
                                                    suffixIcon: GestureDetector(
                                                      onTap: () async {
                                                        DateTime? selectedDate = await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime.now(),
                                                          firstDate: DateTime(1900),
                                                          lastDate: DateTime(2101),
                                                        );
                                                        if (selectedDate != null) {
                                                          String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                                                          dateController.text = formattedDate;
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(13),
                                                        child: Image.asset(
                                                          "assets/Arous_Sales_ERP_Images/MeetingSchedule/calendar.png",
                                                          height: height * 0.02,
                                                          width: width * 0.02,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Text(
                                                  "Meeting Time",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(124, 130, 141, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                TextField(
                                                  controller: timeController,
                                                  autocorrect: true,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                        color: Color.fromRGBO(157, 161, 171, 1),
                                                      ),
                                                      borderRadius: BorderRadius.circular(9),
                                                    ),
                                                    prefixIcon: Padding(
                                                      padding: const EdgeInsets.all(13),
                                                      child: Image.asset(
                                                        "assets/Arous_Sales_ERP_Images/MeetingSchedule/dashTime.png",
                                                        height: height * 0.02,
                                                        width: width * 0.05,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    suffixIcon: GestureDetector(
                                                      onTap: () async {
                                                        TimeOfDay? selectedTime = await showTimePicker(
                                                          context: context,
                                                          initialTime: TimeOfDay.now(),
                                                        );
                                                        if (selectedTime != null) {
                                                          timeController.text = selectedTime.format(context);
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(13),
                                                        child: Image.asset(
                                                          "assets/Arous_Sales_ERP_Images/MeetingSchedule/time.png",
                                                          height: height * 0.02,
                                                          width: width * 0.02,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Text(
                                                  "Reason for rescheduling",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(120, 126, 137, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                Container(
                                                  width: width * 1,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(255, 255, 255, 1),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(width: 2, color: const Color.fromRGBO(230, 232, 236, 1)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        isExpanded: true,
                                                        value: selectedValue,
                                                        icon: Image.asset(
                                                          "assets/Arous_Sales_ERP_Images/AddPlan/arrowDown.png",
                                                          height: height * 0.01,
                                                        ),
                                                        onChanged: (String? newValue) {
                                                          if (newValue != null) {
                                                            setModalState(() {
                                                              selectedValue = newValue;
                                                              reasonController.text = newValue;
                                                            });
                                                          }
                                                        },
                                                        items: items.map((String item) {
                                                          return DropdownMenuItem<String>(
                                                            value: item,
                                                            child: Text(
                                                              item,
                                                              style: TextStyle(
                                                                color: const Color.fromRGBO(92, 92, 92, 1),
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
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Text(
                                                  "Additional Notes",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(120, 126, 137, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 2,
                                                      color: const Color.fromRGBO(157, 162, 171, 1),
                                                    ),
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(22),
                                                      topRight: Radius.circular(21),
                                                      bottomLeft: Radius.circular(9),
                                                      bottomRight: Radius.circular(9),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(5.0),
                                                          child: TextField(
                                                            controller: additionalNotesController,
                                                            autocorrect: true,
                                                            keyboardType: TextInputType.multiline,
                                                            maxLines: null,
                                                            minLines: 4,
                                                            decoration: InputDecoration(
                                                              hintText: "Add any additional notes here...",
                                                              hintStyle: TextStyle(
                                                                fontSize: width * 0.043,
                                                                fontFamily: "Inter",
                                                                color: const Color.fromRGBO(158, 162, 172, 1),
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
                                                SizedBox(height: height * 0.03),
                                                SizedBox(
                                                  width: width * 1,
                                                  height: height * 0.07,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color.fromRGBO(26, 76, 142, 1),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(1),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Save Changes",
                                                      style: TextStyle(
                                                        fontSize: width * 0.043,
                                                        fontFamily: "Inter",
                                                        color: const Color.fromRGBO(175, 192, 215, 1),
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color.fromRGBO(239, 246, 254, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(9),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(16),
                          ),
                          side: const BorderSide(
                            width: 2,
                            color: Color.fromRGBO(248, 249, 251, 1),
                          ),
                        ),
                      ),
                      child: Text(
                        "Re-Schedule Meeting",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(169, 172, 175, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: width * 1,
                    height: height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement Add Notes functionality
                      },
                      style: TextButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color.fromRGBO(239, 246, 254, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(9),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(16),
                          ),
                          side: const BorderSide(
                            width: 2,
                            color: Color.fromRGBO(248, 249, 251, 1),
                          ),
                        ),
                      ),
                      child: Text(
                        "Add Notes",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(164, 166, 169, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(157, 162, 171, 1),
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              autocorrect: true,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              minLines: 4,
                              decoration: InputDecoration(
                                hintText: meeting['notes'] ?? "Add your notes here...",
                                hintStyle: TextStyle(
                                  fontSize: width * 0.043,
                                  fontFamily: "Inter",
                                  color: const Color.fromRGBO(157, 162, 171, 1),
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
                  SizedBox(height: height * 0.03),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}