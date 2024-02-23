import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key, required this.pageController});
  final PageController pageController;

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  List<String> list = ["Akun", "Tampilan"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: FilledButton(
            onPressed: () {
              widget.pageController.previousPage(
                  duration: const Duration(seconds: 300),
                  curve: Curves.easeInOutExpo);
            },
            child: const Text("Go to previous page."),
          )),
    );
  }
}
