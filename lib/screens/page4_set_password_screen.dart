import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/password_field.dart';
import '../widgets/field_label.dart';
import '../widgets/wave_painters.dart';

class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Brown wave header ───────────────────────
          SizedBox(
            width: double.infinity,
            height: topPad + 56,
            child: CustomPaint(painter: WaveHeaderPainter()),
          ),

          // ── Scrollable form ─────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 6, bottom: 4),
                      child: Icon(Icons.chevron_left, size: 34, color: kBrown),
                    ),
                  ),

                  // Title
                  const Center(
                    child: Text(
                      'Set Password',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kBrown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                    'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Password
                  const FieldLabel('Password'),
                  const SizedBox(height: 8),
                  const PasswordField(),
                  const SizedBox(height: 24),

                  // Confirm Password
                  const FieldLabel('Confirm Password'),
                  const SizedBox(height: 8),
                  const PasswordField(),
                  const SizedBox(height: 48),

                  // Create New Password button
                  PrimaryButton(
                    label: 'Create New Password',
                    backgroundColor: kBrownLight,
                    onTap: () {
                      // TODO: navigate to next screen after password creation
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}