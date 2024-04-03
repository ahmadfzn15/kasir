import 'dart:convert';

import 'package:app/add_toko.dart';
import 'package:app/auth/email_verify.dart';
import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
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

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordControllerConfirmation =
      TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool pwdNotSame = false;
  bool loading = false;
  bool showPwd = false;
  bool showPwdConf = false;

  Future<void> _registerUser(BuildContext context) async {
    final res = await http
        .post(Uri.parse("${dotenv.env['API_URL']!}/api/auth/register"),
            body: jsonEncode({
              "nama": _namaController.text,
              "email": _emailController.text,
              "password": _passwordController.text,
            }),
            headers: {"Content-type": "application/json"});

    final result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await const FlutterSecureStorage()
          .write(key: 'token', value: result['data']['token']);
      await const FlutterSecureStorage()
          .write(key: 'role', value: result['data']['role']);
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        _goPage(const EmailVerify()),
        (route) => false,
      );
    } else {
      setState(() {
        _passwordController.clear();
      });
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
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
                            Text("Nama",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CupertinoTextField(
                          controller: _namaController,
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
                                color: const Color(0xFF94a3b8), width: 0.5),
                          ),
                        ),
                        const SizedBox(height: 15),
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
                          controller: _emailController,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(Icons.email),
                          ),
                          placeholder: "Masukkan email",
                          keyboardType: TextInputType.emailAddress,
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
                            Text("Kata Sandi",
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                          obscuringCharacter: "*",
                          onChanged: (value) {
                            if (_passwordControllerConfirmation
                                .text.isNotEmpty) {
                              if (value !=
                                  _passwordControllerConfirmation.text) {
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
                        const SizedBox(height: 15),
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
                          controller: _passwordControllerConfirmation,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(Icons.lock),
                          ),
                          obscuringCharacter: "*",
                          onChanged: (value) {
                            if (_passwordController.text.isNotEmpty) {
                              if (value != _passwordController.text) {
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
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showPwdConf = !showPwdConf;
                                  });
                                },
                                child: showPwdConf
                                    ? const Icon(CupertinoIcons.eye_fill)
                                    : const Icon(
                                        CupertinoIcons.eye_slash_fill)),
                          ),
                          placeholder: "Masukkan ulang kata sandi",
                          obscureText: !showPwdConf,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF94a3b8), width: 0.5),
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
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: CupertinoButton(
                              onPressed: () => !loading && !pwdNotSame
                                  ? _registerUser(context)
                                  : null,
                              color: Colors.orange,
                              child: const Text("Daftar",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                widget.pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOutExpo);
                              },
                              child: const Text(
                                "Masuk",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
