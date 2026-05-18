// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import '../core/services/firebase_service.dart';
import 'find_barista_screen.dart' show branchNotifier; 
import 'placeholder_screens.dart';
import 'games_screen.dart';
import 'app_header_icons.dart';
import 'menu_screen.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String _userName = '';
  bool   _loading  = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid != null) {
      final data = await FirebaseService.getUser(uid);
      if (mounted) {
        setState(() {
          _userName = (data?['nom'] as String? ?? '').split(' ').first;
          _loading  = false;
        });
      }
    } else {
      setState(() {
        _userName = AppDB.currentUser.name.split(' ').first;
        _loading  = false;
      });
    }
  }

  void _navigate(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final size   = MediaQuery.of(context).size;

    final beans      = AppDB.currentUser.beans;
    final beansRatio = beans / 2000.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Dark brown header ─────────────────────────
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

                          // Hello text
                          _loading
                              ? Container(width: 180, height: 28,
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(6)))
                              : Text('Hello, $_userName ',
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),

                          // ✅ Reacts instantly when user picks a barista
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
                      onTap: () => _navigate(context, const SurpriseMeScreen())),
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
                            size: 14, color: Colors.white,
                            fallback: Icons.circle),
                        const SizedBox(width: 26),
                        Text('$beans/2000', style: const TextStyle(
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

          // Best Seller
          _SectionHeader(title: 'Best Seller',
              onViewAll: () => _navigate(context, const MenuScreen())),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: kBestSellers.length,
              itemBuilder: (_, i) {
                final p = kBestSellers[i];
                return _ProductCard(
                    image: p.image, name: p.name, price: p.formattedPrice);
              },
            ),
          ),
          const SizedBox(height: 18),

          // Promo Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(clipBehavior: Clip.hardEdge, children: [
                Container(
                  height: 118, color: kBrown,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Expanded(flex: 6, child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const Text('Experience our\ndelicious new salad',
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: Colors.white, fontSize: 12,
                                fontWeight: FontWeight.w500, height: 1.3)),
                        const SizedBox(height: 3),
                        const Text('10% OFF', style: TextStyle(
                            fontFamily: 'LeagueSpartan', color: Colors.white,
                            fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(color: kBrownLight,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('Order NOW', style: TextStyle(
                              fontFamily: 'LeagueSpartan', color: Colors.white,
                              fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    )),
                    Expanded(flex: 5, child: Image.asset(
                        'assets/images/salade_cesar.png', fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) =>
                            Container(color: kBrownLight))),
                  ]),
                ),
                Positioned(bottom: 8, right: size.width * 0.35,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white38, width: 1)),
                      child: const Text('New', style: TextStyle(
                          fontFamily: 'LeagueSpartan', color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.w700)),
                    )),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Sip & Share header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Row(children: [
                _AssetIcon(path: 'assets/icons/sip_share.png',
                    size: 22, color: kBrown, fallback: Icons.people_alt),
                const SizedBox(width: 8),
                const Text('Sip & Share', style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: kBrown,
                    fontSize: 20, fontWeight: FontWeight.w500)),
              ]),
              GestureDetector(
                onTap: () => _navigate(context, const SipAndShareScreen()),
                child: const Row(children: [
                  Text('View All', style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 12, fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right, color: kBrown, size: 18),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Sip & Share posts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: AppDB.sipSharePosts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SipShareCard(
                    avatar:    post.avatarPath,
                    name:      post.userName,
                    caption:   post.caption,
                    hashtag:   post.hashtag,
                    postImage: post.postImagePath),
              )).toList(),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────

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
  final String image; final String name; final String price;
  const _ProductCard({required this.image, required this.name,
      required this.price});
  @override Widget build(BuildContext context) => Container(
    width: 128, margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
            blurRadius: 8, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.asset(image, height: 115, width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, e, s) => Container(height: 115, color: kInputBg,
                child: const Center(child: Icon(Icons.coffee,
                    color: kBrownLight, size: 38)))),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown, fontSize: 12, fontWeight: FontWeight.w700,
            height: 1.2)),
        const SizedBox(height: 3),
        Text(price, style: const TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrownLight, fontSize: 12, fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

class _SipShareCard extends StatelessWidget {
  final String avatar, name, caption, hashtag, postImage;
  const _SipShareCard({required this.avatar, required this.name,
      required this.caption, required this.hashtag, required this.postImage});
  @override Widget build(BuildContext context) => Container(
    height: 90,
    decoration: BoxDecoration(color: const Color(0xFFEDE8E3),
        borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: kInputBg,
              backgroundImage: AssetImage(avatar),
              onBackgroundImageError: (e, s) {},
              child: const Icon(Icons.person, color: kBrownLight, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text(name, style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontSize: 13, fontWeight: FontWeight.w800)),
            Text(caption, style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: Colors.black54, fontSize: 11)),
            Text(hashtag, style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrownLight, fontSize: 11,
                fontWeight: FontWeight.w700)),
          ])),
        ]),
      )),
      ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
        child: Image.asset(postImage, width: 120, height: 90,
            fit: BoxFit.cover,
            errorBuilder: (ctx, e, s) => Container(width: 120, height: 90,
                color: kInputBg, child: const Icon(Icons.image,
                    color: kBrownLight, size: 32))),
      ),
    ]),
  );
}