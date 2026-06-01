// lib/screens/home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import '../core/models/plat.dart';
import '../core/services/firebase_service.dart';
import 'find_barista_screen.dart' show branchNotifier;
import 'placeholder_screens.dart';
import 'sip_and_share_screen.dart';
import 'games_screen.dart';
import 'app_header_icons.dart';
import 'main_screen.dart';
import 'product_detail_screen.dart';
import 'surprise_me_screen.dart'; // ← added
import 'promo_banner.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String _userName = '';
  int    _beans    = 0;
  bool   _loading  = true;

  final Stream<QuerySnapshot> _bestSellerStream = FirebaseFirestore.instance
      .collection('consommables')
      .where('isBestSeller', isEqualTo: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid != null) {
      final userData   = await FirebaseService.getUser(uid);
      final clientData = await FirebaseService.getClientData(uid);
      if (mounted) {
        setState(() {
          _userName = (userData?['nom'] as String? ?? '').split(' ').first;
          _beans    = (clientData?['beans'] as int?) ?? 0;
          _loading  = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  static double _parsePrice(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  Plat _docToPlat(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Plat(
      id:           doc.id,
      name:         data['nom']          as String? ?? '',
      category:     (data['categorie'] ?? data['catagorie'] ?? 'hot_drinks') as String,
      price:        _parsePrice(data['prix']),
      image:        data['image']        as String? ?? '',
      description:  (data['description'] ?? '') as String,
      isBestSeller: data['isBestSeller'] == true,
    );
  }

  void _goToMenu(BuildContext context) {
    final state = context.findAncestorStateOfType<MainScreenState>();
    if (state != null) {
      state.switchTab(kTabMenu);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) =>
              const MainScreen(initialIndex: kTabMenu)),
          (r) => false);
    }
  }

  void _openProduct(BuildContext context, Plat plat) {
    final product = Product(
      id:           plat.id,
      name:         plat.name,
      category:     (plat.category == 'hot_drinks' ||
                    plat.category == 'cold_drinks') ? 'drink' : 'food',
      price:        plat.price,
      image:        plat.image,
      description:  plat.description,
      isBestSeller: plat.isBestSeller,
    );
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product)));
  }

  void _navigate(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final topPad     = MediaQuery.of(context).padding.top;
    final size       = MediaQuery.of(context).size;
    final beansRatio = (_beans / 2000.0).clamp(0.0, 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Dark brown header ───────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
                top: topPad + 12, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _loading
                              ? Container(width: 180, height: 28,
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(6)))
                              : Text(
                                  _userName.isNotEmpty
                                      ? 'Hello, $_userName '
                                      : 'Hello!',
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          ValueListenableBuilder<Branch?>(
                            valueListenable: branchNotifier,
                            builder: (_, branch, __) => Row(children: [
                              _AssetIcon(
                                  path:     'assets/icons/loc_2.png',
                                  size:     20,
                                  color:    Colors.white,
                                  fallback: Icons.location_on),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  branch?.name ?? "Select a Barista's",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color:      Colors.white,
                                      fontSize:   13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const AppHeaderIcons(),
                  ],
                ),
                const SizedBox(height: 16),

                // Feature cards
                Row(children: [
                  _FeatureCard(path: 'assets/icons/games.png',
                      fallback: Icons.sports_esports_rounded,
                      label: 'Games',
                      onTap: () => _navigate(context, const GamesScreen())),
                  const SizedBox(width: 10),
                  _FeatureCard(path: 'assets/icons/gift.png',
                      fallback: Icons.card_giftcard_rounded,
                      label: 'Suprise Me',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurpriseMeScreen()))), // ← updated
                  const SizedBox(width: 10),
                  _FeatureCard(path: 'assets/icons/sip_share.png',
                      fallback: Icons.people_alt_outlined,
                      label: 'Sip & Share',
                      onTap: () => _navigate(context, const SipAndShareScreen())),
                ]),
                const SizedBox(height: 14),

                // Beans progress
                Container(
                  decoration: BoxDecoration(color: kBrownLight,
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(children: [
                    Image.asset('assets/images/cup baristas 1.png',
                        height: 96, width: 106, fit: BoxFit.contain,
                        errorBuilder: (ctx, e, s) => const Icon(
                            Icons.coffee, color: Colors.white, size: 32)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        _AssetIcon(path: 'assets/icons/coffee1.png',
                            size: 25,
                            color: Colors.white,
                            fallback: Icons.circle),
                        const SizedBox(width: 26),
                        Text('$_beans/2000', style: const TextStyle(
                            fontFamily: 'LeagueSpartan', color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                            value: beansRatio,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 7),
                      ),
                    ])),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Best Sellers from Firestore ─────────────
          _SectionHeader(
              title: 'Best Seller',
              onViewAll: () => _goToMenu(context)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: StreamBuilder<QuerySnapshot>(
              stream: _bestSellerStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                      color: kBrown, strokeWidth: 2));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(child: Text('Aucun best seller',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.4), fontSize: 13)));
                }
                final plats = docs.map(_docToPlat).toList();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  physics: const BouncingScrollPhysics(),
                  itemCount: plats.length,
                  itemBuilder: (_, i) => _ProductCard(
                      plat:  plats[i],
                      onTap: () => _openProduct(context, plats[i])),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // ── Promo Carousel ──────────────────────────
          const PromoBanner(),
          const SizedBox(height: 20),

          // ── Sip & Share ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _AssetIcon(path: 'assets/icons/sip_share.png',
                  size: 22, color: kBrown, fallback: Icons.people_alt),
              const SizedBox(width: 8),
              const Text('Sip & Share', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 20, fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(height: 24),

          Center(
            child: Column(children: [
              Icon(Icons.chat_bubble_outline,
                  size: 56, color: kBrown.withOpacity(0.15)),
              const SizedBox(height: 12),
              Text('comming soon',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.4),
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────

class _AssetIcon extends StatelessWidget {
  final String path; final double size;
  final Color color; final IconData fallback;
  const _AssetIcon({required this.path, required this.size,
      required this.color, required this.fallback});
  @override Widget build(BuildContext context) => Image.asset(path,
      width: size, height: size,
      errorBuilder: (ctx, e, s) => Icon(fallback, color: color, size: size));
}

class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 20, fontWeight: FontWeight.w500)),
      GestureDetector(onTap: onViewAll, child: const Row(children: [
        Text('View All', style: TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown, fontSize: 12, fontWeight: FontWeight.w600)),
        Icon(Icons.chevron_right, color: kBrown, size: 18),
      ])),
    ]),
  );
}

