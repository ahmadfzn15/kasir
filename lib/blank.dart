import 'package:flutter/material.dart';

class Blank extends StatefulWidget {
  const Blank({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BlankState createState() => _BlankState();
}

class _BlankState extends State<Blank> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Hello World"));
  }
}
