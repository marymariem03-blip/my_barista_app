import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'order_confirmed_screen.dart';
import 'main_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final cart = AppDB.cart;
    final branch = AppDB.selectedBranch?.name ?? "Barista's Menzah 9";
    final total = AppDB.cartTotalFormatted;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
              top: topPad + 14,
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
                  'Payment',
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Your Barista's
                    const Text(
                      "Your Barista's",
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: kBrown,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            branch,
                            style: const TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _EditChip(),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Items list compact
                    ...cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: kBrown.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${item.quantity} items',
                              style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        total,
                        style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: kBrown.withOpacity(0.1), height: 1),
                    const SizedBox(height: 20),

                    // Payment Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _EditChip(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Card icon
                        Image.asset(
                          'assets/icons/card.png',
                          width: 32,
                          height: 32,
                          color: kBrown,
                          errorBuilder: (ctx, e, s) => const Icon(
                            Icons.credit_card,
                            color: kBrown,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Credit Card',
                          style: const TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '*** *** *** 43 /00 /000',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: kBrown.withOpacity(0.1), height: 1),
                    const SizedBox(height: 20),

                    // Delivery Time
                    const Text(
                      'Delivery Time',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          '15 mins',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Pay Now button
                    GestureDetector(
                      onTap: () {
                        // Place the order
                        AppDB.placeOrder();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrderConfirmedScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: kBrown,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                      builder: (_) =>
                          const MainScreen(initialIndex: kTabOrders),
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
        ],
      ),
    );
  }
}

class _EditChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Edit',
        style: TextStyle(
          fontFamily: 'LeagueSpartan',
          color: kBrown,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

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
