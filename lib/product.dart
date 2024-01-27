import 'package:app/models/products.dart';
import 'package:app/sublayout.dart';
import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key, required this.title});
  final String title;

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

  final List<Products> products = [
    Products(
        img: "assets/img/chicken.jpeg",
        productName: "Fried Chicken",
        price: 8000),
    Products(
        img: "assets/img/burger.jpeg", productName: "Burger", price: 10000),
    Products(
        img: "assets/img/coca-cola.jpeg",
        productName: "Coca Cola",
        price: 7000),
  ];

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
                    Tab(text: "Product"),
                    Tab(text: "Category"),
                  ],
                  padding: EdgeInsets.zero,
                  physics: BouncingScrollPhysics(),
                  tabAlignment: TabAlignment.fill,
                  splashBorderRadius: BorderRadius.all(Radius.circular(10)),
                ))),
            body: TabBarView(
              children: [
                DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(kToolbarHeight),
                          child: AppBar(
                              bottom: const TabBar(
                            tabs: [
                              Tab(text: "Food"),
                              Tab(text: "Drink"),
                              Tab(text: "Snack"),
                            ],
                            isScrollable: true,
                            physics: BouncingScrollPhysics(),
                            tabAlignment: TabAlignment.center,
                            splashBorderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ))),
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
                          )),
                      body: TabBarView(
                        children: [
                          ListView.builder(
                            itemCount: 20,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                subtitle: const Text("Rp.10.000"),
                                leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child:
                                        Image.asset("assets/img/burger.jpeg")),
                                trailing: PopupMenuButton(
                                  tooltip: "Option",
                                  icon: const Icon(Icons.menu),
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                          value: "Edit", child: Text("Edit")),
                                      const PopupMenuItem(
                                          value: "Delete",
                                          child: Text("Delete"))
                                    ];
                                  },
                                ),
                                title: const Text("Burger"),
                              );
                            },
                          ),
                          ListView.builder(
                            itemCount: 20,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                subtitle: const Text("Rp.10.000"),
                                leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child:
                                        Image.asset("assets/img/burger.jpeg")),
                                trailing: PopupMenuButton(
                                  tooltip: "Option",
                                  icon: const Icon(Icons.menu),
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                          value: "Edit", child: Text("Edit")),
                                      const PopupMenuItem(
                                          value: "Delete",
                                          child: Text("Delete"))
                                    ];
                                  },
                                ),
                                title: const Text("Burger"),
                              );
                            },
                          ),
                          ListView.builder(
                            itemCount: 20,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                subtitle: const Text("Rp.10.000"),
                                leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child:
                                        Image.asset("assets/img/burger.jpeg")),
                                trailing: PopupMenuButton(
                                  tooltip: "Option",
                                  icon: const Icon(Icons.menu),
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                          value: "Edit", child: Text("Edit")),
                                      const PopupMenuItem(
                                          value: "Delete",
                                          child: Text("Delete"))
                                    ];
                                  },
                                ),
                                title: const Text("Burger"),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
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
            )));
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard(
      {super.key,
      required this.products,
      required this.onIncrement,
      required this.onDecrement});
  final Products products;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  // ignore: library_private_types_in_public_api
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              horizontalTitleGap: 15,
              leading: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    widget.products.img,
                    fit: BoxFit.cover,
                  )),
              title: Text(widget.products.productName),
              subtitle: Text("Rp.${widget.products.price}"),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    onPressed: () {
                      if (widget.products.qty > 0) {
                        setState(() {
                          widget.onDecrement();
                        });
                      }
                    },
                    icon: const Icon(Icons.remove)),
                Text(widget.products.qty.toString(),
                    style: const TextStyle(fontSize: 20)),
                IconButton(
                    onPressed: () {
                      if (widget.products.qty < widget.products.stock) {
                        setState(() {
                          widget.onIncrement();
                        });
                      }
                    },
                    icon: const Icon(Icons.add)),
              ]),
            ),
          ),
          const Divider(height: 0, thickness: 1, color: Colors.grey)
        ],
      ),
    );
  }
}
