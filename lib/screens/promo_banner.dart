// lib/screens/promo_banner.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'product_detail_screen.dart';

// ── Firestore IDs ─────────────────────────────────────────
const _kUbeId    = 'kEUyg8YJP9uZT0lYBS5x';
const _kSaladId  = 'Qfc1k3fE7BO7DrDWy3kx';
const _kMojitoId = 'O6QP3T1WAdjQyRuf78DT';

// ── Banner config — text/colors only, image from Firestore ─
class _BannerConfig {
  final String docId;
  final String headline;
  final String subline;
  final String discount;
  final String badge;
  final Color  leftBg;
  final Color  rightBg;
  final Color  headlineColor;
  final Color  sublineColor;
  final Color  accentColor;   // circles + CTA bg
  final Color  ctaTextColor;
  final bool   boldHeadline;
  const _BannerConfig({
    required this.docId,
    required this.headline,
    required this.subline,
    required this.discount,
    required this.badge,
    required this.leftBg,
    required this.rightBg,
    required this.headlineColor,
    required this.sublineColor,
    required this.accentColor,
    required this.ctaTextColor,
    this.boldHeadline = false,
  });
}

const _configs = <_BannerConfig>[
  // Banner 1 — Ube Drink (dark brown + cream circles)
  _BannerConfig(
    docId:         _kUbeId,
    headline:      'Experience our\ndelicious new\nUbe Drink',
    subline:       '',
    discount:      '10% OFF',
    badge:         'New',
    leftBg:        Color(0xFF2C1508),
    rightBg:       Color(0xFFF0EAE0),
    headlineColor: Color(0xFFE8D5B0),
    sublineColor:  Color(0xFFE8D5B0),
    accentColor:   Color(0xFFC8A970),
    ctaTextColor:  Color(0xFF2C1508),
    boldHeadline:  false,
  ),
  // Banner 2 — Blue Mojito (dark brown + cream circles, big bold text)
  _BannerConfig(
    docId:         _kMojitoId,
    headline:      'Your ultimate\nsummer refresher.\nThe Classic\nIced Mojito.',
    subline:       '',
    discount:      '',
    badge:         'Classic',
    leftBg:        Color(0xFF2C1508),
    rightBg:       Color(0xFFF0EAE0),
    headlineColor: Color(0xFFFFFFFF),
    sublineColor:  Color(0xFFE8D5B0),
    accentColor:   Color(0xFFD4B882),
    ctaTextColor:  Color(0xFFFFFFFF),
    boldHeadline:  true,
  ),
  // Banner 3 — Caesar Salad (dark brown + warm circles)
  _BannerConfig(
    docId:         _kSaladId,
    headline:      'Experience our\ndelicious new salad',
    subline:       '',
    discount:      '10% OFF',
    badge:         'New',
    leftBg:        Color(0xFF2C1508),
    rightBg:       Color(0xFFF5EFE6),
    headlineColor: Color(0xFFE8D5B0),
    sublineColor:  Color(0xFFE8D5B0),
    accentColor:   Color(0xFFC8A970),
    ctaTextColor:  Color(0xFF2C1508),
    boldHeadline:  false,
  ),
];

// ── Public widget ─────────────────────────────────────────
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});
  @override State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _controller = PageController();
  int    _current   = 0;
  Timer? _timer;

  // Cache full product data per docId
  final Map<String, Map<String, dynamic>> _dataCache = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    for (final cfg in _configs) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('consommables').doc(cfg.docId).get();
        if (doc.exists && doc.data() != null) {
          _dataCache[cfg.docId] = doc.data()!;
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _loaded = true);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _configs.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context, _BannerConfig cfg) {
    final data = _dataCache[cfg.docId] ?? {};
    double price = 0;
    final raw = data['prix'];
    if (raw is num)    price = raw.toDouble();
    if (raw is String) price = double.tryParse(raw) ?? 0;
    final cat = (data['categorie'] as String? ?? '');
    final product = Product(
      id:           cfg.docId,
      name:         (data['nom']         as String?) ?? cfg.headline.replaceAll('\n', ' '),
      category:     (cat == 'hot_drinks' || cat == 'cold_drinks') ? 'drink' : 'food',
      price:        price,
      image:        (data['image']       as String?) ?? '',
      description:  (data['description'] as String?) ?? '',
      isBestSeller: (data['isBestSeller'] as bool?)  ?? false,
    );
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        // ── Carousel ──────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 160,
            child: _loaded
                ? PageView.builder(
                    controller:    _controller,
                    itemCount:     _configs.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder:   (ctx, i) => _BannerSlide(
                      config:   _configs[i],
                      imageUrl: _dataCache[_configs[i].docId]?['image'] as String?,
                      onTap:    () => _onTap(ctx, _configs[i]),
                    ),
                  )
                : _LoadingBanner(),
          ),
        ),
        const SizedBox(height: 10),

        // ── Dot indicators ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_configs.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin:  const EdgeInsets.symmetric(horizontal: 3),
              width:   active ? 20 : 7,
              height:  7,
              decoration: BoxDecoration(
                color: active
                    ? kBrown
                    : kBrown.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ── Loading placeholder ───────────────────────────────────
class _LoadingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF2C1508),
    child: const Center(child: CircularProgressIndicator(
        color: Color(0xFFC8A970), strokeWidth: 2)),
  );
}

