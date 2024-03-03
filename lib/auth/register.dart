import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Register extends StatefulWidget {
  const Register({super.key, required this.pageController});
  final PageController pageController;

  @override
  // ignore: library_private_types_in_public_api
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordControllerConfirmation =
      TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool loading = false;
  bool showPwd = false;
  bool showPwdConf = false;

  Future<void> _registerUser(BuildContext context) async {
    final res = await http
        .post(Uri.parse("${dotenv.env['API_URL']!}/api/auth/register"),
            body: jsonEncode({
              "username": _usernameController.text,
              "password": _passwordController.text,
            }),
            headers: {"Content-type": "application/json"});

    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, "Daftar berhasil. Silahkan login!", true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, "Daftar gagal", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Username",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username wajib diisi!';
                          }
                          return null;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan username anda",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.person),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFe2e8f0), width: 0.5),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Kata Sandi",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi wajib diisi!';
                          }
                          return null;
                        },
                        obscureText: !showPwd,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan kata sandi anda",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showPwd = !showPwd;
                                });
                              },
                              child: const Icon(Icons.remove_red_eye)),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFe2e8f0), width: 0.5),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Ulang Kata Sandi",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _passwordControllerConfirmation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi wajib diisi!';
                          }
                          return null;
                        },
                        obscureText: !showPwdConf,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan ulang kata sandi anda!",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showPwdConf = !showPwdConf;
                                });
                              },
                              child: const Icon(Icons.remove_red_eye)),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFe2e8f0), width: 0.5),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: () => loading
                                ? null
                                : {
                                    if (_formKey.currentState!.validate())
                                      _registerUser(context)
                                  },
                            style: const ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)))),
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.deepOrange),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white)),
                            child: const Text("Daftar",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Sudah punya akun? ",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              widget.pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutExpo);
                            },
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
