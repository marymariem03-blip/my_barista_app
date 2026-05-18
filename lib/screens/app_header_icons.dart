import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'cart_screen.dart';
import 'placeholder_screens.dart';
import 'profile_drawer_screen.dart';

// ── AppHeaderIcons ────────────────────────────────────
// Reusable row of 3 icons: Cart · Notifications · Profile
// Use in any screen header with the same navigation behavior.
//
// Usage:
//   const AppHeaderIcons()
//
class AppHeaderIcons extends StatelessWidget {
  const AppHeaderIcons({super.key});

  // ── Open cart as slide-in overlay ────────────────────
  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => const CartScreen(),
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

  // ── Open notifications ────────────────────────────────
  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // ── Open profile drawer as slide-in overlay ───────────
  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => const ProfileDrawerScreen(),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cart icon
        _HeaderBtn(
          path: 'assets/icons/chart.png',
          fallback: Icons.shopping_cart_outlined,
          onTap: () => _openCart(context),
        ),
        const SizedBox(width: 8),

        // Notification icon
        _HeaderBtn(
          path: 'assets/icons/not.png',
          fallback: Icons.notifications_outlined,
          onTap: () => _openNotifications(context),
        ),
        const SizedBox(width: 8),

        // Profile icon
        _HeaderBtn(
          path: 'assets/icons/prof.png',
          fallback: Icons.person_outline,
          onTap: () => _openProfile(context),
        ),
      ],
    );
  }
}

// ── Single icon button ────────────────────────────────
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            path,
            width: 20,
            height: 20,
            color: kBrown,
            errorBuilder: (ctx, e, s) =>
                Icon(fallback, color: kBrown, size: 20),
          ),
        ),
      ),
    );
  }
}
