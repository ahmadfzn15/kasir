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

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
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
                  Navigator.of(context).push(_goPage(0, null));
                },
                hoverColor: Colors.white12,
                title: const Text("Profil"),
                trailing: const Icon(Icons.chevron_right,
                    size: 35, color: Colors.orange),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(_goPage(6, null));
                },
                hoverColor: Colors.white12,
                title: const Text("Ubah Kata Sandi"),
                trailing: const Icon(Icons.chevron_right,
                    size: 35, color: Colors.orange),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(_goPage(7, null));
                },
                hoverColor: Colors.white12,
                title: const Text("Hapus Akun"),
                trailing: const Icon(Icons.chevron_right,
                    size: 35, color: Colors.orange),
              ),
              const Divider()
            ],
          )),
    );
  }
}
