import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.total});
  final int total;

  @override
  // ignore: library_private_types_in_public_api
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final TextEditingController _cash = TextEditingController();
  final TextEditingController _cashback = TextEditingController();
  bool _pas = false;

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
            Container(
              height: 200,
              color: Colors.black12,
              child: Center(
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Total Tagihan",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp.${widget.total}",
                      style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Uang Cash",
                              style: TextStyle(
                                  color: Color(0xFF64748b),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextField(
                        controller: _cash,
                        enabled: !_pas,
                        onChanged: (value) {
                          if (int.parse(value) >= widget.total) {
                            _cashback.value = TextEditingValue(
                                text: (int.parse(value) - widget.total)
                                    .toString());
                          }

                          if (int.parse(value) == 0 || value.isEmpty) {
                            _cashback.value = const TextEditingValue(text: "0");
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Masukkan nominal uang cash",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.attach_money_sharp),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFe2e8f0), width: 0.5),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ListTile(
                      onTap: () {
                        setState(() {
                          _pas = !_pas;
                        });
                      },
                      contentPadding: const EdgeInsets.all(0),
                      leading: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Checkbox(
                            value: _pas,
                            onChanged: (value) {
                              setState(() {
                                _pas = !_pas;
                              });
                            },
                          ),
                          const Text("Uang Pas",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF64748b),
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Uang Kembalian",
                              style: TextStyle(
                                  color: Color(0xFF64748b),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextField(
                        controller: _cashback,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.attach_money_sharp),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFe2e8f0), width: 0.5),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
              style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))),
                  backgroundColor: MaterialStatePropertyAll(Colors.orange),
                  foregroundColor: MaterialStatePropertyAll(Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Bayar")),
        ),
      ),
    );
  }
}
