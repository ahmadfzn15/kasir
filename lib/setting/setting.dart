import 'package:app/etc/auth_user.dart';
import 'package:app/sublayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  Map<String, dynamic> user = {};
  String? role;

  @override
  void initState() {
    super.initState();

    getUser();
    getRole();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUser() async {
    String? roles = await const FlutterSecureStorage().read(key: 'role');
    Map<String, dynamic> res = await AuthUser().getCurrentUser();
    setState(() {
      role = roles;
      user = res;
    });
  }

  Future<void> getRole() async {
    String? roles = await const FlutterSecureStorage().read(key: 'role');
    setState(() {
      role = roles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeys,
      body: role != null
          ? SafeArea(
              child: Padding(
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
                      const Divider(
                        color: Color(0xFFcbd5e1),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(_goPage(4, null));
                        },
                        hoverColor: Colors.white12,
                        title: const Text("Tampilan"),
                        trailing: const Icon(Icons.chevron_right,
                            size: 35, color: Colors.orange),
                      ),
                      const Divider(color: Color(0xFFcbd5e1)),
                      role != null && role == 'admin'
                          ? Wrap(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(_goPage(5, null));
                                  },
                                  hoverColor: Colors.white12,
                                  title: const Text("Toko"),
                                  trailing: const Icon(Icons.chevron_right,
                                      size: 35, color: Colors.orange),
                                ),
                                const Divider(color: Color(0xFFcbd5e1))
                              ],
                            )
                          : Container()
                    ],
                  )))
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }
}
