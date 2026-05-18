// lib/screens/manager/manager_login_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import 'manager_main_screen.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;
  bool _loading       = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final result = await FirebaseService.signIn(email, pass);

    if (!mounted) return;

    if (result != null) {
      final role = await FirebaseService.getUserRole(result.user!.uid);
      if (!mounted) return;
      setState(() => _loading = false);

      if (role == 'manager') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ManagerMainScreen()));
      } else {
        await FirebaseService.signOut();
        setState(() => _error = 'Access denied. Manager account required.');
      }
    } else {
      setState(() { _loading = false; _error = 'Invalid credentials.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ───────────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 12, right: 12, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('Manager Access',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 28,
                    fontWeight: FontWeight.w700)),
          ]),
        ),

        // ── Body ─────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 24 + bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                //  Admin asset icon
                Container(
                  width: 96, height: 96,
                  
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/icons/admin.png',
                    fit: BoxFit.contain,
                    color: kBrown,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.admin_panel_settings,
                        color:kBrown, size: 120),
                  ),
                ),
                const SizedBox(height: 48),

                // Email
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller:   _emailCtrl,
                  hint:         'example@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildPasswordField(),

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 40),

                // Login button
                _loading
                    ? const CircularProgressIndicator(color: kBrown)
                    : GestureDetector(
                        onTap: _login,
                        child: Container(
                          width: double.infinity, height: 54,
                          decoration: BoxDecoration(
                              color: kBrown,
                              borderRadius: BorderRadius.circular(32)),
                          alignment: Alignment.center,
                          child: const Text('Log In',
                              style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(
        fontFamily: 'LeagueSpartan', color: kBrown,
        fontSize: 20, fontWeight: FontWeight.w500)),
  );

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Container(
        decoration: BoxDecoration(
            color: kInputBg, borderRadius: BorderRadius.circular(32)),
        child: TextField(
          controller:   controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown, fontSize: 14),
          decoration: InputDecoration(
            hintText:       hint,
            hintStyle:      TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.35), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            border:         InputBorder.none,
          ),
        ),
      );

  Widget _buildPasswordField() => Container(
    decoration: BoxDecoration(
        color: kInputBg, borderRadius: BorderRadius.circular(32)),
    child: TextField(
      controller:  _passwordCtrl,
      obscureText: _obscure,
      style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 14),
      decoration: InputDecoration(
        hintText:       '••••••••••••••',
        hintStyle:      TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown.withOpacity(0.35), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        border:         InputBorder.none,
        suffixIcon:     GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kBrown.withOpacity(0.5), size: 20),
        ),
      ),
    ),
  );
}