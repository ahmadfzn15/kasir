import 'dart:convert';
import 'dart:io';
import 'package:app/models/product_controller.dart';
import 'package:app/models/products.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibration/vibration.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key, required this.product});
  final Products product;

  @override
  // ignore: library_private_types_in_public_api
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final productController = Get.put(ProductController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _barcode = TextEditingController();
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _hargaBeli = TextEditingController();
  final TextEditingController _hargaJual = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _variant = TextEditingController();
  final TextEditingController _stok = TextEditingController();
  final TextEditingController _kategori = TextEditingController();
  XFile? _image;
  String? foto;
  String? _img;
  List<DropdownMenuEntry<dynamic>> _category = [];
  int _selectedOption = 1;
  int? id;
  bool allowStock = false;
  bool allowVarian = false;
  bool loading = false;
  String? barcode;
  String url = dotenv.env['API_URL']!;

  @override
  void initState() {
    super.initState();

    id = widget.product.id;
    foto = widget.product.foto;
    _img = foto != null ? "${dotenv.env['API_URL']}/storage/img/$foto" : null;
    _barcode.value = TextEditingValue(text: widget.product.barcode ?? "");
    _namaProduk.value = TextEditingValue(text: widget.product.namaProduk);
    _hargaBeli.value =
        TextEditingValue(text: widget.product.harga_beli.toString());
    _hargaJual.value =
        TextEditingValue(text: widget.product.harga_jual.toString());
    _deskripsi.value = TextEditingValue(text: widget.product.deskripsi ?? "");
    _stok.value = TextEditingValue(
        text:
            widget.product.stok != null ? widget.product.stok.toString() : "0");
    _kategori.value =
        TextEditingValue(text: widget.product.id_kategori.toString());
    allowStock = widget.product.stok != null;
    fetchDataCategory();
  }

  void _openFileManager() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      XFile? pickImg =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _img = null;
        _image = pickImg;
        foto = null;
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
        _img = null;
        _image = pickImg;
        foto = null;
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

    final response = await http.get(
      Uri.parse("$url/api/category"),
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
                  TextButton(
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.black),
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 0))),
                    onPressed: () {
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
                  TextButton(
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.black),
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 0))),
                    onPressed: () {
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
                  TextButton(
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.red),
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 0))),
                    onPressed: () {
                      setState(() {
                        _image = null;
                        _img = null;
                        foto = null;
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
                      Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
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

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    productController.editProduct(context, {
      'id': id,
      'old_img': foto,
      'new_img': _image,
      'namaProduk': _namaProduk.text,
      'barcode': barcode ?? "",
      'id_kategori': _selectedOption.toString(),
      'harga_beli': _hargaBeli.text,
      'harga_jual': _hargaJual.text,
      'deskripsi': _deskripsi.text,
      'stok': _stok.text,
    });

    setState(() {
      loading = false;
    });
  }

  void scanBarcode() async {
    final res = await BarcodeScanner.scan();
    bool? hasVibration = await Vibration.hasVibrator();
    if (hasVibration!) {
      Vibration.vibrate(
        duration: 100,
        amplitude: 100,
      );
    }

    setState(() {
      barcode = res.rawContent;
      _barcode.value = TextEditingValue(text: res.rawContent);
    });
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
              icon: const Icon(
                CupertinoIcons.back,
              )),
        ),
      ),
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
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _img != null
                                        ? Image.network(
                                            _img!,
                                            fit: BoxFit.cover,
                                          )
                                        : _image != null
                                            ? Image.file(
                                                File(_image!.path),
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                "assets/img/food.png",
                                                fit: BoxFit.cover,
                                              ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      _openDialogImage(context);
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 1)
                                          ]),
                                      child: const Icon(
                                          Icons.add_photo_alternate_rounded),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              barcode != null || _barcode.text != ""
                                  ? SizedBox(
                                      width: 170,
                                      child: CupertinoTextField(
                                        controller: _barcode,
                                        readOnly: true,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFFcbd5e1),
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
                                  color: const Color(0xFFcbd5e1), width: 0.5),
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
                                  color: const Color(0xFFcbd5e1), width: 0.5),
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
                                  color: const Color(0xFFcbd5e1), width: 0.5),
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
                                        leadingIcon: const Icon(Icons.category),
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
                                                                0xFFcbd5e1),
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
                                        color: const Color(0xFFcbd5e1),
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
                            if (!value) {
                              _stok.clear();
                            } else {
                              _stok.value = TextEditingValue(
                                  text: widget.product.stok != null
                                      ? widget.product.stok.toString()
                                      : "0");
                            }
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
                                        color: const Color(0xFFcbd5e1),
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
                                  color: const Color(0xFFcbd5e1), width: 0.5),
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
              onPressed: () {
                _uploadToDatabase(context);
              },
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
