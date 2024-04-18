import 'dart:io';

import 'package:app/models/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Toko extends StatefulWidget {
  const Toko({super.key});

  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  final userController = Get.put(UserController());
  final TextEditingController _namaToko = TextEditingController();
  final TextEditingController _alamatToko = TextEditingController();
  final TextEditingController _usaha = TextEditingController();
  final TextEditingController _noTlp = TextEditingController();
  final TextEditingController _password = TextEditingController();
  XFile? _image;
  String? foto;
  String? _img;
  bool loading = false;
  bool showPwd = false;

  @override
  void initState() {
    super.initState();

    fetchDataMarket();
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

  Future<void> fetchDataMarket() async {
    await userController.getCurrentUser(context);

    var market = userController.toko!.value;
    foto = market.logo;
    _namaToko.value = TextEditingValue(text: market.namaToko ?? "");
    _alamatToko.value = TextEditingValue(text: market.alamat ?? "");
    _usaha.value = TextEditingValue(text: market.bidangUsaha ?? "");
    _noTlp.value = TextEditingValue(text: market.noTlp ?? "");
  }

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    userController.editToko(context, {
      'old_img': foto,
      'new_img': _image,
      'namaToko': _namaToko.text,
      'alamatToko': _alamatToko.text,
      'noTlp': _noTlp.text,
      'usaha': _usaha.text,
    });
    setState(() {
      loading = false;
    });
  }

  Future<void> resetData() async {
    await userController.resetData(context);
  }

  void showConfirmReset() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          actions: [
            CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal")),
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  resetData();
                },
                child: const Text("Reset Data")),
          ],
          title: const Text("Konfirmasi reset data"),
        );
      },
    );
  }

  void showConfirmDelete() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          actions: [
            CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal")),
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {},
                child: const Text("Hapus Toko")),
          ],
          title: const Text("Konfirmasi penghapusan toko"),
          content: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Kata Sandi",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              CupertinoTextField(
                controller: _password,
                placeholder: "Masukkan kata sandi anda",
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showPwd = !showPwd;
                        });
                      },
                      child: showPwd
                          ? const Icon(CupertinoIcons.eye_fill)
                          : const Icon(CupertinoIcons.eye_slash_fill)),
                ),
                obscureText: !showPwd,
                obscuringCharacter: "*",
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
              Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Flexible(
                        child: Text(
                      "Semua data meliputi data karyawan,produk,dan transaksi akan ikut terhapus.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.clip,
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Flexible(
                        child: Text(
                      "Akun anda akan terhapus dan logout secara otomatis.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.clip,
                    ))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Informasi Toko",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Logo Toko",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              : Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.black12),
                                  clipBehavior: Clip.antiAlias,
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
                              BoxShadow(color: Colors.grey, blurRadius: 1)
                            ]),
                        child: const Icon(Icons.add_photo_alternate_rounded),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Nama Toko",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                CupertinoTextField(
                  controller: _namaToko,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.shop),
                  ),
                  placeholder: "Masukkan nama toko",
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Alamat Toko",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                CupertinoTextField(
                  controller: _alamatToko,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.place),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  placeholder: "Masukkan alamat toko",
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Bidang usaha",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                CupertinoTextField(
                  controller: _usaha,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.business),
                  ),
                  placeholder: "Masukkan bidang usaha",
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Nomor Telepon",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                CupertinoTextField(
                  controller: _noTlp,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  placeholder: "Masukkan nomor telepon",
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFcbd5e1), width: 0.5),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: Colors.orange,
                      onPressed: () {
                        _uploadToDatabase(context);
                      },
                      child: const Text("Simpan")),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Reset Semua Data",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: Colors.red,
                      onPressed: () {
                        showConfirmReset();
                      },
                      child: const Text("Reset")),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Hapus Toko",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: Colors.red,
                      onPressed: () {
                        showConfirmDelete();
                      },
                      child: const Text("Hapus")),
                ),
              ],
            )),
      ),
    );
  }
}
