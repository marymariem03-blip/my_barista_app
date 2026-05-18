import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_field.dart';
import '../widgets/password_field.dart';
import '../widgets/field_label.dart';
import '../widgets/wave_painters.dart';
import 'page2_login_screen.dart';
import 'find_barista_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _dobCtrl      = TextEditingController();
  bool _loading       = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // ── Signup handler ────────────────────────────────────
  Future<void> _handleSignUp() async {
    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final phone    = _phoneCtrl.text.trim();
    final dob      = _dobCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all required fields.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMsg = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; });

    // ✅ Firebase Auth register
    final result = await FirebaseService.register(email, password);

    if (!mounted) return;

    if (result != null) {
      // ✅ Save user data to Firestore
      await FirebaseService.createUser(
        uid:   result.user!.uid,
        nom:   name,
        email: email,
        role:  'client',
      );

      // ✅ Also save phone + dob in users doc
      await FirebaseService.updateUserProfile(
        uid:   result.user!.uid,
        nom:   name,
        email: email,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const FindBaristaScreen()));
    } else {
      setState(() {
        _loading  = false;
        _errorMsg = 'Registration failed. Email may already be used.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [

          // ── Brown wave header ──────────────────────
          SizedBox(
            width: double.infinity,
            height: topPad + 56,
            child: CustomPaint(painter: WaveHeaderPainter()),
          ),

          // ── Scrollable form ────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 6, bottom: 4),
                      child: Icon(Icons.chevron_left, size: 34, color: kBrown),
                    ),
                  ),

                  const Center(
                    child: Text('New Account',
                        style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 28, fontWeight: FontWeight.w800, color: kBrown)),
                  ),
                  const SizedBox(height: 24),

                  const FieldLabel('Full name'),
                  const SizedBox(height: 8),
                  InputField(hint: 'Full Name', controller: _nameCtrl),
                  const SizedBox(height: 16),

                  const FieldLabel('Password'),
                  const SizedBox(height: 8),
                  PasswordField(controller: _passwordCtrl),
                  const SizedBox(height: 16),

                  const FieldLabel('Email'),
                  const SizedBox(height: 8),
                  InputField(hint: 'example@example.com', keyboardType: TextInputType.emailAddress, controller: _emailCtrl),
                  const SizedBox(height: 16),

                  const FieldLabel('Mobile Number'),
                  const SizedBox(height: 8),
                  InputField(hint: '+ 123 456 789', keyboardType: TextInputType.phone, controller: _phoneCtrl),
                  const SizedBox(height: 16),

                  const FieldLabel('Date of birth'),
                  const SizedBox(height: 8),
                  InputField(hint: 'DD / MM / YYYY', controller: _dobCtrl),
                  const SizedBox(height: 24),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'By continuing, you agree to\n',
                        style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.black54, fontSize: 14),
                        children: [
                          TextSpan(text: 'Terms of Use', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrownLight, fontWeight: FontWeight.w700)),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy.', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrownLight, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_errorMsg != null) ...[
                    Text(_errorMsg!, style: const TextStyle(fontFamily: 'LeagueSpartan', color: Colors.red, fontSize: 13)),
                    const SizedBox(height: 8),
                  ],

                  _loading
                      ? const Center(child: CircularProgressIndicator(color: kBrown))
                      : PrimaryButton(label: 'Sign Up', onTap: _handleSignUp),

                  const SizedBox(height: 16),

                  const Center(child: Text('or sign up with',
                      style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.black45, fontSize: 14))),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(icon: Icons.g_mobiledata, size: 32),
                      const SizedBox(width: 14),
                      _SocialButton(icon: Icons.facebook, size: 26),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.black54, fontSize: 14),
                          children: [
                            TextSpan(text: 'Log in',
                                style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrownLight, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final double size;
  const _SocialButton({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: const BoxDecoration(color: kInputBg, shape: BoxShape.circle),
      child: Icon(icon, color: kBrownLight, size: size),
    );
  }
}