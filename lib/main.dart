import 'package:app/auth/auth.dart';
import 'package:app/layout.dart';
import 'package:app/etc/startup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Panggil dotenv.load() sebelum runApp()
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode themeMode = ThemeMode.system;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sunda Food",
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: FutureBuilder(
        future: Future.wait(
            [Future.delayed(const Duration(seconds: 1)), checkToken()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data![1]) {
              return const Layout();
            } else {
              return const Auth();
            }
          } else {
            return const Startup();
          }
        },
      ),
    );
  }
}

Future<bool> checkToken() async {
  return await const FlutterSecureStorage().containsKey(key: 'token');
}
