import 'dart:convert';

import 'package:app/models/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/sublayout.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

Route _goPage(int id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Sublayout(id: id),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
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

class _ProductState extends State<Product> {
  bool isSelected = false;
  bool isSelectedStart = false;
  List order = [];
  List<Products> products = [];

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    String url = dotenv.env['API_URL']!;

    final response = await http.get(
      Uri.parse("$url/api/product"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        products = (res['data'] as List<dynamic>)
            .map((data) => Products.fromJson(data))
            .toList();
      });
    } else {
      throw Exception(res['message']);
    }
  }

  Future<void> _handleRefresh() async {
    await fetchData();
  }

  void _addOrder(int id) {
    fetchData();
    setState(() {
      order.add({
        "id": id,
        "namaProduk": products[id].namaProduk,
        "harga": products[id].harga,
        "qty": 1
      });
    });
  }

  void _increment(int id) {
    Iterable data = order.where((element) => element['id'] == id);
    if (data.isNotEmpty) {
      setState(() {
        data.first['qty']++;
      });
    }
  }

  void _decrement(int id) {
    Iterable data = order.where((element) => element['id'] == id);
    if (data.isNotEmpty && data.first['qty'] > 0) {
      setState(() {
        data.first['qty']--;
      });
      if (data.first['qty'] == 0) {
        setState(() {
          order.removeWhere((element) => element['id'] == id);
        });
      }
    }
  }

  void _openOption(BuildContext context, int id) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Edit produk'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              openDialogDelete(context, id);
            },
            child: const Text('Hapus produk'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void openDialogDelete(BuildContext context, int id) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
          title: const Text("Hapus Produk"),
          content:
              const Text("Apakah yakin anda ingin menghapus data produk ini?"),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  deleteProduct(context, id);
                },
                child: const Text("Yes"))
          ]),
    );
  }

  Future<void> deleteProduct(BuildContext context, int id) async {
    String url = dotenv.env['API_URL']!;

    final response = await http.delete(
      Uri.parse("$url/api/product/$id"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    if (response.statusCode == 200) {
      fetchData();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      throw Exception("Data gagal dihapus.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: _handleRefresh,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "Daftar Produk",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Daftar Kategori",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                tabAlignment: TabAlignment.fill,
                splashBorderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(_goPage(2));
                  },
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  tooltip: "Add Orders",
                  shape: const CircleBorder(eccentricity: 0),
                  child: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: products.isNotEmpty
                      ? ListView.builder(
                          itemCount: products.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  products[index].selected = true;
                                });
                              },
                              onTap: () {
                                if (products[index].selected) {
                                  products[index].selected = false;
                                }
                              },
                              child: SizedBox(
                                height: 120,
                                child: Card(
                                  surfaceTintColor: Colors.white,
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Image.asset(
                                                products[index].foto ??
                                                    "assets/img/food.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  products[index].namaProduk,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    "Rp.${products[index].harga}"),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _openOption(context,
                                                    products[index].id);
                                              },
                                              child: const Icon(Icons.menu),
                                            ),
                                            order.isNotEmpty &&
                                                    order
                                                        .where((element) =>
                                                            element['id'] ==
                                                            index)
                                                        .isNotEmpty
                                                ? Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          _decrement(index);
                                                        },
                                                        icon: const Icon(
                                                            Icons.remove),
                                                      ),
                                                      Text(
                                                        order
                                                            .firstWhere(
                                                                (element) =>
                                                                    element[
                                                                        'id'] ==
                                                                    index)[
                                                                'qty']
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          _increment(index);
                                                        },
                                                        icon: const Icon(
                                                            Icons.add),
                                                      ),
                                                    ],
                                                  )
                                                : FilledButton(
                                                    style: const ButtonStyle(
                                                        surfaceTintColor:
                                                            MaterialStatePropertyAll(
                                                                Colors.orange)),
                                                    onPressed: () {
                                                      _addOrder(index);
                                                    },
                                                    child: const Text("Tambah"),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                          color: Colors.blue,
                        )),
                ),
              ),
              ListView.builder(
                itemCount: 10,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Menu $index"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
