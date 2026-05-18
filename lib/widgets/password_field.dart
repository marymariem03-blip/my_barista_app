import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class PasswordField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;

  const PasswordField({super.key, this.hint, this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(
        fontFamily: 'LeagueSpartan',
        color: kBrown,
        fontSize: 15,
        letterSpacing: 3,
      ),
      decoration: InputDecoration(
        hintText: widget.hint ?? '••••••••••••',
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontSize: 15,
          letterSpacing: 3,
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
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kBrownLight,
            size: 22,
          ),
        ),
      ),
    );
  }
}
