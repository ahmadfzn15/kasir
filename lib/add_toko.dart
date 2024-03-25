import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddToko extends StatefulWidget {
  const AddToko({super.key});

  @override
  State<AddToko> createState() => _AddTokoState();
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

class _AddTokoState extends State<AddToko> {
  final TextEditingController _namaToko = TextEditingController();
  final TextEditingController _alamatToko = TextEditingController();
  final TextEditingController _usaha = TextEditingController();
  final TextEditingController _noTlp = TextEditingController();

  bool loading = false;

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/market"),
        body: jsonEncode({
          "nama_toko": _namaToko.text,
          "alamat": _alamatToko.text,
          "bidang_usaha": _usaha.text,
          "no_tlp": _noTlp.text,
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
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        _goPage(const Layout()),
        (route) => false,
      );
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
          "Toko",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                          Text("Nama Toko",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      CupertinoTextField(
                        controller: _namaToko,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.shop),
                        ),
                        placeholder: "Masukkan nama toko",
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
                          Text("Alamat Toko",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      CupertinoTextField(
                        controller: _alamatToko,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.place),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        placeholder: "Masukkan alamat toko",
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
                          Text("Bidang usaha",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      CupertinoTextField(
                        controller: _usaha,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.business),
                        ),
                        placeholder: "Masukkan bidang usaha",
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
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
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
                    ],
                  )))),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.orange,
              onPressed: () {
                _uploadToDatabase(context);
              },
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
