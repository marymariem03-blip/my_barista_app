// lib/screens/barista/barista_login_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import '../../widgets/input_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/field_label.dart';
import 'barista_main_screen.dart';

class BaristaLoginScreen extends StatefulWidget {
  const BaristaLoginScreen({super.key});

  @override
  State<BaristaLoginScreen> createState() => _BaristaLoginScreenState();
}

class _BaristaLoginScreenState extends State<BaristaLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading  = false;
  String? _errorMsg;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _errorMsg = null; });

    final result = await FirebaseService.signIn(email, password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result == null) {
      setState(() => _errorMsg = 'Incorrect email or password.');
      return;
    }

    final role = await FirebaseService.getUserRole(result.user!.uid);
    if (!mounted) return;

    if (role == 'barista') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const BaristaMainScreen()));
    } else {
      await FirebaseService.signOut();
      setState(() => _errorMsg = 'This account is not a barista account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(children: [

          // ── Header ──────────────────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
                top: topPad + 14, left: 20, right: 20, bottom: 24),
            child: Stack(alignment: Alignment.center, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 34),
                ),
              ),
              const Column(
                children: [
                  Text('Barista Access',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: Colors.white, fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Staff portal',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: Colors.white60, fontSize: 13)),
                ],
              ),
            ]),
          ),

          // ── Form ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Barista icon
                  Center(
                    child: Image.asset(
                      'assets/icons/baristaicon.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                            color: kBrown.withOpacity(0.08),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.coffee_maker_outlined,
                            color: kBrown, size: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email
                  const FieldLabel('Email'),
                  const SizedBox(height: 8),
                  InputField(
                    hint: 'example@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl,
                  ),
                  const SizedBox(height: 20),

                  // Password
                  const FieldLabel('Password'),
                  const SizedBox(height: 8),
                  PasswordField(controller: _passwordCtrl),

                  // Error
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMsg!,
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: Colors.red, fontSize: 13))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Log In button
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: kBrown))
                      : GestureDetector(
                          onTap: _handleLogin,
                          child: Container(
                            width: double.infinity, height: 54,
                            decoration: BoxDecoration(
                                color: kBrown,
                                borderRadius: BorderRadius.circular(32)),
                            alignment: Alignment.center,
                            child: const Text('Log In',
                                style: TextStyle(fontFamily: 'LeagueSpartan',
                                    color: Colors.white, fontSize:24,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                  const SizedBox(height: 24),

                  // Footer note
                  Center(
                    child: Text(
                      'Barista accounts are managed by your\nbranch manager.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.4), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}