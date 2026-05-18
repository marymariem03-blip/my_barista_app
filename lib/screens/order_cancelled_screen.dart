import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'menu_screen.dart';
import 'main_screen.dart';

class OrderCancelledScreen extends StatelessWidget {
  const OrderCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          SizedBox(height: topPad),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ── Big X circle ──────────────────────
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kBrown, width: 3),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: kBrown,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Title ─────────────────────────────
                    const Text(
                      'Order Cancelled!',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Subtitle ──────────────────────────
                    Text(
                      'Your order has been\nsuccessfully cancelled',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.6),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Order something else button ────────
                    GestureDetector(
                      onTap: () {
                        // Go to the menu screen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MenuScreen()),
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: kBrown,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Text(
                          'Order something else',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Support text ──────────────────────
                    Text(
                      'If you have any question reach directly to our\ncustomer support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.45),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom nav ────────────────────────────────
          Container(
            height: 68 + bottomPad,
            decoration: const BoxDecoration(
              color: kBrown,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(bottom: bottomPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBtn(
                  icon: Icons.home_rounded,
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const MainScreen(initialIndex: kTabHome)),
                    (route) => false,
                  ),
                ),
                _NavBtn(
                  icon: Icons.receipt_long_outlined,
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const MainScreen(initialIndex: kTabOrders)),
                    (route) => false,
                  ),
                ),
                _NavBtn(
                  icon: Icons.local_cafe_outlined,
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const MainScreen(initialIndex: kTabTrack)),
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white54, size: 28),
      ),
    );
  }
}