import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Toko extends StatefulWidget {
  const Toko({super.key});

  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  final TextEditingController _namaToko = TextEditingController();
  final TextEditingController _alamatToko = TextEditingController();
  final TextEditingController _usaha = TextEditingController();
  final TextEditingController _noTlp = TextEditingController();
  int? id;
  String url = dotenv.env['API_URL']!;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    fetchDataMarket();
  }

  Future<void> fetchDataMarket() async {
    Map<String, dynamic> res = await AuthUser().getCurrentUser();

    var market = res['market'];
    _namaToko.value = TextEditingValue(text: market['nama_toko'] ?? "");
    _alamatToko.value = TextEditingValue(text: market['alamat'] ?? "");
    _usaha.value = TextEditingValue(text: market['bidang_usaha'] ?? "");
    _noTlp.value = TextEditingValue(text: market['no_tlp'] ?? "");
    setState(() {
      id = market['id'];
    });
  }

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.put(
        Uri.parse("${dotenv.env['API_URL']!}/api/market/$id"),
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
