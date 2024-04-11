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
  final TextEditingController _password = TextEditingController();
  int? id;
  String url = dotenv.env['API_URL']!;
  bool loading = false;
  bool showPwd = false;

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

  Future<void> resetData() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/market/$id/reset"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  void showConfirmReset() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          actions: [
            CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal")),
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  resetData();
                },
                child: const Text("Reset Data")),
          ],
          title: const Text("Konfirmasi reset data"),
        );
      },
    );
  }

  void showConfirmDelete() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          actions: [
            CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal")),
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {},
                child: const Text("Hapus Toko")),
          ],
          title: const Text("Konfirmasi penghapusan toko"),
          content: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Kata Sandi",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              CupertinoTextField(
                controller: _password,
                placeholder: "Masukkan kata sandi anda",
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
                obscureText: !showPwd,
                obscuringCharacter: "*",
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Flexible(
                        child: Text(
                      "Semua data meliputi data karyawan,produk,dan transaksi akan ikut terhapus.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.clip,
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Flexible(
                        child: Text(
                      "Akun anda akan terhapus dan logout secara otomatis.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.clip,
                    ))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Informasi Toko",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: Colors.orange,
                      onPressed: () {
                        _uploadToDatabase(context);
                      },
                      child: const Text("Simpan")),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Reset Semua Data",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: Colors.red,
                      onPressed: () {
                        showConfirmReset();
                      },
                      child: const Text("Reset")),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Hapus Toko",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: Colors.red,
                      onPressed: () {
                        showConfirmDelete();
                      },
                      child: const Text("Hapus")),
                ),
              ],
            )),
      ),
    );
  }
}
