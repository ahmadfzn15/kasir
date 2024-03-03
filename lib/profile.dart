import 'dart:convert';
import 'dart:io';

import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _noTlp = TextEditingController();
  XFile? _image;

  @override
  void initState() {
    super.initState();

    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUser() async {
    Map<String, dynamic> res = await AuthUser().getCurrentUser();

    _username.value = TextEditingValue(text: res['username']);
    _email.value = TextEditingValue(text: res['email'] ?? "");
    _noTlp.value = TextEditingValue(text: res['no_tlp'] ?? "");
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

  Future<void> updateData() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');
    var request = http.MultipartRequest(
        "put", Uri.parse("${dotenv.env['API_URL']!}/api/user"));
    request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));
    request.fields['id'] = id!;
    request.fields['username'] = _username.text;
    request.fields['email'] = _email.text;
    request.fields['no_tlp'] = _noTlp.text;
    request.headers['Content-Type'] = "application/json";
    request.headers['Authorization'] = "Bearer $token";
    var res = await request.send();

    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Profil berhasil diupdate', true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, 'Profil gagal diupdate', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Profile Picture",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
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
              height: 20,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            TextField(
              controller: _username,
              decoration: InputDecoration(
                hintText: "Masukkan username",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFe2e8f0), width: 0.5),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Masukkan email",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFe2e8f0), width: 0.5),
                    borderRadius: BorderRadius.circular(10)),
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
            TextField(
              controller: _noTlp,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Masukkan nomor telepon",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFe2e8f0), width: 0.5),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        )),
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
              style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))),
                  backgroundColor: MaterialStatePropertyAll(Colors.orange),
                  foregroundColor: MaterialStatePropertyAll(Colors.white)),
              onPressed: () {
                updateData();
              },
              child: const Text("Save")),
        ),
      ),
    );
  }
}
