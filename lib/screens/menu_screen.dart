import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'main_screen.dart';
import 'app_header_icons.dart';
import 'product_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final List<_Category> _categories = const [
    _Category(label: 'Hot Drinks',  icon: 'assets/icons/hdrinks.png',  fallback: Icons.coffee),
    _Category(label: 'Cold Drinks', icon: 'assets/icons/cdrinks.png',  fallback: Icons.local_cafe_outlined),
    _Category(label: 'Sweet',       icon: 'assets/icons/sweet.png',    fallback: Icons.cake_outlined),
    _Category(label: 'Savory',      icon: 'assets/icons/savory.png',   fallback: Icons.restaurant_outlined),
  ];

  int _catIndex = 0;

  List<Product> get _filtered {
    switch (_catIndex) {
      case 0:
        return kProducts.where((p) => p.category == 'drink').toList();
      case 1:
        return kProducts.where((p) =>
            p.category == 'drink' &&
            (p.name.toLowerCase().contains('iced') ||
             p.name.toLowerCase().contains('frappuccino') ||
             p.name.toLowerCase().contains('matcha'))).toList();
      case 2:
        return kProducts.where((p) =>
            p.category == 'food' &&
            (p.name.toLowerCase().contains('velvet') ||
             p.name.toLowerCase().contains('cachuète'))).toList();
      case 3:
        return kProducts.where((p) => p.category == 'food').toList();
      default:
        return kProducts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [

          // ── Header ───────────────────────────────────
          SizedBox(
            height: 230,
            child: Stack(
              children: [

                // Brown background
                Container(color: kBrown),

                // F5F5F5 union shape — topLeft rounded
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40)),
                    ),
                  ),
                ),

                // Content
                Column(
                  children: [
                    SizedBox(height: topPad + 12),

                    // Search + icon buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Search bar
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22)),
                              child: Row(children: [
                                const SizedBox(width: 16),
                                Text('Search',
                                    style: TextStyle(
                                        fontFamily: 'LeagueSpartan',
                                        color: kBrown.withOpacity(0.35),
                                        fontSize: 15)),
                                const Spacer(),
                                Container(
                                  width: 36, height: 36,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                      color: kBrown, shape: BoxShape.circle),
                                  child: const Icon(Icons.tune,
                                      color: Colors.white, size: 18),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ✅ Reusable icons — same as home screen
                          const AppHeaderIcons(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category tabs
                    SizedBox(
                      height: 106,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_categories.length, (i) {
                          final isActive = _catIndex == i;
                          final cat = _categories[i];
                          return GestureDetector(
                            onTap: () => setState(() => _catIndex = i),
                            child: isActive
                                ? _ActiveTab(cat: cat)
                                : _InactiveTab(cat: cat),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Product list ──────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('No items in this category',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.4),
                        fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) =>
                        _ProductItem(product: _filtered[i]),
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
    );
  }
}

// ── Active tab — arch shape ───────────────────────────
class _ActiveTab extends StatelessWidget {
  final _Category cat;
  const _ActiveTab({required this.cat});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ArchClipper(),
      child: Container(
        width: 90, height: 106,
        color: const Color(0xFFF5F5F5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Image.asset(cat.icon, width: 40, height: 40,
                color: const Color(0xFF31190A),
                errorBuilder: (ctx, e, s) =>
                    Icon(cat.fallback, color: const Color(0xFF31190A), size: 36)),
            const SizedBox(height: 6),
            Text(cat.label, textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Color(0xFF31190A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Arch clipper ──────────────────────────────────────
class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const r = 20.0;
    final archRadius = w / 2;
    path.moveTo(0, h - r);
    path.quadraticBezierTo(0, h, r, h);
    path.lineTo(w - r, h);
    path.quadraticBezierTo(w, h, w, h - r);
    path.lineTo(w, archRadius);
    path.arcToPoint(Offset(0, archRadius),
        radius: Radius.circular(archRadius), clockwise: false);
    path.lineTo(0, h - r);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ArchClipper oldClipper) => false;
}

// ── Inactive tab ──────────────────────────────────────
class _InactiveTab extends StatelessWidget {
  final _Category cat;
  const _InactiveTab({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 49, height: 62,
          decoration: BoxDecoration(
              color: const Color(0xFF988377),
              borderRadius: BorderRadius.circular(14)),
          child: Center(
            child: Image.asset(cat.icon, width: 32, height: 32,
                color: const Color(0xFF31190A),
                errorBuilder: (ctx, e, s) =>
                    Icon(cat.fallback, color: const Color(0xFF31190A), size: 28)),
          ),
        ),
        const SizedBox(height: 6),
        Text(cat.label,
            style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: Colors.white.withOpacity(0.7),
                fontSize: 11)),
      ],
    );
  }
}

// ── Category model ────────────────────────────────────
class _Category {
  final String label;
  final String icon;
  final IconData fallback;
  const _Category({required this.label, required this.icon, required this.fallback});
}

// ── Product item — image directly on background ───────
class _ProductItem extends StatelessWidget {
  final Product product;
  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Image.asset(product.image,
              width: double.infinity, height: 240, fit: BoxFit.contain,
              errorBuilder: (ctx, e, s) => SizedBox(
                  height: 240,
                  child: Center(child: Icon(Icons.coffee,
                      color: kBrown.withOpacity(0.2), size: 80)))),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(product.name,
                style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w800))),
            Text('${product.formattedPrice}dt',
                style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Café, lait et noisette',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.5), fontSize: 13)),
        const SizedBox(height: 24),
      ],
      ), // Column
    ); // GestureDetector
  }
}

// ── Header icon ───────────────────────────────────────
// ── Nav button ────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final String path;
  final IconData fallback;
  final VoidCallback onTap;
  const _NavBtn({required this.path, required this.fallback, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(path, width: 28, height: 28, color: Colors.white38,
            errorBuilder: (ctx, e, s) =>
                Icon(fallback, color: Colors.white38, size: 28)),
      ),
    );
  }
}