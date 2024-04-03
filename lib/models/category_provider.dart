import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CategoryProvider extends ChangeNotifier {
  List<dynamic> _category = [];
  String url = dotenv.env['API_URL']!;

  List get category => _category;

  Future<void> fetchDataCategory() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.get(
      Uri.parse("$url/api/category"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _category = res['data'];
    } else {
      throw Exception(res['message']);
    }

    notifyListeners();
  }

  Future<void> addCategory(BuildContext context, String kategori) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/category"),
        body: jsonEncode({
          "kategori": kategori,
        }),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });

    Map<String, dynamic> result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }

    notifyListeners();
  }
}
