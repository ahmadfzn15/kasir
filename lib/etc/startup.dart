import 'package:flutter/material.dart';

class Startup extends StatelessWidget {
  const Startup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: Center(
        child: SizedBox(
            width: 160,
            height: 80,
            child: Image.asset(
              "assets/img/logo.png",
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}
