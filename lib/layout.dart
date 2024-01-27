import 'package:app/auth/auth.dart';
import 'package:app/home.dart';
import 'package:app/notifications.dart';
import 'package:app/product.dart';
import 'package:app/sublayout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SideItem {
  String label;
  IconData icon;
  bool redirect;
  Function? action;

  SideItem(
      {required this.label,
      required this.icon,
      required this.redirect,
      this.action});
}

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LayoutState createState() => _LayoutState();
}

Route _goPage(int id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Sublayout(id: id),
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

class _LayoutState extends State<Layout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  int _selectedIndex = 0;
  late List<SideItem> link;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    link = [
      SideItem(label: "Home", icon: Icons.home, redirect: true),
      SideItem(label: "Orders", icon: Icons.shop, redirect: true),
      SideItem(label: "History", icon: Icons.history, redirect: true),
      SideItem(label: "Setting", icon: Icons.settings, redirect: true),
      SideItem(label: "Help", icon: Icons.help, redirect: true),
      SideItem(
          label: "Sign out",
          icon: Icons.logout,
          redirect: false,
          // ignore: void_checks
          action: openDialog)
    ];
  }

  List<Widget> page = const [
    Home(),
    Product(title: "Sunda Food"),
    Notifications()
  ];

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() async {
    try {
      // ignore: unused_local_variable
      loading = true;
      await FirebaseAuth.instance.signOut();

      const snackBar = SnackBar(
          content: Text(
            "Sign out Successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepOrange,
          duration: Duration(seconds: 3));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return const Auth();
        },
      ));
      loading = false;
    } on FirebaseAuthException catch (e) {
      loading = false;
      print(e);
    } catch (e) {
      loading = false;
      print(e);
    }
  }

  void openDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
          title: const Text("Sign out"),
          content: const Text("Are your sure to sign out now?"),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  _signOut();
                },
                child: const Text("Yes"))
          ]),
    );
  }

  late XFile? file;
  Future<void> openFile() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? files = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        file = files!;
      });
    } else {
      // ignore: use_build_context_synchronously
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoAlertDialog(
            title: const Text("Sign out"),
            content: const Text("Are your sure to sign out now?"),
            actions: [
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No")),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"))
            ]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              "Beranda",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(_goPage(0));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Badge(label: Text("2"), child: Icon(Icons.notifications)),
            ),
          )
        ],
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(_goPage(1));
                        },
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage:
                                      AssetImage("assets/img/lusi.jpeg"),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Lusi Kuraisin",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                )
                              ],
                            ),
                            IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 30,
                                ))
                          ],
                        )),
                  ]),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text("Orders"),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("History"),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              selected: _selectedIndex == 3,
              onTap: () {
                openFile();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: () {
                Navigator.pop(context);
                openDialog(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Colors.blue,
          child: page[_selectedIndex]),
    );
  }
}
