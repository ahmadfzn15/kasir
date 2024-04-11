import 'package:app/setting/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

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
    getInfo();
  }

  void getInfo() async {
    var vibrates = await const FlutterSecureStorage().read(key: 'vibrate');
    var sounds = await const FlutterSecureStorage().read(key: 'sound');
    setState(() {
      if (vibrates == "1") {
        vibrate = true;
      } else {
        vibrate = false;
      }
    });

    setState(() {
      if (sounds == "1") {
        sound = true;
      } else {
        sound = false;
      }
    });
  }

  void changeSound(value) async {
    if (value) {
      setState(() {
        sound = true;
      });
      await const FlutterSecureStorage().write(key: 'sound', value: "1");
    } else {
      setState(() {
        sound = false;
      });
      await const FlutterSecureStorage().write(key: 'sound', value: "0");
    }
  }

  void changeVibrate(value) async {
    if (value) {
      setState(() {
        vibrate = true;
      });
      await const FlutterSecureStorage().write(key: 'vibrate', value: "1");
    } else {
      setState(() {
        vibrate = false;
      });
      await const FlutterSecureStorage().write(key: 'vibrate', value: "0");
    }
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
                  const Divider(
                    color: Color(0xFFcbd5e1),
                  ),
                  ListTile(
                    onTap: () {
                      if (sound) {
                        changeSound(false);
                      } else {
                        changeSound(true);
                      }
                    },
                    hoverColor: Colors.white12,
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 10,
                    leading: const Icon(
                      Icons.notifications_active_outlined,
                      size: 30,
                    ),
                    title: const Text("Suara Notifikasi"),
                    trailing: Switch(
                      activeColor: Colors.orange,
                      value: sound,
                      onChanged: (value) {
                        changeSound(value);
                      },
                    ),
                  ),
                  const Divider(
                    color: Color(0xFFcbd5e1),
                  ),
                  ListTile(
                    onTap: () {
                      if (vibrate) {
                        changeVibrate(false);
                      } else {
                        changeVibrate(true);
                      }
                    },
                    hoverColor: Colors.white12,
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 10,
                    leading: const Icon(
                      Icons.vibration,
                      size: 30,
                    ),
                    title: const Text("Getaran"),
                    trailing: Switch(
                      activeColor: Colors.orange,
                      value: vibrate,
                      onChanged: (value) {
                        changeVibrate(value);
                      },
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
