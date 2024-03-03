import 'dart:io';
import 'package:app/components/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _stok = TextEditingController();
  XFile? _image;
  final List<DropdownMenuEntry<dynamic>> _category = [
    const DropdownMenuEntry(value: 1, label: "Makanan"),
    const DropdownMenuEntry(value: 2, label: "Minuman"),
  ];
  int _selectedOption = 1;
  bool loading = false;

  void _openFileManager() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      XFile? pickImg =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _image = pickImg;
      });
    } else {
      // ignore: use_build_contevar ronously
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
                  _openFileManager();
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo,
                      size: 30,
                      color: Color(0xFF64748b),
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
                      color: Color(0xFF64748b),
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
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');
    var request = http.MultipartRequest(
        "post", Uri.parse("${dotenv.env['API_URL']!}/api/product"));
    request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));
    request.fields['id'] = id!;
    request.fields['namaProduk'] = _namaProduk.text;
    request.fields['id_kategori'] = _selectedOption.toString();
    request.fields['harga'] = _harga.text;
    request.fields['deskripsi'] = _deskripsi.text;
    request.fields['stok'] = _stok.text;
    request.headers['Content-Type'] = "application/json";
    request.headers['Authorization'] = "Bearer $token";
    var res = await request.send();

    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Produk baru berhasil ditambahkan', true);
      setState(() {
        loading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Produk gagal ditambahkan', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: _formKey,
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
                              child: Image.file(File(_image!.path),
                                  fit: BoxFit.cover),
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
                                  color: Color(0xFF64748b),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _namaProduk,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama produk wajib diisi!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Masukkan nama produk",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.shopping_bag_rounded),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
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
                                  color: Color(0xFF64748b),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _harga,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga wajib diisi!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.price_change),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
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
                                  color: Color(0xFF64748b),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _deskripsi,
                        decoration: InputDecoration(
                          hintText: "Masukkan deskripsi",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.description),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
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
                                        color: Color(0xFF64748b),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            TextFormField(
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
                                        color: Color(0xFF64748b),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: DropdownMenu(
                                  initialSelection: _category[0].value,
                                  inputDecorationTheme: InputDecorationTheme(
                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color(0xFFe2e8f0),
                                              width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(10))),
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
                ],
              )),
        )),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
              style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))),
                  backgroundColor: MaterialStatePropertyAll(Colors.orange),
                  foregroundColor: MaterialStatePropertyAll(Colors.white)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _uploadToDatabase(context);
                }
              },
              child: const Text("Save")),
        ),
      ),
    );
  }
}