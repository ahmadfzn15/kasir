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

  Future<void> deleteAccount() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/user/delete"),
        headers: {"Authorization": "Bearer $token"},
        body: {"id": id, "password": _password.text});

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
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
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
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi wajib diisi!';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Masukkan kata sandi",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: GestureDetector(
                          onTap: null,
                          child: const Icon(CupertinoIcons.eye),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFe2e8f0), width: 0.5),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ))),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
              style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))),
                  backgroundColor: MaterialStatePropertyAll(Colors.red),
                  foregroundColor: MaterialStatePropertyAll(Colors.white)),
              onPressed: () {
                deleteAccount();
              },
              child: const Text("Hapus Akun")),
        ),
      ),
    );
  }
}
