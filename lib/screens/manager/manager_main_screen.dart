// lib/screens/manager/manager_main_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'manager_dashboard_screen.dart';
import 'manager_plats_screen.dart';
import 'manager_feedbacks_screen.dart'; 
import 'manager_profile_screen.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(
        index: _tab,
        children: const [
          ManagerDashboardScreen(),
          ManagerPlatsScreen(),
          ManagerFeedbacksScreen(), 
          ManagerProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: kBrown,
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              assetIcon: 'assets/icons/dashboard.png',
              fallback:  Icons.dashboard_outlined,
              isActive:  _tab == 0,
              onTap:     () => setState(() => _tab = 0),
            ),
            _NavItem(
              assetIcon:  'assets/icons/dish.png',
              fallback:   Icons.restaurant_menu_outlined,
              isActive:   _tab == 1,
              onTap:      () => setState(() => _tab = 1),
              iconWidth:  46,
              iconHeight: 50,
            ),
            _NavItem(
              assetIcon: 'assets/icons/feedbacks.png',
              fallback:  Icons.chat_bubble_outline,
              isActive:  _tab == 2,
              onTap:     () => setState(() => _tab = 2),
            ),
            _NavItem(
              assetIcon: 'assets/icons/prof.png',
              fallback:  Icons.person_outline,
              isActive:  _tab == 3,
              onTap:     () => setState(() => _tab = 3),
              iconWidth:  60,
              iconHeight: 65,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Nav item ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final String       assetIcon;
  final IconData     fallback;
  final bool         isActive;
  final VoidCallback onTap;
  final double       iconWidth;
  final double       iconHeight;

  const _NavItem({
    required this.assetIcon,
    required this.fallback,
    required this.isActive,
    required this.onTap,
    this.iconWidth  = 28,
    this.iconHeight = 28,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56, height: 56,
        child: Center(
          child: Image.asset(
            assetIcon,
            width:  iconWidth,
            height: iconHeight,
            color:  color,
            errorBuilder: (_, __, ___) =>
                Icon(fallback, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}