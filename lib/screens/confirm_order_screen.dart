import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'payment_screen.dart';
import 'main_screen.dart';

class ConfirmOrderScreen extends StatefulWidget {
  const ConfirmOrderScreen({super.key});

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final cart      = AppDB.cart;
    final branch    = AppDB.selectedBranch?.name ?? "Barista's Menzah 9";

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [

          // ── Header ───────────────────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
                top: topPad + 14, left: 20, right: 20, bottom: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 34),
                  ),
                ),
                const Text('Confirm Order',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Your Barista's
                    const Text("Your Barista's",
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: kInputBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: kBrown, size: 18),
                          const SizedBox(width: 8),
                          Text(branch,
                              style: const TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: kBrown,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Order Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Summary',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        _EditBtn(onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cart items
                    ...cart.map((item) => _OrderItem(
                          item: item,
                          onRefresh: _refresh,
                        )),

                    const SizedBox(height: 8),
                    Divider(color: kBrown.withOpacity(0.15), height: 1),
                    const SizedBox(height: 14),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text(AppDB.cartTotalFormatted,
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pay Now button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaymentScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                            color: kBrown,
                            borderRadius: BorderRadius.circular(32)),
                        alignment: Alignment.center,
                        child: const Text('Pay Now',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom nav ────────────────────────────────
          _BottomNav(bottomPad: bottomPad),
        ],
      ),
    );
  }
}

// ── Order item tile ───────────────────────────────────
class _OrderItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRefresh;
  const _OrderItem({required this.item, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delete icon top right
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    AppDB.removeFromCart(item.product.id);
                    onRefresh();
                  },
                  child: Icon(Icons.delete_outline,
                      color: kBrown.withOpacity(0.5), size: 20),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.product.image,
                      width: 70, height: 70, fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => Container(
                          width: 70, height: 70,
                          color: kInputBg,
                          child: const Icon(Icons.coffee,
                              color: kBrownLight, size: 28)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(item.product.name,
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrown,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text(item.formattedSubtotal,
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: kBrown,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Edit + qty controls row
                        Row(
                          children: [
                            // Edit icon
                            Icon(Icons.edit_outlined,
                                color: kBrown.withOpacity(0.5), size: 16),
                            const SizedBox(width: 10),
                            // Minus
                            _SmallCircleBtn(
                              icon: Icons.remove,
                              onTap: () {
                                AppDB.removeFromCart(item.product.id);
                                onRefresh();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Text('${item.quantity}',
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrown,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                            // Plus
                            _SmallCircleBtn(
                              icon: Icons.add,
                              onTap: () {
                                AppDB.addToCart(item.product);
                                onRefresh();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Cancel Order button
                        GestureDetector(
                          onTap: () {
                            AppDB.removeFromCart(item.product.id);
                            onRefresh();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: kBrown.withOpacity(0.3))),
                            child: const Text('Cancel Order',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: kBrown,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: kBrown.withOpacity(0.1), height: 1),
      ],
    );
  }
}

class _SmallCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBrown.withOpacity(0.4))),
        child: Icon(icon, color: kBrown, size: 14),
      ),
    );
  }
}

class _EditBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _EditBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(16)),
        child: const Text('Edit',
            style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: kBrown,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final double bottomPad;
  const _BottomNav({required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
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