// lib/screens/product_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'main_screen.dart';
import 'surprise_me_screen.dart' show awardSurpriseBeans; // ← bonus beans

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool    isSurprise; // ← true when opened from Surprise Me

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isSurprise = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  bool get _isCold =>
      widget.product.category == 'cold_drinks' ||
      widget.product.name.toLowerCase().contains('iced') ||
      widget.product.name.toLowerCase().contains('frappuccino') ||
      widget.product.name.toLowerCase().contains('ice') ||
      widget.product.name.toLowerCase().contains('cold');

  bool get _isFood =>
      widget.product.category == 'food' ||
      widget.product.category == 'sweet' ||
      widget.product.category == 'savory';

  bool get _isHot => !_isCold && !_isFood;

  // ── Sizes ──────────────────────────────────────────
  late final List<_Option> _sizes = _isCold
      ? [_Option('Medium', 0.0), _Option('Large', 1.0)]
      : [_Option('Small', 0.0), _Option('Medium', 1.5), _Option('Large', 2.0)];
  int _sizeIndex = 0;

  // ── Milks ──────────────────────────────────────────
  late final List<_Option> _milks = _isCold
      ? [_Option('Almond milk', 2.0)]
      : [
          _Option('Whole Milk',  0.0),
          _Option('Oat Milk',    1.0),
          _Option('Almond Milk', 1.0),
          _Option('Soy Milk',    1.0),
        ];
  int _milkIndex = 0;

  int _hotIndex    = 1;
  int _sugarIndex  = 1;
  int _coffeeIndex = -1;

  final List<_Option> _coffeeShots = [
    _Option('Shot café',    1.0),
    _Option('Shot Arabica', 0.5),
  ];

  final List<_OptionCheck> _extras = [
    _OptionCheck('Caramel Sauce',          1.5),
    _OptionCheck('Hazelnut Topping',       1.5),
    _OptionCheck('Dark Chocolate Topping', 1.5),
    _OptionCheck('Mocha Topping',          1.5),
    _OptionCheck('White Chocolate Syrup',  1.0),
    _OptionCheck('Hazelnut Syrup',         1.5),
    _OptionCheck('Toffee Syrup',           1.0),
  ];

  int get _selectedExtrasCount => _extras.where((e) => e.selected).length;

  int _qty = 1;

  double get _total {
    double price = widget.product.price;
    if (!_isFood) {
      price += _sizes[_sizeIndex].price;
      price += _milks[_milkIndex].price;
      for (final e in _extras) { if (e.selected) price += e.price; }
      if (_isCold && _coffeeIndex >= 0) {
        price += _coffeeShots[_coffeeIndex].price;
      }
    }
    return price * _qty;
  }

  String get _totalFormatted =>
      '${_total.toStringAsFixed(3).replaceAll('.', ',')}dt';

  String get _subtitle {
    if (widget.product.description.isNotEmpty) return widget.product.description;
    if (_isCold) return 'Café au lait glacé';
    if (_isHot)  return 'Café, lait et noisette';
    return '';
  }

  // ── Add to cart — awards beans if from Surprise Me ─
  Future<void> _addToCart() async {
    AppDB.addToCart(widget.product);

    // Award +5 bonus beans for surprise orders
    if (widget.isSurprise) {
      await awardSurpriseBeans(5);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        widget.isSurprise
            ? '${widget.product.name} added! +5 Beans bonus 🎉'
            : '${widget.product.name} added to cart!',
        style: const TextStyle(fontFamily: 'LeagueSpartan'),
      ),
      backgroundColor: kBrown,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Navigator.pop(context);
  }

  Widget _buildProductImage() {
    final img = widget.product.image;
    const h = 260.0;
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: img, height: h, fit: BoxFit.contain,
        placeholder: (_, __) => const SizedBox(height: h,
            child: Center(child: CircularProgressIndicator(
                color: kBrown, strokeWidth: 2))),
        errorWidget: (_, __, ___) => const Icon(
            Icons.coffee, color: kBrownLight, size: 80),
      );
    }
    return Image.asset(img, height: h, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
            Icons.coffee, color: kBrownLight, size: 80));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [

        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            // ── Image ───────────────────────────────
            Container(
              width: double.infinity, height: 300,
              color: const Color.fromARGB(255, 250, 250, 250),
              child: Stack(children: [
                Center(child: _buildProductImage()),
                Positioned(
                  top: topPad + 12, left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: kBrown, size: 34),
                  ),
                ),
                // Surprise Me badge
                if (widget.isSurprise)
                  Positioned(
                    top: topPad + 12, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: kBrownLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min,
                          children: [
                        Icon(Icons.card_giftcard,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Surprise +5 Beans', style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Price + qty
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Text(_totalFormatted,
                        style: const TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    Row(children: [
                      _QtyBtn(icon: Icons.remove,
                          onTap: () { if (_qty > 1) setState(() => _qty--); }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_qty', style: const TextStyle(
                            fontFamily: 'LeagueSpartan', color: kBrown,
                            fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      _QtyBtn(icon: Icons.add,
                          onTap: () => setState(() => _qty++)),
                    ]),
                  ]),
                  const SizedBox(height: 6),

                  // Name
                  Text(widget.product.name,
                      style: const TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 24,
                          fontWeight: FontWeight.w800)),

                  if (_subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(_subtitle, style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.5), fontSize: 13)),
                  ],
                  const SizedBox(height: 24),

                  // ── COLD DRINKS ───────────────────
                  if (_isCold) ...[
                    _SectionTitle(title: 'Choose the size of your drink',
                        subtitle: 'Choose 1 product', badge: 'Required'),
                    const SizedBox(height: 10),
                    ..._sizes.asMap().entries.map((e) => _RadioRow(
                          label: e.value.label, price: e.value.price,
                          selected: _sizeIndex == e.key,
                          onTap: () => setState(() => _sizeIndex = e.key),
                        )),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Change your milk?',
                        subtitle: 'Choose at least 1 product'),
                    const SizedBox(height: 10),
                    ..._milks.asMap().entries.map((e) => _RadioRow(
                          label: e.value.label, price: e.value.price,
                          selected: _milkIndex == e.key,
                          onTap: () => setState(() => _milkIndex = e.key),
                        )),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Extra',
                        subtitle: 'Choose a maximum of 7 products'),
                    const SizedBox(height: 10),
                    ..._extras.map((e) => _CheckRow(
                          label: e.label, price: e.price,
                          selected: e.selected,
                          onTap: () {
                            if (!e.selected && _selectedExtrasCount >= 7) return;
                            setState(() => e.selected = !e.selected);
                          },
                        )),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Extra Coffee ?',
                        subtitle: 'Choose at least 1 product'),
                    const SizedBox(height: 10),
                    ..._coffeeShots.asMap().entries.map((e) => _RadioRow(
                          label: e.value.label, price: e.value.price,
                          selected: _coffeeIndex == e.key,
                          onTap: () => setState(() =>
                              _coffeeIndex = _coffeeIndex == e.key
                                  ? -1 : e.key),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ── HOT DRINKS ────────────────────
                  if (_isHot) ...[
                    _SectionTitle(title: 'Choose the size of your drink',
                        subtitle: 'Choose 1 product', badge: 'Required'),
                    const SizedBox(height: 10),
                    ..._sizes.asMap().entries.map((e) => _RadioRow(
                          label: e.value.label, price: e.value.price,
                          selected: _sizeIndex == e.key,
                          onTap: () => setState(() => _sizeIndex = e.key),
                        )),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Change your milk?',
                        subtitle: 'Choose at least 1 product'),
                    const SizedBox(height: 10),
                    ..._milks.asMap().entries.map((e) => _RadioRow(
                          label: e.value.label, price: e.value.price,
                          selected: _milkIndex == e.key,
                          onTap: () => setState(() => _milkIndex = e.key),
                        )),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Extra',
                        subtitle: 'Choose a maximum of 7 products'),
                    const SizedBox(height: 10),
                    ..._extras.map((e) => _CheckRow(
                          label: e.label, price: e.price,
                          selected: e.selected,
                          onTap: () {
                            if (!e.selected && _selectedExtrasCount >= 7) return;
                            setState(() => e.selected = !e.selected);
                          },
                        )),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Extra Hot ?',
                        subtitle: 'Choose 1 product', badge: 'Required'),
                    const SizedBox(height: 10),
                    _RadioRow(label: 'Yes', price: null,
                        selected: _hotIndex == 0,
                        onTap: () => setState(() => _hotIndex = 0)),
                    _RadioRow(label: 'No', price: null,
                        selected: _hotIndex == 1,
                        onTap: () => setState(() => _hotIndex = 1)),
                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Less Sugar?',
                        subtitle: 'Choose 1 product', badge: 'Required'),
                    const SizedBox(height: 10),
                    _RadioRow(label: 'Yes', price: null,
                        selected: _sugarIndex == 0,
                        onTap: () => setState(() => _sugarIndex = 0)),
                    _RadioRow(label: 'No', price: null,
                        selected: _sugarIndex == 1,
                        onTap: () => setState(() => _sugarIndex = 1)),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ]),
        ),

        // ── Add to Cart + nav bar ───────────────────
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GestureDetector(
                onTap: _addToCart,
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(color: kBrown,
                      borderRadius: BorderRadius.circular(32)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/chart.png',
                          width: 22, height: 22, color: Colors.white,
                          errorBuilder: (ctx, e, s) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white, size: 22)),
                      const SizedBox(width: 10),
                      const Text('Add to Cart',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            SharedNavBar(activeIndex: kTabMenu),
          ]),
        ),
      ]),
    );
  }
}

