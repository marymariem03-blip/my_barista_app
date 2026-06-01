// lib/screens/page2_login_screen.dart

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_field.dart';
import '../widgets/password_field.dart';
import '../widgets/field_label.dart';
import '../widgets/wave_painters.dart';
import 'page3_signup_screen.dart';
import 'find_barista_screen.dart';
import 'manager/manager_login_screen.dart';
import 'barista/barista_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  String? _errorMsg;

  int  _cupTapCount   = 0;
  DateTime? _firstTap;
  static const int      _tapsRequired = 3;
  static const Duration _tapWindow    = Duration(seconds: 2);

  static const double _bannerHeight = 180.0;
  static const double _cupWidth     = 0.80;
  static const double _cupBottom    = -320;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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

    if (result != null) {
      final role = await FirebaseService.getUserRole(result.user!.uid);
      if (!mounted) return;

      if (role == 'client') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const FindBaristaScreen()));
      } else {
        // ✅ manager or barista — sign out silently, show generic error
        await FirebaseService.signOut();
        setState(() => _errorMsg = 'No account found matching these credentials.');
      }
    } else {
      setState(() => _errorMsg = 'No account found matching these credentials.');
    }
  }

  void _onCupTap() {
    final now = DateTime.now();
    if (_firstTap == null || now.difference(_firstTap!) > _tapWindow) {
      _firstTap    = now;
      _cupTapCount = 1;
    } else {
      _cupTapCount++;
    }

    if (_cupTapCount >= _tapsRequired) {
      _cupTapCount = 0;
      _firstTap    = null;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const BaristaLoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        Column(children: [

          // ── Top bar ─────────────────────────────────
          Container(
            color: kBg,
            padding: EdgeInsets.only(
                top: topPad + 14, left: 20, right: 20, bottom: 10),
            child: Stack(alignment: Alignment.center, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(Icons.chevron_left,
                      size: 34, color: kBrown),
                ),
              ),
              GestureDetector(
                onLongPress: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ManagerLoginScreen())),
                child: const Text('Hello!',
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: kBrown)),
              ),
            ]),
          ),

          // ── Form ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Text('Welcome',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          fontSize: 24, fontWeight: FontWeight.w600,
                          color: kBrown)),
                  const SizedBox(height: 32),

                  const FieldLabel('Email or Mobile Number'),
                  const SizedBox(height: 8),
                  InputField(hint: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl),
                  const SizedBox(height: 20),

                  const FieldLabel('Password'),
                  const SizedBox(height: 8),
                  PasswordField(controller: _passwordCtrl),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(top: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Forget Password',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontWeight: FontWeight.w500,
                              fontSize: 14)),
                    ),
                  ),

                  if (_errorMsg != null) ...[
                    const SizedBox(height: 4),
                    Text(_errorMsg!, style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),

                  _loading
                      ? const Center(child: CircularProgressIndicator(
                          color: kBrown))
                      : PrimaryButton(
                          label: 'Log In', onTap: _handleLogin),

                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen())),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.black54, fontSize: 15),
                          children: [
                            TextSpan(text: 'Sign Up',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: kBrownLight,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Wave banner ──────────────────────────────
          SizedBox(
            height: _bannerHeight,
            width: double.infinity,
            child: Stack(children: [
              Positioned.fill(
                  child: CustomPaint(painter: TopWavePainter())),
              const Positioned(bottom: 18, left: 28,
                child: Text('Click\nPick  Sip',
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 36,
                        fontWeight: FontWeight.w900, height: 1.15))),
            ]),
          ),
        ]),

        // ── Cup — 3 taps → Barista Login ────────────────
        Positioned(
          bottom: _cupBottom, right: -0.25,
          child: GestureDetector(
            onTap: _onCupTap,
            behavior: HitTestBehavior.opaque,
            child: Image.asset('assets/images/cup.png',
                width: size.width * _cupWidth, fit: BoxFit.contain),
          ),
        ),
      ]),
    );
  }
}