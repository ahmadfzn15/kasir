import 'package:app/auth/auth.dart';
import 'package:app/blank.dart';
import 'package:app/help.dart';
import 'package:app/history.dart';
import 'package:app/home.dart';
import 'package:app/product.dart';
import 'package:app/setting/setting.dart';
import 'package:app/sublayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SideItem {
  String label;
  IconData icon;
  Widget? page = const Blank();

  SideItem({required this.label, required this.icon, required, this.page});
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

  int _selectedIndex = 0;
  late List<SideItem> link;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    link = [
      SideItem(label: "Home", icon: Icons.home, page: const Home()),
      SideItem(label: "Product", icon: Icons.shop, page: const Product()),
      SideItem(label: "History", icon: Icons.history, page: const History()),
      SideItem(label: "Setting", icon: Icons.settings, page: const Setting()),
      SideItem(label: "Help", icon: Icons.help, page: const Help()),
    ];
  }

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
          title: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                link[_selectedIndex].label,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              )),
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
                                        AssetImage("assets/img/user.png"),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Lusi Kuraisin",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                                      Text(
                                        "Admin",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
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
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: link.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(link[index].icon),
                    title: Text(link[index].label),
                    selected: _selectedIndex == index,
                    onTap: () {
                      _onItemTapped(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Keluar"),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context);
                },
              ),
            ],
          ),
        ),
        body: link.elementAt(_selectedIndex).page);
  }
}
