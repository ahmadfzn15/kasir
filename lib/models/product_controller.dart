import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/models/products.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

class ProductController extends GetxController {
  List<Products> products = <Products>[].obs;
  List<Products> searchResult = <Products>[].obs;
  String url = dotenv.env['API_URL']!;
  RxBool selectAll = false.obs;
  RxBool select = false.obs;

  Future<void> fetchDataProduct({categoryId = ""}) async {
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/product?category=$categoryId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        products = (res['data'] as List<dynamic>)
            .map((data) => Products.fromJson({...data, "selected": false.obs}))
            .toList();
        searchResult = products;
        update();
      } else {
        throw Exception(res['message']);
      }
    }
  }

  Future<void> addProduct(BuildContext context, data) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');
    var request = http.MultipartRequest("post", Uri.parse("$url/api/product"));
    if (data['img'] != null) {
      request.files
          .add(await http.MultipartFile.fromPath('foto', data['img'].path));
    }
    request.fields['namaProduk'] = data['namaProduk'];
    request.fields['barcode'] = data['barcode'];
    request.fields['variant'] = data['variant'];
    request.fields['id_kategori'] = data['id_kategori'];
    request.fields['harga_beli'] = data['harga_beli'];
    request.fields['harga_jual'] = data['harga_jual'];
    request.fields['deskripsi'] = data['deskripsi'];
    request.fields['stok'] = data['stok'];
    request.headers['Content-Type'] = "application/json";
    request.headers['Authorization'] = "Bearer $token";
    var streamedResponse = await request.send();
    var res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode == 200) {
      await fetchDataProduct();
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Produk baru berhasil ditambahkan', true);
      final notif = AudioPlayer();
      notif.play(AssetSource("sound/sound.mp3"));
      bool? hasVibration = await Vibration.hasVibrator();
      if (hasVibration!) {
        Vibration.vibrate(
          duration: 100,
          amplitude: 100,
        );
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Produk gagal ditambahkan', false);
    }
  }

  Future<void> editProduct(BuildContext context, data) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    var request = http.MultipartRequest(
        "post", Uri.parse("$url/api/product/${data['id']}"));
    if (data['new_img'] != null) {
      request.files.add(
          await http.MultipartFile.fromPath('new_img', data['new_img']!.path));
    }
    if (data['old_img'] != null) {
      request.fields['old_img'] = data['old_img'];
    }
    request.fields['namaProduk'] = data['namaProduk'];
    request.fields['barcode'] = data['barcode'];
    request.fields['id_kategori'] = data['id_kategori'].toString();
    request.fields['harga_beli'] = data['harga_beli'];
    request.fields['harga_jual'] = data['harga_jual'];
    request.fields['deskripsi'] = data['deskripsi'];
    request.fields['stok'] = data['stok'];
    request.headers['Content-Type'] = "application/json";
    request.headers['Authorization'] = "Bearer $token";
    var streamedResponse = await request.send();
    var res = await http.Response.fromStream(streamedResponse);
    var message = jsonDecode(res.body)['message'];

    if (res.statusCode == 200) {
      searchResult.map((e) => e.selected.value = false).toList();
      select.value = false;
      await fetchDataProduct();
      // ignore: use_build_context_synchronously
      Popup().show(context, message, true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.maybePop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, message, false);
    }
  }

  Future<void> deleteProduct(BuildContext context, List<int> id) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(Uri.parse("$url/api/product"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"data": id}));

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      searchResult.map((e) => e.selected.value = false).toList();
      select.value = false;
      await fetchDataProduct();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.maybePop(context);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  void searchProduct(String value) {
    searchResult = products
        .where((element) =>
            element.namaProduk.toLowerCase().contains(value.toLowerCase()))
        .toList();

    update();
  }
}
