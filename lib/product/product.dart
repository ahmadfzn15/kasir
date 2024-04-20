import 'package:app/etc/format_number.dart';
import 'package:app/models/category_controller.dart';
import 'package:app/models/order_controller.dart';
import 'package:app/models/product_controller.dart';
import 'package:app/order/checkout.dart';
import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:app/product/edit_category.dart';
import 'package:app/product/edit_product.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/sublayout.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

Route _goPage(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
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
  final TextEditingController _search = TextEditingController();
  final categoryController = Get.put(CategoryController());
  final orderController = Get.put(OrderController());
  final productController = Get.put(ProductController());
  List<Map<String, dynamic>> filterCategory = [];
  String _selectedCategory = "Semua Kategori";
  int _selectedCategoryId = 0;
  Map<String, dynamic> user = {};
  String url = dotenv.env['API_URL']!;
  bool row = true;
  bool loadingProduct = true;
  bool loadingCategory = true;

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
        duration: 100,
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
    await productController.fetchDataProduct(categoryId: _selectedCategoryId);
    setState(() {
      loadingProduct = false;
    });
  }

  Future<void> fetchDataCategory() async {
    await categoryController.fetchDataCategory();
    var res = categoryController.category;

    setState(() {
      filterCategory.clear();

      filterCategory = [
        {"id": 0, "kategori": "Semua Kategori"}
      ];
      for (var element in res) {
        filterCategory.add({
          "id": element['id'],
          "kategori": element['kategori'],
        });
      }
    });
    setState(() {
      loadingCategory = false;
    });
  }

  Future<void> _handleRefresh() async {
    await fetchDataProduct();
    await fetchDataCategory();
    setState(() {
      orderController.sheetOrderOpen.value = false;
      orderController.order.clear();
      productController.searchResult
          .map((e) => e.selected.value = false)
          .toList();
      productController.select.value = false;
    });
    // ignore: use_build_context_synchronously
    await Navigator.maybePop(context);
  }

  void showSheetOrder() {
    if (orderController.sheetOrderOpen.value) {
      showBottomSheet(
        backgroundColor: Colors.white,
        elevation: 5,
        enableDrag: false,
        context: context,
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
              child: ListTile(
                leading: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    IconButton(
                        onPressed: () {
                          orderController.sheetOrderOpen.value = false;
                          Navigator.pop(context);
                          orderController.order.clear();
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                            "Total (${orderController.order.fold(0, (previousValue, element) => previousValue + (element.qty.value))})",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold))),
                        const SizedBox(
                          height: 3,
                        ),
                        Obx(() => Text(
                              "Rp.${formatNumber(orderController.order.fold(0, (previousValue, element) => previousValue + (element.harga * (element.qty.value))))}",
                              style: const TextStyle(fontSize: 13),
                            ))
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
                      Navigator.of(context).push(
                          _goPage(Checkout(order: orderController.order)));
                    },
                    child: const Text("Lanjut")),
              ));
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _openOptionProduct(BuildContext context) {
    showBottomSheet(
      constraints: const BoxConstraints(maxHeight: 80),
      context: context,
      enableDrag: false,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() => Row(
                mainAxisAlignment: productController.searchResult
                            .where((element) => element.selected.value == true)
                            .length <=
                        1
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  productController.searchResult
                              .where(
                                  (element) => element.selected.value == true)
                              .length <=
                          1
                      ? TextButton(
                          style: const ButtonStyle(
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.black),
                              padding: MaterialStatePropertyAll(
                                  EdgeInsets.symmetric(vertical: 0))),
                          onPressed: () {
                            if (productController.searchResult
                                .where(
                                    (element) => element.selected.value == true)
                                .isNotEmpty) {
                              Navigator.of(context).push(_goPage(EditProduct(
                                  product: productController.searchResult
                                      .where(
                                          (element) => element.selected.value)
                                      .first)));
                            }
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
                  TextButton(
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.red),
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 0))),
                    onPressed: () {
                      if (productController.searchResult
                          .where((element) => element.selected.value == true)
                          .isNotEmpty) {
                        openDeleteProduct(
                            context,
                            productController.searchResult
                                .where((element) => element.selected.value)
                                .map((e) => e.id)
                                .toList());
                      }
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
              )),
        );
      },
    );
  }

  void _openOptionCategory(
      BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxHeight: 110),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.black),
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 0))),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .push(_goPage(EditCategory(category: category)));
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
                  )),
              TextButton(
                  style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.red),
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 0))),
                  onPressed: () {
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
                  )),
            ],
          ),
        );
      },
    );
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
                  productController.deleteProduct(context, id);
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
                  categoryController.deleteCategory(context, id);
                },
                child: const Text("Yes"))
          ]),
    );
  }

  void scanBarcode() async {
    final res = await BarcodeScanner.scan();
    if (res.rawContent.isNotEmpty) {
      var product = productController.searchResult
          .where(
            (element) => element.barcode != null
                ? element.barcode! == res.rawContent
                : false,
          )
          .toList();

      final notif = AudioPlayer();
      if (product.isNotEmpty) {
        await notif.play(AssetSource("sound/beep.mp3"));
        await notif.setVolume(1.0);

        bool? hasVibration = await Vibration.hasVibrator();
        if (hasVibration!) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 100,
          );
        }

        if (orderController.order
            .where((element) => element.id == product.first.id)
            .isEmpty) {
          if (orderController.order.isEmpty) {
            orderController.addOrder(product.first);
            orderController.sheetOrderOpen.value = true;
            showSheetOrder();
          } else {
            orderController.addOrder(product.first);
          }
        } else {
          orderController.incrementOrder(product.first.id);
        }
      } else {
        await notif.play(AssetSource("sound/error.mp3"));
        await notif.setVolume(1.0);

        bool? hasVibration = await Vibration.hasVibrator();
        if (hasVibration!) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 100,
          );
        }
        // ignore: use_build_context_synchronously
        Popup().show(
            // ignore: use_build_context_synchronously
            context,
            "Produk belum didaftarkan, silahkan daftarkan terlebih dahulu!",
            false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f5f9),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() => AppBar(
                leadingWidth: productController.select.value ? 150 : 50,
                leading: productController.select.value
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: productController.selectAll.value,
                            checkColor: Colors.orange,
                            fillColor:
                                const MaterialStatePropertyAll(Colors.white),
                            onChanged: (value) {
                              if (productController.selectAll.value) {
                                productController.searchResult
                                    .map((e) => e.selected.value = false)
                                    .toList();
                              } else {
                                productController.searchResult
                                    .map((e) => e.selected.value = true)
                                    .toList();
                              }
                              setState(() {
                                productController.selectAll.value = value!;
                              });
                            },
                          ),
                          const Text("Pilih Semua")
                        ],
                      )
                    : IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(Icons.menu)),
                title: productController.select.value
                    ? Text(
                        "${productController.searchResult.where((element) => element.selected.value).length} Dipilih")
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: SizedBox(
                              height: 45,
                              child: CupertinoTextField(
                                controller: _search,
                                prefix: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                onChanged: (value) {
                                  productController.searchProduct(value);
                                },
                                placeholder: "Cari Produk",
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            )),
                            user['role'] == 'admin'
                                ? IconButton(
                                    onPressed: () {
                                      scanBarcode();
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.barcode_viewfinder,
                                      size: 35,
                                    ))
                                : Container()
                          ],
                        ),
                      ),
                actions: [
                  productController.select.value
                      ? TextButton(
                          onPressed: () async {
                            productController.searchResult
                                .map((e) => e.selected.value = false)
                                .toList();
                            productController.select.value = false;
                            await Navigator.maybePop(context);
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
              ))),
      body: user.isNotEmpty
          ? user['role'] == 'admin'
              ? DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: AppBar(
                          bottom: TabBar(
                            tabs: [
                              Tab(
                                  child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "Produk",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Chip(
                                    label: Text(productController
                                        .searchResult.length
                                        .toString()),
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    padding: const EdgeInsets.all(5),
                                    shape: const CircleBorder(eccentricity: 0),
                                    labelPadding: const EdgeInsets.all(0),
                                    color: const MaterialStatePropertyAll(
                                        Colors.orange),
                                  )
                                ],
                              )),
                              Tab(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      "Kategori",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Chip(
                                      label: Text(categoryController
                                          .category.length
                                          .toString()),
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      padding: const EdgeInsets.all(5),
                                      shape:
                                          const CircleBorder(eccentricity: 0),
                                      labelPadding: const EdgeInsets.all(0),
                                      color: const MaterialStatePropertyAll(
                                          Colors.orange),
                                    )
                                  ],
                                ),
                              ),
                            ],
                            indicatorSize: TabBarIndicatorSize.tab,
                            padding: EdgeInsets.zero,
                            tabAlignment: TabAlignment.fill,
                            splashBorderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                        )),
                    body: TabBarView(children: [
                      Scaffold(
                        backgroundColor: const Color(0xFFf1f5f9),
                        floatingActionButton: Obx(() => Container(
                              margin: EdgeInsets.only(
                                  bottom: orderController.sheetOrderOpen.value
                                      ? 70
                                      : 0),
                              child: FloatingActionButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(_goPage(const Sublayout(
                                    id: 1,
                                  )));
                                },
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(eccentricity: 0),
                                child: const Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            )),
                        body: !loadingProduct
                            ? GetBuilder<ProductController>(
                                builder: (controller) {
                                  return RefreshIndicator(
                                      onRefresh: _handleRefresh,
                                      color: Colors.orange,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                MenuAnchor(
                                                    builder: (context,
                                                        controller, child) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          if (controller
                                                              .isOpen) {
                                                            controller.close();
                                                          } else {
                                                            controller.open();
                                                          }
                                                        },
                                                        child: Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          direction:
                                                              Axis.horizontal,
                                                          children: [
                                                            Text(
                                                              _selectedCategory,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const Icon(Icons
                                                                .chevron_right),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    menuChildren: filterCategory
                                                        .map((e) =>
                                                            MenuItemButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _selectedCategory =
                                                                      e['kategori'];
                                                                  _selectedCategoryId =
                                                                      e['id'];
                                                                });
                                                                fetchDataProduct();
                                                              },
                                                              child: Text(e[
                                                                  'kategori']),
                                                            ))
                                                        .toList()),
                                                MenuAnchor(
                                                    builder: (context,
                                                        controller, child) {
                                                      return IconButton(
                                                        onPressed: () {
                                                          if (controller
                                                              .isOpen) {
                                                            controller.close();
                                                          } else {
                                                            controller.open();
                                                          }
                                                        },
                                                        icon: const Icon(Icons
                                                            .window_outlined),
                                                      );
                                                    },
                                                    menuChildren: [
                                                      MenuItemButton(
                                                          onPressed: () {
                                                            setView(true);
                                                          },
                                                          child: const Text(
                                                              "Tampilan Baris")),
                                                      MenuItemButton(
                                                          onPressed: () {
                                                            setView(false);
                                                          },
                                                          child: const Text(
                                                              "Tampilan Kolom"))
                                                    ]),
                                              ],
                                            ),
                                          ),
                                          productController
                                                  .searchResult.isNotEmpty
                                              ? Expanded(
                                                  child: SizedBox(
                                                  height: double.infinity,
                                                  child: row
                                                      ? ListView.builder(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 80),
                                                          itemCount:
                                                              productController
                                                                  .searchResult
                                                                  .length,
                                                          shrinkWrap: true,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return GestureDetector(
                                                              onLongPress: () {
                                                                setState(() {
                                                                  vibrateDevices();
                                                                  productController
                                                                      .searchResult[
                                                                          index]
                                                                      .selected
                                                                      .value = true;
                                                                  productController
                                                                          .select
                                                                          .value =
                                                                      true;
                                                                  if (productController
                                                                      .searchResult
                                                                      .every((element) => element
                                                                          .selected
                                                                          .value)) {
                                                                    productController
                                                                        .selectAll
                                                                        .value = true;
                                                                  }
                                                                });
                                                                _openOptionProduct(
                                                                    context);
                                                              },
                                                              onTap: () {
                                                                if (productController
                                                                        .searchResult
                                                                        .any((element) => element
                                                                            .selected
                                                                            .value) ||
                                                                    productController
                                                                        .select
                                                                        .value) {
                                                                  setState(() {
                                                                    if (productController
                                                                        .searchResult[
                                                                            index]
                                                                        .selected
                                                                        .value) {
                                                                      productController
                                                                          .searchResult[
                                                                              index]
                                                                          .selected
                                                                          .value = false;
                                                                      productController
                                                                          .selectAll
                                                                          .value = false;
                                                                    } else {
                                                                      productController
                                                                          .searchResult[
                                                                              index]
                                                                          .selected
                                                                          .value = true;
                                                                      if (productController
                                                                          .searchResult
                                                                          .every((element) => element
                                                                              .selected
                                                                              .value)) {
                                                                        productController
                                                                            .selectAll
                                                                            .value = true;
                                                                      }
                                                                    }
                                                                  });
                                                                }
                                                              },
                                                              child: SizedBox(
                                                                height: 115,
                                                                child: Obx(() =>
                                                                    Card(
                                                                        color: productController.searchResult[index].selected.value
                                                                            ? const Color(
                                                                                0xFF94a3b8)
                                                                            : Colors
                                                                                .white,
                                                                        surfaceTintColor:
                                                                            Colors
                                                                                .white,
                                                                        clipBehavior:
                                                                            Clip
                                                                                .antiAlias,
                                                                        elevation:
                                                                            3,
                                                                        margin: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                5),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10),
                                                                          child:
                                                                              Stack(
                                                                            alignment:
                                                                                Alignment.topLeft,
                                                                            children: [
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 80,
                                                                                    height: 80,
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                    ),
                                                                                    child: productController.searchResult[index].foto != null
                                                                                        ? Image.network(
                                                                                            "$url/storage/img/${productController.searchResult[index].foto}",
                                                                                            fit: BoxFit.cover,
                                                                                          )
                                                                                        : Image.asset(
                                                                                            "assets/img/food.png",
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                  ),
                                                                                  const SizedBox(width: 10),
                                                                                  Expanded(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Flexible(
                                                                                                child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text(
                                                                                                  productController.searchResult[index].namaProduk,
                                                                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                                                                                                ),
                                                                                                Text(
                                                                                                  "Rp.${formatNumber(productController.searchResult[index].harga_jual)}",
                                                                                                  style: const TextStyle(fontSize: 12),
                                                                                                ),
                                                                                              ],
                                                                                            )),
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                                          children: [
                                                                                            productController.searchResult[index].stok != null ? Text(productController.searchResult[index].stok != 0 ? "Stok : ${productController.searchResult[index].stok}" : "Stok Habis") : Container(),
                                                                                            orderController.order.isNotEmpty && orderController.order.where((element) => element.id == productController.searchResult[index].id).isNotEmpty
                                                                                                ? Row(
                                                                                                    children: [
                                                                                                      IconButton(
                                                                                                        onPressed: () {
                                                                                                          orderController.decrementOrder(productController.searchResult[index].id);
                                                                                                          if (orderController.order.isEmpty) {
                                                                                                            showSheetOrder();
                                                                                                          }
                                                                                                        },
                                                                                                        icon: const Icon(Icons.remove),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        orderController.order.firstWhere((element) => element.id == productController.searchResult[index].id).qty.toString(),
                                                                                                        style: const TextStyle(fontSize: 20),
                                                                                                      ),
                                                                                                      IconButton(
                                                                                                        onPressed: () {
                                                                                                          orderController.incrementOrder(productController.searchResult[index].id);
                                                                                                        },
                                                                                                        icon: const Icon(Icons.add),
                                                                                                      ),
                                                                                                    ],
                                                                                                  )
                                                                                                : CupertinoButton(
                                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                                    color: productController.searchResult[index].stok != 0 ? Colors.orange : Colors.orange.shade200,
                                                                                                    onPressed: () {
                                                                                                      if (!productController.searchResult[index].selected.value && productController.searchResult[index].stok != 0) {
                                                                                                        if (!orderController.sheetOrderOpen.value) {
                                                                                                          orderController.sheetOrderOpen.value = true;
                                                                                                          showSheetOrder();
                                                                                                        }
                                                                                                        orderController.addOrder(productController.searchResult[index]);
                                                                                                      }
                                                                                                    },
                                                                                                    child: const Text("Tambah"),
                                                                                                  )
                                                                                          ],
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              productController.select.value
                                                                                  ? productController.searchResult[index].selected.value
                                                                                      ? const Icon(
                                                                                          Icons.check_circle,
                                                                                          color: Colors.white,
                                                                                        )
                                                                                      : const Icon(
                                                                                          Icons.circle_outlined,
                                                                                          color: Colors.white,
                                                                                        )
                                                                                  : Container()
                                                                            ],
                                                                          ),
                                                                        ))),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : GridView.builder(
                                                          itemCount:
                                                              productController
                                                                  .searchResult
                                                                  .length,
                                                          shrinkWrap: true,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  bottom: 80),
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                            mainAxisExtent: 255,
                                                            crossAxisCount: 2,
                                                            crossAxisSpacing: 5,
                                                            mainAxisSpacing: 5,
                                                          ),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return GestureDetector(
                                                              onLongPress: () {
                                                                setState(() {
                                                                  vibrateDevices();
                                                                  productController
                                                                      .searchResult[
                                                                          index]
                                                                      .selected
                                                                      .value = true;
                                                                  productController
                                                                          .select
                                                                          .value =
                                                                      true;
                                                                  if (productController
                                                                      .searchResult
                                                                      .every((element) => element
                                                                          .selected
                                                                          .value)) {
                                                                    productController
                                                                        .selectAll
                                                                        .value = true;
                                                                  }
                                                                });
                                                                _openOptionProduct(
                                                                  context,
                                                                );
                                                              },
                                                              onTap: () {
                                                                if (productController
                                                                        .searchResult
                                                                        .any((element) => element
                                                                            .selected
                                                                            .value) ||
                                                                    productController
                                                                        .select
                                                                        .value) {
                                                                  setState(() {
                                                                    if (productController
                                                                        .searchResult[
                                                                            index]
                                                                        .selected
                                                                        .value) {
                                                                      productController
                                                                          .searchResult[
                                                                              index]
                                                                          .selected
                                                                          .value = false;
                                                                      productController
                                                                          .selectAll
                                                                          .value = false;
                                                                    } else {
                                                                      productController
                                                                          .searchResult[
                                                                              index]
                                                                          .selected
                                                                          .value = true;
                                                                      if (productController
                                                                          .searchResult
                                                                          .every((element) => element
                                                                              .selected
                                                                              .value)) {
                                                                        productController
                                                                            .selectAll
                                                                            .value = true;
                                                                      }
                                                                    }
                                                                  });
                                                                }
                                                              },
                                                              child:
                                                                  Obx(
                                                                      () =>
                                                                          Card(
                                                                            color: productController.searchResult[index].selected.value
                                                                                ? const Color(0xFF94a3b8)
                                                                                : Colors.white,
                                                                            surfaceTintColor:
                                                                                Colors.white,
                                                                            elevation:
                                                                                3,
                                                                            clipBehavior:
                                                                                Clip.antiAlias,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: Stack(
                                                                                alignment: Alignment.topLeft,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        height: 100,
                                                                                        child: Center(
                                                                                          child: productController.searchResult[index].foto != null
                                                                                              ? Image.network(
                                                                                                  "$url/storage/img/${productController.searchResult[index].foto}",
                                                                                                  fit: BoxFit.cover,
                                                                                                )
                                                                                              : Image.asset(
                                                                                                  "assets/img/food.png",
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(height: 10),
                                                                                      Expanded(
                                                                                          child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              Flexible(
                                                                                                  child: Text(
                                                                                                productController.searchResult[index].namaProduk,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                maxLines: 2,
                                                                                              ))
                                                                                            ],
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Text(
                                                                                                "Rp.${formatNumber(productController.searchResult[index].harga_jual).toString()}",
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                              productController.searchResult[index].stok != null
                                                                                                  ? Text(
                                                                                                      productController.searchResult[index].stok != 0 ? "Stok : ${productController.searchResult[index].stok}" : "Stok Habis",
                                                                                                    )
                                                                                                  : Container(),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      )),
                                                                                      const SizedBox(height: 5),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          orderController.order.isNotEmpty && orderController.order.where((element) => element.id == productController.searchResult[index].id).isNotEmpty
                                                                                              ? Expanded(
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      IconButton(
                                                                                                        onPressed: () {
                                                                                                          orderController.decrementOrder(productController.searchResult[index].id);
                                                                                                          if (orderController.order.isEmpty) {
                                                                                                            showSheetOrder();
                                                                                                          }
                                                                                                        },
                                                                                                        icon: const Icon(Icons.remove),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        orderController.order.firstWhere((element) => element.id == productController.searchResult[index].id).qty.toString(),
                                                                                                        style: const TextStyle(fontSize: 20),
                                                                                                      ),
                                                                                                      IconButton(
                                                                                                        onPressed: () {
                                                                                                          orderController.incrementOrder(productController.searchResult[index].id);
                                                                                                        },
                                                                                                        icon: const Icon(Icons.add),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              : Expanded(
                                                                                                  child: SizedBox(
                                                                                                    width: double.infinity,
                                                                                                    child: FilledButton(
                                                                                                      style: ButtonStyle(shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))), backgroundColor: MaterialStatePropertyAll(productController.searchResult[index].stok != 0 ? Colors.orange : Colors.orange.shade200), foregroundColor: const MaterialStatePropertyAll(Colors.white)),
                                                                                                      onPressed: () {
                                                                                                        if (!productController.searchResult[index].selected.value && productController.searchResult[index].stok != 0) {
                                                                                                          if (!orderController.sheetOrderOpen.value) {
                                                                                                            orderController.sheetOrderOpen.value = true;
                                                                                                            showSheetOrder();
                                                                                                          }
                                                                                                          orderController.addOrder(productController.searchResult[index]);
                                                                                                        }
                                                                                                      },
                                                                                                      child: const Text("Tambah"),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  productController.select.value
                                                                                      ? productController.searchResult[index].selected.value
                                                                                          ? const Icon(
                                                                                              Icons.check_circle,
                                                                                              color: Colors.white,
                                                                                            )
                                                                                          : const Icon(
                                                                                              Icons.circle_outlined,
                                                                                              color: Colors.white,
                                                                                            )
                                                                                      : Container()
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )),
                                                            );
                                                          },
                                                        ),
                                                ))
                                              : const Expanded(
                                                  child: SizedBox(
                                                  child: Center(
                                                      child:
                                                          Text("Data kosong")),
                                                ))
                                        ],
                                      ));
                                },
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                color: Colors.orange,
                              )),
                      ),
                      Scaffold(
                          backgroundColor: const Color(0xFFf1f5f9),
                          floatingActionButton: Obx(() => Container(
                                margin: EdgeInsets.only(
                                    bottom: orderController.sheetOrderOpen.value
                                        ? 70
                                        : 0),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(_goPage(const Sublayout(id: 8)));
                                  },
                                  tooltip: "Add Captegory",
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: const CircleBorder(eccentricity: 0),
                                  child: const Icon(
                                    Icons.add,
                                    size: 30,
                                  ),
                                ),
                              )),
                          body: !loadingCategory
                              ? GetBuilder<CategoryController>(
                                  builder: (controller) {
                                    return RefreshIndicator(
                                        onRefresh: _handleRefresh,
                                        color: Colors.orange,
                                        child: categoryController
                                                .category.isNotEmpty
                                            ? SizedBox(
                                                height: double.infinity,
                                                child: ListView.builder(
                                                  itemCount: categoryController
                                                      .category.length,
                                                  shrinkWrap: true,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  itemBuilder:
                                                      (context, index) {
                                                    var category =
                                                        categoryController
                                                            .category;
                                                    return Card(
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        title: Text(
                                                            category[index]
                                                                ['kategori']),
                                                        trailing: IconButton(
                                                            onPressed: () {
                                                              _openOptionCategory(
                                                                  context,
                                                                  category[
                                                                      index]);
                                                            },
                                                            icon: const Icon(
                                                                CupertinoIcons
                                                                    .ellipsis_vertical)),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : const SizedBox(
                                                height: double.infinity,
                                                child: Center(
                                                    child:
                                                        Text("Data kosong"))));
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ))),
                    ]),
                  ))
              : Scaffold(
                  backgroundColor: const Color(0xFFf1f5f9),
                  floatingActionButton: Obx(() => Container(
                        margin: EdgeInsets.only(
                            bottom:
                                orderController.sheetOrderOpen.value ? 70 : 0),
                        child: FloatingActionButton(
                          onPressed: () {
                            scanBarcode();
                          },
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(eccentricity: 0),
                          child: const Icon(
                            CupertinoIcons.barcode_viewfinder,
                            size: 30,
                          ),
                        ),
                      )),
                  body: !loadingProduct
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
                                    MenuAnchor(
                                        builder: (context, controller, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (controller.isOpen) {
                                                controller.close();
                                              } else {
                                                controller.open();
                                              }
                                            },
                                            child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              direction: Axis.horizontal,
                                              children: [
                                                Text(_selectedCategory),
                                                const Icon(Icons.chevron_right)
                                              ],
                                            ),
                                          );
                                        },
                                        menuChildren: filterCategory
                                            .map((e) => MenuItemButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedCategory =
                                                          e['kategori'];
                                                      _selectedCategoryId =
                                                          e['id'];
                                                    });
                                                    fetchDataProduct();
                                                  },
                                                  child: Text(e['kategori']),
                                                ))
                                            .toList()),
                                    MenuAnchor(
                                        builder: (context, controller, child) {
                                          return IconButton(
                                            onPressed: () {
                                              if (controller.isOpen) {
                                                controller.close();
                                              } else {
                                                controller.open();
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.window_outlined),
                                          );
                                        },
                                        menuChildren: [
                                          MenuItemButton(
                                              onPressed: () {
                                                setView(true);
                                              },
                                              child:
                                                  const Text("Tampilan Baris")),
                                          MenuItemButton(
                                              onPressed: () {
                                                setView(false);
                                              },
                                              child:
                                                  const Text("Tampilan Kolom"))
                                        ]),
                                  ],
                                ),
                              ),
                              GetBuilder<ProductController>(
                                builder: (controller) {
                                  return productController
                                          .searchResult.isNotEmpty
                                      ? Expanded(
                                          child: SizedBox(
                                          height: double.infinity,
                                          child: row
                                              ? ListView.builder(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 80),
                                                  itemCount: productController
                                                      .searchResult.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                      onLongPress: () {},
                                                      child: SizedBox(
                                                        height: 115,
                                                        child: Card(
                                                            surfaceTintColor:
                                                                Colors.white,
                                                            clipBehavior: Clip
                                                                .antiAlias,
                                                            elevation: 3,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
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
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child: productController.searchResult[index].foto !=
                                                                            null
                                                                        ? Image
                                                                            .network(
                                                                            "$url/storage/img/${productController.searchResult[index].foto}",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            "assets/img/food.png",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                                child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  productController.searchResult[index].namaProduk,
                                                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                                                                                ),
                                                                                Text(
                                                                                  "Rp.${formatNumber(productController.searchResult[index].harga_jual)}",
                                                                                  style: const TextStyle(fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                          ],
                                                                        ),
                                                                        Obx(() =>
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                productController.searchResult[index].stok != null ? Text(productController.searchResult[index].stok != 0 ? "Stok : ${productController.searchResult[index].stok}" : "Stok Habis") : Container(),
                                                                                orderController.order.isNotEmpty && orderController.order.where((element) => element.id == productController.searchResult[index].id).isNotEmpty
                                                                                    ? Row(
                                                                                        children: [
                                                                                          IconButton(
                                                                                            onPressed: () {
                                                                                              orderController.decrementOrder(productController.searchResult[index].id);
                                                                                              if (orderController.order.isEmpty) {
                                                                                                showSheetOrder();
                                                                                              }
                                                                                            },
                                                                                            icon: const Icon(Icons.remove),
                                                                                          ),
                                                                                          Text(
                                                                                            orderController.order.firstWhere((element) => element.id == productController.searchResult[index].id).qty.toString(),
                                                                                            style: const TextStyle(fontSize: 20),
                                                                                          ),
                                                                                          IconButton(
                                                                                            onPressed: () {
                                                                                              orderController.incrementOrder(productController.searchResult[index].id);
                                                                                            },
                                                                                            icon: const Icon(Icons.add),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : CupertinoButton(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                        color: productController.searchResult[index].stok != 0 ? Colors.orange : Colors.orange.shade200,
                                                                                        onPressed: () {
                                                                                          if (!productController.searchResult[index].selected.value && productController.searchResult[index].stok != 0) {
                                                                                            if (!orderController.sheetOrderOpen.value) {
                                                                                              orderController.sheetOrderOpen.value = true;
                                                                                              showSheetOrder();
                                                                                            }
                                                                                            orderController.addOrder(productController.searchResult[index]);
                                                                                          }
                                                                                        },
                                                                                        child: const Text("Tambah"),
                                                                                      )
                                                                              ],
                                                                            ))
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : GridView.builder(
                                                  itemCount: productController
                                                      .searchResult.length,
                                                  shrinkWrap: true,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 80),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                          mainAxisExtent: 240,
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 5,
                                                          mainAxisSpacing: 5),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                      child: Card(
                                                        surfaceTintColor:
                                                            productController
                                                                    .searchResult[
                                                                        index]
                                                                    .selected
                                                                    .value
                                                                ? const Color
                                                                    .fromARGB(
                                                                    96,
                                                                    197,
                                                                    30,
                                                                    30)
                                                                : Colors.white,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        elevation: 3,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                  height: 100,
                                                                  child: Center(
                                                                    child: productController.searchResult[index].foto !=
                                                                            null
                                                                        ? Image
                                                                            .network(
                                                                            "$url/storage/img/${productController.searchResult[index].foto}",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            "assets/img/food.png",
                                                                            fit:
                                                                                BoxFit.cover,
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
                                                                  Text(productController
                                                                      .searchResult[
                                                                          index]
                                                                      .namaProduk),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        "Rp.${formatNumber(productController.searchResult[index].harga_jual).toString()}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      productController.searchResult[index].stok !=
                                                                              null
                                                                          ? Text(productController.searchResult[index].stok != 0
                                                                              ? "Stok : ${productController.searchResult[index].stok}"
                                                                              : "Stok Habis")
                                                                          : Container()
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Obx(() => Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      orderController.order.isNotEmpty &&
                                                                              orderController.order.where((element) => element.id == productController.searchResult[index].id).isNotEmpty
                                                                          ? Expanded(
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      orderController.decrementOrder(productController.searchResult[index].id);
                                                                                      if (orderController.order.isEmpty) {
                                                                                        showSheetOrder();
                                                                                      }
                                                                                    },
                                                                                    icon: const Icon(Icons.remove),
                                                                                  ),
                                                                                  Text(
                                                                                    orderController.order.firstWhere((element) => element.id == productController.searchResult[index].id).qty.toString(),
                                                                                    style: const TextStyle(fontSize: 20),
                                                                                  ),
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      orderController.incrementOrder(productController.searchResult[index].id);
                                                                                    },
                                                                                    icon: const Icon(Icons.add),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : Expanded(
                                                                              child: SizedBox(
                                                                                width: double.infinity,
                                                                                child: FilledButton(
                                                                                  style: ButtonStyle(
                                                                                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                                                                                    backgroundColor: MaterialStatePropertyAll(productController.searchResult[index].stok != 0 ? Colors.orange : Colors.orange.shade200),
                                                                                    foregroundColor: const MaterialStatePropertyAll(Colors.white),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    if (!productController.searchResult[index].selected.value && productController.searchResult[index].stok != 0) {
                                                                                      if (!orderController.sheetOrderOpen.value) {
                                                                                        orderController.sheetOrderOpen.value = true;
                                                                                        showSheetOrder();
                                                                                      }
                                                                                      orderController.addOrder(productController.searchResult[index]);
                                                                                    }
                                                                                  },
                                                                                  child: const Text("Tambah"),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                    ],
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ))
                                      : const Expanded(
                                          child: SizedBox(
                                          child: Center(
                                              child: Text("Data kosong")),
                                        ));
                                },
                              )
                            ],
                          ))
                      : const Center(
                          child: CircularProgressIndicator(
                          color: Colors.orange,
                        )),
                )
          : const Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            )),
    );
  }
}
