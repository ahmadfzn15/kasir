import 'package:app/setting/account.dart';
import 'package:app/setting/setting_page.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          children: [
            SettingPage(pageController: _pageController),
            Account(pageController: _pageController),
          ]),
    );
  }
}
