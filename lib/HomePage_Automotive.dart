import 'package:arouse_automotive_day1/designLayoutsPage/mobiledesign.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/webdesign.dart';
import 'package:flutter/material.dart';

class HomepageAutomotive extends StatelessWidget {
  const HomepageAutomotive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Webdesign();
          } else {
            return Mobiledesign();
          }
        }
      ),
    );
  }
}