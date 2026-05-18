// lib/screens/barista/barista_login_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import '../../widgets/primary_button.dart';
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
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMsg;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BaristaMainScreen()),
      );
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
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Container(
              color: kBrown,
              padding: EdgeInsets.only(
                top: topPad + 14,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.coffee,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barista Access',
                            style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Staff portal — authorized only',
                            style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coffee icon accent
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: kBrown.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.coffee_maker_outlined,
                          color: kBrown,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'Welcome back,\nBarista!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    const FieldLabel('Email'),
                    const SizedBox(height: 8),
                    InputField(
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel('Password'),
                    const SizedBox(height: 8),
                    PasswordField(controller: _passwordCtrl),
                    const SizedBox(height: 8),

                    if (_errorMsg != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    _loading
                        ? const Center(
                            child: CircularProgressIndicator(color: kBrown),
                          )
                        : PrimaryButton(label: 'Sign In', onTap: _handleLogin),

                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Barista accounts are managed\nby your branch manager.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
