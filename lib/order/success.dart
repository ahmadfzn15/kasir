import 'dart:typed_data';

import 'package:app/components/popup.dart';
import 'package:app/order/struk.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class Success extends StatefulWidget {
  const Success({super.key, required this.detail});
  final Map<String, dynamic> detail;

  @override
  // ignore: library_private_types_in_public_api
  _SuccessState createState() => _SuccessState();
}

Route _goPage(Map<String, dynamic> data, DateTime date) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Struk(data: data, date: date),
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOutExpo));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class _SuccessState extends State<Success> {
  final ScreenshotController _screenShot = ScreenshotController();
  DateTime date = DateTime.now();

  Future<void> _printReceipt() async {
    PermissionStatus permissionStatus = await Permission.bluetooth.request();

    if (permissionStatus.isGranted) {
      BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

      bool? isAvailable = await bluetooth.isAvailable;

      if (isAvailable!) {
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
        if (devices.isNotEmpty) {
          BluetoothDevice device = devices.first;
          await bluetooth.connect(device);
          final Uint8List? img = await _screenShot.capture();
          await bluetooth.printImageBytes(img!);
          await bluetooth.disconnect();
          // ignore: use_build_context_synchronously
          Popup().show(context, "Cetak berhasil", true);
        } else {
          // ignore: use_build_context_synchronously
          Popup().show(context, "Tidak ada printer Bluetooth terhubung", false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Screenshot(
            controller: _screenShot,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Colors.lightGreen,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "Transaksi Berhasil",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                        "${date.day}-${date.month}-${date.year}, ${date.hour}:${date.minute}:${date.second}"),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Metode Pembayaran"),
                        Text(widget.detail['data']['metode_pembayaran'])
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Tagihan"),
                        Text("Rp.${widget.detail['data']['total']}")
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Diterima"),
                        Text("Rp.${widget.detail['data']['cash']}")
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Kembalian"),
                        Text("Rp.${widget.detail['data']['cashback']}")
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: SizedBox(
          height: 110,
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                      style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))))),
                      onPressed: () {
                        Navigator.of(context)
                            .push(_goPage(widget.detail['data'], date));
                      },
                      child: const Text("Lihat Struk"),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: FilledButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.orange),
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))))),
                      onPressed: () {},
                      child: const Text("Cetak Struk"),
                    )),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Colors.orange,
                  child: const Text("Transaksi Lagi"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
