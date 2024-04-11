import 'dart:convert';
import 'dart:io';

import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:app/etc/format_time.dart';
import 'package:app/order/receipt.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryState createState() => _HistoryState();
}

Route _goPage(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
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

class _HistoryState extends State<History> {
  String url = dotenv.env['API_URL']!;
  Map<String, dynamic> sale = {};
  Map<String, dynamic> user = {};
  List<dynamic> history = [];
  bool loading = true;
  bool _selectAll = false;
  bool _select = false;

  @override
  void initState() {
    super.initState();

    getUser();
    fetchDataHistory();
    fetchDataSale();
  }

  Future<void> getUser() async {
    Map<String, dynamic> res = await AuthUser().getCurrentUser();
    setState(() {
      user = res;
    });
  }

  Future<void> _refresh() async {
    fetchDataHistory();
  }

  Future<void> fetchDataSale() async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.get(
      Uri.parse("$url/api/sale/statistics"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        sale = res['data'];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      throw Exception(res['message']);
    }
  }

  Future<void> fetchDataHistory() async {
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/sale"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          history = (res['data'] as List<dynamic>)
              .map((e) => {...e, "selected": false})
              .toList();

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        throw Exception(res['message']);
      }
    }
  }

  void _openOption(BuildContext context, int id) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxHeight: 120),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  openDelete(context, id);
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
        );
      },
    );
  }

  void openDelete(BuildContext context, int id) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
          title: const Text("Hapus Histori"),
          content: const Text("Apakah yakin anda ingin menghapus histori ini?"),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  deleteHistory(context, id);
                },
                child: const Text("Yes"))
          ]),
    );
  }

  Future<void> deleteHistory(BuildContext context, int id) async {
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.delete(
      Uri.parse("$url/api/sale/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _refresh();
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], true);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, res['message'], false);
    }
  }

  void showSheetOrder(BuildContext context) {
    if (history.any((element) => element['selected'])) {
      showBottomSheet(
        backgroundColor: Colors.white,
        elevation: 5,
        enableDrag: false,
        context: context,
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10, right: 10),
              child: SizedBox(
                height: 80,
                child: ListTile(
                  trailing: FilledButton(
                      style: const ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red)),
                      onPressed: () {},
                      child: const Text("Hapus")),
                ),
              ));
        },
      );
    } else {
      Navigator.pop(context);
    }
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

    for (var i = 0; i < history.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue((i + 1).toString());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(history[i]['nomor_struk']);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue("Rp.${history[i]['cash']}");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue("Rp.${history[i]['cashback']}");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(history[i]['status']);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = TextCellValue("Rp.${history[i]['total_pembayaran']}");
    }

    var fileBytes = excel.save();
    var status = await Permission.storage.request();
    var vibrate = await const FlutterSecureStorage().read(key: 'vibrate');
    var sound = await const FlutterSecureStorage().read(key: 'sound');

    if (status.isGranted) {
      var date = DateTime.now();
      var path = await getApplicationDocumentsDirectory();

      String outputFile =
          "${path.path}/data_penjualan_${date.toIso8601String()}.xlsx";

      if (fileBytes != null) {
        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        if (sound == "1") {
          final notif = AudioPlayer();
          await notif.play(AssetSource("sound/sound.mp3"));
        }
        bool? hasVibration = await Vibration.hasVibrator();

        if (hasVibration! && vibrate == "1") {
          Vibration.vibrate(duration: 200, amplitude: 100);
        }

        // ignore: use_build_context_synchronously
        Popup().show(context, "File berhasil didownload", true);
      } else {
        // ignore: use_build_context_synchronously
        Popup().show(context, "File gagal didownload", false);
      }
      // ignore: use_build_context_synchronously
    } else if (status.isDenied) {
      openAppSettings();
      // ignore: use_build_context_synchronously
      Popup().show(context, "File gagal didownload", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: _select
            ? Checkbox(
                value: _selectAll,
                checkColor: Colors.orange,
                fillColor: const MaterialStatePropertyAll(Colors.white),
                onChanged: (value) {
                  setState(() {
                    _selectAll = value!;
                    if (_selectAll) {
                      history.map((e) => e['selected'] = true).toList();
                    } else {
                      history.map((e) => e['selected'] = false).toList();
                    }
                  });
                },
              )
            : IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu)),
        title: _select
            ? Text(
                "${history.where((element) => element['selected']).length} Dipilih")
            : const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Histori",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
        actions: [
          _select
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      history.map((e) => e['selected'] = false).toList();
                      _select = false;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Batalkan",
                    style: TextStyle(color: Colors.white),
                  ))
              : Container()
        ],
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: !loading
          ? history.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () {
                    return _refresh();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        user['role'] == 'admin'
                            ? Column(
                                children: [
                                  GridView(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              mainAxisExtent: 80,
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 5,
                                              mainAxisSpacing: 5),
                                      children: [
                                        Card(
                                          surfaceTintColor: Colors.white,
                                          shadowColor: const Color(0xFFf1f5f9),
                                          child: ListTile(
                                            title: const Text(
                                              "Transaksi Lunas",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              sale.isNotEmpty
                                                  ? sale['transaksi_lunas']
                                                      .toString()
                                                  : "0",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          surfaceTintColor: Colors.white,
                                          shadowColor: const Color(0xFFf1f5f9),
                                          child: ListTile(
                                            title: const Text(
                                              "Produk Terjual",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              sale.isNotEmpty
                                                  ? sale['produk_terjual']
                                                          ['jumlah']
                                                      .toString()
                                                  : "0",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          surfaceTintColor: Colors.white,
                                          shadowColor: const Color(0xFFf1f5f9),
                                          child: ListTile(
                                            title: const Text(
                                              "Omset",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              "Rp.${sale.isNotEmpty ? sale['omset'].toString() : "0"}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          surfaceTintColor: Colors.white,
                                          shadowColor: const Color(0xFFf1f5f9),
                                          child: ListTile(
                                            title: const Text(
                                              "Keuntungan",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              "Rp.${sale.isNotEmpty ? sale['laba'].toString() : "0"}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      ]),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CupertinoButton(
                                      color: Colors.orange,
                                      onPressed: () {
                                        printExcel();
                                      },
                                      child: const Text("Download Excel"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              )
                            : Container(),
                        Expanded(
                            child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: history.length,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          itemBuilder: (context, index) {
                            return Wrap(
                              children: [
                                user.isNotEmpty && user['role'] == 'admin'
                                    ? Card(
                                        clipBehavior: Clip.antiAlias,
                                        surfaceTintColor: Colors.white,
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 10),
                                          onLongPress: () {
                                            setState(() {
                                              _select = true;
                                              history[index]['selected'] = true;
                                            });
                                            showSheetOrder(context);
                                          },
                                          onTap: () {
                                            if (history[index]['selected']) {
                                              setState(() {
                                                history[index]['selected'] =
                                                    false;
                                              });
                                              showSheetOrder(context);
                                            } else if (history.any((element) =>
                                                element['selected'])) {
                                              setState(() {
                                                history[index]['selected'] =
                                                    true;
                                              });
                                              showSheetOrder(context);
                                            } else {
                                              Navigator.of(context).push(
                                                  _goPage(Receipt(
                                                      id: history[index]
                                                          ['id'])));
                                            }
                                          },
                                          selected: history[index]['selected'],
                                          selectedTileColor: Colors.black26,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          title: Text(
                                            history[index]['kode'].toString(),
                                          ),
                                          subtitle: Text(
                                              "Rp.${history[index]['total_pembayaran']}",
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold)),
                                          trailing: Wrap(
                                            direction: Axis.vertical,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: [
                                              Text(history[index]['status'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  )),
                                              Text(
                                                formatTime(history[index]
                                                    ['created_at']),
                                              ),
                                              Text(
                                                  "Dibuat oleh ${history[index]['cashier']['nama']}"),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Card(
                                        clipBehavior: Clip.antiAlias,
                                        surfaceTintColor: Colors.white,
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 10),
                                          onTap: () {
                                            Navigator.of(context).push(_goPage(
                                                Receipt(
                                                    id: history[index]['id'])));
                                          },
                                          selectedTileColor: Colors.black26,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          title: Text(
                                            history[index]['kode'].toString(),
                                          ),
                                          subtitle: Text(
                                              "Rp.${history[index]['total_pembayaran']}",
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold)),
                                          trailing: Wrap(
                                            direction: Axis.vertical,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: [
                                              Text(history[index]['status'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  )),
                                              Text(
                                                formatTime(history[index]
                                                    ['created_at']),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          },
                        ))
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text("Data Kosong"),
                )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }
}
