import 'package:http/http.dart' as http;
import 'dart:convert';

class AddtoDriveApi {
  final String baseUrl = "http://10.0.2.2:3000";

  Future<bool> saveTestDriveData(Map<String, dynamic> testDriveData) async {
    final url = Uri.parse('$baseUrl/api/book_test_Drive'); 

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(testDriveData),
      );

      if (response.statusCode == 201) {
        print("Data saved successfully!");
        return true;
      } else {
        print("Failed to save data: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sending data: $e");
      return false;
    }
  }
}
