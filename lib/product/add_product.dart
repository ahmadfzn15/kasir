import 'dart:convert';
import 'dart:io';
import 'package:app/components/popup.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
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
  final TextEditingController _barcode = TextEditingController();
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _hargaBeli = TextEditingController();
  final TextEditingController _hargaJual = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _variant = TextEditingController();
  final TextEditingController _stok = TextEditingController();
  XFile? _image;
  List<DropdownMenuEntry<dynamic>> _category = [];
  int _selectedOption = 1;
  bool allowStock = false;
  bool allowVarian = false;
  bool loading = false;
  String? barcode;

  @override
  void initState() {
    super.initState();

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
    String? id = await const FlutterSecureStorage().read(key: 'id');
    var request = http.MultipartRequest(
        "post", Uri.parse("${dotenv.env['API_URL']!}/api/product"));
    request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));
    request.fields['id'] = id!;
    request.fields['namaProduk'] = _namaProduk.text;
    request.fields['barcode'] = barcode ?? "";
    request.fields['id_kategori'] = _selectedOption.toString();
    request.fields['harga_beli'] = _hargaBeli.text;
    request.fields['harga_jual'] = _hargaJual.text;
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

  void openAddCategory() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Tambah Kategori Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              CupertinoTextField(
                placeholder: "Masukkan kategori baru",
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFe2e8f0), width: 0.5),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Colors.orange,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void scanBarcode() async {
    final res = await BarcodeScanner.scan();
    setState(() {
      barcode = res.rawContent;
      _barcode.value = TextEditingValue(text: res.rawContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            surfaceTintColor: Colors.white,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Foto Produk",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  _image != null
                                      ? Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.black26)),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.file(File(_image!.path),
                                              fit: BoxFit.cover),
                                        )
                                      : Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.black12),
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
                                            BoxShadow(
                                                color: Colors.black,
                                                blurRadius: 2)
                                          ]),
                                      child: const Icon(Icons.edit),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              barcode != null
                                  ? SizedBox(
                                      width: 170,
                                      child: CupertinoTextField(
                                        controller: _barcode,
                                        readOnly: true,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF94a3b8),
                                              width: 0.5),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 5,
                              ),
                              CupertinoButton(
                                color: Colors.orange,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                onPressed: () {
                                  scanBarcode();
                                },
                                child: const Wrap(
                                  direction: Axis.horizontal,
                                  children: [
                                    Icon(CupertinoIcons.barcode_viewfinder),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Pindai Barcode")
                                  ],
                                ),
                              )
                            ],
                          ))
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          CupertinoTextField(
                            controller: _namaProduk,
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.shopping_bag_rounded),
                            ),
                            placeholder: "Masukkan nama produk",
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF94a3b8), width: 0.5),
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
                              Text("Harga Beli",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          CupertinoTextField(
                            controller: _hargaBeli,
                            keyboardType: TextInputType.number,
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("Rp."),
                            ),
                            placeholder: "0",
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF94a3b8), width: 0.5),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          CupertinoTextField(
                            controller: _hargaJual,
                            keyboardType: TextInputType.number,
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("Rp."),
                            ),
                            placeholder: "0",
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF94a3b8), width: 0.5),
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
                              Text("Kategori",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: DropdownMenu(
                                        expandedInsets: const EdgeInsets.all(0),
                                        initialSelection: _category.isNotEmpty
                                            ? _category[0].value
                                            : 0,
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 50),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFe2e8f0),
                                                            width: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                        onSelected: (newValue) {
                                          setState(() {
                                            _selectedOption = newValue;
                                          });
                                        },
                                        dropdownMenuEntries: _category,
                                      ))),
                              const SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                  onPressed: () {
                                    openAddCategory();
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 35,
                                  ))
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                        value: allowVarian,
                        title: const Text("Varian"),
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            allowVarian = value;
                          });
                        },
                      ),
                      allowVarian
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Varian",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                CupertinoTextField(
                                  controller: _variant,
                                  placeholder: "Masukkan varian",
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF94a3b8),
                                        width: 0.5),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  indent: 10,
                                  endIndent: 10,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                        value: allowStock,
                        title: const Text("Manajemen Stok"),
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            allowStock = value;
                          });
                        },
                      ),
                      allowStock
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Stok",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                CupertinoTextField(
                                  controller: _stok,
                                  keyboardType: TextInputType.number,
                                  placeholder: "0",
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF94a3b8),
                                        width: 0.5),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  indent: 10,
                                  endIndent: 10,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Deskripsi",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          CupertinoTextField(
                            controller: _deskripsi,
                            placeholder: "Masukkan deskripsi",
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF94a3b8), width: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        )),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: Colors.orange,
            child: const Text("Simpan"),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _uploadToDatabase(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
