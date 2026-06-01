// lib/screens/cart_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'confirm_order_screen.dart';
import 'main_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final cart      = AppDB.cart;
    final screenW   = MediaQuery.of(context).size.width;
    final navH      = 68.0 + bottomPad;

    return Material(
      color: Colors.transparent,
      child: Stack(children: [

        // ── Left tap-to-close ─────────────────────────
        Positioned(
          left: 0, top: 0, bottom: 0,
          width: screenW * 0.16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
        ),

        // ── Cart dark panel (stops above nav bar) ─────
        Positioned(
          right: 0, top: 0, bottom: navH,
          width: screenW * 0.84,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
            ),
            child: Container(
              color: const Color(0xFF1E0E05),
              child: Column(children: [
                SizedBox(height: topPad + 16),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Image.asset('assets/icons/chart.png',
                        width: 30, height: 30, color: Colors.white,
                        errorBuilder: (ctx, e, s) => const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white, size: 30)),
                    const SizedBox(width: 10),
                    const Text('Cart', style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: cart.isEmpty
                      ? _EmptyCart()
                      : _FilledCart(cart: cart, onRefresh: _refresh),
                ),
              ]),
            ),
          ),
        ),

        // ── Nav bar — full width at screen bottom ─────
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: navH,
          child: Container(
            decoration: const BoxDecoration(
              color: kBrown,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(bottom: bottomPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  path:     'assets/icons/home.png',
                  fallback: Icons.home_rounded,
                  onTap: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) =>
                          const MainScreen(initialIndex: kTabHome)),
                      (r) => false),
                ),
                _NavItem(
                  path:       'assets/icons/dish.png',
                  fallback:   Icons.restaurant_menu_outlined,
                  iconWidth:  46,
                  iconHeight: 50,
                  onTap: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) =>
                          const MainScreen(initialIndex: kTabMenu)),
                      (r) => false),
                ),
                _NavItem(
                  path:       'assets/icons/cup.png',
                  fallback:   Icons.local_cafe_outlined,
                  iconWidth:  46,
                  iconHeight: 50,
                  onTap: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) =>
                          const MainScreen(initialIndex: kTabTrack)),
                      (r) => false),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Nav item ──────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final String path;
  final IconData fallback;
  final VoidCallback onTap;
  final double iconWidth;
  final double iconHeight;

  const _NavItem({
    required this.path,
    required this.fallback,
    required this.onTap,
    this.iconWidth  = 28,
    this.iconHeight = 28,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Image.asset(path,
          width: iconWidth, height: iconHeight,
          color: Colors.white38,
          errorBuilder: (ctx, e, s) =>
              Icon(fallback, color: Colors.white38, size: iconWidth)),
    ),
  );
}

// ── Empty cart ────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Your cart is empty',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: Colors.white.withOpacity(0.55),
                fontSize: 16, fontWeight: FontWeight.w400,
                decoration: TextDecoration.none)),
        const SizedBox(height: 52),
        GestureDetector(
          onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>
                  const MainScreen(initialIndex: kTabMenu)),
              (r) => false),
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5)),
            child: const Icon(Icons.add, color: Colors.white, size: 64),
          ),
        ),
        const SizedBox(height: 28),
        const Text('Want To Add\nSomething?',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: Colors.white, fontSize: 24,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none, height: 1.3)),
      ],
    );
  }
}

// ── Filled cart ───────────────────────────────────────
class _FilledCart extends StatelessWidget {
  final List<CartItem> cart;
  final VoidCallback onRefresh;
  const _FilledCart({required this.cart, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final itemCount = cart.fold<int>(0, (sum, i) => sum + i.quantity);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('You have $itemCount items in the cart',
            style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.w500)),
      ),
      const SizedBox(height: 16),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: cart.length,
          separatorBuilder: (_, __) => Divider(
              color: Colors.white.withOpacity(0.12),
              height: 1, thickness: 1),
          itemBuilder: (_, i) =>
              _CartTile(item: cart[i], onRefresh: onRefresh),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _DashedLine(),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          const Text('Total', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: Colors.white,
              fontSize: 18, fontWeight: FontWeight.w700)),
          Text(AppDB.cartTotalFormatted,
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const ConfirmOrderScreen())),
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
                color: const Color(0xFF6B3A1F).withOpacity(0.7),
                borderRadius: BorderRadius.circular(32)),
            alignment: Alignment.center,
            child: const Text('Confirm Order',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }
}

// ── Cart tile ─────────────────────────────────────────
class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRefresh;
  const _CartTile({required this.item, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final imgPath = item.product.image;
    final isFile  = imgPath.startsWith('/');
    final isHttp  = imgPath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isFile
              ? Image.file(File(imgPath), width: 64, height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => _imgPlaceholder())
              : isHttp
                  ? Image.network(imgPath, width: 64, height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => _imgPlaceholder())
                  : Image.asset(imgPath, width: 64, height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => _imgPlaceholder()),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Expanded(child: Text(item.product.name,
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w700))),
            Text(item.formattedSubtotal,
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Spacer(),
            GestureDetector(
              onTap: () { AppDB.removeFromCart(item.product.id); onRefresh(); },
              child: Container(width: 26, height: 26,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38, width: 1.5),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.remove, color: Colors.white, size: 14)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${item.quantity}',
                  style: const TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
            GestureDetector(
              onTap: () { AppDB.addToCart(item.product); onRefresh(); },
              child: Container(width: 26, height: 26,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38, width: 1.5),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 14)),
            ),
          ]),
        ])),
      ]),
    );
  }

  Widget _imgPlaceholder() => Container(
      width: 64, height: 64, color: Colors.white12,
      child: const Icon(Icons.coffee, color: Colors.white38, size: 28));
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 1,
    child: CustomPaint(
        painter: _DashedPainter(),
        size: const Size(double.infinity, 1)),
  );
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white38..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 10;
    }
  }
  @override bool shouldRepaint(_DashedPainter old) => false;
}