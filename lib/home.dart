import 'package:app/components/banners.dart';
import 'package:flutter/material.dart';

class WidgetIcon {
  IconData icon;
  String label;

  WidgetIcon({required this.icon, required this.label});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> page = const [
    Banners(img: "assets/img/french-fries.jpeg"),
    Banners(img: "assets/img/sprite.jpg"),
    Banners(img: "assets/img/burger.jpeg")
  ];
  DateTime time = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
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
            "Beranda",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
            onRefresh: () {
              return _refresh();
            },
            child: Column(children: [
              SizedBox(
                  height: 200,
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: page.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return page[index];
                      })),
              GridView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 80,
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  children: const [
                    Card(
                      child: ListTile(
                        title: Text(
                          "Transaksi Lunas",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          "1",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text(
                          "Produk Terjual",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          "3",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ]),
            ])),
      ),
    );
  }
}
