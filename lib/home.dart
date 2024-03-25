import 'dart:convert';

import 'package:app/components/banners.dart';
import 'package:app/product/product.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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
  Map<String, dynamic> sale = {};
  bool loading = false;
  String url = dotenv.env['API_URL']!;
  DateTime time = DateTime.now();

  @override
  void initState() {
    super.initState();

    fetchDataSale();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
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
      });
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      throw Exception(res['message']);
    }
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
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
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
                  height: 300,
                  child: PageView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Card(
                          margin: const EdgeInsets.all(20),
                          elevation: 5,
                          clipBehavior: Clip.antiAlias,
                          surfaceTintColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Produk Terjual",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    child: PieChart(PieChartData(
                                  sections: sale.isNotEmpty
                                      ? sale['produk_terjual']['data']
                                          .map<PieChartSectionData>((value) {
                                          return PieChartSectionData(
                                            color: Colors.orange,
                                            value: value['jumlah'].toDouble(),
                                            title: value['namaProduk'],
                                          );
                                        }).toList()
                                      : [],
                                )))
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.all(20),
                          elevation: 5,
                          clipBehavior: Clip.antiAlias,
                          surfaceTintColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Produk Terjual",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Expanded(
                                    child: BarChart(BarChartData(
                                  barGroups: [
                                    BarChartGroupData(x: 1, barRods: [
                                      BarChartRodData(
                                          toY: sale.isNotEmpty
                                              ? sale['produk_terjual']
                                                      ['produk_perhari']
                                                  .toDouble()
                                              : 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 2, barRods: [
                                      BarChartRodData(
                                          toY: 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 3, barRods: [
                                      BarChartRodData(
                                          toY: 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 4, barRods: [
                                      BarChartRodData(
                                          toY: 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 5, barRods: [
                                      BarChartRodData(
                                          toY: 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 6, barRods: [
                                      BarChartRodData(
                                          toY: 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 7, barRods: [
                                      BarChartRodData(
                                          toY: 0,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                  ],
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  titlesData: const FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: true),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: true),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      )),
                                ))),
                              ],
                            ),
                          ),
                        )
                      ])),
              GridView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 80,
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text(
                          "Transaksi Lunas",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          sale.isNotEmpty
                              ? sale['transaksi_lunas'].toString()
                              : "0",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text(
                          "Produk Terjual",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          sale.isNotEmpty
                              ? sale['produk_terjual']['jumlah'].toString()
                              : "0",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text(
                          "Omset",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          "Rp.${sale.isNotEmpty ? sale['omset'].toString() : "0"}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text(
                          "Keuntungan",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          "Rp.${sale.isNotEmpty ? sale['laba'].toString() : "0"}",
                          style: const TextStyle(
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
