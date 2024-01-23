import 'package:app/auth/auth.dart';
import 'package:app/home.dart';
import 'package:app/product.dart';
import 'package:app/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class _LayoutState extends State<Layout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

  List<Widget> page = const [Home(), Product(title: "Sunda Food"), Setting()];

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
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Sign Out"),
              content: const Text(
                "Are you sure to sign out now?",
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                FilledButton(
                    onPressed: () => _signOut(),
                    child: const Text(
                      "Yes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: TextField(
            decoration: InputDecoration(
                hintText: "Search Products",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.search)),
          ),
        ),
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/img/lusi.jpeg"),
                    ),
                    Text(
                      "Lusi Kuraisin",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    )
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
                _onItemTapped(3);
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
      body: page[_selectedIndex],
      floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
                backgroundColor: Colors.white,
                showDragHandle: true,
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return const SizedBox(
                      height: double.infinity, width: double.infinity);
                },
              ),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          tooltip: "Add Orders",
          shape: const CircleBorder(eccentricity: 0),
          child: const Icon(
            Icons.add,
            size: 30,
          )),
    );
  }
}
