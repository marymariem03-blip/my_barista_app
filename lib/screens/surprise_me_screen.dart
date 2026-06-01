// lib/screens/surprise_me_screen.dart

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import '../core/models/plat.dart';
import '../core/services/firebase_service.dart';
import 'product_detail_screen.dart';

// ── Fetch a random product from Firestore ─────────────
Future<Plat?> _fetchRandomPlat() async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('consommables')
        .get();
    if (snap.docs.isEmpty) return null;
    final docs = snap.docs;
    final doc  = docs[Random().nextInt(docs.length)];
    return _docToPlat(doc);
  } catch (_) {
    return null;
  }
}

Plat _docToPlat(QueryDocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  double price = 0;
  final raw = data['prix'];
  if (raw is num)    price = raw.toDouble();
  if (raw is String) price = double.tryParse(raw) ?? 0;

  return Plat(
    id:           doc.id,
    name:         (data['nom']         as String?) ?? '',
    category:     (data['categorie']   as String?) ?? 'hot_drinks',
    price:        price,
    image:        (data['image']       as String?) ?? '',
    description:  (data['description'] as String?) ?? '',
    isBestSeller: data['isBestSeller'] == true,
  );
}

String _categoryLabel(String cat) {
  switch (cat) {
    case 'hot_drinks':  return 'Hot Drinks';
    case 'cold_drinks': return 'Cold Drinks';
    case 'sweet':       return 'Sweet';
    case 'savory':      return 'Savory';
    default:            return cat;
  }
}


class SurpriseMeScreen extends StatefulWidget {
  const SurpriseMeScreen({super.key});
  @override State<SurpriseMeScreen> createState() => _SurpriseMeScreenState();
}

class _SurpriseMeScreenState extends State<SurpriseMeScreen> {
  Plat?  _plat;
  bool   _loading = false;

  Future<void> _surprise() async {
    setState(() => _loading = true);
    final plat = await _fetchRandomPlat();
    if (mounted) setState(() { _plat = plat; _loading = false; });
  }

  void _tryThis() {
    if (_plat == null) return;
    final product = Product(
      id:           _plat!.id,
      name:         _plat!.name,
      category:     (_plat!.category == 'hot_drinks' ||
                    _plat!.category == 'cold_drinks') ? 'drink' : 'food',
      price:        _plat!.price,
      image:        _plat!.image,
      description:  _plat!.description,
      isBestSeller: _plat!.isBestSeller,
    );
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
            product: product, isSurprise: true)));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 12, right: 20, bottom: 20),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('Surprise Me',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ]),
        ),

        // ── Content ─────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _plat == null
                ? _buildLanding(key: const ValueKey('landing'))
                : _buildResult(key: const ValueKey('result')),
          ),
        ),
      ]),
    );
  }

  // ── Landing state ────────────────────────────────
  Widget _buildLanding({Key? key}) => Padding(
    key: key,
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
              color: kBrown.withOpacity(0.08), shape: BoxShape.circle),
          child: Image.asset('assets/icons/gift.png',
              width: 64, height: 64, color: kBrown,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.card_giftcard_rounded, color: kBrown, size: 56)),
        ),
        const SizedBox(height: 28),
        const Text('Not sure what to order?',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: kInputBg, borderRadius: BorderRadius.circular(20)),
          child: Text(
            'Let My Barista surprise you with a randomly selected drink from our menu. Discover new flavors and earn bonus Beans when you try something unexpected.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.7), fontSize: 14, height: 1.6),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.circle, color: kBrownLight, size: 10),
          const SizedBox(width: 6),
          Text('+5 Bonus Beans when you order your surprise',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrownLight, fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: _loading ? null : _surprise,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
                color: kBrown, borderRadius: BorderRadius.circular(32)),
            alignment: Alignment.center,
            child: _loading
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Image.asset('assets/icons/gift.png',
                        width: 22, height: 22, color: Colors.white,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.card_giftcard_rounded,
                            color: Colors.white, size: 22)),
                    const SizedBox(width: 10),
                    const Text('Surprise Me!',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ]),
          ),
        ),
      ],
    ),
  );

  // ── Result state ─────────────────────────────────
  Widget _buildResult({Key? key}) {
    final p   = _plat!;
    final img = p.image;

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(20),
      child: Column(children: [

        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: img.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: img, height: 240, width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      height: 240, color: kInputBg),
                  errorWidget: (_, __, ___) => _imgPlaceholder())
              : img.startsWith('assets/')
                  ? Image.asset(img, height: 240,
                      width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder())
                  : _imgPlaceholder(),
        ),
        const SizedBox(height: 20),

        // Name
        Align(
          alignment: Alignment.centerLeft,
          child: Text(p.name,
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontSize: 24, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),

        // Category + price row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                color: kBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(_categoryLabel(p.category),
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text(p.formattedPrice,
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontSize: 20, fontWeight: FontWeight.w800)),
        ]),

        if (p.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(p.description,
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.6),
                    fontSize: 13, height: 1.4)),
          ),
        ],

        // Beans hint
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: kBrownLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.circle, color: kBrownLight, size: 8),
            const SizedBox(width: 6),
            Text('+5 Bonus Beans if you order this',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrownLight, fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 28),

        // Try This Drink
        GestureDetector(
          onTap: _tryThis,
          child: Container(
            width: double.infinity, height: 54,
            decoration: BoxDecoration(
                color: kBrown, borderRadius: BorderRadius.circular(32)),
            alignment: Alignment.center,
            child: const Text('Try This Drink',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 12),

        // Another Surprise + Back row
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: _loading ? null : _surprise,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                  color: kInputBg, borderRadius: BorderRadius.circular(24)),
              alignment: Alignment.center,
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: kBrown, strokeWidth: 2))
                  : const Text('Another Surprise',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 14,
                          fontWeight: FontWeight.w700)),
            ),
          )),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _plat = null),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: kInputBg, borderRadius: BorderRadius.circular(24)),
              alignment: Alignment.center,
              child: Text('Back',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.55), fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _imgPlaceholder() => Container(
      height: 240, color: kInputBg,
      child: const Center(child: Icon(Icons.coffee_outlined,
          color: kBrownLight, size: 60)));
}

// ── Bonus beans helper — call after surprise order placed ──
Future<void> awardSurpriseBeans(int amount) async {
  final uid = FirebaseService.currentUser?.uid;
  if (uid == null) return;
  try {
    final doc = await FirebaseFirestore.instance
        .collection('client').doc(uid).get();
    final current = (doc.data()?['beans'] as int?) ?? 0;
    await FirebaseFirestore.instance
        .collection('client').doc(uid)
        .set({'beans': current + amount}, SetOptions(merge: true));
  } catch (_) {}
}