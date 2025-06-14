import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

class Home extends StatefulWidget {
  final Function(int) onNavigate;

  const Home({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static bool isOn = true;
  String date = '';
  String time = '';
  Timer? _timer;
  List<Map<String, dynamic>> meetings = [];
  List<Map<String, dynamic>> clients = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    if (isOn) {
      _startTimer();
    }
    _loadData();
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isOn && _timer == null) {
      _startTimer();
    }
  }

  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        date = DateFormat('MMMM d, yyyy').format(now);
        time = DateFormat('hh:mm a').format(now);
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
      _stopTimer();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    await _loadClients();
    await _loadMeetings();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadClients() async {
    final String baseUrl = Platform.isAndroid ? 'http://127.0.0.1:7500' : 'http://localhost:7500';
    final String apiUrl = '$baseUrl/api/client/getall';
    try {
      final token = await getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No valid token found. Please log in again."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('Client API Response: ${response.body}');
        if (responseData.containsKey('success') &&
            responseData['success'] == true &&
            responseData.containsKey('clients')) {
          if (mounted) {
            setState(() {
              clients = List<Map<String, dynamic>>.from(responseData['clients'] ?? []);
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid response from server"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expired. Please log in again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to fetch clients: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      print('Error fetching clients: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching clients: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? meetingStrings = prefs.getStringList('meetings');
    if (meetingStrings == null) {
      print('No meetings found in SharedPreferences');
      if (mounted) {
        setState(() {
          meetings = [];
        });
      }
      return;
    }

    List<Map<String, dynamic>> tempMeetings = [];
    for (var meeting in meetingStrings) {
      try {
        tempMeetings.add(jsonDecode(meeting) as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing meeting: $e');
      }
    }

    if (clients.isEmpty) {
      print('No clients available for meeting matching');
      if (mounted) {
        setState(() {
          meetings = [];
        });
      }
      return;
    }

    for (var meeting in tempMeetings) {
      final client = clients.firstWhere(
        (client) => client['vendorName'] == meeting['vendorName'],
        orElse: () => {
          'vendorName': meeting['vendorName'] ?? 'Unknown Vendor',
          'address': 'Unknown Address',
          'contactPerson': 'Unknown Contact',
        },
      );
      meeting['vendorName'] = meeting['vendorName'] ?? client['vendorName'];
      meeting['address'] = meeting['address'] ?? client['address'];
      meeting['contactPerson'] = meeting['contactPerson'] ?? client['contactPerson'];
      meeting['importantNote'] ??= 'No notes available';
    }

    final today = DateTime.now();
    final dateFormats = [
      DateFormat('yyyy-MM-dd'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('dd-MM-yyyy'),
    ];
    if (mounted) {
      setState(() {
        meetings = tempMeetings.where((meeting) {
          try {
            DateTime? meetingDate;
            for (var format in dateFormats) {
              try {
                meetingDate = format.parse(meeting['meetingDate'], true);
                break;
              } catch (_) {}
            }
            if (meetingDate == null) {
              print('Invalid date format for meeting: ${meeting['meetingDate']}');
              return false;
            }
            return isSameDay(meetingDate, today);
          } catch (e) {
            print('Error parsing meeting date: $e');
            return false;
          }
        }).toList().take(2).toList();
      });
      print("Today's meetings: $meetings");
      if (tempMeetings.length > 2 && meetings.length == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("More meetings available. Tap 'View all' to see them."),
          ),
        );
      }
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Date",
                              style: TextStyle(
                                fontSize: width * 0.034,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "Time",
                              style: TextStyle(
                                fontSize: width * 0.034,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: width * 0.037,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: width * 0.037,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Clock In/Out",
                              style: TextStyle(
                                fontSize: width * 0.037,
                              ),
                            ),
                            Switch(
                              value: isOn,
                              onChanged: (value) {
                                setState(() {
                                  isOn = value;
                                  if (isOn) {
                                    _updateDateTime();
                                    _startTimer();
                                  } else {
                                    _updateDateTime();
                                    _stopTimer();
                                  }
                                });
                              },
                              activeColor: const Color.fromARGB(255, 0, 91, 165),
                              inactiveThumbColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: width * 0.039,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        color: const Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onNavigate(1);
                      },
                      child: Text(
                        "View all",
                        style: TextStyle(
                          fontSize: width * 0.032,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Inter",
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : meetings.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "",
                              style: TextStyle(
                                fontSize: width * 0.035,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                                color: const Color.fromRGBO(162, 167, 175, 1),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: meetings.map((meeting) {
                              String displayNotes = meeting['meetingImportantNotes'] ?? 'No notes available';
                              print('Meeting: ${meeting['meetingId']}, Vendor: ${meeting['vendorName']}, Notes: $displayNotes');

                              return Padding(
                                padding: EdgeInsets.only(bottom: height * 0.02),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "assets/Arous_Sales_ERP_Images/Home/Circle.png",
                                                  height: height * 0.023,
                                                  width: width * 0.023,
                                                ),
                                                SizedBox(width: width * 0.02),
                                                Text(
                                                  meeting['vendorName'] ?? 'Unknown Vendor',
                                                  style: TextStyle(
                                                    fontSize: width * 0.036,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Inter",
                                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  meeting['meetingTime'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: width * 0.039,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Inter",
                                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: height * 0.02),
                                        Text(
                                          displayNotes,
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                        SizedBox(height: height * 0.02),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              meeting['contactPerson'] ?? 'Unknown Contact',
                                              style: TextStyle(
                                                fontSize: width * 0.039,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.w400,
                                                color: const Color.fromRGBO(0, 0, 0, 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                SizedBox(height: height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Assign Task",
                      style: TextStyle(
                        fontSize: width * 0.042,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: const Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onNavigate(1);
                      },
                      child: Text(
                        "View all",
                        style: TextStyle(
                          fontSize: width * 0.032,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: meetings.isEmpty
                          ? [
                              Text(
                                "",
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromRGBO(162, 167, 175, 1),
                                ),
                              ),
                            ]
                          : meetings.take(2).map((meeting) {
                              String displayNotes = meeting['resdulingNotes'] ?? 'No notes available';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/Arous_Sales_ERP_Images/Home/AssingTask.png",
                                        width: width * 0.045,
                                        height: width * 0.045,
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Text(
                                        meeting['vendorName'] ?? 'Unknown Vendor',
                                        style: TextStyle(
                                          fontSize: width * 0.037,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromRGBO(0, 0, 0, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Padding(
                                    padding: EdgeInsets.only(left: width * 0.074),
                                    child: Text(
                                      displayNotes,
                                      style: TextStyle(
                                        fontSize: width * 0.032,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w400,
                                        color: const Color.fromRGBO(29, 29, 29, 1),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                ],
                              );
                            }).toList(),
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
}