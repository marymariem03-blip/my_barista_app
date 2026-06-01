// lib/screens/confirm_order_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
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
    final topPad = MediaQuery.of(context).padding.top;
    final cart   = AppDB.cart;
    final branch = AppDB.selectedBranch?.name ?? "Barista's Menzah 9";

    return Scaffold(
      backgroundColor: kBrown, // ✅ brown background like orders screen
      bottomNavigationBar: SharedNavBar(activeIndex: -1),
      body: Column(children: [

        // ── Brown header ─────────────────────────────
        Padding(
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('Confirm Order', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 28, fontWeight: FontWeight.w700)),
          ]),
        ),

        //  White body with rounded top corners
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Your Barista's ──────────────────
                  const SizedBox(height: 4),
                  const Text("Your Barista's",
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 24,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: kInputBg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      const Icon(Icons.location_on_outlined,
                          color: kBrown, size: 18),
                      const SizedBox(width: 8),
                      Flexible(child: Text(branch,
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 14,
                              fontWeight: FontWeight.w400))),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // ── Order Summary ───────────────────
                  const Text('Order Summary',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Divider(color: kBrown.withOpacity(0.15), height: 1),

                  // Cart items
                  ...cart.map((item) =>
                      _OrderItem(item: item, onRefresh: _refresh)),

                  Divider(color: kBrown.withOpacity(0.15),
                      height: 1, thickness: 1),
                  const SizedBox(height: 14),

                  // ── Total ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(
                          fontFamily: 'LeagueSpartan', color: kBrown,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(AppDB.cartTotalFormatted,
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan', color: kBrown,
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Pay Now ─────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const PaymentScreen())),
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(color: kBrown,
                          borderRadius: BorderRadius.circular(32)),
                      alignment: Alignment.center,
                      child: const Text('Pay Now', style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: Colors.white, fontSize: 23,
                          fontWeight: FontWeight.w400)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Order item tile ───────────────────────────────────
class _OrderItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRefresh;
  const _OrderItem({required this.item, required this.onRefresh});

  Widget _buildImage() {
    final img = item.product.image;
    final placeholder = Container(
        width: 80, height: 80, color: kInputBg,
        child: const Center(child: Icon(Icons.coffee,
            color: kBrownLight, size: 28)));

    if (img.startsWith('http://') || img.startsWith('https://')) {
      return CachedNetworkImage(
          imageUrl: img, width: 80, height: 80,
          fit: BoxFit.contain,
          placeholder: (_, __) => placeholder,
          errorWidget: (_, __, ___) => placeholder);
    }
    return Image.asset(img, width: 80, height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => placeholder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            ),
            const SizedBox(width: 12),

            // Name + cancel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item.product.name,
                      style: const TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      for (int i = 0; i < item.quantity; i++) {
                        AppDB.removeFromCart(item.product.id);
                      }
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
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),

            // Price + delete + qty
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    for (int i = 0; i < item.quantity; i++) {
                      AppDB.removeFromCart(item.product.id);
                    }
                    onRefresh();
                  },
                  child: Icon(Icons.delete_outline,
                      color: kBrown.withOpacity(0.5), size: 20),
                ),
                const SizedBox(height: 6),
                Text(item.formattedSubtotal,
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown, fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(children: [
                  _QtyBtn(icon: Icons.remove, onTap: () {
                    AppDB.removeFromCart(item.product.id);
                    onRefresh();
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                        style: const TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                  _QtyBtn(icon: Icons.add, onTap: () {
                    AppDB.addToCart(item.product);
                    onRefresh();
                  }),
                ]),
              ],
            ),
          ],
        ),
      ),
      Divider(color: kBrown.withOpacity(0.1), height: 1),
    ]);
  }
}

// ── Qty button ────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26, height: 26,
      decoration: const BoxDecoration(
          color: kBrown, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 14),
    ),
  );
}