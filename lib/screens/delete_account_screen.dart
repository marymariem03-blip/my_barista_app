// lib/screens/delete_account_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'page2_login_screen.dart';
import 'main_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool    _understood = false;
  bool    _deleting   = false;
  String? _errorMsg;

  Future<void> _handleDelete() async {
    if (!_understood) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please confirm you understand this action.',
            style: TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() { _deleting = true; _errorMsg = null; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _deleting = false; _errorMsg = 'No user logged in.'; });
      return;
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) await _showReauthAndDelete(user);
        return;
      }
      setState(() { _deleting = false; _errorMsg = 'Auth error: ${e.message}'; });
      return;
    } catch (e) {
      setState(() { _deleting = false; _errorMsg = 'Error: $e'; });
      return;
    }

    // ✅ Auth deleted — clean Firestore
    await _deleteFirestoreDocs(user.uid);

    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false);
    }
  }

  // ✅ Delete from all collections
  Future<void> _deleteFirestoreDocs(String uid) async {
    final db = FirebaseFirestore.instance;
    await Future.wait([
      db.collection('users').doc(uid).delete().catchError((_) {}),
      db.collection('client').doc(uid).delete().catchError((_) {}),
      db.collection('barista').doc(uid).delete().catchError((_) {}),
      db.collection('manager').doc(uid).delete().catchError((_) {}),
    ]);
  }

  Future<void> _showReauthAndDelete(User user) async {
    final passCtrl = TextEditingController();
    String? dlgError;
    bool    loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm your password',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontWeight: FontWeight.w800)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'For security, please enter your password to confirm account deletion.',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.4)),
                filled: true, fillColor: kInputBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            if (dlgError != null) ...[
              const SizedBox(height: 8),
              Text(dlgError!, style: const TextStyle(
                  color: Colors.red, fontSize: 12,
                  fontFamily: 'LeagueSpartan')),
            ],
          ]),
          actions: [
            TextButton(
              onPressed: loading ? null : () {
                setState(() { _deleting = false; _errorMsg = null; });
                Navigator.pop(ctx);
              },
              child: const Text('Cancel', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: loading ? null : () async {
                setDlg(() { loading = true; dlgError = null; });
                try {
                  final cred = EmailAuthProvider.credential(
                    email:    user.email!,
                    password: passCtrl.text.trim(),
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.delete();
                  await _deleteFirestoreDocs(user.uid);

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false);
                  }
                } on FirebaseAuthException catch (e) {
                  setDlg(() {
                    loading  = false;
                    dlgError = e.message ?? 'Wrong password.';
                  });
                }
              },
              child: loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Delete', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      // ✅ SharedNavBar — same as all other screens
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
            const Text('Delete Account', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 25, fontWeight: FontWeight.w700)),
          ]),
        ),

        // ── Content ─────────────────────────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Center(
                    child: Text("We're sorry to see\nyou go!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 26,
                            fontWeight: FontWeight.w800, height: 1.3)),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Deleting your account is permanent. If you proceed, you will lose:',
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.8),
                        fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),

                  _Bullet('All accumulated Beans and active rewards.'),
                  _Bullet('Your favorite drink presets and order history.'),
                  _Bullet('Access to app-exclusive "My Barista" offers.'),
                  const SizedBox(height: 24),

                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.2))),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMsg!,
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: Colors.red, fontSize: 13))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Checkbox
                  GestureDetector(
                    onTap: _deleting
                        ? null
                        : () => setState(
                            () => _understood = !_understood),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kBrown, width: 2),
                            color: _understood
                                ? kBrown : Colors.transparent,
                          ),
                          child: _understood
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I understand that this action cannot be undone.',
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: kBrown, fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Delete button
                  GestureDetector(
                    onTap: _deleting ? null : _handleDelete,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                          color: _deleting
                              ? Colors.red.withOpacity(0.5)
                              : Colors.red,
                          borderRadius: BorderRadius.circular(32)),
                      alignment: Alignment.center,
                      child: _deleting
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Delete', style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('  •  ', style: TextStyle(
          color: kBrown.withOpacity(0.8), fontSize: 14,
          fontWeight: FontWeight.w700)),
      Expanded(child: Text(text, style: TextStyle(
          fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.8),
          fontSize: 14, height: 1.5))),
    ]),
  );
}