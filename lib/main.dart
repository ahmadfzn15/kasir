import 'package:app/auth/auth.dart';
import 'package:app/firebase_options.dart';
import 'package:app/layout.dart';
import 'package:app/startup.dart';
import 'package:app/sublayout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode themeMode = ThemeMode.system;
  FirebaseAuth auth = FirebaseAuth.instance;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Sunda Food",
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(
            useMaterial3: true,
            textTheme:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
        home: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 2)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                future: checkAuthentication(),
                builder: (context, authSnapshot) {
                  if (authSnapshot.connectionState == ConnectionState.done) {
                    if (authSnapshot.data != null) {
                      return FutureBuilder<String?>(
                        future: storage.read(key: "uid"),
                        builder: (context, uidSnapshot) {
                          if (uidSnapshot.connectionState ==
                              ConnectionState.done) {
                            if (authSnapshot.data?.uid == uidSnapshot.data) {
                              return const Layout();
                            } else {
                              return const Auth();
                            }
                          } else {
                            return const Startup();
                          }
                        },
                      );
                    } else {
                      return const Auth();
                    }
                  } else {
                    return const Startup();
                  }
                },
              );
            } else {
              return const Startup();
            }
          },
        ));
  }

  Future<User?> checkAuthentication() async {
    return auth.currentUser;
  }
}
