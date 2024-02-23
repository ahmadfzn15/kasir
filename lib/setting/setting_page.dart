import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.pageController});
  final PageController pageController;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<String> list = ["Akun", "Tampilan"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                widget.pageController.animateToPage(index + 1,
                    duration: const Duration(seconds: 300),
                    curve: Curves.easeInOutExpo);
              },
              hoverColor: Colors.white12,
              title: Text(list[index]),
              trailing: const Icon(Icons.chevron_right,
                  size: 35, color: Colors.orange),
            );
          },
        ),
      ),
    );
  }
}
