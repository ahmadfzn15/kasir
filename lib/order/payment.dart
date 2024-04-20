import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/etc/format_number.dart';
import 'package:app/models/order_controller.dart';
import 'package:app/order/success.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.total});
  final int total;

  @override
  // ignore: library_private_types_in_public_api
  _PaymentState createState() => _PaymentState();
}

Route _goPage(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    opaque: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
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

class _PaymentState extends State<Payment> {
  final orderController = Get.put(OrderController());
  final TextEditingController _cash = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _cashback = TextEditingController(text: "");
  final TextEditingController _discountValue = TextEditingController(text: "");
  final TextEditingController _etcValue = TextEditingController(text: "");
  final TextEditingController _ket = TextEditingController(text: "");
  final List<DropdownMenuEntry<int>> _biaya = [
    const DropdownMenuEntry(value: 1, label: "Ongkir"),
    const DropdownMenuEntry(value: 2, label: "Lain-lain"),
  ];

  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '0');
    } else if (newValue.text == '0') {
      return newValue;
    } else {
      final num = int.tryParse(newValue.text);
      if (num == null) {
        return oldValue;
      } else if (num > 100) {
        return oldValue;
      } else {
        return newValue;
      }
    }
  }

  int? etcDescription;
  int _status = 1;
  bool _pas = false;
  bool _discount = false;
  bool _etc = false;
  bool _hargaKurang = false;
  int harga = 0;
  double total = 0;
  bool loading = false;

  @override
  initState() {
    super.initState();

    harga = widget.total;
  }

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(Uri.parse("${dotenv.env['API_URL']!}/api/sale"),
        body: jsonEncode({
          "nama_pelanggan": _name.text,
          "cash": _cash.text,
          "cashback": _cashback.text,
          "total_harga": widget.total,
          "status": _status == 1,
          "biaya_tambahan": _etcValue.text,
          "deskripsi_biaya_tambahan":
              etcDescription == 1 ? "Ongkir" : "Lain-lain",
          "diskon": _discountValue.text,
          "total_pembayaran": total == 0 ? harga : total,
          "ket": _ket.text,
          "order":
              orderController.order.map((element) => element.toMap()).toList()
        }),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });

    Map<String, dynamic> result = jsonDecode(res.body);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], true);
      setState(() {
        loading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(_goPage(Success(
        detail: result['data'],
      )));
    } else {
      // ignore: use_build_context_synchronously
      Popup().show(context, result['message'], false);
    }
  }

  void changeCash() {
    setState(() {
      _pas = !_pas;
    });
    if (_pas) {
      setState(() {
        _hargaKurang = false;
      });
      _cash.value = TextEditingValue(
          text:
              total != 0 ? total.round().toString() : widget.total.toString());
      _cashback.value = const TextEditingValue(text: "0");
    } else {
      setState(() {
        _hargaKurang = true;
      });
      _cash.clear();
      _cashback.clear();
    }
  }

  void _openConfirmDialog(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      constraints:
          const BoxConstraints(maxHeight: 350, minWidth: double.infinity),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    _status == 1 ? "Lunas" : "Belum Lunas (Utang)",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Nama Pelanggan",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_name.text.isNotEmpty ? _name.text : "-",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Bayar",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "Rp.${total == 0 ? formatNumber(harga) : formatNumber(total.round())}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Uang diterima",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _cashback.text.isNotEmpty
                          ? Text(
                              "Rp.${formatNumber(int.parse(_cash.text))}",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          : const Text("-")
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kembalian",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _cashback.text.isNotEmpty
                          ? Text(
                              "Rp.${formatNumber(int.parse(_cashback.text))}",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          : const Text("-")
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    "Apakah anda yakin ingin melanjutkan transaksi ini?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        color: Colors.red,
                        child: const Text("Batal"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        color: Colors.orange,
                        child: const Text("Bayar"),
                        onPressed: () {
                          _uploadToDatabase(context);
                        },
                      ))
                    ],
                  )
                ],
              )
            ],
          ),
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
          "Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              CupertinoIcons.back,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Nama Pelanggan (Opsional)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  CupertinoTextField(
                    controller: _name,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.person),
                    ),
                    placeholder: "Masukkan nama pelanggan",
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFcbd5e1), width: 0.5),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Status Pembayaran",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      RadioMenuButton(
                        value: 1,
                        groupValue: _status,
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                        child: const Text("Lunas"),
                      ),
                      RadioMenuButton(
                        value: 0,
                        groupValue: _status,
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                            _cash.clear();
                            _cashback.clear();
                            _pas = false;
                          });
                        },
                        child: const Text("Utang"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SwitchListTile(
                    activeColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    value: _discount,
                    title: const Wrap(
                      direction: Axis.horizontal,
                      children: [
                        Icon(Icons.discount),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Diskon",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _discount = value;
                        _discountValue.clear();
                        total = 0;
                      });
                    },
                  ),
                  _discount
                      ? Column(children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Masukkan Diskon",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          CupertinoTextField(
                            controller: _discountValue,
                            keyboardType: TextInputType.number,
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.discount),
                            ),
                            suffix: const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.percent),
                            ),
                            onChanged: (value) {
                              if (int.parse(value) > 0 &&
                                  int.parse(value) <= 100) {
                                setState(() {
                                  if (total != 0) {
                                    total = total *
                                        ((100 - int.parse(value)) / 100);
                                  } else {
                                    total = harga *
                                        ((100 - int.parse(value)) / 100);
                                  }
                                });
                              } else {
                                setState(() {
                                  total = 0;
                                });
                              }
                            },
                            placeholder: "0",
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFcbd5e1), width: 0.5),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ])
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  SwitchListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    activeColor: Colors.orange,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    value: _etc,
                    title: const Wrap(
                      direction: Axis.horizontal,
                      children: [
                        Icon(Icons.add_card),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Biaya Tambahan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _etc = value;
                        if (value) {
                          etcDescription = 1;
                        } else {
                          etcDescription = null;
                        }

                        if (_etcValue.text.isNotEmpty) {
                          if (total != 0) {
                            total -= double.parse(_etcValue.text);
                          }
                          harga -= int.parse(_etcValue.text);
                          _etcValue.clear();
                        }
                      });
                    },
                  ),
                  _etc
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text("Masukkan Biaya Tambahan",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    CupertinoTextField(
                                      controller: _etcValue,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value.isNotEmpty) {
                                            if (total ==
                                                harga +
                                                    double.parse(
                                                        _etcValue.text)) {
                                              total -=
                                                  double.parse(_etcValue.text);
                                            }
                                            total = double.parse(
                                                (harga + int.parse(value))
                                                    .toString());
                                          } else {
                                            total -= double.parse(
                                                (int.parse(_etcValue.text))
                                                    .toString());
                                          }
                                        });
                                      },
                                      prefix: const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text("Rp."),
                                      ),
                                      placeholder: "0",
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 15, bottom: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFcbd5e1),
                                            width: 0.5),
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                flex: 3,
                                child: DropdownMenu(
                                    expandedInsets: const EdgeInsets.all(0),
                                    initialSelection: etcDescription,
                                    inputDecorationTheme: InputDecorationTheme(
                                        constraints:
                                            const BoxConstraints(maxHeight: 50),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xFFcbd5e1),
                                                width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onSelected: (newValue) {
                                      setState(() {
                                        etcDescription = newValue!;
                                      });
                                    },
                                    dropdownMenuEntries: _biaya))
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 15,
                  ),
                  _status == 1
                      ? Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: FilterChip(
                                      selected: _pas,
                                      padding: const EdgeInsets.all(12),
                                      side: BorderSide.none,
                                      elevation: 5,
                                      label: const Text("Uang Pas ?"),
                                      onSelected: (value) {
                                        changeCash();
                                      },
                                    )),
                                Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text("Uang Cash",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        CupertinoTextField(
                                          controller: _cash,
                                          keyboardType: TextInputType.number,
                                          prefix: const Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text("Rp."),
                                          ),
                                          readOnly: _pas,
                                          onChanged: (value) {
                                            if (int.parse(value) >=
                                                widget.total) {
                                              setState(() {
                                                _hargaKurang = false;
                                              });
                                              _cashback.value =
                                                  TextEditingValue(
                                                      text: (int.parse(value) -
                                                              (total == 0
                                                                  ? harga
                                                                  : total
                                                                      .round()))
                                                          .toString());
                                            }

                                            if (int.parse(value) <
                                                (total == 0
                                                    ? harga
                                                    : total.round())) {
                                              setState(() {
                                                _hargaKurang = true;
                                                _cashback.clear();
                                              });
                                            }

                                            if (int.parse(value) == 0 ||
                                                value.isEmpty ||
                                                _cash.text.isEmpty) {
                                              setState(() {
                                                _cashback.clear();
                                                _hargaKurang = false;
                                              });
                                            }
                                          },
                                          placeholder: "0",
                                          padding: const EdgeInsets.only(
                                              right: 10, top: 15, bottom: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: const Color(0xFFcbd5e1),
                                                width: 0.5),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _hargaKurang && _cash.text.isNotEmpty
                                    ? const Text(
                                        "Nominal uang kurang.",
                                        style: TextStyle(color: Colors.red),
                                        textAlign: TextAlign.start,
                                      )
                                    : Container()
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              title: const Text(
                                "Jumlah Kembalian",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: _cashback.text.isNotEmpty
                                  ? Text(
                                      "Rp.${formatNumber(int.parse(_cashback.text))}",
                                      style: const TextStyle(fontSize: 15),
                                    )
                                  : const Text("-"),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        )
                      : Container(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Keterangan (Opsional)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      CupertinoTextField(
                        controller: _ket,
                        placeholder: "Masukkan keterangan",
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFcbd5e1), width: 0.5),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: SizedBox(
          height: 100,
          child: Column(
            children: [
              const Divider(
                color: Color(0xFFcbd5e1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                      "Rp.${total == 0 ? formatNumber(harga) : formatNumber(total.round())}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Colors.orange,
                  child: const Text("Bayar"),
                  onPressed: () {
                    if (_status == 1) {
                      if (_cash.text.isNotEmpty) {
                        _openConfirmDialog(context);
                      } else {
                        Popup().show(context, "Uang cash wajib diisi!", false);
                      }
                    } else {
                      _openConfirmDialog(context);
                    }
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
