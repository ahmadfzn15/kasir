import 'dart:typed_data';
import 'dart:ui';

import 'package:app/components/popup.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class Struk extends StatefulWidget {
  const Struk({super.key, required this.data, required this.date});
  final Map<String, dynamic> data;
  final DateTime date;

  @override
  // ignore: library_private_types_in_public_api
  _StrukState createState() => _StrukState();
}

class _StrukState extends State<Struk> {
  final ScreenshotController _screenShot = ScreenshotController();

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

  Future<void> shareStruk() async {
    final image = await _screenShot.captureAsUiImage();
    final byte = await image!.toByteData(format: ImageByteFormat.png);
    final file = byte!.buffer.asUint8List();
    Share.shareXFiles(
        [XFile.fromData(file, name: "Struk", mimeType: 'image/png')],
        text: "Struk Penjualan", subject: "Struk Penjualan");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.grey,
          elevation: 1,
          title: const Text(
            "Detail Histori Pembayaran",
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
        body: SingleChildScrollView(
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
                      const Text(
                        "Sunda Food",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Warung Makanan Sunda",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(
                        color: Color(0xFFcbd5e1),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Kasir"), Text("Ahmad Fauzan")],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Waktu"),
                          Text(
                              "${widget.date.day}-${widget.date.month}-${widget.date.year}, ${widget.date.hour}:${widget.date.minute}:${widget.date.second}")
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Nomor Struk"), Text("INV-001")],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Metode Pembayaran"),
                          Text(widget.data['metode_pembayaran'])
                        ],
                      ),
                      const Divider(
                        color: Color(0xFFcbd5e1),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Lunas",
                        style: TextStyle(fontSize: 22),
                      ),
                      const Divider(
                        color: Color(0xFFcbd5e1),
                      ),
                      ListView.builder(
                        itemCount: widget.data['order'].length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(
                              widget.data['order'][index]['namaProduk'],
                              style: const TextStyle(fontSize: 15),
                            ),
                            subtitle: Text(
                              "Rp.${widget.data['order'][index]['harga']} x ${widget.data['order'][index]['qty']}",
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              "Rp.${widget.data['order'][index]['harga'] * widget.data['order'][index]['qty']}",
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
                          Text("Rp.${widget.data['total']}")
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
                            "Total (${widget.data['order'].fold(0, (previousValue, element) => previousValue + element['qty'] as int)} Produk)",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            "Rp.${widget.data['total']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
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
                          Text("Rp.${widget.data['cash']}")
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kembalian"),
                          Text("Rp.${widget.data['cashback']}")
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
        )),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton(
                color: Colors.orange,
                onPressed: () {
                  _printReceipt();
                },
                child: const Text("Cetak Struk")),
          ),
        ));
  }
}
