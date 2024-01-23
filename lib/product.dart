import 'dart:js_util';

import 'package:app/models/products.dart';
import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key, required this.title});
  final String title;

  @override
  State<Product> createState() => _ProductState();
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
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                products: products[index],
                onIncrement: () {
                  products[index].qty++;
                },
                onDecrement: () {
                  products[index].qty--;
                },
              );
            },
          ),
        ),
      ],
    );
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
