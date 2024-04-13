import 'dart:convert';

import 'package:app/auth/auth.dart';
import 'package:app/components/popup.dart';
import 'package:app/models/market.dart';
import 'package:app/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

Route _goPage(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOutExpo));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class UserController extends GetxController {
  Rx<User>? user = User().obs;
  Rx<Market>? toko = Market().obs;
  String url = dotenv.env['API_URL']!;

  Future<void> getCurrentUser(BuildContext context) async {
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String url = dotenv.env['API_URL']!;

    if (hasToken) {
      try {
        final response = await http.get(
          Uri.parse("$url/api/user"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
        );

        Map<String, dynamic> res = jsonDecode(response.body);
        if (response.statusCode == 200) {
          user = User.fromJson(res['data']).obs;
          toko = Market.fromJson(res['data']['market']).obs;

          update();
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    } else {
      await const FlutterSecureStorage().deleteAll();
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          _goPage(const Auth()),
          (route) => false);
    }
  }

  Future<void> editToko(BuildContext context, data) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.put(
        Uri.parse("${dotenv.env['API_URL']!}/api/market/${toko!.value.id}"),
        body: jsonEncode({
          "nama_toko": data['namaToko'],
          "alamat": data['alamatToko'],
          "bidang_usaha": data['usaha'],
          "no_tlp": data['noTlp'],
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
  }

  Future<void> resetData(BuildContext context) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/market/${toko!.value.id}/reset"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }
}
