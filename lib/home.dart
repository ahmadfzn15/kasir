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
    WidgetIcon(icon: Icons.shopping_bag, label: "Products"),
    WidgetIcon(icon: Icons.people, label: "Employee")
  ];

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(
      Uri.parse("https://102a-36-74-40-162.ngrok-free.app"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data.');
    }
  }

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
              return GestureDetector(
                onTap: () {
                  showBottomSheet(
                    elevation: 10,
                    constraints: const BoxConstraints(maxWidth: 640),
                    context: context,
                    builder: (context) {
                      return const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Burger"), Text("Rp.10.0000")],
                        ),
                      );
                    },
                  );
                },
                child: Card(
                    surfaceTintColor: const Color.fromRGBO(255, 255, 255, 1),
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon[index].icon, color: Colors.orange, size: 40),
                        const SizedBox(height: 5),
                        Text(
                          icon[index].label,
                        )
                      ],
                    )),
              );
            },
          ),
        )
      ]),
    );
  }
}
