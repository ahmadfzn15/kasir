import 'package:get/get.dart';

class Products {
  int id;
  String? foto;
  String namaProduk;
  String? barcode;
  String? deskripsi;
  // ignore: non_constant_identifier_names
  int id_kategori;
  // ignore: non_constant_identifier_names
  int harga_beli;
  // ignore: non_constant_identifier_names
  int harga_jual;
  int? stok;
  RxBool selected;

  Products(
      {required this.id,
      this.foto,
      required this.namaProduk,
      this.barcode,
      // ignore: non_constant_identifier_names
      required this.harga_beli,
      // ignore: non_constant_identifier_names
      required this.harga_jual,
      this.deskripsi = "",
      // ignore: non_constant_identifier_names
      required this.id_kategori,
      this.stok = 0,
      required this.selected});

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'],
      foto: json['foto'],
      namaProduk: json['namaProduk'],
      barcode: json['barcode'],
      harga_beli: json['harga_beli'],
      harga_jual: json['harga_jual'],
      deskripsi: json['deskripsi'],
      id_kategori: json['id_kategori'],
      stok: json['stok'],
      selected: json['selected'],
    );
  }
}
