import 'package:app/product.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> page = const [
    Product(title: "Sunda Food"),
    Product(title: "Sunda Food"),
    Product(title: "Sunda Food")
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: page.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return page[index];
        });
  }
}
