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
  int _selectedOption = 1;
  bool pwdNotSame = false;
  bool showPwd = false;
  bool showRepeatPwd = false;
  bool loading = false;
  final List<DropdownMenuEntry<int>> _role = [
    const DropdownMenuEntry(value: 1, label: "Staff Kasir"),
    const DropdownMenuEntry(value: 2, label: "Staff Inventaris"),
  ];

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/cashier"),
        body: jsonEncode({
          "nama": _nama.text,
          "role": _selectedOption,
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
      setState(() {
        loading = false;
      });
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(15),
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
                        Text("Posisi Karyawan",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: DropdownMenu(
                          leadingIcon: const Icon(Icons.person),
                          expandedInsets: const EdgeInsets.all(0),
                          initialSelection: 1,
                          inputDecorationTheme: InputDecorationTheme(
                              constraints: const BoxConstraints(maxHeight: 50),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFFcbd5e1), width: 0.5),
                                  borderRadius: BorderRadius.circular(10))),
                          onSelected: (newValue) {
                            setState(() {
                              _selectedOption = newValue!;
                            });
                          },
                          dropdownMenuEntries: _role,
                        )),
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
                      obscuringCharacter: "*",
                      onChanged: (value) {
                        if (_repeatPassword.text.isNotEmpty) {
                          if (value != _repeatPassword.text) {
                            setState(() {
                              pwdNotSame = true;
                            });
                          } else {
                            setState(() {
                              pwdNotSame = false;
                            });
                          }
                        }
                      },
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
                      placeholder: "Masukkan ulang kata sandi",
                      obscuringCharacter: "*",
                      onChanged: (value) {
                        if (_password.text.isNotEmpty) {
                          if (value != _password.text) {
                            setState(() {
                              pwdNotSame = true;
                            });
                          } else {
                            setState(() {
                              pwdNotSame = false;
                            });
                          }
                        }
                      },
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
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        pwdNotSame
                            ? const Text(
                                "Kata sandi tidak sama",
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.start,
                              )
                            : const Text("")
                      ],
                    )
                  ],
                ))),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.orange,
              onPressed: () {
                !loading && !pwdNotSame ? _uploadToDatabase(context) : null;
              },
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
