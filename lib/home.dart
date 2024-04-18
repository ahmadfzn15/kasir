import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:app/employee/employee.dart';
import 'package:app/etc/format_time.dart';
import 'package:app/etc/label.dart';
import 'package:app/etc/wave.dart';
import 'package:app/models/user_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
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
  final userController = Get.put(UserController());
  Map<String, dynamic> sale = {};
  bool loading = false;
  String url = dotenv.env['API_URL']!;
  DateTime time = DateTime.now();
  List<Color> colorLabel = [];
  int firstIndex = -1;
  int secondIndex = -1;

  @override
  void initState() {
    super.initState();

    getUser();
    fetchDataSale();
  }

  Future<void> getUser() async {
    await userController.getCurrentUser(context);
  }

  Color getRandomColor() {
    var rand = Random();

    int red = rand.nextInt(256);
    int green = rand.nextInt(256);
    int blue = rand.nextInt(256);

    return Color.fromRGBO(red, green, blue, 1);
  }

  Future<void> _refresh() async {
    getUser();
    fetchDataSale();
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
      backgroundColor: const Color(0xFFf1f5f9),
      body: CustomPaint(
        size: Size.infinite,
        painter: WavePainter(),
        child: SingleChildScrollView(
          child: RefreshIndicator(
              onRefresh: () {
                return _refresh();
              },
              child: Column(children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 10),
                        child: Obx(() => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                        icon: const Icon(
                                          Icons.menu,
                                          size: 30,
                                          color: Colors.white,
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Label.welcome,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            userController.user?.value.nama !=
                                                    null
                                                ? userController
                                                    .user!.value.nama!
                                                : '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            userController.user?.value.role !=
                                                    null
                                                ? userController
                                                    .user!.value.role!
                                                : '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 15, top: 20),
                                  child: Column(
                                    children: [
                                      userController.user?.value.foto != null
                                          ? CircleAvatar(
                                              radius: 40,
                                              backgroundImage: NetworkImage(
                                                  "$url/storage/img/${userController.user!.value.foto}"),
                                            )
                                          : const CircleAvatar(
                                              radius: 40,
                                              backgroundImage: AssetImage(
                                                  "assets/img/user.png"),
                                            ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        formatTime2(DateTime.now()),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 150),
                        height: 250,
                        child: PageView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              Container(
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Produk Terjual",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          GridView(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    mainAxisExtent: 140,
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 10),
                                            children: [
                                              PieChart(
                                                PieChartData(
                                                  sections: sale.isNotEmpty
                                                      ? sale['produk_terjual']
                                                              ['data']
                                                          .map<PieChartSectionData>(
                                                              (value) {
                                                          var color =
                                                              getRandomColor();
                                                          colorLabel.add(color);
                                                          setState(() {
                                                            firstIndex++;
                                                          });
                                                          return PieChartSectionData(
                                                            title:
                                                                value['jumlah']
                                                                    .toString(),
                                                            color: colorLabel[
                                                                firstIndex],
                                                            value:
                                                                value['jumlah']
                                                                    .toDouble(),
                                                          );
                                                        }).toList()
                                                      : [],
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: sale.isNotEmpty
                                                      ? sale['produk_terjual']
                                                              ['data']
                                                          .map<Widget>((value) {
                                                          setState(() {
                                                            secondIndex++;
                                                          });
                                                          return Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                width: 15,
                                                                height: 15,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: colorLabel[
                                                                        secondIndex]),
                                                              ),
                                                              const SizedBox(
                                                                width: 7,
                                                              ),
                                                              Flexible(
                                                                  child: Text(
                                                                value[
                                                                    'namaProduk'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ))
                                                            ],
                                                          );
                                                        }).toList()
                                                      : [],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Omset Perhari",
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
                                                BarChartGroupData(
                                                    x: 1,
                                                    barRods: [
                                                      BarChartRodData(
                                                          toY: sale.isNotEmpty
                                                              ? double.parse(
                                                                  sale['omset']
                                                                      .toString())
                                                              : 0,
                                                          color: Colors.orange,
                                                          width: 25),
                                                    ]),
                                                BarChartGroupData(
                                                    x: 2,
                                                    barRods: [
                                                      BarChartRodData(
                                                          toY: 0,
                                                          color: Colors.orange,
                                                          width: 25),
                                                    ]),
                                                BarChartGroupData(
                                                    x: 3,
                                                    barRods: [
                                                      BarChartRodData(
                                                          toY: 0,
                                                          color: Colors.orange,
                                                          width: 25),
                                                    ]),
                                                BarChartGroupData(
                                                    x: 4,
                                                    barRods: [
                                                      BarChartRodData(
                                                          toY: 0,
                                                          color: Colors.orange,
                                                          width: 25),
                                                    ]),
                                                BarChartGroupData(
                                                    x: 5,
                                                    barRods: [
                                                      BarChartRodData(
                                                          toY: 0,
                                                          color: Colors.orange,
                                                          width: 25),
                                                    ]),
                                                BarChartGroupData(
                                                    x: 6,
                                                    barRods: [
                                                      BarChartRodData(
                                                          toY: 0,
                                                          color: Colors.orange,
                                                          width: 25),
                                                    ]),
                                                BarChartGroupData(
                                                    x: 7,
                                                    barRods: [
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
                                                    sideTitles: SideTitles(
                                                        showTitles: true),
                                                  ),
                                                  leftTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: true),
                                                  ),
                                                  rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false),
                                                  ),
                                                  topTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false),
                                                  )),
                                            ))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                            ])),
                  ],
                ),
                GridView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisExtent: 80,
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5),
                    children: [
                      Card(
                        surfaceTintColor: Colors.white,
                        shadowColor: const Color(0xFFf1f5f9),
                        child: ListTile(
                          onTap: () {
                            Get.to(const Employee());
                          },
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
                        surfaceTintColor: Colors.white,
                        shadowColor: const Color(0xFFf1f5f9),
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
                        surfaceTintColor: Colors.white,
                        shadowColor: const Color(0xFFf1f5f9),
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
                        surfaceTintColor: Colors.white,
                        shadowColor: const Color(0xFFf1f5f9),
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
                      ),
                    ]),
              ])),
        ),
      ),
    );
  }
}
