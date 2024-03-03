import 'package:app/order/detail_product.dart';
import 'package:app/order/payment.dart';
import 'package:flutter/material.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key, required this.order});
  final List order;

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
      ),
      body: ListView.builder(
        itemCount: widget.order.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                      _goPage(DetailProduct(detail: widget.order[index])));
                },
                title: Text(widget.order[index]['namaProduk'],
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "Rp.${widget.order[index]['harga']} x ${widget.order[index]['qty']}"),
                trailing: Text(
                  "Rp.${widget.order[index]['harga'] * widget.order[index]['qty']}",
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
                  Text(
                      "Total (${widget.order.fold(0, (previousValue, element) => previousValue + element['qty'] as int)})",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                      "Rp.${widget.order.fold(0, (previousValue, element) => previousValue + (element['harga'] * element['qty']) as int)}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.orange),
                        foregroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                    onPressed: () {
                      Navigator.of(context).push(_goPage(Payment(
                          total: widget.order.fold(
                              0,
                              (previousValue, element) => previousValue +
                                      (element['harga'] * element['qty'])
                                  as int))));
                    },
                    child: const Text("Bayar")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
