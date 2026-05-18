import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'main_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  // ── Detect if cold drink ──────────────────────────────
  bool get _isCold =>
      widget.product.name.toLowerCase().contains('iced') ||
      widget.product.name.toLowerCase().contains('frappuccino') ||
      widget.product.name.toLowerCase().contains('matcha') ||
      widget.product.name.toLowerCase().contains('ice') ||
      widget.product.name.toLowerCase().contains('cold');

  bool get _isFood => widget.product.category == 'food';

  // ── Sizes ─────────────────────────────────────────────
  // Hot: Small / Medium / Large
  // Cold: Medium / Large only
  late final List<_Option> _sizes = _isCold
      ? [_Option('Medium', 0.0), _Option('Large', 1.0)]
      : [_Option('Small', 0.0), _Option('Medium', 1.5), _Option('Large', 2.0)];

  int _sizeIndex = 0;

  // ── Milk ──────────────────────────────────────────────
  // Hot: all options
  // Cold: Almond milk only shown (pre-selected)
  late final List<_Option> _milks = _isCold
      ? [_Option('Almond milk', 2.0)]
      : [
          _Option('Whole Milk',  0.0),
          _Option('Oat Milk',    1.0),
          _Option('Almond Milk', 1.0),
          _Option('Soy Milk',    1.0),
        ];

  int _milkIndex = 0;

  // ── Extras ────────────────────────────────────────────
  final List<_OptionCheck> _extras = [
    _OptionCheck('Caramel Sauce',          1.5),
    _OptionCheck('Hazelnut Topping',       1.5),
    _OptionCheck('Dark Chocolate Topping', 1.5),
    _OptionCheck('Mocha Topping',          1.5),
    _OptionCheck('White Chocolate Syrup',  1.0),
    _OptionCheck('Hazelnut Syrup',         1.5),
    _OptionCheck('Toffee Syrup',           1.0),
  ];

  // ── Extra Hot (hot drinks only) ───────────────────────
  int _hotIndex = 1;

  // ── Less Sugar (hot drinks only) ──────────────────────
  int _sugarIndex = 1;

  // ── Extra Coffee (cold drinks only) ───────────────────
  // Radio selection
  int _coffeeIndex = -1; // -1 = none selected
  final List<_Option> _coffeeShots = [
    _Option('Shot café',    1.0),
    _Option('Shot Arabica', 0.5),
  ];

  // ── Quantity ──────────────────────────────────────────
  int _qty = 1;

  // ── Total ─────────────────────────────────────────────
  double get _total {
    double price = widget.product.price;
    price += _sizes[_sizeIndex].price;
    if (!_isCold) price += _milks[_milkIndex].price;
    for (final e in _extras) {
      if (e.selected) price += e.price;
    }
    if (_isCold && _coffeeIndex >= 0) {
      price += _coffeeShots[_coffeeIndex].price;
    }
    return price * _qty;
  }

  String get _totalFormatted =>
      '${_total.toStringAsFixed(3).replaceAll('.', ',')}dt';

  int get _selectedExtrasCount => _extras.where((e) => e.selected).length;

  void _addToCart() {
    AppDB.addToCart(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart!',
            style: const TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad    = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [

          // ── Scrollable content ────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 120 + bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Product image ───────────────────────
                Container(
                  width: double.infinity,
                  height: 300,
                  color: const Color(0xFFF0EBE5),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          widget.product.image,
                          height: 260,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, e, s) => const Icon(
                              Icons.coffee, color: kBrownLight, size: 80),
                        ),
                      ),
                      Positioned(
                        top: topPad + 12,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.chevron_left,
                              color: kBrown, size: 34),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Price + qty ──────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_totalFormatted,
                              style: const TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: kBrown,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          Row(children: [
                            _QtyBtn(icon: Icons.remove,
                                onTap: () {
                                  if (_qty > 1) setState(() => _qty--);
                                }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Text('$_qty',
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrown,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ),
                            _QtyBtn(icon: Icons.add,
                                onTap: () => setState(() => _qty++)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ── Name + subtitle ──────────────
                      Text(widget.product.name,
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        _isCold
                            ? 'Café au lait glacé'
                            : _isFood
                                ? 'Café, lait et noisette'
                                : 'Café, lait et noisette',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.5),
                            fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // ── Size section ─────────────────
                      if (!_isFood) ...[
                        _SectionTitle(
                            title: 'Choose the size of your drink',
                            subtitle: 'Choose 1 product',
                            badge: 'Required'),
                        const SizedBox(height: 10),
                        ..._sizes.asMap().entries.map((e) => _RadioRow(
                              label: e.value.label,
                              price: e.value.price,
                              selected: _sizeIndex == e.key,
                              onTap: () =>
                                  setState(() => _sizeIndex = e.key),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // ── Milk section ─────────────────
                      if (!_isFood) ...[
                        _SectionTitle(
                            title: 'Change your milk?',
                            subtitle: 'Choose at least 1 product'),
                        const SizedBox(height: 10),
                        ..._milks.asMap().entries.map((e) => _RadioRow(
                              label: e.value.label,
                              price: e.value.price,
                              selected: _milkIndex == e.key,
                              onTap: () =>
                                  setState(() => _milkIndex = e.key),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // ── Extras ───────────────────────
                      _SectionTitle(
                          title: 'Extra',
                          subtitle: 'Choose a maximum of 7 products'),
                      const SizedBox(height: 10),
                      ..._extras.map((e) => _CheckRow(
                            label: e.label,
                            price: e.price,
                            selected: e.selected,
                            onTap: () {
                              if (!e.selected &&
                                  _selectedExtrasCount >= 7) return;
                              setState(() => e.selected = !e.selected);
                            },
                          )),
                      const SizedBox(height: 24),

                      // ── HOT DRINKS ONLY ──────────────
                      if (!_isCold && !_isFood) ...[
                        _SectionTitle(
                            title: 'Extra Hot ?',
                            subtitle: 'Choose 1 product',
                            badge: 'Required'),
                        const SizedBox(height: 10),
                        _RadioRow(
                            label: 'Yes', price: null,
                            selected: _hotIndex == 0,
                            onTap: () =>
                                setState(() => _hotIndex = 0)),
                        _RadioRow(
                            label: 'No', price: null,
                            selected: _hotIndex == 1,
                            onTap: () =>
                                setState(() => _hotIndex = 1)),
                        const SizedBox(height: 24),

                        _SectionTitle(
                            title: 'Less Sugar?',
                            subtitle: 'Choose 1 product',
                            badge: 'Required'),
                        const SizedBox(height: 10),
                        _RadioRow(
                            label: 'Yes', price: null,
                            selected: _sugarIndex == 0,
                            onTap: () =>
                                setState(() => _sugarIndex = 0)),
                        _RadioRow(
                            label: 'No', price: null,
                            selected: _sugarIndex == 1,
                            onTap: () =>
                                setState(() => _sugarIndex = 1)),
                        const SizedBox(height: 24),
                      ],

                      // ── COLD DRINKS ONLY ─────────────
                      if (_isCold) ...[
                        _SectionTitle(
                            title: 'Extra Coffee ?',
                            subtitle: 'Choose at least 1 product'),
                        const SizedBox(height: 10),
                        ..._coffeeShots.asMap().entries.map((e) =>
                            _RadioRow(
                              label: e.value.label,
                              price: e.value.price,
                              selected: _coffeeIndex == e.key,
                              onTap: () => setState(
                                  () => _coffeeIndex =
                                      _coffeeIndex == e.key
                                          ? -1
                                          : e.key),
                            )),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom: Add to Cart + nav ─────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: kBg,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GestureDetector(
                    onTap: _addToCart,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                          color: kBrown,
                          borderRadius: BorderRadius.circular(32)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/chart.png',
                              width: 22, height: 22,
                              color: Colors.white,
                              errorBuilder: (ctx, e, s) => const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white, size: 22)),
                          const SizedBox(width: 10),
                          const Text('Add to Cart',
                              style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
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
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) =>
                                const MainScreen(initialIndex: kTabHome)),
                            (route) => false,
                          )),
                      _NavBtn(path: 'assets/icons/order.png',
                          fallback: Icons.receipt_long_outlined,
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) =>
                                const MainScreen(initialIndex: kTabOrders)),
                            (route) => false,
                          )),
                      _NavBtn(path: 'assets/icons/cup.png',
                          fallback: Icons.local_cafe_outlined,
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) =>
                                const MainScreen(initialIndex: kTabTrack)),
                            (route) => false,
                          )),
                    ],
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

// ── Section title ─────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  const _SectionTitle(
      {required this.title, required this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  color: kBrown,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: kBrown,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(badge!,
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        const SizedBox(height: 2),
        Text(subtitle,
            style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.55),
                fontSize: 13)),
      ],
    );
  }
}

