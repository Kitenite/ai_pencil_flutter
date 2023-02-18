import 'package:flutter/material.dart';

class SelectProjectScreen extends StatefulWidget {
  const SelectProjectScreen({super.key});

  @override
  State<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ai Pencil",
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Select"),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Hello"),
          ],
        ),
      ),
    );
  }
}
