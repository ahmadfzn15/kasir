import 'dart:io';

import 'package:app/components/popup.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  List<dynamic> data = [
    {
      "id": 18,
      "nomor_struk": "p3aKyV",
      "id_toko": 1,
      "id_kasir": 1,
      "cash": 50000,
      "cashback": 18000,
      "total_harga": 32000,
      "status": "Lunas",
      "biaya_tambahan": 0,
      "deskripsi_biaya_tambahan": null,
      "diskon": 0,
      "total_pembayaran": 32000,
      "ket": null,
      "created_at": "2024-03-21T13:50:17.000000Z",
      "updated_at": "2024-03-21T13:50:17.000000Z"
    },
    {
      "id": 17,
      "nomor_struk": "W5yeiW",
      "id_toko": 1,
      "id_kasir": 1,
      "cash": 12000,
      "cashback": 0,
      "total_harga": 12000,
      "status": "Lunas",
      "biaya_tambahan": 0,
      "deskripsi_biaya_tambahan": null,
      "diskon": 0,
      "total_pembayaran": 12000,
      "ket": null,
      "created_at": "2024-03-21T10:38:18.000000Z",
      "updated_at": "2024-03-21T10:38:18.000000Z"
    },
    {
      "id": 2,
      "nomor_struk": "NY3hVV",
      "id_toko": 1,
      "id_kasir": 1,
      "cash": 18000,
      "cashback": 0,
      "total_harga": 18000,
      "status": "Lunas",
      "biaya_tambahan": 0,
      "deskripsi_biaya_tambahan": null,
      "diskon": 0,
      "total_pembayaran": 18000,
      "ket": null,
      "created_at": "2024-03-20T08:13:21.000000Z",
      "updated_at": "2024-03-20T08:13:21.000000Z"
    },
    {
      "id": 1,
      "nomor_struk": "BxsrM0",
      "id_toko": 1,
      "id_kasir": 1,
      "cash": 15000,
      "cashback": 0,
      "total_harga": 15000,
      "status": "Lunas",
      "biaya_tambahan": 0,
      "deskripsi_biaya_tambahan": null,
      "diskon": null,
      "total_pembayaran": 15000,
      "ket": null,
      "created_at": "2024-03-19T10:25:37.000000Z",
      "updated_at": "2024-03-19T10:25:37.000000Z"
    }
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> printExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    var head = [
      "No",
      "Nomor Struk",
      "Diterima",
      "Kembalian",
      "Status",
      "Total Pembayaran"
    ];

    for (var i = 0; i < head.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(head[i]);
    }

    for (var i = 0; i < data.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue((i + 1).toString());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(data[i]['nomor_struk']);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue("Rp.${data[i]['cash']}");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue("Rp.${data[i]['cashback']}");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(data[i]['status']);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = TextCellValue("Rp.${data[i]['total_pembayaran']}");
    }

    var fileBytes = excel.save();
    var vibrate = await const FlutterSecureStorage().read(key: 'vibrate');
    var sound = await const FlutterSecureStorage().read(key: 'sound');

    var externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      String downloadDirPath = "${externalDir.path}/Download";
      Directory downloadDir = Directory(downloadDirPath);
      if (!await downloadDir.exists()) {
        downloadDir.createSync(recursive: true);
      }

      String outputFile = "$downloadDirPath/data.xlsx";
      File file = File(outputFile);

      await file.writeAsBytes(fileBytes!);

      if (sound == "1") {
        final notif = AudioPlayer();
        await notif.play(AssetSource("sound/sound.mp3"));
      }
      bool? hasVibration = await Vibration.hasVibrator();

      if (hasVibration! && vibrate == "1") {
        Vibration.vibrate(duration: 200, amplitude: 100);
      }

      Popup().show(context, "File berhasil didownload", true);
    } else {
      Popup().show(context, "Gagal mengakses penyimpanan eksternal", false);
    }
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
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

  void openDialog() {
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                shrinkWrap: true,
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    title: Text(_devices[index].name!),
                  );
                },
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
        leading: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu)),
        title: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            "Bantuan",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Wrap(
        children: [
          CupertinoButton(
            color: Colors.orange,
            onPressed: () {
              printExcel();
            },
            child: const Text("Download data"),
          ),
          CupertinoButton(
            color: Colors.orange,
            onPressed: () {
              openDialog();
            },
            child: const Text("Cetak Struk"),
          )
        ],
      ),
    );
  }
}
