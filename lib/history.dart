import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/order/struk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  const History({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryState createState() => _HistoryState();
}

Route _goPage(int id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Struk(),
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
  List<dynamic> history = [];
  bool loading = false;
  bool _selectAll = false;
  bool _select = false;

  @override
  void initState() {
    super.initState();

    fetchDataHistory();
  }

  Future<void> _refresh() async {
    fetchDataHistory();
  }

  Future<void> fetchDataHistory() async {
    setState(() {
      loading = true;
    });
    bool hasToken =
        await const FlutterSecureStorage().containsKey(key: 'token');
    String? token = await const FlutterSecureStorage().read(key: 'token');
    String? id = await const FlutterSecureStorage().read(key: 'id');

    if (hasToken) {
      final response = await http.get(
        Uri.parse("$url/api/sale/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        history = (res['data'] as List<dynamic>)
            .map((e) => {...e, "selected": false})
            .toList();

        setState(() {
          loading = false;
        });
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Card(
                      surfaceTintColor: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          return Wrap(
                            children: [
                              Dismissible(
                                  key: Key(history[index]['id'].toString()),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    final details = await Future.delayed(
                                      const Duration(seconds: 3),
                                      () {
                                        null;
                                      },
                                    );

                                    return details != null;
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    history.removeAt(index);
                                  },
                                  child: ListTile(
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
                                          history[index]['selected'] = false;
                                        });
                                        showSheetOrder(context);
                                      } else if (history.any(
                                          (element) => element['selected'])) {
                                        setState(() {
                                          history[index]['selected'] = true;
                                        });
                                        showSheetOrder(context);
                                      } else {
                                        Navigator.of(context).push(
                                            _goPage(history[index]['id']));
                                      }
                                    },
                                    selected: history[index]['selected'],
                                    selectedTileColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    title: Text(
                                      "Rp.${history[index]['total_pembayaran'].toString()}",
                                      style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        history[index]['metode_pembayaran']),
                                  )),
                              if (index != history.length - 1) const Divider()
                            ],
                          );
                        },
                      ),
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
