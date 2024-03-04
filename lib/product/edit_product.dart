import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key, required this.id});
  final int id;

  @override
  // ignore: library_private_types_in_public_api
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _stok = TextEditingController();
  final TextEditingController _menuCategory = TextEditingController();
  XFile? _image;
  final List<DropdownMenuEntry<dynamic>> _category = [
    const DropdownMenuEntry(value: 1, label: "Makanan"),
    const DropdownMenuEntry(value: 2, label: "Minuman"),
  ];
  int _selectedOption = 1;

  @override
  void initState() {
    super.initState();

    fetchDataProduct();
  }

  Future<void> fetchDataProduct() async {
    String url = dotenv.env['API_URL']!;

    final response = await http.get(
      Uri.parse("$url/api/product/${widget.id}"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> products = res['data'];
        _namaProduk.value = TextEditingValue(text: products['namaProduk']);
        _harga.value = TextEditingValue(text: products['harga'].toString());
        _deskripsi.value = TextEditingValue(text: products['deskripsi']);
        _stok.value = TextEditingValue(text: products['stok'].toString());
        _menuCategory.value =
            TextEditingValue(text: products['id_kategori'].toString());
      });
    } else {
      throw Exception(res['message']);
    }
  }

  void _openFileManager() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      XFile? pickImg =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _image = pickImg;
      });
    } else {
      // ignore: use_build_context_synchronously
      showCupertinoModalPopup(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CupertinoAlertDialog(
            title: const Text("Access denied"),
            content: const Text("Please allow storage usage to upload images."),
            actions: [
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Ok"))
            ]),
      );
    }
  }

  void _openCamera() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      XFile? pickImg =
          await ImagePicker().pickImage(source: ImageSource.camera);
      setState(() {
        _image = pickImg;
      });
    } else {
      // ignore: use_build_context_synchronously
      showCupertinoModalPopup(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CupertinoAlertDialog(
            title: const Text("Access denied"),
            content: const Text("Please allow camera to upload images."),
            actions: [
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Ok"))
            ]),
      );
    }
  }

  void _openDialogImage(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxHeight: 150),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  _openFileManager();
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Pick from galery")
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _openCamera();
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Open camera")
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadToDatabase(BuildContext context) async {
    final res = await http
        .put(Uri.parse("${dotenv.env['API_URL']!}/api/product/${widget.id}"),
            body: jsonEncode({
              "namaProduk": _namaProduk.text,
              "id_kategori": _selectedOption,
              "harga": _harga.text,
              "deskripsi": _deskripsi.text,
              "stok": _stok.text
            }),
            headers: {"Content-type": "application/json"});

    Map<String, dynamic> result = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, result['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      showSnackBar(context, result['message'], false);
    }
  }

  void showSnackBar(BuildContext context, String message, bool status) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: status ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _image != null
                    ? Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(color: Colors.grey)),
                        clipBehavior: Clip.antiAlias,
                        child:
                            Image.file(File(_image!.path), fit: BoxFit.cover),
                      )
                    : Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey),
                        clipBehavior: Clip.antiAlias,
                      ),
                GestureDetector(
                  onTap: () async {
                    _openDialogImage(context);
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black, blurRadius: 2)
                        ]),
                    child: const Icon(Icons.edit),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Nama Produk",
                        style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _namaProduk,
                  decoration: InputDecoration(
                    hintText: "Masukkan nama produk",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.shopping_bag_rounded),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFe2e8f0), width: 0.5),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Harga Jual",
                        style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _harga,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "0",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.price_change),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFe2e8f0), width: 0.5),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Deskripsi",
                        style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _deskripsi,
                  decoration: InputDecoration(
                    hintText: "Masukkan deskripsi",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.description),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFe2e8f0), width: 0.5),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Stok",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextField(
                        controller: _stok,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFe2e8f0), width: 0.5),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Kategori",
                              style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: DropdownMenu(
                            controller: _menuCategory,
                            initialSelection: _category[0].value,
                            inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFFe2e8f0), width: 0.5),
                                    borderRadius: BorderRadius.circular(10))),
                            onSelected: (newValue) {
                              setState(() {
                                _selectedOption = newValue;
                              });
                            },
                            dropdownMenuEntries: _category,
                          ))
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  style: const ButtonStyle(
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                      backgroundColor: MaterialStatePropertyAll(Colors.orange),
                      foregroundColor: MaterialStatePropertyAll(Colors.white)),
                  onPressed: () {
                    _uploadToDatabase(context);
                  },
                  child: const Text("Simpan")),
            )
          ],
        ),
      )),
    );
  }
}
