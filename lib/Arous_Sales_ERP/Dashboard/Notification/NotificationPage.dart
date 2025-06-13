import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Notificationpage extends StatefulWidget {
  final String? initialMeetingId;

  const Notificationpage({super.key, this.initialMeetingId});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  List<Map<String, dynamic>> notifications = [];
  bool showNew = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? notificationStrings = prefs.getStringList('notifications');
    if (notificationStrings != null) {
      setState(() {
        notifications = notificationStrings
            .map((string) => jsonDecode(string) as Map<String, dynamic>)
            .toList();
        // Sort notifications by timestamp (newest first)
        notifications.sort((a, b) =>
            DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? notificationStrings = prefs.getStringList('notifications');
    if (notificationStrings != null) {
      notificationStrings = notificationStrings.map((string) {
        final notification = jsonDecode(string) as Map<String, dynamic>;
        if (notification['id'] == id) {
          notification['isRead'] = true;
        }
        return jsonEncode(notification);
      }).toList();
      await prefs.setStringList('notifications', notificationStrings);
      await _loadNotifications();
    }
  }

  String _getTimeLabel(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  Map<String, dynamic> _getStatusStyle(DateTime timestamp, bool isRead) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (isRead) {
      return {
        'label': _getTimeLabel(timestamp),
        'backgroundColor': const Color.fromRGBO(254, 225, 225, 1),
        'textColor': const Color.fromRGBO(234, 118, 118, 1),
      };
    } else if (difference.inHours < 1) {
      return {
        'label': 'New',
        'backgroundColor': const Color.fromRGBO(254, 225, 225, 1),
        'textColor': const Color.fromRGBO(234, 118, 118, 1),
      };
    } else if (difference.inHours < 24) {
      return {
        'label': _getTimeLabel(timestamp),
        'backgroundColor': const Color.fromRGBO(255, 237, 212, 1),
        'textColor': const Color.fromRGBO(243, 155, 103, 1),
      };
    } else {
      return {
        'label': _getTimeLabel(timestamp),
        'backgroundColor': const Color.fromRGBO(243, 244, 246, 1),
        'textColor': const Color.fromRGBO(146, 152, 161, 1),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Filter notifications based on initialMeetingId if provided
    final filteredNotifications = notifications.where((notification) {
      final matchesTab = showNew ? !notification['isRead'] : notification['isRead'];
      final matchesMeetingId = widget.initialMeetingId == null ||
          notification['meetingId'] == widget.initialMeetingId;
      return matchesTab && matchesMeetingId;
    }).toList();

    final newNotificationCount = notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.1,
        shadowColor: const Color.fromRGBO(128, 135, 145, 1),
        backgroundColor: Colors.white,
        title: const Text('Notification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.04,
              bottom: height * 0.04),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: width * 0.25,
                    height: height * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNew = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(2.25),
                            topRight: Radius.circular(2.25),
                            bottomRight: Radius.circular(1.75),
                          ),
                        ),
                        backgroundColor: showNew
                            ? const Color.fromRGBO(0, 51, 160, 1)
                            : Colors.white,
                        side: const BorderSide(
                          color: Color.fromRGBO(223, 222, 225, 1),
                        ),
                      ),
                      child: Text(
                        "New",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w300,
                          color: showNew
                              ? Colors.white
                              : const Color.fromRGBO(113, 144, 185, 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: width * 0.25,
                    height: height * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNew = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(2.25),
                            topRight: Radius.circular(2.25),
                            bottomRight: Radius.circular(1.75),
                          ),
                        ),
                        backgroundColor: !showNew
                            ? const Color.fromRGBO(0, 51, 160, 1)
                            : Colors.white,
                        side: const BorderSide(
                          color: Color.fromRGBO(223, 222, 225, 1),
                        ),
                      ),
                      child: Text(
                        "Read",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w300,
                          color: !showNew
                              ? Colors.white
                              : const Color.fromRGBO(113, 144, 185, 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "$newNotificationCount notifications",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.036,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromRGBO(168, 172, 181, 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              ...filteredNotifications.asMap().entries.map((entry) {
                final index = entry.key;
                final notification = entry.value;
                final timestamp = DateTime.parse(notification['timestamp']);
                final statusStyle = _getStatusStyle(timestamp, notification['isRead']);
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!notification['isRead']) {
                          _markAsRead(notification['id']);
                        }
                      },
                      child: Container(
                        height: height * 0.19,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/Arous_Sales_ERP_Images/Notifications/Img${(index % 6) + 1}.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: width * 0.15,
                                    height: height * 0.033,
                                    decoration: BoxDecoration(
                                      color: notification['type'] == 'Order'
                                          ? const Color.fromRGBO(218, 234, 254, 1)
                                          : statusStyle['backgroundColor'],
                                      borderRadius: BorderRadius.circular(3.75),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      notification['type'] == 'Order' ? 'Order' : statusStyle['label'],
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: width * 0.03,
                                        fontWeight: FontWeight.w400,
                                        color: notification['type'] == 'Order'
                                            ? const Color.fromRGBO(122, 161, 243, 1)
                                            : statusStyle['textColor'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Client: ${notification['vendorName']}",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: width * 0.034,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromRGBO(65, 65, 65, 1),
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                notification['purpose'],
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: width * 0.034,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromRGBO(128, 135, 145, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                  ],
                );
              }).toList(),
              if (filteredNotifications.isEmpty)
                Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Text(
                    showNew ? "No new notifications" : "No read notifications",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: width * 0.04,
                      color: const Color.fromRGBO(128, 135, 145, 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}