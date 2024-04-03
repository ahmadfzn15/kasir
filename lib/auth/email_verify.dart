import 'dart:convert';

import 'package:app/add_toko.dart';
import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EmailVerify extends StatefulWidget {
  const EmailVerify({super.key});

  @override
  State<EmailVerify> createState() => _EmailVerifyState();
}

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

class _EmailVerifyState extends State<EmailVerify> {
  final TextEditingController _code = TextEditingController();

  Future<void> sendCode() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/verify-email"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"code": _code.text}));

    final result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        _goPage(const AddToko()),
        (route) => false,
      );
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }
  }

  Future<void> sendEmailVerification() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
      Uri.parse("${dotenv.env['API_URL']!}/api/send-verify"),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 1,
        title: const Text(
          "Verifikasi Email",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Masukkan Kode Verifikasi Email",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  CupertinoTextField(
                    controller: _code,
                    placeholder: "Masukkan kode",
                    maxLength: 6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFcbd5e1), width: 0.5),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          sendEmailVerification();
                        },
                        child: const Text(
                          "Kirim ulang kode verifikasi",
                        ),
                      ),
                    ],
                  ),
                ],
              ))),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.orange,
              onPressed: () {
                sendCode();
              },
              child: const Text("Kirim")),
        ),
      ),
    );
  }
}
