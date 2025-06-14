import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Editprofile extends StatefulWidget {
  final String? initialName;
  final File? initialImage;

  const Editprofile({
    super.key,
    this.initialName,
    this.initialImage,
  });

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> with WidgetsBindingObserver {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  File? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isNameEditable = false;
  bool isEmailEditable = false;
  bool isLoading = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addObserver(this);
    _image = widget.initialImage;
    if (widget.initialName != null) {
      nameController.text = widget.initialName!;
    }
    _loadImageFromPrefs();
    fetchUserDetails();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isMounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImage');
    if (imagePath != null && File(imagePath).existsSync()) {
      if (_isMounted) {
        setState(() {
          _image = File(imagePath);
        });
      }
    }
  }

  Future<void> _saveImageToPrefs(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', imagePath);
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null && _isMounted) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _saveImageToPrefs(pickedFile.path);
      }
    } catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to pick image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> fetchUserDetails() async {
    if (!_isMounted) return;

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty || token.isEmpty) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:7500/api/user/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (!_isMounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final firstName = data['user']['firstName'] ?? '';
          final lastName = data['user']['lastName'] ?? '';
          nameController.text = '$firstName $lastName'.trim();
          emailController.text = data['user']['email'] ?? '';
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch user details: ${response.reasonPhrase}"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $error"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name must be at least 2 characters long"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> saveChanges() async {
    if (!_validateInputs() || !_isMounted) return;

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final userId = prefs.getString('userId') ?? '';

    // Save name and image to SharedPreferences
    await prefs.setString('name', nameController.text.trim());
    await prefs.setString('email', emailController.text.trim());
    if (_image != null && _image!.existsSync()) {
      await prefs.setString('profileImage', _image!.path);
    }

    // Perform server update in the background
    if (userId.isNotEmpty && token.isNotEmpty) {
      final nameParts = nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse("http://127.0.0.1:7500/api/user/$userId"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = emailController.text.trim();

      if (_image != null && _image!.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Status Code: ${response.statusCode}');
        print('Response Body: $responseBody');

        if (!_isMounted) return;

        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: ${response.statusCode} - ${response.reasonPhrase}"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          final responseData = jsonDecode(responseBody);
          if (responseData['success'] != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to update profile on server: ${responseData['message'] ?? 'Unknown error'}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (error) {
        if (_isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: $error"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, {
        'name': nameController.text.trim(),
        'image': _image,
      });

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: height * 0.05,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color.fromRGBO(0, 51, 160, 1),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: const Color.fromRGBO(130, 136, 146, 1),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: CircleAvatar(
                              radius: width * 0.2,
                              backgroundColor: Colors.white,
                              backgroundImage: _image != null && _image!.existsSync() ? FileImage(_image!) : null,
                              child: _image == null || !_image!.existsSync()
                                  ? Icon(
                                      Icons.person_outline_outlined,
                                      size: width * 0.35,
                                      color: const Color.fromRGBO(130, 136, 146, 1),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 7,
                            right: 13,
                            child: GestureDetector(
                              onTap: isLoading ? null : _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(31, 31, 31, 1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(0, 51, 160, 1),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          TextField(
                            controller: nameController,
                            enabled: isNameEditable && !isLoading,
                            autocorrect: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromRGBO(0, 51, 160, 1).withOpacity(0.3),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromRGBO(0, 51, 160, 1).withOpacity(0.3),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 51, 160, 1),
                                  width: 1.0,
                                ),
                              ),
                              hintText: "Enter your name",
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(130, 136, 146, 1),
                              ),
                              suffixIcon: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          isNameEditable = !isNameEditable;
                                          if (isNameEditable) {
                                            FocusScope.of(context).requestFocus(_nameFocusNode);
                                            nameController.selection = TextSelection.fromPosition(
                                              TextPosition(offset: nameController.text.length),
                                            );
                                          }
                                        });
                                      },
                                child: Text(
                                  isNameEditable ? "Done" : "Edit",
                                  style: TextStyle(
                                    fontSize: 13.1,
                                    color: isNameEditable
                                        ? const Color.fromRGBO(0, 51, 160, 1)
                                        : const Color.fromRGBO(130, 136, 146, 1),
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            focusNode: _nameFocusNode,
                          ),
                          SizedBox(height: height * 0.02),
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(0, 51, 160, 1),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          TextField(
                            controller: emailController,
                            enabled: isEmailEditable && !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromRGBO(0, 51, 160, 1).withOpacity(0.3),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromRGBO(0, 51, 160, 1).withOpacity(0.3),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 51, 160, 1),
                                  width: 1.0,
                                ),
                              ),
                              hintText: "Enter your email",
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
                                color: Color.fromRGBO(130, 136, 146, 1),
                              ),
                              suffixIcon: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          isNameEditable = !isNameEditable;
                                          if (isNameEditable) {
                                            FocusScope.of(context).requestFocus(_nameFocusNode);
                                            nameController.selection = TextSelection.fromPosition(
                                              TextPosition(offset: nameController.text.length),
                                            );
                                          }
                                        });
                                      },
                                child: Text(
                                  isNameEditable ? "Done" : "Edit",
                                  style: TextStyle(
                                    fontSize: 13.1,
                                    color: isNameEditable
                                        ? const Color.fromRGBO(0, 51, 160, 1)
                                        : const Color.fromRGBO(130, 136, 146, 1),
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            focusNode: _emailFocusNode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.06,
              width: width * 0.5,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 51, 160, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }
}