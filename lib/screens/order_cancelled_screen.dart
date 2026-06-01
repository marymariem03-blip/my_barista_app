import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'main_screen.dart';

class OrderCancelledScreen extends StatelessWidget {
  const OrderCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: SharedNavBar(activeIndex: -1),
      body: Column(children: [
        SizedBox(height: topPad),

        // ── Back arrow ────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.chevron_left, color: kBrown, size: 32),
            ),
          ),
        ),

        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ── cancel.png icon ───────────────────
                  Image.asset(
                    'assets/icons/cancel.png',
                    width: 160, height: 160,
                    color: kBrown,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kBrown, width: 3)),
                      child: const Icon(Icons.close,
                          color: kBrown, size: 60),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Title ─────────────────────────────
                  const Text('Order Cancelled!',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 28,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),

                  // ── Subtitle ──────────────────────────
                  Text('Your order has been\nsuccessfully cancelled',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.6),
                          fontSize: 15, height: 1.5)),
                  const SizedBox(height: 36),

                  // ── Order something else ──────────────
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) =>
                            const MainScreen(initialIndex: kTabMenu)),
                        (route) => false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(color: kBrown,
                          borderRadius: BorderRadius.circular(32)),
                      child: const Text('Order something else',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Support text ──────────────────────
                  Text(
                    'If you have any question reach directly to our\ncustomer support',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.45),
                        fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}