import 'package:app/sublayout.dart';
import 'package:flutter/material.dart';

Route _goPage(int id, int? idProduk) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Sublayout(
      id: id,
    ),
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
                      Navigator.of(context).push(_goPage(0, null));
                    },
                    hoverColor: Colors.white12,
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 10,
                    leading: const Icon(
                      Icons.person_outlined,
                      size: 30,
                    ),
                    title: const Text("Profil"),
                    trailing: const Icon(Icons.chevron_right,
                        size: 35, color: Colors.orange),
                  ),
                  const Divider(color: Color(0xFFcbd5e1)),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(_goPage(5, null));
                    },
                    hoverColor: Colors.white12,
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 10,
                    leading: const Icon(
                      Icons.lock_outline,
                      size: 30,
                    ),
                    title: const Text("Ubah Kata Sandi"),
                    trailing: const Icon(Icons.chevron_right,
                        size: 35, color: Colors.orange),
                  ),
                  const Divider(color: Color(0xFFcbd5e1)),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(_goPage(6, null));
                    },
                    hoverColor: Colors.white12,
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 10,
                    leading: const Icon(
                      Icons.delete_forever_outlined,
                      size: 30,
                    ),
                    title: const Text("Hapus Akun"),
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
