import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

// ── Data ─────────────────────────────────────────────
class _CardItem {
  final String emoji;
  final int id;
  bool isFlipped;
  bool isMatched;

  _CardItem({                 
    required this.emoji,
    required this.id,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

// ── Screen ────────────────────────────────────────────
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with TickerProviderStateMixin {
  // Coffee-themed items — 8 pairs = 16 cards
  static const _emojis = ['☕', '🧋', '🍰', '🥐', '🫖', '🍩', '🧁', '🍫'];

  List<_CardItem> _cards = [];
  List<int> _flipped = [];
  int _moves = 0;
  int _matched = 0;
  bool _locked = false;
  bool _won = false;

  // Per-card flip animation controllers
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  // ── Game logic ───────────────────────────────────
  void _initGame() {
    final deck = [..._emojis, ..._emojis];
    deck.shuffle(Random());

    _cards = deck
        .asMap()
        .entries
        .map((e) => _CardItem(emoji: e.value, id: e.key))
        .toList();

    _controllers = List.generate(
      16,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    _flipped = [];
    _moves = 0;
    _matched = 0;
    _locked = false;
    _won = false;
  }

  void _restart() {
    for (final c in _controllers) {
      c.reverse();
      c.dispose();
    }
    setState(() => _initGame());
  }

  void _onCardTap(int index) {
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

      if (a.emoji == b.emoji) {
        // Match found
        Timer(const Duration(milliseconds: 400), () {
          setState(() {
            a.isMatched = true;
            b.isMatched = true;
            _matched++;
            _flipped.clear();
            _locked = false;
            if (_matched == 8) _won = true;
          });
        });
      } else {
        // No match — flip back
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

  // ── Build ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
              top: topPad + 12,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Coffee Memory',
                    style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Moves counter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_moves moves',
                    style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Stats row ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _StatChip(label: 'Pairs found', value: '$_matched / 8'),
                const SizedBox(width: 12),
                _StatChip(label: 'Remaining', value: '${8 - _matched}'),
                const Spacer(),
                GestureDetector(
                  onTap: _restart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kBrownLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'New Game',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Win banner ─────────────────────────────
          if (_won)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'You matched all pairs!',
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // ── Card grid ──────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 16,
                itemBuilder: (_, i) => _MemoryCard(
                  card: _cards[i],
                  animation: _animations[i],
                  onTap: () => _onCardTap(i),
                ),
              ),
            ),
          ),

          // ── Instructions ───────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Tap cards to find matching pairs',
              style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Memory card widget ────────────────────────────────
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
          // Front shows when animation > 0.5
          final showFront = animation.value > 0.5;
          final angle = animation.value * pi;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: showFront
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: kBrown,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: const Center(child: Text('☕', style: TextStyle(fontSize: 24))),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        color: card.isMatched
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: card.isMatched
              ? const Color(0xFF4CAF50)
              : kBrownLight.withOpacity(0.4),
          width: card.isMatched ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(card.emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrown,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrown.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
