import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

// ── Generic placeholder screen ────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kBrownLight, size: 72),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Coming soon...',
                style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.black38,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// CartScreen → cart_screen.dart 
// TrackOrderScreen → track_order_screen.dart 

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(
      title: 'Notifications', icon: Icons.notifications_outlined);
}

class SurpriseMeScreen extends StatelessWidget {
  const SurpriseMeScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(
      title: 'Surprise Me', icon: Icons.card_giftcard_rounded);
}

class SipAndShareScreen extends StatelessWidget {
  const SipAndShareScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(
      title: 'Sip & Share', icon: Icons.people_alt_outlined);
}