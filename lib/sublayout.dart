import 'package:app/employee/add_employee.dart';
import 'package:app/product/add_category.dart';
import 'package:app/product/add_product.dart';
import 'package:app/product/edit_product.dart';
import 'package:app/profile.dart';
import 'package:app/setting/account.dart';
import 'package:app/setting/change_password.dart';
import 'package:app/setting/delete_account.dart';
import 'package:app/setting/theme_page.dart';
import 'package:app/setting/toko.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sublayout extends StatefulWidget {
  // ignore: non_constant_identifier_names
  const Sublayout({super.key, required this.id, this.id_product = 0});
  final int? id;
  // ignore: non_constant_identifier_names
  final int id_product;

  @override
  // ignore: library_private_types_in_public_api
  _SublayoutState createState() => _SublayoutState();
}

class Pages {
  Widget page;
  String title;
  Widget? action;

  Pages({required this.page, required this.title, this.action});
}

class _SublayoutState extends State<Sublayout> {
  late List<Pages> page;

  @override
  void initState() {
    super.initState();

    page = [
      Pages(page: const Profile(), title: "Profile"),
      Pages(page: const AddProduct(), title: "Add Product"),
      Pages(
          page: EditProduct(
            id: widget.id_product,
          ),
          title: "Edit Product"),
      Pages(page: const Account(), title: "Akun"),
      Pages(page: const ThemePage(), title: "Tampilan"),
      Pages(page: const Toko(), title: "Pengaturan Toko"),
      Pages(page: const ChangePassword(), title: "Ubah Kata Sandi"),
      Pages(page: const DeleteAccount(), title: "Hapus Akun"),
      Pages(page: const AddEmployee(), title: "Tambah Karyawan"),
      Pages(page: const AddCategory(), title: "Tambah Kategori"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 1,
        title: Text(
          page[widget.id!].title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                CupertinoIcons.back,
              )),
        ),
      ),
      body: page[widget.id!].page,
    );
  }
}
