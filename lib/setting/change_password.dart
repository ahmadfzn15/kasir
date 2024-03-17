import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();
  String url = dotenv.env['API_URL']!;
  bool showPwd = false;
  bool showNewPwd = false;
  bool showRepeatPwd = false;

  Future<void> uploadData() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');

    final response = await http.put(
        Uri.parse("$url/api/user/change-password/$id"),
        body: jsonEncode({
          "email": _email.text,
          "current_password": _currentPassword.text,
          "new_password": _newPassword.text,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        });

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            surfaceTintColor: Colors.white,
            elevation: 4,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Email Saat Ini",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    CupertinoTextField(
                      controller: _email,
                      placeholder: "Masukkan email saat ini",
                      keyboardType: TextInputType.emailAddress,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.email),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFcbd5e1), width: 0.5),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Kata Sandi Saat Ini",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    CupertinoTextField(
                      controller: _currentPassword,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.lock),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showPwd = !showPwd;
                              });
                            },
                            child: showPwd
                                ? const Icon(CupertinoIcons.eye_fill)
                                : const Icon(CupertinoIcons.eye_slash_fill)),
                      ),
                      placeholder: "Masukkan kata sandi saat ini",
                      obscureText: true,
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
                      height: 12,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Kata Sandi Baru",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    CupertinoTextField(
                      controller: _newPassword,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.lock),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showNewPwd = !showNewPwd;
                              });
                            },
                            child: showNewPwd
                                ? const Icon(CupertinoIcons.eye_fill)
                                : const Icon(CupertinoIcons.eye_slash_fill)),
                      ),
                      placeholder: "Masukkan kata sandi baru",
                      obscureText: true,
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
                      height: 12,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Ulang Kata Sandi",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    CupertinoTextField(
                      controller: _repeatPassword,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.lock),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showRepeatPwd = !showRepeatPwd;
                              });
                            },
                            child: showRepeatPwd
                                ? const Icon(CupertinoIcons.eye_fill)
                                : const Icon(CupertinoIcons.eye_slash_fill)),
                      ),
                      placeholder: "Masukkan ulang kata sandi baru",
                      obscureText: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFcbd5e1), width: 0.5),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.orange,
              onPressed: () {},
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
