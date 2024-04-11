import 'package:get/get.dart';

class Order {
  int id;
  String namaProduk;
  int harga;
  int? stok;
  RxInt qty;

  Order({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.stok,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaProduk': namaProduk,
      'harga': harga,
      'stok': stok,
      'qty': qty.value,
    };
  }
}
