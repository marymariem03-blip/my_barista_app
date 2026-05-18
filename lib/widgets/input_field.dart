import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class InputField extends StatelessWidget {
  final String hint;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const InputField({
    super.key,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'LeagueSpartan',
        color: kBrown,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'LeagueSpartan',
          color: Colors.black38,
          fontSize: 15,
        ),
        filled: true,
        fillColor: kInputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: kBrownLight, width: 1.5),
        ),
      ),
    );
  }
}
