import 'dart:convert';

import 'package:app/order/checkout.dart';
import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:app/models/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/sublayout.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

Route _goPage(int id, int? idProduk) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Sublayout(
      id: id,
      id_product: idProduk!,
    ),
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
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

Route _toCheckoutPage(List order) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Checkout(
      order: order,
    ),
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
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
  List order = [];
  List<Products> products = [];
  List<dynamic> category = [];
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();

    getUser();
    fetchDataProduct();
    fetchDataCategory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchDataProduct();
    fetchDataCategory();
    order.clear();
  }

  Future<void> getUser() async {
    Map<String, dynamic> res = await AuthUser().getCurrentUser();
    setState(() {
      user = res;
    });
  }

  Future<void> fetchDataProduct() async {
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');
    String url = dotenv.env['API_URL']!;

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/product/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
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
  }

  Future<void> fetchDataCategory() async {
    String url = dotenv.env['API_URL']!;
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');

    final response = await http.get(
      Uri.parse("$url/api/category/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        category = res['data'];
      });
    } else {
      throw Exception(res['message']);
    }
  }

  Future<void> _handleRefresh() async {
    await fetchDataProduct();
    await fetchDataCategory();
  }

  void _addOrder(BuildContext context, int id) {
    setState(() {
      order.add({
        "id": id,
        "namaProduk": products[id].namaProduk,
        "harga": products[id].harga,
        "qty": 1
      });
    });

    showSheetOrder();
  }

  void showSheetOrder() {
    if (order.isNotEmpty) {
      showBottomSheet(
        backgroundColor: Colors.white,
        elevation: 5,
        enableDrag: false,
        context: context,
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, right: 10),
              child: ListTile(
                leading: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            order = [];
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Total (${order.fold(0, (previousValue, element) => previousValue + element['qty'] as int)})",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Rp.${order.fold(0, (previousValue, element) => previousValue + (element['harga'] * element['qty']) as int)}",
                          style: const TextStyle(fontSize: 13),
                        )
                      ],
                    ),
                  ],
                ),
                trailing: FilledButton(
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.white),
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.orange)),
                    onPressed: () {
                      Navigator.of(context).push(_toCheckoutPage(order));
                    },
                    child: const Text("Checkout")),
              ));
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _openOptionProduct(BuildContext context, int id) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxHeight: 120),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(_goPage(2, id));
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Edit")
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  openDeleteProduct(context, id);
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Hapus")
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openOptionCategory(BuildContext context, int id) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxHeight: 120),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(_goPage(2, id));
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Edit")
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  openDeleteCategory(context, id);
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Hapus")
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddCategory() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      enableDrag: false,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints.expand(),
      builder: (context) {
        return const Padding(padding: EdgeInsets.all(20), child: Text("Hello"));
      },
    );
  }

  void _increment(BuildContext context, int id) {
    showSheetOrder();
    Iterable data = order.where((element) => element['id'] == id);
    if (data.isNotEmpty) {
      setState(() {
        data.first['qty']++;
      });
    }
  }

  void _decrement(BuildContext context, int id) {
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
    showSheetOrder();
  }

  void openDeleteProduct(BuildContext context, int id) {
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
                isDestructiveAction: true,
                onPressed: () {
                  deleteProduct(context, id);
                },
                child: const Text("Yes"))
          ]),
    );
  }

  void openDeleteCategory(BuildContext context, int id) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
          title: const Text("Hapus Kategori"),
          content:
              const Text("Apakah yakin anda ingin menghapus kategori ini?"),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  deleteCategory(context, id);
                },
                child: const Text("Yes"))
          ]),
    );
  }

  Future<void> deleteProduct(BuildContext context, int id) async {
    String url = dotenv.env['API_URL']!;
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/product/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _handleRefresh();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  Future<void> deleteCategory(BuildContext context, int id) async {
    String url = dotenv.env['API_URL']!;
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/category/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _handleRefresh();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Tab(
                  child: Text(
                    "Daftar Kategori",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 4,
              padding: EdgeInsets.zero,
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
                  Navigator.of(context).push(_goPage(1, 0));
                },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                tooltip: "Tambah Produk",
                shape: const CircleBorder(eccentricity: 0),
                child: const Icon(
                  Icons.add,
                  size: 30,
                ),
              ),
              body: products.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: Colors.orange,
                      child: SizedBox(
                        height: double.infinity,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, top: 15),
                          itemCount: products.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 115,
                              child: Card(
                                surfaceTintColor: Colors.white,
                                clipBehavior: Clip.antiAlias,
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      products[index]
                                                          .namaProduk,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                    Text(
                                                      "Rp.${products[index].harga}",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                )),
                                                user.isNotEmpty &&
                                                        user['role'] == 'admin'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          _openOptionProduct(
                                                              context,
                                                              products[index]
                                                                  .id);
                                                        },
                                                        child: const Icon(
                                                            Icons.menu),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
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
                                                              _decrement(
                                                                  context,
                                                                  index);
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
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              _increment(
                                                                  context,
                                                                  index);
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
                                                                    Colors
                                                                        .orange)),
                                                        onPressed: () {
                                                          _addOrder(
                                                              context, index);
                                                        },
                                                        child: const Text(
                                                            "Tambah"),
                                                      )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ))
                  : const Center(
                      child: CircularProgressIndicator(
                      color: Colors.orange,
                    )),
            ),
            Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(_goPage(9, 0));
                  },
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  tooltip: "Add Category",
                  shape: const CircleBorder(eccentricity: 0),
                  child: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                ),
                body: category.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Colors.orange,
                        child: SizedBox(
                          height: double.infinity,
                          child: ListView.builder(
                            itemCount: category.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(category[index]['kategori']),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        _openOptionCategory(
                                            context, category[index]['id']);
                                      },
                                      child: const Icon(Icons.menu),
                                    ),
                                  ),
                                  const Divider(
                                    indent: 10,
                                    endIndent: 10,
                                  )
                                ],
                              );
                            },
                          ),
                        ))
                    : const Center(
                        child: CircularProgressIndicator(
                        color: Colors.orange,
                      )))
          ],
        ),
      ),
    );
  }
}
