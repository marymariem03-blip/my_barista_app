import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'manager_dashboard_screen.dart';
import 'manager_plats_screen.dart';
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
          ManagerProfileScreen(),
        ],
      ),
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
            _NavItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              isActive: _tab == 0,
              onTap: () => setState(() => _tab = 0),
            ),
            _NavItem(
              icon: Icons.restaurant_menu_outlined,
              label: 'Plats',
              isActive: _tab == 1,
              onTap: () => setState(() => _tab = 1),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: _tab == 2,
              onTap: () => setState(() => _tab = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: color,
                    fontSize: 11,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}