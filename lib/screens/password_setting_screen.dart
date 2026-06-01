// lib/screens/password_setting_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'main_screen.dart';

class PasswordSettingScreen extends StatefulWidget {
  const PasswordSettingScreen({super.key});

  @override
  State<PasswordSettingScreen> createState() =>
      _PasswordSettingScreenState();
}

class _PasswordSettingScreenState extends State<PasswordSettingScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl      = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _loading     = false;
  String? _errorMsg;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleChange() async {
    final current = _currentCtrl.text.trim();
    final newPass  = _newCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    // ── Local validation ──────────────────────────────
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all fields.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _errorMsg = 'New password must be at least 6 characters.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _errorMsg = 'New passwords do not match.');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() { _loading = false; _errorMsg = 'No user logged in.'; });
      return;
    }

    try {
      // ✅ Step 1 — Re-authenticate with current password
      final cred = EmailAuthProvider.credential(
        email:    user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      // ✅ Step 2 — Update to new password in Firebase Auth
      await user.updatePassword(newPass);

      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password changed successfully!',
            style: TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading  = false;
        _errorMsg = e.code == 'wrong-password'
            ? 'Current password is incorrect.'
            : e.message ?? 'Something went wrong.';
      });
    } catch (e) {
      setState(() { _loading = false; _errorMsg = 'Error: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: SharedNavBar(activeIndex: -1),
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 18, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('Password Setting', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 25, fontWeight: FontWeight.w700)),
          ]),
        ),

        // ── Form ────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  _FieldLabel('Current Password'),
                  const SizedBox(height: 8),
                  _PasswordField(controller: _currentCtrl,
                      show: _showCurrent,
                      onToggle: () =>
                          setState(() => _showCurrent = !_showCurrent)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Forgot Password?',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('New Password'),
                  const SizedBox(height: 8),
                  _PasswordField(controller: _newCtrl,
                      show: _showNew,
                      onToggle: () =>
                          setState(() => _showNew = !_showNew)),
                  const SizedBox(height: 20),

                  _FieldLabel('Confirm New Password'),
                  const SizedBox(height: 8),
                  _PasswordField(controller: _confirmCtrl,
                      show: _showConfirm,
                      onToggle: () =>
                          setState(() => _showConfirm = !_showConfirm)),
                  const SizedBox(height: 12),

                  if (_errorMsg != null) ...[
                    Text(_errorMsg!, style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.red, fontSize: 13)),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 32),

                  // ✅ Shows spinner while updating
                  _loading
                      ? const Center(child: CircularProgressIndicator(
                          color: kBrown))
                      : GestureDetector(
                          onTap: _handleChange,
                          child: Container(
                            width: double.infinity, height: 52,
                            decoration: BoxDecoration(color: kBrown,
                                borderRadius: BorderRadius.circular(32)),
                            alignment: Alignment.center,
                            child: const Text('Change Password',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.white, fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 16, fontWeight: FontWeight.w700));
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;
  const _PasswordField({required this.controller, required this.show,
      required this.onToggle});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: kInputBg,
        borderRadius: BorderRadius.circular(32)),
    child: TextField(
      controller: controller,
      obscureText: !show,
      style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        border: InputBorder.none,
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
              show ? Icons.visibility_outlined
                   : Icons.visibility_off_outlined,
              color: kBrown.withOpacity(0.5), size: 20),
        ),
      ),
    ),
  );
}