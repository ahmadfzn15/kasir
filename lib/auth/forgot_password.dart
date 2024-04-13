import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _email = TextEditingController();

  Future<void> sendEmail() async {
    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/forgot-password"),
        headers: {
          "Content-type": "application/json",
        },
        body: jsonEncode({"email": _email.text}));

    final result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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
          "Lupa Kata Sandi",
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
                        Text("Email",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    CupertinoTextField(
                      controller: _email,
                      placeholder: "Masukkan email",
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
                  ],
                ))),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.orange,
              onPressed: () {
                sendEmail();
              },
              child: const Text("Kirim")),
        ),
      ),
    );
  }
}
