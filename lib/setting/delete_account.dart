import 'dart:convert';

import 'package:app/auth/auth.dart';
import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final TextEditingController _password = TextEditingController();
  bool showPwd = false;

  Future<void> deleteAccount() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.delete(
        Uri.parse("${dotenv.env['API_URL']!}/api/user/delete"),
        headers: {"Authorization": "Bearer $token"},
        body: {"password": _password.text});

    final result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await const FlutterSecureStorage().deleteAll();
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Auth();
          },
        ),
      );
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
    } else {
      print(result['message']);
      // ignore: use_build_context_synchronously
      // Popup().show(context, result['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
                child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Masukkan kata sandi untuk menghapus akun",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                CupertinoTextField(
                  controller: _password,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.lock),
                  ),
                  placeholder: "Masukkan kata sandi saat ini",
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
                  obscureText: !showPwd,
                  obscuringCharacter: "*",
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                  ),
                ),
              ],
            ))),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.red,
              onPressed: () {
                deleteAccount();
              },
              child: const Text("Hapus Akun")),
        ),
      ),
    );
  }
}
