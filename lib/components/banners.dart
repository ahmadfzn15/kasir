import 'package:flutter/material.dart';

class Banners extends StatelessWidget {
  const Banners({super.key, required this.img});
  final String img;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(20),
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            img,
            fit: BoxFit.cover,
          ),
        ));
  }
}
