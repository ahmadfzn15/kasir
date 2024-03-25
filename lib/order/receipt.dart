import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:app/etc/format_time.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class Receipt extends StatefulWidget {
  const Receipt({super.key, required this.id});
  final int id;

  @override
  // ignore: library_private_types_in_public_api
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  final ScreenshotController _screenShot = ScreenshotController();
  String url = dotenv.env['API_URL']!;
  Map<String, dynamic> user = {};
  Map<String, dynamic> data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();

    fetchDataUser();
    fetchData();
    initPlatformState();
  }

  Future<void> fetchDataUser() async {
    Map<String, dynamic> res = await AuthUser().getCurrentUser();

    setState(() {
      user = res;
    });
  }

  Future<void> fetchData() async {
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/sale/${widget.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        data = res['data'];

        setState(() {
          loading = false;
        });
      } else {
        throw Exception(res['message']);
      }
    }
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    devices = await bluetooth.getBondedDevices();

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> _printReceipt(BluetoothDevice device) async {
    PermissionStatus permissionStatus = await Permission.bluetooth.request();

    if (permissionStatus.isGranted) {
      BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

      bool? isAvailable = await bluetooth.isAvailable;

      if (isAvailable!) {
        try {
          await bluetooth.connect(device);
          final Uint8List? img = await _screenShot.capture();
          await bluetooth.printImageBytes(img!);
          await bluetooth.disconnect();
          // ignore: use_build_context_synchronously
          Popup().show(context, "Cetak berhasil", true);
        } catch (e) {
          // ignore: use_build_context_synchronously
          Popup().show(context, "Gagal mencetak struk", false);
        }
      } else {
        // ignore: use_build_context_synchronously
        Popup().show(context, "Bluetooth tidak tersedia", false);
      }
    } else {
      showCupertinoModalPopup(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CupertinoAlertDialog(
            title: const Text("Akses ditolak"),
            content: const Text(
                "Mohon untuk mengizinkan dan mengaktifkan bluetooth untuk mencetak struk."),
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

  Future<void> shareStruk() async {
    final image = await _screenShot.captureAsUiImage();
    final byte = await image!.toByteData(format: ImageByteFormat.png);
    final file = byte!.buffer.asUint8List();
    Share.shareXFiles(
        [XFile.fromData(file, name: "Struk", mimeType: 'image/png')],
        text: "Struk Penjualan", subject: "Struk Penjualan");
  }

  void openPrint() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text("Pilih Printer"),
          ),
          content: Material(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 250,
              child: _devices.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 5),
                      shrinkWrap: true,
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            _printReceipt(_devices[index]);
                          },
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          title: Text(_devices[index].name!),
                        );
                      },
                    )
                  : const Center(
                      child: Text("Tidak ada printer yang tersedia"),
                    ),
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal")),
            CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  initPlatformState();
                },
                child: const Text("Refresh"))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.grey,
          elevation: 1,
          title: const Text(
            "Struk",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
              )),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            shareStruk();
          },
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: const CircleBorder(eccentricity: 0),
          child: const Icon(
            Icons.share_outlined,
            size: 30,
          ),
        ),
        body: !loading
            ? SingleChildScrollView(
                child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Screenshot(
                    controller: _screenShot,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              user.isNotEmpty
                                  ? user['market']['nama_toko']
                                  : "",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user.isNotEmpty ? user['market']['alamat'] : "",
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Divider(
                              color: Color(0xFFcbd5e1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Kasir"),
                                Text(data['sale']['cashier']['nama'])
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Waktu"),
                                Text(formatTime(data['sale']['created_at']))
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Nomor Struk"),
                                Text(data['sale']['kode'])
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Status"),
                                Text(data['sale']['status'])
                              ],
                            ),
                            const Divider(
                              color: Color(0xFFcbd5e1),
                            ),
                            ListView.builder(
                              itemCount: data['detail'].length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Text(
                                    data['detail'][index]['product']
                                        ['namaProduk'],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  subtitle: Text(
                                    "Rp.${data['detail'][index]['product']['harga_jual']} x ${data['detail'][index]['qty']}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  trailing: Text(
                                    "Rp.${data['detail'][index]['product']['harga_jual'] * data['detail'][index]['qty']}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: Color(0xFFcbd5e1),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Subtotal"),
                                Text("Rp.${data['sale']['total_harga']}")
                              ],
                            ),
                            const Divider(
                              color: Color(0xFFcbd5e1),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total (${data['detail'].fold(0, (previousValue, element) => previousValue + element['qty'] as int)} Produk)",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(
                                  "Rp.${data['sale']['total_pembayaran']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              ],
                            ),
                            const Divider(
                              color: Color(0xFFcbd5e1),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Bayar"),
                                Text("Rp.${data['sale']['cash']}")
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Kembalian"),
                                Text("Rp.${data['sale']['cashback']}")
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              "Terima kasih telah berbelanja di toko ini",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    )),
              ))
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton(
                color: Colors.orange,
                onPressed: () {
                  openPrint();
                },
                child: const Text("Cetak Struk")),
          ),
        ));
  }
}
