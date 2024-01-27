import 'package:app/add_product.dart';
import 'package:app/notifications.dart';
import 'package:app/profile.dart';
import 'package:flutter/material.dart';

class Sublayout extends StatefulWidget {
  const Sublayout({super.key, required this.id});
  final int id;

  @override
  // ignore: library_private_types_in_public_api
  _SublayoutState createState() => _SublayoutState();
}

class Pages {
  Widget page;
  String title;
  Widget? action;

  Pages({required this.page, required this.title, this.action});
}

class _SublayoutState extends State<Sublayout> {
  List<Pages> page = [
    Pages(page: const Notifications(), title: "Notification"),
    Pages(page: const Profile(), title: "Profile"),
    Pages(page: const AddProduct(), title: "Add Product"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 2,
        title: Text(
          page[widget.id].title,
        ),
        leading: GestureDetector(
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
              )),
        ),
      ),
      body: page[widget.id].page,
    );
  }
}
