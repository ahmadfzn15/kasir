import 'package:flutter/material.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmployeeState createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return const Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/img/lusi.jpeg"),
                ),
                title: Text("Lusi"),
                subtitle: Text("Kasir"),
                trailing: Icon(Icons.menu),
              ),
              Divider(
                indent: 15,
                endIndent: 15,
              )
            ],
          );
        },
      ),
    );
  }
}
