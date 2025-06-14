import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

class Addplan extends StatefulWidget {
  final String vendorName;
  final String address;

  const Addplan({Key? key, required this.vendorName, required this.address}) : super(key: key);

  @override
  State<Addplan> createState() => _AddplanState();
}

class _AddplanState extends State<Addplan> {
  List<String> vendorNames = [];
  List<Map<String, dynamic>> allVendors = [];
  List<String> filteredVendorNames = [];
  final List<String> MeetItems = ['Meet Client', 'Meet Client 1', 'Meet Client 2', 'Meet Client 3'];
  String MeetingValue = 'Meet Client';
  final List<String> items = ['Select a reason', 'No Time', 'Not Interested', 'No Reason'];
  String selectedValue = 'Select a reason';
  bool isVendorListVisible = false;
  FocusNode searchFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  String selectedAddress = '';
  bool isFetchingVendors = false;
  final GlobalKey _searchBarKey = GlobalKey();
  String? selectedFileName;

  @override
  void initState() {
    super.initState();
    _fetchAllVendors();
    _loadClientData();
    if (items.isNotEmpty) {
      selectedValue = items.first;
      meetingController.text = selectedValue;
      ownerController.text = widget.vendorName;
      selectedAddress = widget.address;
    }
    searchFocusNode.addListener(_handleSearchFocus);
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    reasonController.dispose();
    additionalNotesController.dispose();
    purposeController.dispose();
    notesController.dispose();
    meetingController.dispose();
    ownerController.dispose();
    searchFocusNode.removeListener(_handleSearchFocus);
    searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _fetchAllVendors() async {
    setState(() {
      isFetchingVendors = true;
    });
    const String apiUrl = "http://127.0.0.1:7500/api/client/getall";
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
                        onTap: () {
                          setState(() {
                            ownerController.text = vendorName;
                            selectedAddress = vendorAddress;
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

  final TextEditingController ownerController = TextEditingController();
  final TextEditingController meetingController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController additionalNotesController = TextEditingController();

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

  Future<String?> getUserId() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['userId'];
    } catch (e) {
      return null;
    }
  }

  Future<void> createMeeting() async {
    const String apiUrl = "http://127.0.0.1:7500/api/meeting/addmeeting";
    String? token = await getToken();
    String? userId = await getUserId();

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No valid token found. Please log in again."), backgroundColor: Colors.red),
      );
      return;
    }

    if (ownerController.text.isEmpty ||
        meetingController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields."), backgroundColor: Colors.red),
      );
      return;
    }

    String meetingId = generateMeetingId();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "idController": userId,
          "meetingOwner": ownerController.text,
          "meetingClient": meetingController.text,
          "meetingDate": dateController.text,
          "meetingTime": timeController.text,
          "meetingPurpose": purposeController.text,
          "meetingImportantNotes": notesController.text,
          "resdulingPurpose": reasonController.text,
          "resdulingNotes": additionalNotesController.text,
          "notesFile": selectedFileName,
          "meetingId": meetingId,
          "orderType": "Meeting",
        }),
      );

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        List<String> meetings = prefs.getStringList('meetings') ?? [];
        Map<String, dynamic> meetingData = {
          'meetingId': meetingId,
          'vendorName': ownerController.text,
          'meetingClient': meetingController.text,
          'meetingDate': dateController.text,
          'meetingTime': timeController.text,
          'meetingPurpose': purposeController.text,
          'meetingImportantNotes': notesController.text,
          'resdulingPurpose': reasonController.text,
          'resdulingNotes': additionalNotesController.text,
          'notesFile': selectedFileName,
          'address': selectedAddress,
          'contactPerson': contactPerson, // Include contact person
          'orderType': 'Meeting', // Add order type
          'timestamp': DateTime.now().toIso8601String(),
        };
        meetings.insert(0, jsonEncode(meetingData)); // Insert at the beginning
        await prefs.setStringList('meetings', meetings);

        // Save notification
        List<String> notifications = prefs.getStringList('notifications') ?? [];
        Map<String, dynamic> notificationData = {
          'id': 'NOTIF-$meetingId',
          'vendorName': ownerController.text,
          'purpose': purposeController.text,
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
        };
        notifications.add(jsonEncode(notificationData));
        await prefs.setStringList('notifications', notifications);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order placed successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to place order"), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again."), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> updateMeeting(String meetingId) async {
    final String apiUrl = "http://127.0.0.1:7500/api/meeting/$meetingId/updatemeeting";
    String? token = await getToken();
    String? userId = await getUserId();

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No valid token found. Please log in again."), backgroundColor: Colors.red),
      );
      return;
    }

    if (meetingController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields."), backgroundColor: Colors.red),
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
          "idController": userId,
          "meetingClient": meetingController.text,
          "meetingDate": dateController.text,
          "meetingTime": timeController.text,
          "meetingPurpose": purposeController.text,
          "meetingImportantNotes": notesController.text,
          "resdulingPurpose": reasonController.text,
          "resdulingNotes": additionalNotesController.text,
          "notesFile": selectedFileName,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        List<String>? meetings = prefs.getStringList('meetings');
        if (meetings != null) {
          meetings = meetings.map((meeting) {
            final meetingData = jsonDecode(meeting) as Map<String, dynamic>;
            if (meetingData['meetingId'] == meetingId) {
              meetingData['meetingClient'] = meetingController.text;
              meetingData['meetingDate'] = dateController.text;
              meetingData['meetingTime'] = timeController.text;
              meetingData['meetingPurpose'] = purposeController.text;
              meetingData['meetingImportantNotes'] = notesController.text;
              meetingData['resdulingPurpose'] = reasonController.text;
              meetingData['resdulingNotes'] = additionalNotesController.text;
              meetingData['notesFile'] = selectedFileName;
            }
            return jsonEncode(meetingData);
          }).toList();
          await prefs.setStringList('meetings', meetings);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Meeting updated successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to update meeting"), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while updating."), backgroundColor: Colors.red),
      );
    }
  }

  String vendorName = '';
  String contactPerson = '';
  String address = '';

  bool isLoading = true;
  String? errorMessage;

  Future<void> _loadClientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorId = prefs.getString('vendorId');

    if (vendorId == null || vendorId.isEmpty) {
      setState(() {
        errorMessage = 'Vendor ID not found in SharedPreferences';
        isLoading = false;
      });
      return;
    }

    final String apiUrl = "http://127.0.0.1:7500/api/client/get/$vendorId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final clientData = responseData['client'];

        setState(() {
          vendorName = clientData['vendorName'] ?? 'Coca-Cola Beverages Ltd.';
          contactPerson = clientData['contactPerson'] ?? 'John Anderson';
          address = clientData['address'] ?? '123 Business Park, Suite 456, New York, NY 10001';
          isLoading = false;
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          errorMessage = responseData['message'] ?? 'Failed to fetch client data';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching client data: $error';
        isLoading = false;
      });
    }
  }

  String generateMeetingId() {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final random = Random().nextInt(10000).toString().padLeft(4, '0');
    return 'MTG-$datePart$random';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 249, 250, 1),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Add Plan',
          style: TextStyle(
            fontSize: width * 0.05,
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(68, 68, 68, 1),
          ),
        ),
        elevation: 0.1,
        shadowColor: Color.fromRGBO(228, 229, 232, 1),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              await createMeeting();
              setState(() {
                ownerController.clear();
                meetingController.clear();
                dateController.clear();
                timeController.clear();
                reasonController.clear();
                additionalNotesController.clear();
                purposeController.clear();
                notesController.clear();
                selectedAddress = '';
                selectedFileName = null;
              });
            },
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: width * 0.04,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(106, 138, 181, 1),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  key: _searchBarKey,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
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
                        hintText: "Search vendor name...",
                        hintStyle: TextStyle(
                          fontSize: width * 0.043,
                          color: Color.fromRGBO(92, 92, 92, 1),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: isFetchingVendors
                            ? Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.search, size: 30, color: Color.fromRGBO(165, 170, 178, 1)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Container(
                  width: width * 1,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: MeetingValue,
                        icon: Image.asset("assets/Arous_Sales_ERP_Images/AddPlan/arrowDown.png", height: height * 0.01),
                        onChanged: (String? value) {
                          setState(() {
                            MeetingValue = value!;
                            meetingController.text = value;
                          });
                        },
                        items: MeetItems.map((String meetItem) {
                          return DropdownMenuItem<String>(
                            value: meetItem,
                            child: Text(
                              meetItem,
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
                ),
                SizedBox(height: height * 0.02),
                Container(
                  width: width * 1,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/Arous_Sales_ERP_Images/AddPlan/companyImage.png",
                          width: width * 0.13,
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ownerController.text.isEmpty ? 'Select a vendor' : ownerController.text,
                                style: TextStyle(
                                  color: Color.fromRGBO(91, 91, 91, 1),
                                  fontSize: width * 0.04,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                selectedAddress.isEmpty ? 'Vendor address' : selectedAddress,
                                style: TextStyle(
                                  color: Color.fromRGBO(164, 168, 177, 1),
                                  fontSize: width * 0.035,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
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
                                        decoration: BoxDecoration(
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
                                                    child: Divider(
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
                                                      "Schedule Meeting",
                                                      style: TextStyle(
                                                        fontSize: width * 0.05,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color.fromRGBO(77, 77, 77, 1),
                                                        fontFamily: "Inter",
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final meetingId = generateMeetingId();
                                                        await updateMeeting(meetingId);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Done",
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          fontWeight: FontWeight.w400,
                                                          color: Color.fromRGBO(110, 142, 183, 1),
                                                          fontFamily: "Inter",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 1,
                                                  color: Colors.black12,
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Text(
                                                  "Meeting Date",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(124, 130, 141, 1),
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
                                                      color: Color.fromRGBO(167, 171, 179, 1),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
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
                                                        padding: EdgeInsets.all(13),
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
                                                    color: Color.fromRGBO(124, 130, 141, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                TextField(
                                                  controller: timeController,
                                                  autocorrect: true,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color.fromRGBO(157, 161, 171, 1),
                                                      ),
                                                      borderRadius: BorderRadius.circular(9),
                                                    ),
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.all(13),
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
                                                        padding: EdgeInsets.all(13),
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
                                                    color: Color.fromRGBO(120, 126, 137, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                Container(
                                                  width: width * 1,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(255, 255, 255, 1),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(width: 2, color: Color.fromRGBO(230, 232, 236, 1)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        isExpanded: true,
                                                        value: selectedValue,
                                                        icon: Image.asset("assets/Arous_Sales_ERP_Images/AddPlan/arrowDown.png",
                                                            height: height * 0.01),
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
                                                ),
                                                SizedBox(height: height * 0.02),
                                                Text(
                                                  "Additional Notes",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color.fromRGBO(120, 126, 137, 1),
                                                    fontFamily: "Inter",
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 2,
                                                      color: Color.fromRGBO(157, 162, 171, 1),
                                                    ),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(22),
                                                      topRight: Radius.circular(21),
                                                      bottomLeft: Radius.circular(9),
                                                      bottomRight: Radius.circular(9),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                                                color: Color.fromRGBO(158, 162, 172, 1),
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
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(1),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Save Changes",
                                                      style: TextStyle(
                                                        fontSize: width * 0.043,
                                                        fontFamily: "Inter",
                                                        color: Color.fromRGBO(175, 192, 215, 1),
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
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomRight: Radius.circular(6),
                            topRight: Radius.circular(13),
                          ),
                          side: BorderSide(
                            color: Color.fromRGBO(230, 232, 236, 1),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 18),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/Arous_Sales_ERP_Images/AddPlan/calendar.png",
                              width: width * 0.04,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: width * 0.02),
                            Text(
                              "Meeting Date",
                              style: TextStyle(
                                color: Color.fromRGBO(154, 159, 168, 1),
                                fontSize: width * 0.035,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          timeController.text = selectedTime.format(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomRight: Radius.circular(6),
                            topRight: Radius.circular(13),
                          ),
                          side: BorderSide(
                            color: Color.fromRGBO(230, 232, 236, 1),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 18),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/Arous_Sales_ERP_Images/AddPlan/time.png",
                              width: width * 0.05,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: width * 0.02),
                            Text(
                              "Meeting Time",
                              style: TextStyle(
                                color: Color.fromRGBO(164, 169, 177, 1),
                                fontSize: width * 0.035,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(157, 162, 171, 1),
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            controller: purposeController,
                            autocorrect: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: "Purpose of Plan",
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(157, 162, 171, 1),
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
                SizedBox(height: height * 0.02),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(157, 162, 171, 1),
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            controller: notesController,
                            autocorrect: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: "Important Notes",
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(157, 162, 171, 1),
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
                SizedBox(height: height * 0.02),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color.fromRGBO(246, 247, 248, 1)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        side: BorderSide(
                          width: 5,
                          color: Color.fromRGBO(246, 247, 248, 1),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(19),
                          bottomLeft: Radius.circular(3),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/Arous_Sales_ERP_Images/AddPlan/fileAttach.png",
                          width: width * 0.04,
                        ),
                        SizedBox(width: width * 0.03),
                        Text(
                          "Add Attachment",
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(161, 166, 175, 1),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedFileName != null) ...[
                  SizedBox(height: height * 0.01),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Color.fromRGBO(230, 232, 236, 1),
                      ),
                      color: Color.fromRGBO(249, 250, 251, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedFileName!,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: width * 0.04,
                              color: Color.fromRGBO(162, 167, 176, 1),
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}