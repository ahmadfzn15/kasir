import 'package:flutter/material.dart';

class Banners extends StatelessWidget {
  const Banners({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(20),
        elevation: 5,
        surfaceTintColor: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(text),
          ),
        ));
  }
}
