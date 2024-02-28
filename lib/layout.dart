import 'package:app/employee.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'auth/auth.dart';
import 'help.dart';
import 'history.dart';
import 'home.dart';
import 'product.dart';
import 'setting/setting.dart';
import 'sublayout.dart';

class SideItem {
  String label;
  IconData icon;
  IconData iconSelected;
  Widget? page;

  SideItem(
      {required this.label,
      required this.icon,
      required this.iconSelected,
      this.page});
}

class Layout extends StatefulWidget {
  const Layout({super.key, required this.user});
  final Map<String, dynamic> user;

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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  int _selectedIndex = 1;
  late List<SideItem> link;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    link = [
      SideItem(
          label: "Beranda",
          icon: Icons.home_outlined,
          iconSelected: Icons.home,
          page: const Home()),
      SideItem(
          label: "Produk",
          icon: Icons.shopping_bag_outlined,
          iconSelected: Icons.shopping_bag,
          page: const Product()),
      SideItem(
          label: "Petugas",
          icon: Icons.person_2_outlined,
          iconSelected: Icons.person_2,
          page: const Employee()),
      SideItem(
          label: "Histori",
          icon: Icons.history_outlined,
          iconSelected: Icons.history,
          page: const History()),
      SideItem(
          label: "Pengaturan",
          icon: Icons.settings_outlined,
          iconSelected: Icons.settings,
          page: const Setting()),
      SideItem(
          label: "Bantuan",
          icon: Icons.help_outline,
          iconSelected: Icons.help,
          page: const Help()),
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
      loading = true;

      const snackBar = SnackBar(
        content: Text(
          "Sign out Successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Auth();
          },
        ),
      );
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
            child: const Text("No"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              _signOut();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
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
      showCupertinoModalPopup(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Permission Required"),
          content: const Text("Camera permission is required to upload image."),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _selectedIndex == 1
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 45,
                  child: SearchAnchor.bar(
                    barLeading: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 30,
                    ),
                    barBackgroundColor:
                        const MaterialStatePropertyAll(Colors.white),
                    barElevation: const MaterialStatePropertyAll(0),
                    barHintText: "Search product",
                    suggestionsBuilder: (context, controller) {
                      return [
                        const Center(
                          child: Text('No search history.',
                              style: TextStyle(color: Colors.grey)),
                        )
                      ];
                    },
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  link[_selectedIndex].label,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
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
                      Navigator.of(context).push(_goPage(0));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              backgroundImage:
                                  AssetImage("assets/img/user.png"),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.isNotEmpty
                                      ? widget.user['username']
                                      : "Ahmad Fauzan",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  widget.user.isNotEmpty
                                      ? widget.user['role']
                                      : "Admin",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: link.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(_selectedIndex == index
                      ? link[index].iconSelected
                      : link[index].icon),
                  title: Text(link[index].label),
                  selected: _selectedIndex == index,
                  selectedColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(index);
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Keluar"),
              selectedColor: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                openDialog(context);
              },
            ),
            const SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text("V.1.0")],
              ),
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.orange,
        onRefresh: _handleRefresh,
        child: link[_selectedIndex].page!,
      ),
    );
  }
}