// ── Section title ─────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title, subtitle;
  final String? badge;
  const _SectionTitle({required this.title, required this.subtitle,
      this.badge});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Flexible(child: Text(title,
            style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontSize: 18, fontWeight: FontWeight.w800))),
        if (badge != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: kBrown,
                borderRadius: BorderRadius.circular(10)),
            child: Text(badge!, style: const TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ]),
      const SizedBox(height: 2),
      Text(subtitle, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.55), fontSize: 13)),
    ],
  );
}

// ── Radio row ─────────────────────────────────────────
class _RadioRow extends StatelessWidget {
  final String label;
  final double? price;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({required this.label, required this.price,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceStr = price == null ? ''
        : price == 0 ? '+0.000dt'
        : '+${price!.toStringAsFixed(3).replaceAll('.', ',')}dt';

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Text(label, style: const TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown, fontSize: 14, fontWeight: FontWeight.w500)),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _DottedLine(),
          )),
          if (priceStr.isNotEmpty) ...[
            Text(priceStr, style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.7), fontSize: 13)),
            const SizedBox(width: 8),
          ],
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? kBrown : Colors.black26, width: 2)),
            child: selected
                ? Center(child: Container(width: 10, height: 10,
                    decoration: const BoxDecoration(
                        color: kBrown, shape: BoxShape.circle)))
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
  const _CheckRow({required this.label, required this.price,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(label, style: const TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown, fontSize: 14, fontWeight: FontWeight.w500)),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _DottedLine(),
        )),
        Text('+${price.toStringAsFixed(3).replaceAll('.', ',')}dt',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.7), fontSize: 13)),
        const SizedBox(width: 8),
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
              color: selected ? kBrown : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected ? kBrown : Colors.black26, width: 1.5)),
          child: Icon(selected ? Icons.check : Icons.add,
              color: selected ? Colors.white : kBrown.withOpacity(0.5),
              size: 14),
        ),
      ]),
    ),
  );
}

// ── Dotted line ───────────────────────────────────────
class _DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final count = (constraints.maxWidth / 6).floor();
      return Row(children: List.generate(count, (_) => Expanded(
        child: Container(height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: kBrown.withOpacity(0.2)),
      )));
    },
  );
}

// ── Qty button ────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 32, height: 32,
        decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18)),
  );
}

// ── Models ────────────────────────────────────────────
class _Option {
  final String label;
  final double price;
  const _Option(this.label, this.price);
}

class _OptionCheck {
  final String label;
  final double price;
  bool selected;
  _OptionCheck(this.label, this.price, {this.selected = false});
}