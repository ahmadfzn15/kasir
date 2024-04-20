import 'dart:convert';
import 'dart:io';

import 'package:app/components/popup.dart';
import 'package:app/etc/auth_user.dart';
import 'package:app/etc/format_number.dart';
import 'package:app/etc/format_time.dart';
import 'package:app/order/receipt.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool sheetOrderOpen = false;
  Map<String, dynamic> sale = {};
  Map<String, dynamic> user = {};
  List<dynamic> history = [];
  List<dynamic> sortResult = [];
  bool loading = true;
  bool _selectAll = false;
  bool _select = false;
  String _selectedStatus = "Semua";
  int? _selectedStatusId;
  final DateTime firstDate = DateTime(1970);
  final DateTime lastDate = DateTime(2100);
  DateTime fromDate = DateTime(
    DateTime.now().year,
    DateTime.now().month - 1,
    DateTime.now().day,
  );
  DateTime toDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    getUser();
    fetchDataHistory();
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

  void sortByStatus() {
    setState(() {
      if (_selectedStatusId != null) {
        sortResult = history
            .where((element) => element['status'] == _selectedStatusId)
            .toList();
      } else {
        sortResult = history;
      }
    });
  }

  void sortByDate() {
    setState(() {
      sortResult = history
          .where((element) =>
              DateTime.parse(element['created_at'])
                  .isAfter(fromDate.subtract(const Duration(days: 1))) &&
              DateTime.parse(element['created_at'])
                  .isBefore(toDate.add(const Duration(days: 1))))
          .toList();
    });
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
          sortByDate();

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
          .value = TextCellValue(history[i]['kode']);
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

    if (status.isGranted) {
      var date = DateTime.now();
      var path = await getApplicationDocumentsDirectory();

      String outputFile =
          "${path.path}/data_penjualan_${date.toIso8601String()}.xlsx";

      if (fileBytes != null) {
        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

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
          ? RefreshIndicator(
              onRefresh: () {
                return _refresh();
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MenuAnchor(
                              builder: (context, controller, child) {
                                return GestureDetector(
                                  onTap: () {
                                    if (controller.isOpen) {
                                      controller.close();
                                    } else {
                                      controller.open();
                                    }
                                  },
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    direction: Axis.horizontal,
                                    children: [
                                      Text(
                                        _selectedStatus,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Icon(Icons.chevron_right),
                                      Chip(
                                        label:
                                            Text(sortResult.length.toString()),
                                        labelStyle: const TextStyle(
                                            color: Colors.white),
                                        padding: const EdgeInsets.all(6),
                                        shape:
                                            const CircleBorder(eccentricity: 0),
                                        labelPadding: const EdgeInsets.all(0),
                                        color: const MaterialStatePropertyAll(
                                            Colors.orange),
                                      )
                                    ],
                                  ),
                                );
                              },
                              menuChildren: [
                                MenuItemButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatus = "Semua";
                                      _selectedStatusId = null;
                                    });
                                    sortByStatus();
                                  },
                                  child: const Text("Semua"),
                                ),
                                MenuItemButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatus = "Lunas";
                                      _selectedStatusId = 1;
                                    });
                                    sortByStatus();
                                  },
                                  child: const Text("Lunas"),
                                ),
                                MenuItemButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatus = "Belum Lunas";
                                      _selectedStatusId = 0;
                                    });
                                    sortByStatus();
                                  },
                                  child: const Text("Belum Lunas"),
                                ),
                              ]),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            surfaceTintColor: Colors.white,
                            child: Row(
                              children: [
                                TextButton(
                                  child: Text(
                                      "${fromDate.day}/${fromDate.month}/${fromDate.year}"),
                                  onPressed: () async {
                                    DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate: fromDate,
                                        firstDate: firstDate,
                                        lastDate: lastDate);

                                    setState(() {
                                      fromDate = date!;
                                    });
                                    sortByDate();
                                  },
                                ),
                                const Text(" - "),
                                TextButton(
                                  child: Text(
                                      "${toDate.day}/${toDate.month}/${toDate.year}"),
                                  onPressed: () async {
                                    DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate: toDate,
                                        firstDate: firstDate,
                                        lastDate: lastDate);

                                    setState(() {
                                      toDate = date!;
                                    });
                                    sortByDate();
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    sortResult.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: sortResult.length,
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
                                                    vertical: 0,
                                                    horizontal: 10),
                                            onLongPress: () {
                                              setState(() {
                                                _select = true;
                                                sortResult[index]['selected'] =
                                                    true;
                                              });
                                              showSheetOrder(context);
                                            },
                                            onTap: () {
                                              if (sortResult[index]
                                                  ['selected']) {
                                                setState(() {
                                                  sortResult[index]
                                                      ['selected'] = false;
                                                });
                                                showSheetOrder(context);
                                              } else if (sortResult.any(
                                                  (element) =>
                                                      element['selected'])) {
                                                setState(() {
                                                  sortResult[index]
                                                      ['selected'] = true;
                                                });
                                                showSheetOrder(context);
                                              } else {
                                                Navigator.of(context).push(
                                                    _goPage(Receipt(
                                                        id: sortResult[index]
                                                            ['id'])));
                                              }
                                            },
                                            selected: sortResult[index]
                                                ['selected'],
                                            selectedTileColor: Colors.black26,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            title: Text(
                                              sortResult[index]['kode']
                                                  .toString(),
                                            ),
                                            subtitle: Text(
                                                "Rp.${formatNumber(sortResult[index]['total_pembayaran'])}",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.orange,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            trailing: Wrap(
                                              direction: Axis.vertical,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.end,
                                              children: [
                                                Text(
                                                    sortResult[index]
                                                                ['status'] ==
                                                            1
                                                        ? "Lunas"
                                                        : "Belum Lunas",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    )),
                                                Text(
                                                  formatTime(sortResult[index]
                                                      ['created_at']),
                                                ),
                                                Text(
                                                    "Dibuat oleh ${sortResult[index]['cashier']['nama']}"),
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
                                                    vertical: 0,
                                                    horizontal: 10),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  _goPage(Receipt(
                                                      id: sortResult[index]
                                                          ['id'])));
                                            },
                                            selectedTileColor: Colors.black26,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            title: Text(
                                              sortResult[index]['kode']
                                                  .toString(),
                                            ),
                                            subtitle: Text(
                                                "Rp.${sortResult[index]['total_pembayaran']}",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.orange,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            trailing: Wrap(
                                              direction: Axis.vertical,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.end,
                                              children: [
                                                Text(
                                                    sortResult[index]
                                                                ['status'] ==
                                                            1
                                                        ? "Lunas"
                                                        : "Belum Lunas",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    )),
                                                Text(
                                                  formatTime(sortResult[index]
                                                      ['created_at']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              );
                            },
                          )
                        : const Center(
                            child: Text("Data Kosong"),
                          )
                  ],
                ),
              ))
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }
}
