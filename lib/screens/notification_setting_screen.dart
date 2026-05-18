import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'main_screen.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  // Toggle states matching design
  bool _generalNotif = false;
  bool _sound = false;
  bool _soundCall = false;
  bool _vibrate = true;
  bool _specialOffers = true;
  bool _promoDiscount = true;

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
              top: topPad + 18,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const Text(
                  'Notification Setting',
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── Toggle list ───────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _ToggleItem(
                    label: 'General Notification',
                    value: _generalNotif,
                    onChanged: (v) => setState(() => _generalNotif = v),
                  ),
                  _divider(),
                  _ToggleItem(
                    label: 'Sound',
                    value: _sound,
                    onChanged: (v) => setState(() => _sound = v),
                  ),
                  _divider(),
                  _ToggleItem(
                    label: 'Sound Call',
                    value: _soundCall,
                    onChanged: (v) => setState(() => _soundCall = v),
                  ),
                  _divider(),
                  _ToggleItem(
                    label: 'Vibrate',
                    value: _vibrate,
                    onChanged: (v) => setState(() => _vibrate = v),
                  ),
                  _divider(),
                  _ToggleItem(
                    label: 'Special Offers',
                    value: _specialOffers,
                    onChanged: (v) => setState(() => _specialOffers = v),
                  ),
                  _divider(),
                  _ToggleItem(
                    label: 'Promo and discount',
                    value: _promoDiscount,
                    onChanged: (v) => setState(() => _promoDiscount = v),
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
            _NavBtn(
              path: 'assets/icons/home.png',
              fallback: Icons.home_rounded,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainScreen(initialIndex: kTabHome),
                ),
                (route) => false,
              ),
            ),
            _NavBtn(
              path: 'assets/icons/order.png',
              fallback: Icons.receipt_long_outlined,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainScreen(initialIndex: kTabOrders),
                ),
                (route) => false,
              ),
            ),
            _NavBtn(
              path: 'assets/icons/cup.png',
              fallback: Icons.local_cafe_outlined,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainScreen(initialIndex: kTabTrack),
                ),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
    color: kBrown.withOpacity(0.1),
    thickness: 1,
    height: 1,
    indent: 16,
    endIndent: 16,
  );
}

// ── Toggle item ───────────────────────────────────────
class _ToggleItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                color: kBrown,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // ✅ Switch styled to match design (brown when on, grey when off)
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: kBrown,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final String path;
  final IconData fallback;
  final VoidCallback onTap;
  const _NavBtn({
    required this.path,
    required this.fallback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          path,
          width: 28,
          height: 28,
          color: Colors.white38,
          errorBuilder: (ctx, e, s) =>
              Icon(fallback, color: Colors.white38, size: 28),
        ),
      ),
    );
  }
}
