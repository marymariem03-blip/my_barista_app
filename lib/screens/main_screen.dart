// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'home_screen.dart';
import 'track_order_screen.dart';
import 'menu_screen.dart';
import 'sip_and_share_screen.dart';

const int kTabHome    = 0;
const int kTabMenu    = 1;
const int kTabTrack   = 2;
const int kTabSip     = 3;
const int kTabOrders  = 1;

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
    MenuScreen(),
    TrackOrderScreen(),
    SipAndShareScreen(),
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
      extendBody: true,
      bottomNavigationBar: SharedNavBar(
        activeIndex: _activeNav,
        onTabSelected: switchTab,
      ),
      body: IndexedStack(
        index: _activeNav,
        children: _pages,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SharedNavBar
// ══════════════════════════════════════════════════════════
class SharedNavBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int)? onTabSelected;

  const SharedNavBar({
    super.key,
    required this.activeIndex,
    this.onTabSelected,
  });

  void _tap(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => MainScreen(initialIndex: index)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: kBrown,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _NavItem(
            path:     'assets/icons/home.png',
            fallback: Icons.home_rounded,
            isActive: activeIndex == kTabHome,
            onTap:    () => _tap(context, kTabHome),
          ),
          // Menu
          _NavItem(
            path:       'assets/icons/dish.png',
            fallback:   Icons.restaurant_menu_outlined,
            isActive:   activeIndex == kTabMenu,
            onTap:      () => _tap(context, kTabMenu),
            iconWidth:  46,
            iconHeight: 50,
          ),
          // Track
          _NavItem(
            path:       'assets/icons/cup.png',
            fallback:   Icons.local_cafe_outlined,
            isActive:   activeIndex == kTabTrack,
            onTap:      () => _tap(context, kTabTrack),
            iconWidth:  46,
            iconHeight: 50,
          ),
          // Sip & Share
          _NavItem(
            path:     'assets/icons/sip_share.png',
            fallback: Icons.people_alt_outlined,
            isActive: activeIndex == kTabSip,
            onTap:    () => _tap(context, kTabSip),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// _NavItem
// ══════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final String   path;
  final IconData fallback;
  final bool     isActive;
  final VoidCallback onTap;
  final double   iconWidth;
  final double   iconHeight;

  const _NavItem({
    required this.path,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(path,
            width:  iconWidth,
            height: iconHeight,
            color:  color,
            errorBuilder: (ctx, e, s) =>
                Icon(fallback, color: color, size: iconWidth)),
      ),
    );
  }
}