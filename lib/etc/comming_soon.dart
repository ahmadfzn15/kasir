import 'package:flutter/material.dart';

class CommingSoon extends StatefulWidget {
  const CommingSoon({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CommingSoonState createState() => _CommingSoonState();
}

class _CommingSoonState extends State<CommingSoon> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Image.asset("assets/img/comming_soon.png"));
  }
}
