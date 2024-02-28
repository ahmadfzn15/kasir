import 'package:app/sublayout.dart';
import 'package:flutter/material.dart';

Route _goPage(int id, int? idProduk) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Sublayout(
      id: id,
    ),
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

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  List<String> list = ["Akun", "Tampilan"];
  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();

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
                  Navigator.of(context).push(_goPage(3, null));
                },
                hoverColor: Colors.white12,
                title: const Text("Akun"),
                trailing: const Icon(Icons.chevron_right,
                    size: 35, color: Colors.orange),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(_goPage(4, null));
                },
                hoverColor: Colors.white12,
                title: const Text("Tampilan"),
                trailing: const Icon(Icons.chevron_right,
                    size: 35, color: Colors.orange),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(_goPage(5, null));
                },
                hoverColor: Colors.white12,
                title: const Text("Toko"),
                trailing: const Icon(Icons.chevron_right,
                    size: 35, color: Colors.orange),
              ),
              const Divider()
            ],
          )),
    );
  }
}
