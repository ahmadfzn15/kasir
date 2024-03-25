import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _noTlp = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();
  bool showPwd = false;
  bool showRepeatPwd = false;
  bool loading = false;

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/cashier"),
        body: jsonEncode({
          "nama": _nama.text,
          "email": _email.text,
          "no_tlp": _noTlp.text,
          "password": _password.text,
        }),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });

    Map<String, dynamic> result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
      setState(() {
        loading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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
                    key: _formKey,
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Nama Karyawan",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CupertinoTextField(
                          controller: _nama,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(Icons.person),
                          ),
                          placeholder: "Masukkan nama",
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
                            Text("Email",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CupertinoTextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(Icons.email),
                          ),
                          placeholder: "Masukkan alamat email",
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
                            Text("Nomor Telepon",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CupertinoTextField(
                          controller: _noTlp,
                          keyboardType: TextInputType.phone,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(Icons.phone),
                          ),
                          placeholder: "Masukkan nomor telepon",
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
                            Text("Kata Sandi",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CupertinoTextField(
                          controller: _password,
                          obscureText: !showPwd,
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
                                    : const Icon(
                                        CupertinoIcons.eye_slash_fill)),
                          ),
                          placeholder: "Masukkan kata sandi",
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
                          obscureText: !showRepeatPwd,
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
                                    : const Icon(
                                        CupertinoIcons.eye_slash_fill)),
                          ),
                          placeholder: "Masukkan ulang kata sandi",
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
                !loading ? _uploadToDatabase(context) : null;
              },
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
