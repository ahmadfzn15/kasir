import 'package:app/models/order.dart';
import 'package:app/models/products.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final RxList<Order> order = <Order>[].obs;
  RxBool sheetOrderOpen = false.obs;

  void addOrder(Products product) {
    order.add(Order(
        id: product.id,
        namaProduk: product.namaProduk,
        harga: product.harga_jual,
        stok: product.stok,
        qty: 1.obs));
  }

  void incrementOrder(int id) {
    var data = order.where((element) => element.id == id);
    if (data.first.stok != null) {
      if (data.first.qty.value < data.first.stok!) {
        if (data.isNotEmpty) {
          data.first.qty.value++;
          update();
        }
      }
    } else {
      if (data.isNotEmpty) {
        data.first.qty.value++;
        update();
      }
    }
  }

  void decrementOrder(int id) {
    Iterable<Order> data = order.where((element) => element.id == id);
    if (data.isNotEmpty && data.first.qty.value > 0) {
      data.first.qty.value--;
      if (data.first.qty.value == 0) {
        order.removeWhere((element) => element.id == id);
        if (data.isEmpty) {
          sheetOrderOpen.value = false;
        }
        update();
      }
    }
  }
}
