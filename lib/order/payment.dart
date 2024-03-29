import 'dart:convert';

import 'package:app/components/popup.dart';
import 'package:app/order/success.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.total, required this.order});
  final int total;
  final List order;

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
  final TextEditingController _cash = TextEditingController();
  final TextEditingController _cashback = TextEditingController(text: "0");
  final TextEditingController _discountValue = TextEditingController(text: "0");
  final TextEditingController _etcValue = TextEditingController(text: "0");
  final TextEditingController _deskripsi = TextEditingController(text: "");
  final TextEditingController _ket = TextEditingController(text: "");
  final List<DropdownMenuEntry<dynamic>> _metode = [
    const DropdownMenuEntry(value: 0, label: "Tunai"),
  ];

  int _selectedOption = 0;
  bool _pas = false;
  bool _discount = false;
  bool _etc = false;
  bool _hargaKurang = false;
  double total = 0;
  bool loading = false;

  Future<void> _uploadToDatabase(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String? token = await const FlutterSecureStorage().read(key: 'token');

    final res = await http.post(Uri.parse("${dotenv.env['API_URL']!}/api/sale"),
        body: jsonEncode({
          "cash": _cash.text,
          "cashback": _cashback.text,
          "total_harga": widget.total,
          "status": _metode[_selectedOption].label,
          "biaya_tambahan": _etcValue.text,
          "deskripsi_biaya_tambahan": _deskripsi.text,
          "diskon": _discountValue.text,
          "total_pembayaran": total == 0 ? widget.total : total,
          "ket": _ket.text,
          "order": widget.order
        }),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });

    Map<String, dynamic> result = jsonDecode(res.body);
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
      _cash.value = TextEditingValue(text: widget.total.toString());
      _cashback.value = const TextEditingValue(text: "0");
    } else {
      setState(() {
        _hargaKurang = true;
      });
      _cash.clear();
      _cashback.clear();
    }
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
                      Text("Metode Pembayaran",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: DropdownMenu(
                        leadingIcon: const Icon(Icons.payment),
                        expandedInsets: const EdgeInsets.all(0),
                        initialSelection:
                            _metode.isNotEmpty ? _metode[0].value : 0,
                        inputDecorationTheme: InputDecorationTheme(
                            constraints: const BoxConstraints(maxHeight: 50),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFe2e8f0), width: 0.5),
                                borderRadius: BorderRadius.circular(10))),
                        onSelected: (newValue) {
                          setState(() {
                            _selectedOption = newValue;
                          });
                        },
                        dropdownMenuEntries: _metode,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  SwitchListTile(
                    activeColor: Colors.orange,
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
                                  total = widget.total *
                                      ((100 - int.parse(value)) / 100);
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
                    height: 6,
                  ),
                  SwitchListTile(
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
                      });
                    },
                  ),
                  _etc
                      ? Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Masukkan Biaya Tambahan",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CupertinoTextField(
                              controller: _etcValue,
                              keyboardType: TextInputType.number,
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
                                    color: const Color(0xFFcbd5e1), width: 0.5),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 6,
                  ),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Uang Cash",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                                  if (int.parse(value) >= widget.total) {
                                    setState(() {
                                      _hargaKurang = false;
                                    });
                                    _cashback.value = TextEditingValue(
                                        text: (int.parse(value) - widget.total)
                                            .toString());
                                  }

                                  if (int.parse(value) < widget.total) {
                                    setState(() {
                                      _hargaKurang = true;
                                    });
                                  }

                                  if (int.parse(value) == 0 || value.isEmpty) {
                                    _cashback.clear();
                                  }
                                },
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: const Text(
                      "Jumlah Kembalian",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      "Rp.${_cashback.text}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Keterangan",
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
                      "Rp.${total == 0 ? widget.total.toString() : total.round()}",
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
                    _uploadToDatabase(context);
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
