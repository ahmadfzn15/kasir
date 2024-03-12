import 'dart:convert';
import 'dart:io';
import 'package:app/components/popup.dart';
import 'package:app/models/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key, required this.product});
  final Products product;

  @override
  // ignore: library_private_types_in_public_api
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _stok = TextEditingController();
  final TextEditingController _kategori = TextEditingController();
  XFile? _image;
  List<DropdownMenuEntry<dynamic>> _category = [];
  int _selectedOption = 1;
  bool loading = false;
  String url = dotenv.env['API_URL']!;

  @override
  void initState() {
    super.initState();

    _namaProduk.value = TextEditingValue(text: widget.product.namaProduk);
    _harga.value = TextEditingValue(text: widget.product.harga_jual.toString());
    _deskripsi.value = TextEditingValue(text: widget.product.deskripsi ?? "");
    _stok.value = TextEditingValue(text: widget.product.stok.toString());
    _kategori.value =
        TextEditingValue(text: widget.product.id_kategori.toString());
    fetchDataCategory();
  }

  void _openFileManager() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      XFile? pickImg =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _image = pickImg;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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

  Future<void> fetchDataCategory() async {
    String url = dotenv.env['API_URL']!;
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');

    final response = await http.get(
      Uri.parse("$url/api/category/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _category = (res['data'] as List<dynamic>)
            .map((data) =>
                DropdownMenuEntry(value: data['id'], label: data['kategori']))
            .toList();
      });
    } else {
      throw Exception(res['message']);
    }
  }

  void _openDialogImage(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints:
          const BoxConstraints(maxHeight: 120, minWidth: double.infinity),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 50,
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
                        Text("Galeri")
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
                        Text("Kamera")
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _image = null;
                      });
                      Navigator.pop(context);
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
    var request = http.MultipartRequest(
        "put",
        Uri.parse(
            "${dotenv.env['API_URL']!}/api/product/${widget.product.id}"));
    request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));
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
      Popup().show(context, 'Produk berhasil diubah', true);
      setState(() {
        loading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Produk gagal diubah', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 1,
        title: const Text(
          "Ubah Produk",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.chevron_left)),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Foto Produk",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      widget.product.foto != null || _image != null
                          ? Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(75),
                                  border: Border.all(color: Colors.grey)),
                              clipBehavior: Clip.antiAlias,
                              child: _image != null
                                  ? Image.file(File(_image!.path))
                                  : Image.network(
                                      '$url/storage/img/${widget.product.foto}'),
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
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Nama Produk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _deskripsi,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Masukkan deskripsi",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: DropdownMenu(
                                  controller: _kategori,
                                  expandedInsets: const EdgeInsets.all(0),
                                  initialSelection: _category.isNotEmpty
                                      ? _category[0].value
                                      : 0,
                                  inputDecorationTheme: InputDecorationTheme(
                                      constraints:
                                          const BoxConstraints(maxHeight: 50),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
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
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
