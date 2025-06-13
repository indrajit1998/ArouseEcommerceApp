import 'package:http/http.dart' as http;
import 'dart:convert';

class AddtocompareApi {
  final String baseUrl = "http://10.0.2.2:3000";

  Future<bool> saveCompareData(Map<String, dynamic> compareData) async {
    final url = Uri.parse('$baseUrl/api/user_book_online'); 

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(compareData),
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
