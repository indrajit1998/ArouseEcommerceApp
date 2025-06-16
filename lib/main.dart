// import 'package:arouse_automotive_day1/Arous_Sales_ERP/LoginERP/LoginERP.dart';
// import 'package:arouse_automotive_day1/HomePage_Automotive.dart';
// import 'package:arouse_automotive_day1/designLayoutsPage/WebDesigns/ProfileAutomotive/profileArouseAutomotive.dart';
// import 'package:arouse_automotive_day1/designLayoutsPage/mobiledesign.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/webdesign.dart';
import 'package:flutter/material.dart';
// import 'package:arouse_automotive_day1/login_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   runApp(MyApp());
// }

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

// void _setupWebViewPlatform() {
//   // Android-specific initialization
//   if (WebViewPlatform.instance is! WebKitWebViewPlatform) {
//     WebViewPlatform.instance = AndroidWebViewPlatform();
//   }
//   // iOS-specific initialization (already handled by default in most cases)
//   if (WebViewPlatform.instance is! AndroidWebViewPlatform) {
//     WebViewPlatform.instance = WebKitWebViewPlatform();
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Webdesign(),
    );
  }
}
