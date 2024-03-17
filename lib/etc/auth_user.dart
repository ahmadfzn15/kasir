import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUser {
  Future<Map<String, dynamic>> getCurrentUser() async {
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String url = dotenv.env['API_URL']!;

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return res['data'];
      } else {
        return {};
      }
    } else {
      return {};
    }
  }
}
