import 'package:app/employee/edit_employee.dart';
import 'package:app/models/employee_controller.dart';
import 'package:app/sublayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

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
  final employeeController = Get.put(EmployeeController());
  List<dynamic> employee = [];
  String url = dotenv.env['API_URL']!;
  bool pwdNotSame = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDataEmployee();
  }

  Future<void> _handleRefresh() async {
    await fetchDataEmployee();
  }

  Future<void> fetchDataEmployee() async {
    await employeeController.fetchDataEmployee();
    setState(() {
      loading = false;
    });
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, _goPage(EditEmployee(data: data)));
                },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.black),
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 0))),
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openDelete(context, data['id']);
                },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.red),
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 0))),
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
    await employeeController.deleteEmployee(context, id);
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
          ? GetBuilder<EmployeeController>(
              builder: (controller) {
                return RefreshIndicator(
                  onRefresh: () {
                    return _handleRefresh();
                  },
                  child: employeeController.employee.isNotEmpty
                      ? SizedBox(
                          height: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: employeeController.employee.length,
                              itemBuilder: (context, index) {
                                return Wrap(
                                  children: [
                                    Card(
                                      surfaceTintColor: Colors.white,
                                      child: ListTile(
                                        leading: employeeController
                                                    .employee[index]['foto'] !=
                                                null
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    "$url/storage/img/${employeeController.employee[index]['foto']}"),
                                              )
                                            : const CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    "assets/img/user.png"),
                                              ),
                                        contentPadding: const EdgeInsets.only(
                                            right: 0, left: 10),
                                        title: Text(employeeController
                                            .employee[index]['nama']),
                                        subtitle: Text(employeeController
                                            .employee[index]['role']),
                                        trailing: IconButton(
                                            onPressed: () {
                                              _openOption(
                                                  context,
                                                  employeeController
                                                      .employee[index]);
                                            },
                                            icon: const Icon(CupertinoIcons
                                                .ellipsis_vertical)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () {
                            return _handleRefresh();
                          },
                          child: const SizedBox(
                            height: double.infinity,
                            child: Center(
                              child: Text("Data Kosong"),
                            ),
                          )),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }
}
