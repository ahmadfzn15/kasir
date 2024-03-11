import 'dart:convert';

import 'package:app/order/checkout.dart';
import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:app/models/products.dart';
import 'package:app/product/edit_category.dart';
import 'package:app/product/edit_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/sublayout.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

Route _goPage(int id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Sublayout(
      id: id,
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

Route _toEditProduct(Products produk) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EditProduct(
      product: produk,
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

Route _toEditCategory(Map<String, dynamic> kategori) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        EditCategory(category: kategori),
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
  String url = dotenv.env['API_URL']!;
  bool row = true;
  bool _selectAll = false;
  bool _select = false;

  @override
  void initState() {
    super.initState();

    fetchDataProduct();
    fetchDataCategory();
    getUser();
    getView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void vibrateDevices() async {
    bool? hasVibration = await Vibration.hasVibrator();
    if (hasVibration!) {
      Vibration.vibrate(
        duration: 300,
        amplitude: 100,
      );
    }
  }

  Future<void> setView(bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("viewProduct", value);
    getView();
  }

  Future<void> getView() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool res = pref.getBool("viewProduct")!;
    setState(() {
      row = res;
    });
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
        products = (res['data'] as List<dynamic>)
            .map((data) => Products.fromJson({...data, "selected": false}))
            .toList();
      } else {
        throw Exception(res['message']);
      }
    }
  }

  Future<void> fetchDataCategory() async {
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
        "idProduk": products[id].id,
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

  void _openOptionProduct(BuildContext context, Products product) {
    showBottomSheet(
      constraints: const BoxConstraints(maxHeight: 80),
      context: context,
      enableDrag: false,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              products.where((element) => element.selected).length == 1
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(_toEditProduct(product));
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    )
                  : Container(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  openDeleteProduct(
                      context,
                      products
                          .where((element) => element.selected)
                          .map((e) => e.id)
                          .toList());
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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

  void _openOptionCategory(
      BuildContext context, Map<String, dynamic> category) {
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
                  Navigator.of(context).push(_toEditCategory(category));
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
                  openDeleteCategory(context, category['id']);
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

  void openDeleteProduct(BuildContext context, List<int> id) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
          title: const Text("Hapus Produk"),
          content: Text(
              "Apakah yakin anda ingin menghapus ${id.length} produk ini?"),
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

  Future<void> deleteProduct(BuildContext context, List<int> id) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.post(Uri.parse("$url/api/product/delete"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"data": id}));

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _handleRefresh();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  Future<void> deleteCategory(BuildContext context, int id) async {
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
    return Scaffold(
      appBar: AppBar(
        leading: _select
            ? Checkbox(
                value: _selectAll,
                checkColor: Colors.orange,
                fillColor: const MaterialStatePropertyAll(Colors.white),
                onChanged: (value) {
                  setState(() {
                    _selectAll = value!;
                    if (_selectAll) {
                      products.map((e) => e.selected = true).toList();
                    } else {
                      products.map((e) => e.selected = false).toList();
                    }
                  });
                },
              )
            : IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu)),
        title: _select
            ? Text(
                "${products.where((element) => element.selected).length} Dipilih")
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 45,
                  child: SearchAnchor.bar(
                    barLeading: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 30,
                    ),
                    barBackgroundColor:
                        const MaterialStatePropertyAll(Colors.white),
                    barElevation: const MaterialStatePropertyAll(0),
                    barHintText: "Search product",
                    suggestionsBuilder: (context, controller) {
                      return [
                        const Center(
                          child: Text('No search history.',
                              style: TextStyle(color: Colors.grey)),
                        )
                      ];
                    },
                  ),
                ),
              ),
        actions: [
          _select
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      products.map((e) => e.selected = false).toList();
                      _select = false;
                    });
                  },
                  child: const Text(
                    "Batalkan",
                    style: TextStyle(color: Colors.white),
                  ))
              : Container()
        ],
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
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
                    Navigator.of(context).push(_goPage(1));
                  },
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
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
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Atur Tampilan"),
                                  DropdownButton(
                                    icon: const Icon(Icons.window_outlined),
                                    items: const [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text("Tampilan Baris")),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text("Tampilan Kolom")),
                                    ],
                                    onChanged: (value) {
                                      setView(value!);
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: SizedBox(
                              height: double.infinity,
                              child: row
                                  ? ListView.builder(
                                      padding:
                                          const EdgeInsets.only(bottom: 80),
                                      itemCount: products.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onLongPress: () {},
                                          child: SizedBox(
                                            height: 115,
                                            child: Card(
                                                surfaceTintColor: Colors.white,
                                                clipBehavior: Clip.antiAlias,
                                                elevation: 3,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: Dismissible(
                                                  key: Key(products[index]
                                                      .id
                                                      .toString()),
                                                  direction: DismissDirection
                                                      .endToStart,
                                                  confirmDismiss:
                                                      (direction) async {
                                                    final details =
                                                        await Future.delayed(
                                                      const Duration(
                                                          seconds: 5),
                                                      () {
                                                        null;
                                                      },
                                                    );

                                                    return details != null;
                                                  },
                                                  background: Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black12,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Wrap(
                                                      direction:
                                                          Axis.horizontal,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(_toEditProduct(
                                                                      products[
                                                                          index]));
                                                            },
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.green,
                                                              size: 40,
                                                            )),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        IconButton(
                                                            onPressed: () {
                                                              openDeleteProduct(
                                                                  context, [
                                                                products[index]
                                                                    .id
                                                              ]);
                                                            },
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 40,
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 80,
                                                          height: 80,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: products[index]
                                                                      .foto !=
                                                                  null
                                                              ? Image.network(
                                                                  "$url/storage/img/${products[index].foto}",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.asset(
                                                                  "assets/img/food.png",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                      child:
                                                                          Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        products[index]
                                                                            .namaProduk,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            overflow: TextOverflow.ellipsis),
                                                                      ),
                                                                      Text(
                                                                        "Rp.${products[index].harga}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  )),
                                                                  user.isNotEmpty &&
                                                                          user['role'] ==
                                                                              'admin'
                                                                      ? GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            _openOptionProduct(context,
                                                                                products[index]);
                                                                          },
                                                                          child:
                                                                              const Icon(Icons.menu),
                                                                        )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  order.isNotEmpty &&
                                                                          order
                                                                              .where((element) => element['id'] == index)
                                                                              .isNotEmpty
                                                                      ? Row(
                                                                          children: [
                                                                            IconButton(
                                                                              onPressed: () {
                                                                                _decrement(context, index);
                                                                              },
                                                                              icon: const Icon(Icons.remove),
                                                                            ),
                                                                            Text(
                                                                              order.firstWhere((element) => element['id'] == index)['qty'].toString(),
                                                                              style: const TextStyle(fontSize: 20),
                                                                            ),
                                                                            IconButton(
                                                                              onPressed: () {
                                                                                _increment(context, index);
                                                                              },
                                                                              icon: const Icon(Icons.add),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : FilledButton(
                                                                          style:
                                                                              const ButtonStyle(surfaceTintColor: MaterialStatePropertyAll(Colors.orange)),
                                                                          onPressed:
                                                                              () {
                                                                            _addOrder(context,
                                                                                index);
                                                                          },
                                                                          child:
                                                                              const Text("Tambah"),
                                                                        )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        );
                                      },
                                    )
                                  : GridView.builder(
                                      itemCount: products.length,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, bottom: 80),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              mainAxisExtent: 240,
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            setState(() {
                                              vibrateDevices();
                                              products[index].selected = true;
                                              _select = true;
                                              if (products.every((element) =>
                                                  element.selected)) {
                                                _selectAll = true;
                                              }
                                            });
                                            _openOptionProduct(
                                                context, products[index]);
                                          },
                                          onTap: () {
                                            if (products.any((element) =>
                                                    element.selected) ||
                                                _select) {
                                              if (products[index].selected) {
                                                setState(() {
                                                  products[index].selected =
                                                      false;
                                                  _selectAll = false;
                                                });
                                              } else {
                                                setState(() {
                                                  products[index].selected =
                                                      true;
                                                  if (products.every(
                                                      (element) =>
                                                          element.selected)) {
                                                    _selectAll = true;
                                                  }
                                                });
                                              }
                                            }
                                          },
                                          child: Card(
                                            surfaceTintColor:
                                                products[index].selected
                                                    ? const Color.fromARGB(
                                                        96, 197, 30, 30)
                                                    : Colors.white,
                                            elevation: 4,
                                            clipBehavior: Clip.antiAlias,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                      height: 100,
                                                      child: Center(
                                                        child: products[index]
                                                                    .foto !=
                                                                null
                                                            ? Image.network(
                                                                "$url/storage/img/${products[index].foto}",
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.asset(
                                                                "assets/img/food.png",
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(products[index]
                                                          .namaProduk),
                                                      Text(
                                                        "Rp.${products[index].harga.toString()}",
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      order.isNotEmpty &&
                                                              order
                                                                  .where((element) =>
                                                                      element[
                                                                          'id'] ==
                                                                      index)
                                                                  .isNotEmpty
                                                          ? Expanded(
                                                              child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    _decrement(
                                                                        context,
                                                                        index);
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .remove),
                                                                ),
                                                                Text(
                                                                  order
                                                                      .firstWhere(
                                                                          (element) =>
                                                                              element['id'] ==
                                                                              index)[
                                                                          'qty']
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    _increment(
                                                                        context,
                                                                        index);
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .add),
                                                                ),
                                                              ],
                                                            ))
                                                          : Expanded(
                                                              child: SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child:
                                                                  FilledButton(
                                                                      style: const ButtonStyle(
                                                                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(
                                                                                  5)))),
                                                                          backgroundColor: MaterialStatePropertyAll(Colors
                                                                              .orange),
                                                                          foregroundColor: MaterialStatePropertyAll(Colors
                                                                              .white)),
                                                                      onPressed:
                                                                          () {
                                                                        if (!products[index]
                                                                            .selected) {
                                                                          _addOrder(
                                                                              context,
                                                                              index);
                                                                        }
                                                                        return;
                                                                      },
                                                                      child: const Text(
                                                                          "Tambah")),
                                                            ))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ))
                          ],
                        ))
                    : const Center(
                        child: CircularProgressIndicator(
                        color: Colors.orange,
                      )),
              ),
              Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(_goPage(8));
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      surfaceTintColor: Colors.white,
                                      elevation: 4,
                                      child: ListTile(
                                        title:
                                            Text(category[index]['kategori']),
                                        trailing: GestureDetector(
                                          onTap: () {
                                            _openOptionCategory(
                                                context, category[index]);
                                          },
                                          child: const Icon(Icons.menu),
                                        ),
                                      ),
                                    ),
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
      ),
    );
  }
}
