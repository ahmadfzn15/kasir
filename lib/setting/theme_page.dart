import 'package:flutter/material.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeys,
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  setState(() {
                    darkMode = !darkMode;
                  });
                },
                hoverColor: Colors.white12,
                title: const Text("Dark Mode"),
                trailing: Switch(
                  activeColor: Colors.blue,
                  value: darkMode,
                  onChanged: (value) {
                    setState(() {
                      darkMode = !darkMode;
                    });
                  },
                ),
              ),
              const Divider(color: Color(0xFFcbd5e1))
            ],
          )),
    );
  }
}