// ── Single banner slide ───────────────────────────────────
class _BannerSlide extends StatelessWidget {
  final _BannerConfig config;
  final String?       imageUrl;
  final VoidCallback  onTap;
  const _BannerSlide({
    required this.config,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width - 32; // width minus padding

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width:  sw,
        height: 160,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── LEFT: brown side ─────────────────────────
          Expanded(
            flex: 55,
            child: Container(
              color: config.leftBg,
              child: Stack(children: [

                // Decorative circle outlines (bottom-left corner)
                Positioned(bottom: -30, left: -30,
                  child: _CircleOutline(
                      size: 110,
                      color: config.accentColor,
                      opacity: 0.35)),
                Positioned(bottom: 10, left: -10,
                  child: _CircleOutline(
                      size: 60,
                      color: config.accentColor,
                      opacity: 0.25)),

                // Text content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      // Headline
                      Text(config.headline,
                          style: TextStyle(
                              fontFamily:  'LeagueSpartan',
                              color:       config.headlineColor,
                              fontSize:    config.boldHeadline ? 13 : 12,
                              fontWeight:  config.boldHeadline
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              height: 1.25)),

                      // Discount
                      if (config.discount.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(config.discount,
                            style: const TextStyle(
                                fontFamily:  'LeagueSpartan',
                                color:       Color(0xFFE8D5B0),
                                fontSize:    26,
                                fontWeight:  FontWeight.w900,
                                height:      1.0)),
                      ],
                      const SizedBox(height: 10),

                      // CTA button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                            color:        config.accentColor,
                            borderRadius: BorderRadius.circular(24)),
                        child: Text('Order NOW',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color:      config.ctaTextColor,
                                fontSize:   11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          // ── RIGHT: light side with product image ─────
          Expanded(
            flex: 45,
            child: Container(
              color: config.rightBg,
              child: Stack(fit: StackFit.expand, children: [

                // Decorative circles (top-right)
                Positioned(top: -25, right: -25,
                  child: _CircleOutline(
                      size: 100,
                      color: config.accentColor,
                      opacity: 0.45)),
                Positioned(bottom: -20, right: 10,
                  child: _CircleOutline(
                      size: 65,
                      color: config.accentColor,
                      opacity: 0.3)),

                // Product image — centered, contained
                Center(child: _ProductImage(imageUrl: imageUrl)),

                // Badge pill
                if (config.badge.isNotEmpty)
                  Positioned(bottom: 12, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color:        config.leftBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(config.badge,
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color:      config.accentColor,
                              fontSize:   10,
                              fontWeight: FontWeight.w700)),
                    )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Product image loader ──────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.coffee_outlined,
          color: Color(0xFFC8A970), size: 60);
    }
    return CachedNetworkImage(
      imageUrl:    imageUrl!,
      height:      140,
      width:       double.infinity,
      fit:         BoxFit.contain,
      placeholder: (_, __) => const SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator(
              color: Color(0xFFC8A970), strokeWidth: 1.5))),
      errorWidget: (_, __, ___) => const Icon(Icons.coffee_outlined,
          color: Color(0xFFC8A970), size: 60),
    );
  }
}

// ── Circle outline deco ───────────────────────────────────
class _CircleOutline extends StatelessWidget {
  final double size, opacity;
  final Color  color;
  const _CircleOutline({
    required this.size,
    required this.color,
    required this.opacity,
  });
  @override
  Widget build(BuildContext context) => Container(
    width:  size,
    height: size,
    decoration: BoxDecoration(
        shape:  BoxShape.circle,
        border: Border.all(
            color: color.withOpacity(opacity), width: 2.5)),
  );
}