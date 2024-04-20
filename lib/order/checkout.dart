import 'package:app/etc/format_number.dart';
import 'package:app/models/order.dart';
import 'package:app/models/order_controller.dart';
import 'package:app/order/payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key, required this.order});
  final List<Order> order;

  @override
  // ignore: library_private_types_in_public_api
  _CheckoutState createState() => _CheckoutState();
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

class _CheckoutState extends State<Checkout> {
  final orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 1,
        title: const Text(
          "Checkout",
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
        actions: [
          TextButton(
            onPressed: () {
              orderController.sheetOrderOpen.value = false;
              orderController.order.clear();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Batalkan"),
          )
        ],
      ),
      body: Obx(() => orderController.order.isNotEmpty
          ? ListView.builder(
              itemCount: orderController.order.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Dismissible(
                    key: Key(index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                orderController.order.removeAt(index);
                              });
                              if (orderController.order.isEmpty) {
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 40,
                            ))),
                    child: Column(
                      children: [
                        ListTile(
                            title: Text(orderController.order[index].namaProduk,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "Rp.${formatNumber(orderController.order[index].harga)}"),
                            trailing: Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    orderController.decrementOrder(
                                        orderController.order[index].id);
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Obx(() => Text(
                                      orderController.order[index].qty
                                          .toString(),
                                      style: const TextStyle(fontSize: 20),
                                    )),
                                IconButton(
                                  onPressed: () {
                                    orderController.incrementOrder(
                                        orderController.order[index].id);
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            )),
                        index != orderController.order.length - 1
                            ? const Divider(
                                indent: 15,
                                endIndent: 15,
                              )
                            : Container()
                      ],
                    ));
              },
            )
          : Container()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: SizedBox(
          height: 100,
          child: Column(
            children: [
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                      "Total (${orderController.order.fold(0, (previousValue, element) => previousValue + element.qty.value)} Produk)",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
                  Obx(() => Text(
                      "Rp.${formatNumber(orderController.order.fold(0, (previousValue, element) => previousValue + (element.harga * element.qty.value)))}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Colors.orange,
                  child: const Text("Bayar"),
                  onPressed: () {
                    Navigator.of(context).push(_goPage(Payment(
                        total: orderController.order.fold(
                            0,
                            (previousValue, element) =>
                                previousValue +
                                (element.harga * element.qty.value)))));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
