import 'package:app/etc/auth_user.dart';
import 'package:app/sublayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Route _goPage(int id) {
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
      backgroundColor: const Color(0xFFf1f5f9),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu)),
        title: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            "Pengaturan",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: role != null
          ? SafeArea(
              child: Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                surfaceTintColor: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context).push(_goPage(2));
                          },
                          hoverColor: Colors.white12,
                          contentPadding: const EdgeInsets.all(0),
                          horizontalTitleGap: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          leading: const Icon(
                            Icons.account_circle_outlined,
                            size: 30,
                          ),
                          title: const Text("Akun"),
                          trailing: const Icon(Icons.chevron_right,
                              size: 35, color: Colors.orange),
                        ),
                        const Divider(color: Color(0xFFcbd5e1)),
                        role != null && role == 'admin'
                            ? Wrap(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(_goPage(4));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hoverColor: Colors.white12,
                                    contentPadding: const EdgeInsets.all(0),
                                    horizontalTitleGap: 10,
                                    leading: const Icon(
                                      Icons.home_work_outlined,
                                      size: 30,
                                    ),
                                    title: const Text("Toko"),
                                    trailing: const Icon(Icons.chevron_right,
                                        size: 35, color: Colors.orange),
                                  ),
                                  const Divider(
                                    color: Color(0xFFcbd5e1),
                                  ),
                                ],
                              )
                            : Container(),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).push(_goPage(9));
                          },
                          hoverColor: Colors.white12,
                          contentPadding: const EdgeInsets.all(0),
                          horizontalTitleGap: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          leading: const Icon(
                            Icons.settings_outlined,
                            size: 30,
                          ),
                          title: const Text("Lainnya"),
                          trailing: const Icon(Icons.chevron_right,
                              size: 35, color: Colors.orange),
                        ),
                      ],
                    )),
              ),
            ))
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }
}
