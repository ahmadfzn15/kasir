import 'package:app/components/banners.dart';
import 'package:fl_chart/fl_chart.dart';
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
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: 50,
                                      title: '50%',
                                    ),
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: 10,
                                      title: '10%',
                                    ),
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: 25,
                                      title: '25%',
                                    ),
                                    PieChartSectionData(
                                      color: Colors.yellow,
                                      value: 15,
                                      title: '15%',
                                    ),
                                  ],
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
                                          toY: 10,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 2, barRods: [
                                      BarChartRodData(
                                          toY: 15,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 3, barRods: [
                                      BarChartRodData(
                                          toY: 25,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 4, barRods: [
                                      BarChartRodData(
                                          toY: 20,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 5, barRods: [
                                      BarChartRodData(
                                          toY: 15,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 6, barRods: [
                                      BarChartRodData(
                                          toY: 25,
                                          color: Colors.orange,
                                          width: 25),
                                    ]),
                                    BarChartGroupData(x: 7, barRods: [
                                      BarChartRodData(
                                          toY: 30,
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
