import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key, required this.pageController});
  final PageController pageController;

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool loading = false;
  bool showPwd = false;

  void _loginUser(BuildContext context) async {
    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text
        }));

    if (res.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(res.body);
      await const FlutterSecureStorage()
          .write(key: 'token', value: result['data']['token']);
      await const FlutterSecureStorage()
          .write(key: 'id', value: result['data']['id'].toString());
      await const FlutterSecureStorage()
          .write(key: 'role', value: result['data']['role']);

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Layout();
          },
        ),
      );
      // ignore: use_build_context_synchronously
      Popup().show(context, "Login berhasil.", true);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, "Login gagal.", false);
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
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                          Text("Kata sandi",
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
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Lupa kata sandi?",
                            style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
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
                                      _loginUser(context)
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
                            child: const Text("Masuk",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutExpo);
                            },
                            child: const Text(
                              "Daftar",
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
