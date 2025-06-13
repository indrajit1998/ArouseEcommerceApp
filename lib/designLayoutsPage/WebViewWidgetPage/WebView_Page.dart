import 'package:arouse_automotive_day1/components_screen/help&support/helpPage.dart';
import 'package:arouse_automotive_day1/designLayoutsPage/mobiledesign.dart';
import 'package:arouse_automotive_day1/login_button.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await Future.delayed(const Duration(seconds: 1));

            // JavaScript to handle video and UI modifications
            await _controller.runJavaScript('''
              (function() {
                // Function to remove Expert Connect button with retry mechanism
                function removeExpertConnect() {
                  const selectors = [
                    '.expertConnectContainer',
                    '[class*="expertConnect"]',
                    '[class*="ExpertConnect"]',
                    '[class*="connect"]',
                    'button[class*="connect"]',
                    'div:has(> button:contains("Tap to connect"))',
                    'div:has(> button:contains("Expert Connect"))'
                  ];
                  let expertConnect = null;

                  for (const selector of selectors) {
                    expertConnect = document.querySelector(selector);
                    if (expertConnect) break;
                  }

                  if (expertConnect) {
                    expertConnect.remove();
                    console.log("Expert Connect element removed successfully.");
                  } else {
                    console.warn("Expert Connect element not found, retrying...");
                    setTimeout(removeExpertConnect, 500);
                  }
                }

                // Function to remove Expert Connect dialogue box (modal/popup)
                function removeExpertConnectDialogue() {
                  const dialogueSelectors = [
                    '[class*="modal"]',
                    '[class*="dialogue"]',
                    '[class*="popup"]',
                    '[class*="expertConnect"]',
                    '[class*="ExpertConnect"]',
                    'div:has(> div:contains("Honda Expert Connect"))',
                    'div[class*="overlay"]'
                  ];
                  let dialogue = null;

                  for (const selector of dialogueSelectors) {
                    dialogue = document.querySelector(selector);
                    if (dialogue) break;
                  }

                  if (dialogue) {
                    dialogue.remove();
                    console.log("Expert Connect dialogue removed successfully.");
                  } else {
                    console.warn("Expert Connect dialogue not found, retrying...");
                    setTimeout(removeExpertConnectDialogue, 500);
                  }
                }

                // Handle video
                const video = document.getElementById("streamingVideo");
                if (video) {
                  video.style.visibility = "visible";
                  video.style.display = "block";
                  video.style.opacity = "1";
                  video.style.width = "100%";
                  video.style.height = "auto";
                  video.classList.remove("hidden");
                  video.setAttribute("autoplay", "autoplay");
                  video.setAttribute("muted", "true");
                  video.setAttribute("loop", "");
                  video.setAttribute("playsinline", "true");
                  video.load();

                  const playPromise = video.play();
                  if (playPromise !== undefined) {
                    playPromise
                      .then(() => {
                        console.log("Car rotation video is playing.");
                      })
                      .catch((error) => {
                        console.warn("Could not play car video:", error);
                      });
                  }
                } else {
                  console.warn("Car video element not found (ID: streamingVideo).");
                }

                // Remove Expert Connect button and dialogue
                removeExpertConnect();
                removeExpertConnectDialogue();

                // Add WhatsApp Connect button
                const whatsappContainer = document.createElement('div');
                whatsappContainer.style.position = 'fixed';
                whatsappContainer.style.left = '20px';
                whatsappContainer.style.top = '100px';
                whatsappContainer.style.display = 'flex';
                whatsappContainer.style.alignItems = 'center';
                whatsappContainer.style.zIndex = '1000';

                // WhatsApp button with icon inside
                const whatsappBtn = document.createElement('button');
                whatsappBtn.innerHTML = '<span style="margin-right: 8px;color:white;">📞</span>WhatsApp to Connect';
                whatsappBtn.style.backgroundColor = '#1A4C8E';
                whatsappBtn.style.color = '#ffffff';
                whatsappBtn.style.border = 'none';
                whatsappBtn.style.padding = '8px 12px';
                whatsappBtn.style.borderRadius = '5px';
                whatsappBtn.style.cursor = 'pointer';
                whatsappBtn.style.fontSize = '14px';
                whatsappBtn.style.display = 'flex';
                whatsappBtn.style.alignItems = 'center';
                whatsappBtn.onclick = () => {
                  window.location.href = 'https://wa.me/6289166961?text=Hello%20I%20am%20interested%20in%20the%20Honda%20Amaze';
                };

                whatsappContainer.appendChild(whatsappBtn);
                document.body.appendChild(whatsappContainer);

                // Remove existing footer
                const existingFooter = document.querySelector('.footerContainer');
                if (existingFooter) {
                  existingFooter.remove();
                } else {
                  console.warn("Existing footer not found.");
                }

                // Create and append new footer
                const newFooter = document.createElement('div');
                newFooter.style.position = 'fixed';
                newFooter.style.bottom = '0';
                newFooter.style.left = '0';
                newFooter.style.width = '100%';
                newFooter.style.backgroundColor = '#ffffff';
                newFooter.style.display = 'flex';
                newFooter.style.justifyContent = 'space-around';
                newFooter.style.padding = '5px';
                newFooter.style.boxShadow = '0 -2px 5px rgba(0,0,0,0.1)';
                newFooter.style.zIndex = '1000';

                // Book Online button
                const bookOnlineBtn = document.createElement('button');
                bookOnlineBtn.innerText = 'Book Online';
                bookOnlineBtn.style.backgroundColor = '#1A4C8E';
                bookOnlineBtn.style.color = '#ffffff';
                bookOnlineBtn.style.border = 'none';
                bookOnlineBtn.style.padding = '5px 15px';
                bookOnlineBtn.style.borderRadius = '30px';
                bookOnlineBtn.style.cursor = 'pointer';
                bookOnlineBtn.onclick = () => {
                  FlutterChannel.postMessage('navigateToBookOnline1');
                };

                // Book Test Drive button
                const testDriveBtn = document.createElement('button');
                testDriveBtn.innerText = 'Book Test Drive';
                testDriveBtn.style.backgroundColor = '#ffffff';
                testDriveBtn.style.color = '#1A4C8E';
                testDriveBtn.style.border = '2px solid #1A4C8E';
                testDriveBtn.style.padding = '8px 20px';
                testDriveBtn.style.borderRadius = '30px';
                testDriveBtn.style.cursor = 'pointer';
                testDriveBtn.onclick = () => {
                  FlutterChannel.postMessage('navigateToBookOnline');
                };

                newFooter.appendChild(bookOnlineBtn);
                newFooter.appendChild(testDriveBtn);
                document.body.appendChild(newFooter);
              })();
            ''');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          print("JS Message: ${message.message}");
          if (message.message == 'navigateToBookOnline') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginButton()),
            );
          } else if (message.message == 'navigateToBookOnline1') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Mobiledesign()),
            );
          }
        },
      )
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36",
      )
      ..loadRequest(Uri.parse(widget.url));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => Helppage()));
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
                color: Color(0xFF004C90),
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
              child: Icon(Icons.search, color: Color.fromRGBO(26, 76, 142, 1), size: iconSize),
            ),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}