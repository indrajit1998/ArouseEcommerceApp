import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:ui' as ui; // Needed for platformViewRegistry
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

class WebWebviewPage extends StatefulWidget {
  final String url;

  const WebWebviewPage({super.key, required this.url});

  @override
  State<WebWebviewPage> createState() => _WebWebviewPageState();
}

class _WebWebviewPageState extends State<WebWebviewPage> {
  bool _isLoading = true;
  String? _errorMessage;
  final String _iframeViewType = 'iframeElement';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Register the iframe *once* for this view type.
      // This allows hot reload and multiple instances.
      // Use a unique view type if you need multiple iframes on a page.
      // ignore: undefined_prefixed_name
      // ui.platformViewRegistry.registerViewFactory(_iframeViewType, (int viewId) {
      //   final html.IFrameElement element = html.IFrameElement()
      //     ..src = widget.url
      //     ..style.border = 'none'
      //     ..width = '100%'
      //     ..height = '100%'
      //     ..allow = 'fullscreen'
      //     ..allowFullscreen = true;

      //   // Optionally listen for load/error events here

      //   return element;
      // });

      // Simulate loading completion (no direct load event for platform view)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWebOrDesktop = screenWidth >= 1024;

    double imageSize = isWebOrDesktop ? 40 : isTablet ? 30 : screenWidth * 0.075;
    double iconSize = isWebOrDesktop ? 30 : isTablet ? 20 : screenWidth * 0.08;
    double fontSize = isWebOrDesktop ? 20 : isTablet ? 18 : screenWidth * 0.03 + 4;
    double spacing = isWebOrDesktop ? 10 : isTablet ? 8 : screenWidth * 0.01;

    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        shadowColor: Colors.grey,
        leading: Padding(
          padding: EdgeInsets.all(screenHeight * 0.015),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/menu.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image.png',
              height: imageSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: spacing),
            Text(
              'AROUSE',
              style: TextStyle(
                color: const Color(0xFF004C90),
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DMSans",
              ),
            ),
            SizedBox(width: spacing),
            Text(
              'AUTOMOTIVE',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DMSans",
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(spacing),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: Icon(Icons.search, color: const Color.fromRGBO(26, 76, 142, 1), size: iconSize),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          kIsWeb
              ? SizedBox.expand(
                  child: HtmlElementView(viewType: _iframeViewType),
                )
              : WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setBackgroundColor(Colors.transparent)
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onPageStarted: (url) {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          print('WebView: Started loading $url');
                        },
                        onPageFinished: (url) {
                          setState(() {
                            _isLoading = false;
                          });
                          print('WebView: Finished loading $url');
                        },
                        onWebResourceError: (error) {
                          setState(() {
                            _isLoading = false;
                            _errorMessage = 'Failed to load page: ${error.description}';
                          });
                          print('WebView: Error occurred: ${error.description}, Code: ${error.errorCode}');
                        },
                      ),
                    )
                    ..loadRequest(Uri.parse(widget.url)),
                ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      // For iframe, reload by rebuilding the widget
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebWebviewPage(url: widget.url),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}