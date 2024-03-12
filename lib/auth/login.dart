import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/layout.dart';
import 'package:flutter/cupertino.dart';
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

Route _goPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Layout(),
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
          _goPage());
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
                      CupertinoTextField(
                        controller: _usernameController,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.person),
                        ),
                        placeholder: "Masukkan username anda",
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF94a3b8), width: 0.5),
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
                      CupertinoTextField(
                        controller: _passwordController,
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
                        placeholder: "Masukkan kata sandi anda",
                        obscureText: !showPwd,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF94a3b8), width: 0.5),
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
                          child: CupertinoButton(
                            onPressed: () => loading
                                ? null
                                : {
                                    if (_formKey.currentState!.validate())
                                      _loginUser(context)
                                  },
                            color: Colors.orange,
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