class _FeatureCard extends StatelessWidget {
  final String path; final IconData fallback;
  final String label; final VoidCallback onTap;
  const _FeatureCard({required this.path, required this.fallback,
      required this.label, required this.onTap});
  @override Widget build(BuildContext context) => Expanded(
    child: GestureDetector(onTap: onTap, child: Container(
      height: 84,
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _AssetIcon(path: path, size: 58, color: kBrown, fallback: fallback),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    )),
  );
}

class _ProductCard extends StatelessWidget {
  final Plat plat;
  final VoidCallback onTap;
  const _ProductCard({required this.plat, required this.onTap});

  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 128, margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
              blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: _buildImage(plat.image),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Text(plat.name, style: const TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown, fontSize: 12, fontWeight: FontWeight.w700,
              height: 1.2)),
          const SizedBox(height: 3),
          Text(plat.formattedPrice, style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrownLight, fontSize: 12, fontWeight: FontWeight.w700)),
        ])),
      ]),
    ),
  );

  static Widget _buildImage(String img) {
    final placeholder = Container(height: 115, color: kInputBg,
        child: const Center(child: Icon(Icons.coffee,
            color: kBrownLight, size: 38)));
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return CachedNetworkImage(
          imageUrl: img, height: 115, width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => placeholder,
          errorWidget: (_, __, ___) => placeholder);
    }
    return Image.asset(img, height: 115, width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder);
  }
}