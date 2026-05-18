import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'main_screen.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Delivery time — 29th, 4:00 PM
    final now = DateTime.now();
    final deliveryStr =
        'Delivery by ${now.day}th, ${_formatTime(now.add(const Duration(minutes: 15)))}';

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ── Check circle ──────────────────────
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kBrown, width: 3),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/check.png',
                          width: 54, height: 54,
                          color: kBrown,
                          errorBuilder: (ctx, e, s) => const Icon(
                              Icons.check, color: kBrown, size: 54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Order Confirmed!
                    const Text('Order Confirmed!',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),

                    Text(
                      'Your order has been placed\nsuccesfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.6),
                          fontSize: 14,
                          height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    // Delivery time
                    Text(
                      deliveryStr,
                      style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 36),

                    // Track my order button
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) =>
                            const MainScreen(initialIndex: kTabTrack)), // ✅
                        (route) => false,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                        decoration: BoxDecoration(
                            color: kBrown,
                            borderRadius: BorderRadius.circular(32)),
                        child: const Text('Track my order',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Support text
                    Text(
                      'If you have any questions, please reach out\ndirectly to our customer support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.45),
                          fontSize: 12,
                          height: 1.5),
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
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

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