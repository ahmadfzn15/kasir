import 'package:app/order/payment.dart';
import 'package:flutter/cupertino.dart';
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
  void _increment(int id) {
    Iterable data = widget.order.where((element) => element['id'] == id);
    if (data.isNotEmpty) {
      setState(() {
        data.first['qty']++;
      });
    }
  }

  void _decrement(int id) {
    Iterable data = widget.order.where((element) => element['id'] == id);
    if (data.first['qty'] > 1) {
      setState(() {
        data.first['qty']--;
      });
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
              Navigator.pop(context);
              setState(() {
                widget.order.clear();
              });
            },
            child: const Text("Batalkan"),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.order.length,
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
                          widget.order.removeAt(index);
                        });
                        if (widget.order.isEmpty) {
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
                      title: Text(widget.order[index]['namaProduk'],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      subtitle: Text("Rp.${widget.order[index]['harga']}"),
                      trailing: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              _decrement(widget.order[index]['id']);
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            widget.order[index]['qty'].toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                          IconButton(
                            onPressed: () {
                              _increment(widget.order[index]['id']);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      )),
                  const Divider(
                    indent: 15,
                    endIndent: 15,
                  )
                ],
              ));
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
                      "Total (${widget.order.fold(0, (previousValue, element) => previousValue + element['qty'] as int)} Produk)",
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
                child: CupertinoButton(
                  color: Colors.orange,
                  child: const Text("Bayar"),
                  onPressed: () {
                    Navigator.of(context).push(_goPage(Payment(
                        order: widget.order,
                        total: widget.order.fold(
                            0,
                            (previousValue, element) => previousValue +
                                (element['harga'] * element['qty']) as int))));
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
