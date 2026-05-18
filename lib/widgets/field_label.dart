import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'LeagueSpartan',
        color: kBrown,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
    );
  }
}
