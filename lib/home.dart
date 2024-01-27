import 'package:flutter/material.dart';
import 'components/banners.dart';

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
    Banners(text: "Sunda Food"),
    Banners(text: "Sunda Food"),
    Banners(text: "Sunda Food")
  ];

  List<WidgetIcon> icon = [
    WidgetIcon(icon: Icons.shop, label: "Product"),
    WidgetIcon(icon: Icons.people, label: "Employee")
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 150,
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
                ));
          },
        ),
      )
    ]);
  }
}
