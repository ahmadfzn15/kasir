import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/employee/employee.dart';
import 'package:app/etc/startup.dart';
import 'package:app/help.dart';
import 'package:app/models/order_controller.dart';
import 'package:app/models/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'auth/auth.dart';
import 'history.dart';
import 'home.dart';
import 'product/product.dart';
import 'setting/setting.dart';
import 'sublayout.dart';

class SideItem {
  String label;
  IconData icon;
  IconData iconSelected;
  bool? admin;
  Widget? page;

  SideItem(
      {required this.label,
      required this.icon,
      required this.iconSelected,
      this.admin = false,
      this.page});
}

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LayoutState createState() => _LayoutState();
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

class _LayoutState extends State<Layout> {
  final userController = Get.put(UserController());
  final orderController = Get.put(OrderController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String url = dotenv.env['API_URL']!;
  int? _selectedIndex;
  late List<SideItem> link;
  bool loading = false;
  bool hasToko = false;
  Map<String, dynamic> user = {};
  String? role;

  @override
  void initState() {
    super.initState();
    getUser();
    getRole();

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
          label: "Karyawan",
          icon: Icons.group_outlined,
          iconSelected: Icons.group,
          admin: true,
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

  Future<void> getUser() async {
    await userController.getCurrentUser(context);
    var res = userController.user;
    // ignore: unnecessary_null_comparison
    if (res == null) {
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          _goPage(const Auth()),
          (route) => false);
    }
  }

  Future<void> getRole() async {
    String? roles = await const FlutterSecureStorage().read(key: 'role');
    setState(() {
      role = roles;
      if (roles == "admin") {
        _selectedIndex = 0;
      } else {
        _selectedIndex = 1;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      loading = true;

      bool hasToken =
          await const FlutterSecureStorage().containsKey(key: 'token');
      String? token = await const FlutterSecureStorage().read(key: 'token');
      String url = dotenv.env['API_URL']!;

      if (hasToken) {
        await http.post(
          Uri.parse("$url/api/logout"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
        ).then((response) async {
          await const FlutterSecureStorage().deleteAll();
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Auth();
              },
            ),
            (route) => false,
          );
          // ignore: use_build_context_synchronously
          Popup().show(context, jsonDecode(response.body)['message'], true);
        });
        loading = false;
      }
    } catch (e) {
      await const FlutterSecureStorage().deleteAll();
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Auth();
          },
        ),
        (route) => false,
      );
      // ignore: use_build_context_synchronously
      Popup().show(context, "Logout Berhasil", true);
      loading = false;
    }
  }

  void openDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah yakin anda ingin logout sekarang?"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFf1f5f9),
      drawerEdgeDragWidth: 50,
      drawer: Drawer(
        surfaceTintColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userController.toko!.value.namaToko != null
                              ? userController.toko!.value.namaToko!
                              : "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context)
                                .push(_goPage(const Sublayout(id: 0)));
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  userController.user?.value.foto != null
                                      ? CircleAvatar(
                                          radius: 35,
                                          backgroundImage: NetworkImage(
                                              "$url/storage/img/${userController.user!.value.foto}"),
                                        )
                                      : const CircleAvatar(
                                          radius: 35,
                                          backgroundImage:
                                              AssetImage("assets/img/user.png"),
                                        ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userController.user?.value.nama != null
                                            ? userController.user!.value.nama!
                                            : "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        userController.user?.value.role != null
                                            ? userController.user!.value.role!
                                            : "",
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
                  )),
              role != null && role == 'admin'
                  ? ListTile(
                      leading: _selectedIndex == 0
                          ? Icon(link[0].iconSelected)
                          : Icon(link[0].icon),
                      title: const Text("Beranda"),
                      selected: _selectedIndex == 0,
                      selectedColor: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(0);
                      },
                    )
                  : Container(),
              ListTile(
                leading: _selectedIndex == 1
                    ? Icon(link[1].iconSelected)
                    : Icon(link[1].icon),
                title: const Text("Produk"),
                selected: _selectedIndex == 1,
                selectedColor: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1);
                },
              ),
              role != null && role == 'admin'
                  ? ListTile(
                      leading: _selectedIndex == 2
                          ? Icon(link[2].iconSelected)
                          : Icon(link[2].icon),
                      title: const Text("Karyawan"),
                      selected: _selectedIndex == 2,
                      selectedColor: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(2);
                      },
                    )
                  : Container(),
              ListTile(
                leading: _selectedIndex == 3
                    ? Icon(link[3].iconSelected)
                    : Icon(link[3].icon),
                title: const Text("Histori"),
                selected: _selectedIndex == 3,
                selectedColor: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(3);
                },
              ),
              ListTile(
                leading: _selectedIndex == 4
                    ? Icon(link[4].iconSelected)
                    : Icon(link[4].icon),
                title: const Text("Pengaturan"),
                selected: _selectedIndex == 4,
                selectedColor: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(4);
                },
              ),
              ListTile(
                leading: _selectedIndex == 5
                    ? Icon(link[5].iconSelected)
                    : Icon(link[5].icon),
                title: const Text("Bantuan"),
                selected: _selectedIndex == 5,
                selectedColor: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(5);
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
            ],
          ),
        ),
      ),
      body: role != null ? link[_selectedIndex!].page : const Startup(),
    );
  }
}