// ── Radio row ─────────────────────────────────────────
class _RadioRow extends StatelessWidget {
  final String label;
  final double? price;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow(
      {required this.label,
      required this.price,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceStr = price == null
        ? ''
        : price == 0
            ? '+0.000dt'
            : '+${price!.toStringAsFixed(3).replaceAll('.', ',')}dt';

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  color: kBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _DottedLine(),
            ),
          ),
          if (priceStr.isNotEmpty) ...[
            Text(priceStr,
                style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.7),
                    fontSize: 13)),
            const SizedBox(width: 8),
          ],
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected ? kBrown : Colors.black26,
                  width: 2),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                          color: kBrown, shape: BoxShape.circle),
                    ),
                  )
                : null,
          ),
        ]),
      ),
    );
  }
}

// ── Check row ─────────────────────────────────────────
class _CheckRow extends StatelessWidget {
  final String label;
  final double price;
  final bool selected;
  final VoidCallback onTap;
  const _CheckRow(
      {required this.label,
      required this.price,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceStr =
        '+${price.toStringAsFixed(3).replaceAll('.', ',')}dt';

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  color: kBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _DottedLine(),
            ),
          ),
          Text(priceStr,
              style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.7),
                  fontSize: 13)),
          const SizedBox(width: 8),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
                color: selected ? kBrown : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? kBrown : Colors.black26,
                    width: 1.5)),
            child: Icon(
              selected ? Icons.check : Icons.add,
              color: selected ? Colors.white : kBrown.withOpacity(0.5),
              size: 14,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Dotted line ───────────────────────────────────────
class _DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final count = (constraints.maxWidth / 6).floor();
      return Row(
        children: List.generate(count, (i) => Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: kBrown.withOpacity(0.2),
          ),
        )),
      );
    });
  }
}

// ── Qty button ────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(
            color: kBrown, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final String path;
  final IconData fallback;
  final VoidCallback onTap;
  const _NavBtn(
      {required this.path,
      required this.fallback,
      required this.onTap});

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

// ── Data models ───────────────────────────────────────
class _Option {
  final String label;
  final double price;
  const _Option(this.label, this.price);
}

class _OptionCheck {
  final String label;
  final double price;
  bool selected = false;
  _OptionCheck(this.label, this.price, {this.selected = false});
}