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
      title: Text(title),
      children: [
        SizedBox(
          height: 135,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        )
      ],
    );
  }
}
