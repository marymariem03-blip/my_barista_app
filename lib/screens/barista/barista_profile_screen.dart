// lib/screens/barista/barista_profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import '../../core/models/barista_order.dart';
import '../page2_login_screen.dart';

class BaristaProfileScreen extends StatefulWidget {
  const BaristaProfileScreen({super.key});

  @override
  State<BaristaProfileScreen> createState() => _BaristaProfileScreenState();
}

class _BaristaProfileScreenState extends State<BaristaProfileScreen> {
  String _name      = '';
  String _email     = '';
  String _avatarUrl = '';
  bool   _loading   = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid != null) {
      final data = await FirebaseService.getUser(uid);
      if (mounted) {
        setState(() {
          _name      = data?['nom']    as String? ?? 'Barista';
          _email     = data?['email']  as String? ?? '';
          _avatarUrl = data?['avatar'] as String? ?? '';
          _loading   = false;
        });
      }
    } else {
      setState(() => _loading = false);
    }
  }

  Widget _buildAvatar() {
    if (_avatarUrl.isNotEmpty && _avatarUrl.startsWith('http')) {
      return CircleAvatar(radius: 44, backgroundColor: kInputBg,
          child: ClipOval(child: CachedNetworkImage(
              imageUrl: _avatarUrl, width: 88, height: 88,
              fit: BoxFit.cover,
              placeholder: (_, __) => const CircularProgressIndicator(
                  color: kBrown, strokeWidth: 2),
              errorWidget: (_, __, ___) => _defaultAvatar())));
    }
    return CircleAvatar(radius: 44, backgroundColor: kInputBg,
        child: _defaultAvatar());
  }

  Widget _defaultAvatar() =>
      const Icon(Icons.person, color: kBrownLight, size: 48);

  void _showLogoutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Se déconnecter ?', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(height: 50,
                  decoration: BoxDecoration(color: const Color(0xFFE0DAD4),
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Annuler', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 16, fontWeight: FontWeight.w700))),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async {
                await FirebaseService.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false);
                }
              },
              child: Container(height: 50,
                  decoration: BoxDecoration(color: Colors.red,
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Déconnexion', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w700))),
            )),
          ]),
        ]),
      ),
    );
  }

  // Stats
  int get _completedToday => kFakeBaristaOrders
      .where((o) => o.status == BaristaOrderStatus.completed).length;
  int get _drinksToday => kFakeBaristaOrders
      .where((o) => o.status == BaristaOrderStatus.completed)
      .fold(0, (s, o) => s + o.totalDrinks);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(children: [

      // ── Header ────────────────────────────────────────
      Container(
        color: kBrown,
        padding: EdgeInsets.only(
            top: topPad + 14, left: 20, right: 20, bottom: 20),
        child: const Row(children: [
          Text('Mon Profil', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: Colors.white,
              fontSize: 22, fontWeight: FontWeight.w800)),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [

            // ── Profile card ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10, offset: const Offset(0, 3))]),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                      color: kBrown))
                  : Column(children: [
                      _buildAvatar(),
                      const SizedBox(height: 14),
                      Text(_name, style: const TextStyle(
                          fontFamily: 'LeagueSpartan', color: kBrown,
                          fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(_email, style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.5), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Barista', style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: Color(0xFFE65100),
                            fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ]),
            ),
            const SizedBox(height: 16),

            // ── Today stats ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10, offset: const Offset(0, 3))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Aujourd'hui", style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _MiniStat(
                        label: 'Commandes\ncomplétées',
                        value: '$_completedToday',
                        icon: Icons.check_circle_outline,
                        color: Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _MiniStat(
                        label: 'Boissons\npréparées',
                        value: '$_drinksToday',
                        icon: Icons.local_cafe_outlined,
                        color: const Color(0xFFE65100))),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Menu items ───────────────────────────────
            _MenuItem(icon: Icons.notifications_outlined,
                label: 'Notifications', onTap: () {}),
            _MenuItem(icon: Icons.help_outline,
                label: 'Aide & Support', onTap: () {}),
            _MenuItem(icon: Icons.logout, label: 'Déconnexion',
                color: Colors.red, onTap: _showLogoutDialog),

            const SizedBox(height: 16),
          ]),
        ),
      ),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MiniStat({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontFamily: 'LeagueSpartan',
            color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
            color: color.withOpacity(0.7), fontSize: 10, height: 1.3)),
      ]),
    ]),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label,
      required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(children: [
        Icon(icon, color: color ?? kBrown, size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(
            fontFamily: 'LeagueSpartan',
            color: color ?? kBrown,
            fontSize: 15, fontWeight: FontWeight.w600))),
        Icon(Icons.chevron_right,
            color: (color ?? kBrown).withOpacity(0.4), size: 20),
      ]),
    ),
  );
}