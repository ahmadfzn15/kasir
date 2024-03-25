import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Other extends StatefulWidget {
  const Other({super.key});

  @override
  State<Other> createState() => _OtherState();
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          surfaceTintColor: Colors.white,
          elevation: 4,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                children: [
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
