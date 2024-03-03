import 'package:flutter/material.dart';

class DetailProduct extends StatefulWidget {
  const DetailProduct({super.key, required this.detail});
  final Map<String, dynamic> detail;

  @override
  // ignore: library_private_types_in_public_api
  _DetailProductState createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct> {
  void _increment() {
    setState(() {
      widget.detail['qty']++;
    });
  }

  void _decrement() {
    if (widget.detail['qty'] > 1) {
      setState(() {
        widget.detail['qty']--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 1,
        title: Text(
          widget.detail['namaProduk'],
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      body: Column(
        children: [
          ListTile(
            leading: const Text("Harga",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            trailing: Text("Rp.${widget.detail['harga']}",
                style: const TextStyle(fontSize: 15)),
          ),
          const Divider(
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            leading: const Text("Jumlah Produk",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            trailing: Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      _decrement();
                    },
                    icon: const Icon(Icons.remove)),
                Text(
                  widget.detail['qty'].toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                    onPressed: () {
                      _increment();
                    },
                    icon: const Icon(Icons.add)),
              ],
            ),
          ),
          const Divider(
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            leading: const Text("Total Harga",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            trailing: Text(
                "Rp.${widget.detail['harga'] * widget.detail['qty']}",
                style: const TextStyle(fontSize: 15)),
          ),
        ],
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
              child: const Text("Simpan")),
        ),
      ),
    );
  }
}
