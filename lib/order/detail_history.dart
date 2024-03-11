import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DetailHistory extends StatefulWidget {
  const DetailHistory({super.key, required this.id});
  final int id;

  @override
  // ignore: library_private_types_in_public_api
  _DetailHistoryState createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  String url = dotenv.env['API_URL']!;
  List<dynamic> detail = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    fetchDataHistory();
  }

  Future<void> fetchDataHistory() async {
    setState(() {
      loading = true;
    });
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/sale/detail/${widget.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        detail = res['data'];

        setState(() {
          loading = false;
        });
      } else {
        throw Exception(res['message']);
      }
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
          "Detail Histori",
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
      body: ListView.builder(
        itemCount: detail.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(detail[index]['namaProduk'],
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "Rp.${detail[index]['harga']} x ${detail[index]['qty']}"),
                trailing: Text(
                  "Rp.${detail[index]['harga'] * detail[index]['qty']}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Divider(
                indent: 15,
                endIndent: 15,
              )
            ],
          );
        },
      ),
    );
  }
}
