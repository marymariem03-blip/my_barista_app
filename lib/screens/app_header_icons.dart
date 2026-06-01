// lib/screens/app_header_icons.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';
import 'profile_drawer_screen.dart';

class AppHeaderIcons extends StatelessWidget {
  const AppHeaderIcons({super.key});

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => CartScreen(),
        transitionsBuilder: (ctx, anim, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => const NotificationsScreen(),
        transitionsBuilder: (ctx, anim, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => ProfileDrawerScreen(),
        transitionsBuilder: (ctx, anim, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.currentUser?.uid ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cart
        _HeaderBtn(
          path:     'assets/icons/chart.png',
          fallback: Icons.shopping_cart_outlined,
          onTap:    () => _openCart(context),
        ),
        const SizedBox(width: 8),

        // Notification bell with unread badge
        StreamBuilder<QuerySnapshot>(
          stream: uid.isEmpty
              ? const Stream.empty()
              : FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: uid)
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
          builder: (context, snap) {
            final unread = snap.data?.docs.length ?? 0;
            return GestureDetector(
              onTap: () => _openNotifications(context),
              child: Stack(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/not.png',
                      width: 20, height: 20, color: kBrown,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.notifications_outlined,
                          color: kBrown, size: 20),
                    ),
                  ),
                ),
                if (unread > 0)
                  Positioned(top: 5, right: 5,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFD4A017),
                          shape: BoxShape.circle),
                    ),
                  ),
              ]),
            );
          },
        ),
        const SizedBox(width: 8),

        // Profile
        _HeaderBtn(
          path:     'assets/icons/prof.png',
          fallback: Icons.person_outline,
          onTap:    () => _openProfile(context),
        ),
      ],
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final String path;
  final IconData fallback;
  final VoidCallback onTap;

  const _HeaderBtn({
    required this.path,
    required this.fallback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(path,
              width: 20, height: 20, color: kBrown,
              errorBuilder: (ctx, e, s) =>
                  Icon(fallback, color: kBrown, size: 20)),
        ),
      ),
    );
  }
}