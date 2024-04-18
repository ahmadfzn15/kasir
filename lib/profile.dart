import 'dart:io';

import 'package:app/etc/auth_user.dart';
import 'package:app/models/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final userController = Get.put(UserController());
  final TextEditingController _nama = TextEditingController(text: "");
  final TextEditingController _email = TextEditingController(text: "");
  final TextEditingController _noTlp = TextEditingController(text: "");
  XFile? _image;
  String? _img;
  bool loading = true;
  String url = dotenv.env['API_URL']!;

  @override
  void initState() {
    super.initState();

    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refresh() async {
    await getUser();
  }

  Future<void> getUser() async {
    Map<String, dynamic> res = await AuthUser().getCurrentUser();

    _img = res['foto'];
    _nama.value = TextEditingValue(text: res['nama'] ?? "");
    _email.value = TextEditingValue(text: res['email'] ?? "");
    _noTlp.value = TextEditingValue(text: res['no_tlp'] ?? "");
    setState(() {
      loading = false;
    });
  }

  void _openFileManager() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      XFile? pickImg =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _img = null;
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
                        _img = null;
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

  Future<void> updateData() async {
    await userController.updateUser(context, {
      "new_img": _image,
      "old_img": _img,
      "nama": _nama.text,
      "email": _email.text,
      "noTlp": _noTlp.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: RefreshIndicator(
          color: Colors.orange,
          onRefresh: () {
            return refresh();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Foto Profil",
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
                        borderRadius: BorderRadius.circular(75),
                        border: Border.all(color: Colors.grey),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: !loading
                          ? _img != null
                              ? Image.network(
                                  "$url/storage/img/$_img",
                                  fit: BoxFit.cover,
                                )
                              : _image != null
                                  ? Image.file(
                                      File(_image!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/img/user.png",
                                      fit: BoxFit.cover,
                                    )
                          : Container(),
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
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Nama",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      CupertinoTextField(
                        controller: _nama,
                        placeholder: "Masukkan nama",
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.person),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFcbd5e1), width: 0.5),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Email",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      CupertinoTextField(
                        controller: _email,
                        placeholder: "Masukkan email",
                        keyboardType: TextInputType.emailAddress,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.email),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFcbd5e1), width: 0.5),
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
                        placeholder: "Masukkan nomor telepon",
                        keyboardType: TextInputType.phone,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.phone),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFcbd5e1), width: 0.5),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: Colors.orange,
              onPressed: () {
                updateData();
              },
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
