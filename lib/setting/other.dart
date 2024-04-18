import 'package:app/setting/language.dart';
import 'package:flutter/material.dart';

class Other extends StatefulWidget {
  const Other({super.key});

  @override
  State<Other> createState() => _OtherState();
}

Route _goPage(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOutExpo));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class _OtherState extends State<Other> {
  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  bool vibrate = false;
  bool sound = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeys,
      backgroundColor: const Color(0xFFf1f5f9),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          surfaceTintColor: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, _goPage(const Language()));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hoverColor: Colors.white12,
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 10,
                    leading: const Icon(
                      Icons.language,
                      size: 30,
                    ),
                    title: const Text("Bahasa"),
                    trailing: const Icon(Icons.chevron_right,
                        size: 35, color: Colors.orange),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
