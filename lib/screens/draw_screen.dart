import 'package:flutter/material.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  @override
  Widget build(BuildContext context) {
    var trailingActions = [
      TextButton(
        onPressed: () {},
        child: const Text(
          "AI",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.photo_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.ios_share),
            ),
          ],
        ),
        actions: trailingActions,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Draw screen"),
          ],
        ),
      ),
    );
  }
}
