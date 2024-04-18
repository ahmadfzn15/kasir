import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  List<String> languages = ["Indonesia", "Inggris"];
  String? language;

  @override
  void initState() {
    super.initState();

    getLanguange();
  }

  void getLanguange() async {
    var storage = await SharedPreferences.getInstance();
    setState(() {
      language = storage.getString("language");
    });
  }

  void changeLang(value) async {
    setState(() {
      language = value;
    });

    var storage = await SharedPreferences.getInstance();
    storage.setString("language", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeys,
      backgroundColor: const Color(0xFFf1f5f9),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 1,
        title: const Text(
          "Bahasa",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(CupertinoIcons.back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          surfaceTintColor: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                children: [
                  ListView.builder(
                    itemCount: languages.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return RadioListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        value: languages[index],
                        activeColor: Colors.orange,
                        title: Text(languages[index]),
                        groupValue: language,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                        splashRadius: 30,
                        onChanged: (value) {
                          changeLang(value);
                        },
                      );
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
