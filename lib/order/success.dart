import 'dart:typed_data';

import 'package:app/components/popup.dart';
import 'package:app/etc/format_number.dart';
import 'package:app/etc/format_time.dart';
import 'package:app/models/order_controller.dart';
import 'package:app/order/receipt.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class Success extends StatefulWidget {
  const Success({super.key, required this.detail});
  final Map<String, dynamic> detail;

  @override
  // ignore: library_private_types_in_public_api
  _SuccessState createState() => _SuccessState();
}

Route _goPage(int id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Receipt(id: id),
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
  final orderController = Get.put(OrderController());
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  final ScreenshotController _screenShot = ScreenshotController();
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();

    initPlatformState();
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
                    Text(formatTime(widget.detail['created_at'])),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status"),
                        Text(widget.detail['status']
                            ? "Lunas"
                            : "Belum Lunas (Utang)")
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Tagihan"),
                        Text(
                            "Rp.${formatNumber(widget.detail['total_pembayaran'])}")
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Diterima"),
                        Text(
                            "Rp.${widget.detail['cash'] != null ? formatNumber(int.parse(widget.detail['cash'])) : "-"}")
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Kembalian"),
                        Text(
                            "Rp.${widget.detail['cashback'] != null ? formatNumber(int.parse(widget.detail['cashback'])) : "-"}")
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
                            .push(_goPage(widget.detail['id']));
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
                      onPressed: () {
                        openPrint();
                      },
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
                    orderController.sheetOrderOpen.value = false;
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    orderController.order.clear();
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
