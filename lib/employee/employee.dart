import 'dart:convert';

import 'package:app/sublayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmployeeState createState() => _EmployeeState();
}

Route _toAddPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const Sublayout(id: 8),
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
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

class _EmployeeState extends State<Employee> {
  List<dynamic> employee = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchDataEmployee();
  }

  Future<void> _refresh() async {
    fetchDataEmployee();
  }

  Future<void> fetchDataEmployee() async {
    setState(() {
      loading = true;
    });

    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');
    String url = dotenv.env['API_URL']!;

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/cashier/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loading = false;
        setState(() {
          employee = (res['data'] as List<dynamic>).map((e) => e).toList();
        });
      } else {
        throw Exception(res['message']);
      }
    }
  }

  void _openOption(BuildContext context, int id) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxHeight: 120),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Edit")
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  openDialogDelete(context, id);
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Hapus")
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openDialogDelete(BuildContext context, int id) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
          title: const Text("Hapus Karyawan"),
          content: const Text(
              "Apakah yakin anda ingin menghapus akun karyawan ini?"),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            const CupertinoDialogAction(
                isDestructiveAction: true, onPressed: null, child: Text("Yes"))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(_toAddPage());
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        tooltip: "Tambah Karyawan",
        shape: const CircleBorder(eccentricity: 0),
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: !loading
          ? employee.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () {
                    return _refresh();
                  },
                  child: ListView.builder(
                    itemCount: employee.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundImage:
                                  AssetImage("assets/img/lusi.jpeg"),
                            ),
                            title: Text(employee[index]['username']),
                            subtitle: Text(employee[index]['role']),
                            trailing: IconButton(
                                onPressed: () {
                                  _openOption(context, employee[index]['id']);
                                },
                                icon: const Icon(Icons.menu)),
                          ),
                          const Divider(
                            indent: 15,
                            endIndent: 15,
                          )
                        ],
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text("Data Kosong"),
                )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }
}