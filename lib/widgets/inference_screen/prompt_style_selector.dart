import 'package:flutter/material.dart';

class PromptStyleSelector extends StatelessWidget {
  const PromptStyleSelector({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.transparent),
      ),
      title: Text(title),
      children: [
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        )
      ],
    );
  }
}
