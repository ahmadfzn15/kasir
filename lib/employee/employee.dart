import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/employee/edit_employee.dart';
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

Route _goPage(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchDataEmployee();
  }

  Future<void> _handleRefresh() async {
    fetchDataEmployee();
  }

  Future<void> fetchDataEmployee() async {
    setState(() {
      loading = true;
    });

    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String url = dotenv.env['API_URL']!;

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/cashier"),
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

  void _openOption(BuildContext context, Map<String, dynamic> data) {
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
                  Navigator.push(context, _goPage(EditEmployee(data: data)));
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
                  openDelete(context, data['id']);
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

  void openDelete(BuildContext context, int id) {
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
            CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  deleteEmployee(context, id);
                },
                child: const Text("Yes"))
          ]),
    );
  }

  Future<void> deleteEmployee(BuildContext context, int id) async {
    String url = dotenv.env['API_URL']!;
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/user/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _handleRefresh();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            "Karyawan",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(_goPage(const Sublayout(id: 7)));
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        tooltip: "Tambah Karyawan",
        shape: const CircleBorder(eccentricity: 0),
        child: const Icon(
          Icons.person_add_alt_1,
          size: 30,
        ),
      ),
      body: !loading
          ? employee.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () {
                    return _handleRefresh();
                  },
                  child: SizedBox(
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: employee.length,
                        itemBuilder: (context, index) {
                          return Wrap(
                            children: [
                              Card(
                                surfaceTintColor: Colors.white,
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/img/lusi.jpeg"),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(right: 0, left: 10),
                                  title: Text(employee[index]['nama']),
                                  subtitle: Text(employee[index]['role']),
                                  trailing: IconButton(
                                      onPressed: () {
                                        _openOption(context, employee[index]);
                                      },
                                      icon: const Icon(
                                          CupertinoIcons.ellipsis_vertical)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
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
