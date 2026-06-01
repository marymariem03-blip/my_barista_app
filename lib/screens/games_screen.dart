// lib/screens/games_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';

class _CardItem {
  final String imagePath;
  final int id;
  bool isFlipped;
  bool isMatched;

  _CardItem({
    required this.imagePath,
    required this.id,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with TickerProviderStateMixin {

  static const _images = [
    'assets/images/games_card/coffee.png',
    'assets/images/games_card/cookie.png',
    'assets/images/games_card/frappuccino.png',
    'assets/images/games_card/matcha.png',
    'assets/images/games_card/mojito.png',
    'assets/images/games_card/red_velvet.png',
    'assets/images/games_card/salad.png',
    'assets/images/games_card/tuna_sandwich.png',
  ];

  List<_CardItem> _cards = [];
  List<int> _flipped     = [];
  int  _moves   = 0;
  int  _matched = 0;
  bool _locked  = false;
  bool _won     = false;
  bool _beansAwarded = false;
  bool _gameStarted  = false; //  controls popup

  late List<AnimationController> _controllers;
  late List<Animation<double>>   _animations;

  @override
  void initState() {
    super.initState();
    _initGame();
    //  Show rules popup after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRulesDialog();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _initGame() {
    final deck = [..._images, ..._images];
    deck.shuffle(Random());

    _cards = deck
        .asMap()
        .entries
        .map((e) => _CardItem(imagePath: e.value, id: e.key))
        .toList();

    _controllers = List.generate(16, (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    ));

    _animations = _controllers.map((c) =>
        Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();

    _flipped       = [];
    _moves         = 0;
    _matched       = 0;
    _locked        = false;
    _won           = false;
    _beansAwarded  = false;
  }

  // Rules popup
  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                    color: kBrown.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.coffee,
                    color: kBrown, size: 36),
              ),
              const SizedBox(height: 16),

              // Title
              const Text('Coffee Memory',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),

              // Rules
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RuleItem(icon: Icons.touch_app_outlined,
                        text: 'Tap two cards to flip them'),
                    const SizedBox(height: 8),
                    _RuleItem(icon: Icons.compare_outlined,
                        text: 'Match all 8 pairs to win'),
                    const SizedBox(height: 8),
                    _RuleItem(icon: Icons.repeat,
                        text: 'Unmatched cards flip back'),
                    const SizedBox(height: 8),
                    _RuleItem(icon: Icons.emoji_events_outlined,
                        text: 'Win in ≤15 moves to earn',
                        highlight: '+5 Beans ☕'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Start button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _gameStarted = true);
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                      color: kBrown,
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Start Now',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restart() {
    for (final c in _controllers) {
      c.reverse();
      c.dispose();
    }
    setState(() {
      _initGame();
      _gameStarted = true; // keep started after restart
    });
  }

  // ✅ Award 5 beans — saved to Firestore
  Future<void> _checkAndAwardBeans() async {
    if (_beansAwarded) return;
    if (_moves > 15) return;
    _beansAwarded = true;

    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseService.addBeans(uid, 5);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('☕ +5 Beans awarded!',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    } catch (_) {}
  }

  void _onCardTap(int index) {
    if (!_gameStarted) return; // 
    if (_locked) return;
    final card = _cards[index];
    if (card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
      _controllers[index].forward();
      _flipped.add(index);
    });

    if (_flipped.length == 2) {
      _locked = true;
      _moves++;
      final a = _cards[_flipped[0]];
      final b = _cards[_flipped[1]];

      if (a.imagePath == b.imagePath) {
        Timer(const Duration(milliseconds: 400), () {
          setState(() {
            a.isMatched = true;
            b.isMatched = true;
            _matched++;
            _flipped.clear();
            _locked = false;
            if (_matched == 8) {
              _won = true;
              _checkAndAwardBeans();
            }
          });
        });
      } else {
        Timer(const Duration(milliseconds: 900), () {
          setState(() {
            _controllers[_flipped[0]].reverse();
            _controllers[_flipped[1]].reverse();
            a.isFlipped = false;
            b.isFlipped = false;
            _flipped.clear();
            _locked = false;
          });
        });
      }
    }
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
              top: topPad + 12, left: 16, right: 16, bottom: 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Coffee Memory',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.white12,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$_moves moves',
                  style: const TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // ── Stats row ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            _StatChip(label: 'Pairs found', value: '$_matched / 8'),
            const SizedBox(width: 12),
            _StatChip(label: 'Remaining',   value: '${8 - _matched}'),
            const Spacer(),
            GestureDetector(
              onTap: _restart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: kBrownLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('New Game',
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),

        // ── Win banner ──────────────────────────────
        if (_won)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(
              _moves <= 15
                  ? ' You won in $_moves moves! +5 Beans '
                  : ' You won! Finish in ≤15 moves to earn beans',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w700),
            )),
          ),

        // ── Grid ────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
              itemCount: 16,
              itemBuilder: (_, i) => _MemoryCard(
                card:      _cards[i],
                animation: _animations[i],
                onTap:     () => _onCardTap(i),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text('Tap cards to find matching pairs',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.5), fontSize: 13)),
        ),
      ]),
    );
  }
}

// ── Rule item ─────────────────────────────────────────
class _RuleItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? highlight;
  const _RuleItem({required this.icon, required this.text, this.highlight});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: kBrown, size: 18),
      const SizedBox(width: 10),
      Expanded(child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown, fontSize: 13),
          children: highlight != null ? [
            TextSpan(text: ' $highlight',
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrownLight, fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ] : [],
        ),
      )),
    ],
  );
}

// ── Memory card ───────────────────────────────────────
class _MemoryCard extends StatelessWidget {
  final _CardItem card;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final showFront = animation.value > 0.5;
          final angle     = animation.value * pi;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: showFront
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildFront(),
                  )
                : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() => Container(
    decoration: BoxDecoration(
        color: const Color.fromARGB(53, 84, 60, 3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withOpacity(0.15), width: 1.5)),
    padding: const EdgeInsets.all(10),
    child: Image.asset(
      'assets/images/games_card/cup.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.coffee, color: Colors.white, size: 28),
    ),
  );

  Widget _buildFront() => Container(
    decoration: BoxDecoration(
        color: card.isMatched
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: card.isMatched
                ? const Color(0xFF4CAF50)
                : kBrownLight.withOpacity(0.4),
            width: card.isMatched ? 2 : 1)),
    padding: const EdgeInsets.all(6),
    child: Image.asset(
      card.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_outlined, color: kBrownLight, size: 28),
    ),
  );
}

// ── Stat chip ─────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: kInputBg,
        borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 16, fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.6), fontSize: 11)),
    ]),
  );
}