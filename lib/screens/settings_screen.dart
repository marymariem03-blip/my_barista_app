import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'notification_setting_screen.dart';
import 'password_setting_screen.dart';
import 'delete_account_screen.dart';
import 'help_screen.dart'; // ✅
import 'main_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [

          // ── Header ───────────────────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
                top: topPad + 14, left: 20, right: 20, bottom: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 34),
                  ),
                ),
                const Text('Settings',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          // ── Settings list ─────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _SettingItem(
                    icon: Icons.notifications_outlined,
                    iconAsset: 'assets/icons/not.png',
                    label: 'Notification Setting',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                            const NotificationSettingScreen())),
                  ),
                  _SettingItem(
                    icon: Icons.key_outlined,
                    iconAsset: 'assets/icons/password.png',
                    label: 'Password Setting',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                            const PasswordSettingScreen())),
                  ),
                  // ✅ Navigates to DeleteAccountScreen
                  _SettingItem(
                    icon: Icons.person_outline,
                    iconAsset: 'assets/icons/prof.png',
                    label: 'Delete Account',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                            const DeleteAccountScreen())),
                  ),
                  _SettingItem(
                    icon: Icons.chat_bubble_outline,
                    iconAsset: 'assets/icons/help.png',
                    label: 'Help',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                            const HelpScreen())), // ✅
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom nav ────────────────────────────────────
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: kBrown,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBtn(path: 'assets/icons/home.png',
                fallback: Icons.home_rounded,
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) =>
                        const MainScreen(initialIndex: kTabHome)),
                    (route) => false)),
            _NavBtn(path: 'assets/icons/order.png',
                fallback: Icons.receipt_long_outlined,
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) =>
                        const MainScreen(initialIndex: kTabOrders)),
                    (route) => false)),
            _NavBtn(path: 'assets/icons/cup.png',
                fallback: Icons.local_cafe_outlined,
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) =>
                        const MainScreen(initialIndex: kTabTrack)),
                    (route) => false)),
          ],
        ),
      ),
    );
  }
}

// ── Setting item ──────────────────────────────────────
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Image.asset(iconAsset,
                width: 26, height: 26, color: kBrown,
                errorBuilder: (ctx, e, s) =>
                    Icon(icon, color: kBrown, size: 26)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: kBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: kBrown.withOpacity(0.6), size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final String path;
  final IconData fallback;
  final VoidCallback onTap;
  const _NavBtn(
      {required this.path, required this.fallback, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(path,
            width: 28, height: 28, color: Colors.white38,
            errorBuilder: (ctx, e, s) =>
                Icon(fallback, color: Colors.white38, size: 28)),
      ),
    );
  }
}