import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.grey,
        surfaceTintColor: Colors.white,
        title: const Text("Lusi Kuraisin"),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 2),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/img/lusi.jpeg"),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.menu),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 1,
                              child: Padding(
                                padding: EdgeInsets.all(7),
                                child: Text(
                                    "Hello guys, bagaimana kabarnya hari ini?"),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Card(
                              elevation: 1,
                              child: Padding(
                                padding: EdgeInsets.all(7),
                                child: Text(
                                    "Hello guys, bagaimana kabarnya hari ini?"),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              controller: _message,
              decoration: InputDecoration(
                hintText: "Type here...",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.send),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                border: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFe2e8f0), width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
