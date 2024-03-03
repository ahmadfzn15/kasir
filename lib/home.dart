import 'dart:convert';

import 'package:app/components/banners.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WidgetIcon {
  IconData icon;
  String label;

  WidgetIcon({required this.icon, required this.label});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> page = const [
    Banners(img: "assets/img/french-fries.jpeg"),
    Banners(img: "assets/img/sprite.jpg"),
    Banners(img: "assets/img/burger.jpeg")
  ];

  List<WidgetIcon> icon = [
    WidgetIcon(icon: Icons.shopping_bag_outlined, label: "Produk"),
    WidgetIcon(icon: Icons.people_outline, label: "Karyawan"),
    WidgetIcon(icon: Icons.shop_outlined, label: "Toko"),
    WidgetIcon(icon: Icons.headset_mic_outlined, label: "Bantuan")
  ];

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RefreshIndicator(
          onRefresh: () {
            return _refresh();
          },
          child: Column(children: [
            SizedBox(
                height: 200,
                child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: page.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return page[index];
                    })),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 300,
              child: GridView.builder(
                itemCount: icon.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 5, mainAxisSpacing: 5),
                itemBuilder: (context, index) {
                  return Card(
                      elevation: 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon[index].icon,
                              color: Colors.orange, size: 30),
                          const SizedBox(height: 4),
                          Text(
                            icon[index].label,
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ));
                },
              ),
            )
          ])),
    );
  }
}
