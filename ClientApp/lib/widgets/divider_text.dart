import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({
    super.key,
    required this.text,
    this.margin = const EdgeInsets.symmetric(horizontal: 32),
  });

  final String text;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(children: [
        const Expanded(child: Divider(color: Colors.black38)),
        const SizedBox(width: 12),
        Text(
          "Or",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: Colors.black38)),
      ]),
    );
  }
}
