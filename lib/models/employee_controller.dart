import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmployeeController extends GetxController {
  List<dynamic> employee = [].obs;
  String url = dotenv.env['API_URL']!;

  Future<void> fetchDataEmployee() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.get(
      Uri.parse("$url/api/cashier"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      employee = res['data'];
      update();
    } else {
      throw Exception(res['message']);
    }
  }

  Future<void> addEmployee(BuildContext context, String kategori) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/employee"),
        body: jsonEncode({
          "kategori": kategori,
        }),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });

    Map<String, dynamic> result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await fetchDataEmployee();
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }
  }

  Future<void> deleteEmployee(BuildContext context, int id) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/user/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await fetchDataEmployee();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }
}
