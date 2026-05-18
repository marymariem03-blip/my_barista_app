import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'track_order_screen.dart';
import 'menu_screen.dart'; // ✅

const int kTabHome    = 0;
const int kTabOrders  = 1;
const int kTabTrack   = 2;
const int kTabProfile = 3;

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _activeNav;

  static const List<Widget> _pages = [
    HomeBody(),
    OrdersScreen(),
    TrackOrderScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _activeNav = widget.initialIndex;
  }

  void switchTab(int index) => setState(() => _activeNav = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
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
            // Home
            _NavItem(
              path: 'assets/icons/home.png',
              fallback: Icons.home_rounded,
              isActive: _activeNav == kTabHome,
              onTap: () => switchTab(kTabHome),
            ),
            // ✅ Order icon → MenuScreen (not a tab switch)
            _NavItem(
              path: 'assets/icons/order.png',
              fallback: Icons.receipt_long_outlined,
              isActive: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              ),
            ),
            // Track (cup)
            _NavItem(
              path: 'assets/icons/cup.png',
              fallback: Icons.local_cafe_outlined,
              isActive: _activeNav == kTabTrack,
              onTap: () => switchTab(kTabTrack),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _activeNav,
        children: _pages,
      ),
    );
  }
}

class MainScreenHelper {
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<MainScreenState>();
    state?.switchTab(index);
  }
}

class _NavItem extends StatelessWidget {
  final String path;
  final IconData fallback;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.path,
    required this.fallback,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          path,
          width: 28,
          height: 28,
          color: color,
          errorBuilder: (ctx, e, s) =>
              Icon(fallback, color: color, size: 28),
        ),
      ),
    );
  }
}