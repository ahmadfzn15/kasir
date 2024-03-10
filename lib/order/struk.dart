import 'package:flutter/material.dart';

class Struk extends StatefulWidget {
  const Struk({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StrukState createState() => _StrukState();
}

class _StrukState extends State<Struk> {
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
          onPressed: () {},
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
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Sunda Food",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Warung Makanan Sunda",
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Kasir"), Text("Ahmad Fauzan")],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Waktu"), Text("7 Maret 2024, 08:04")],
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Metode Pembayaran"), Text("Tunai")],
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Lunas",
                  style: TextStyle(fontSize: 22),
                ),
                const Divider(),
                ListView.builder(
                  itemCount: 1,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        "Chicken",
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        "Rp.9.000 x 2",
                        style: TextStyle(fontSize: 15),
                      ),
                      trailing: Text(
                        "Rp.18.000",
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  },
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Subtotal"), Text("Rp.18.000")],
                ),
                const Divider(),
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total (2 Produk)",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "Rp.18.000",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(
                  height: 15,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Bayar"), Text("Rp.20.000")],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Kembalian"), Text("Rp.2.000")],
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
        )));
  }
}
