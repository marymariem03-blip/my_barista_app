// lib/screens/manager/manager_feedbacks_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class ManagerFeedbacksScreen extends StatelessWidget {
  const ManagerFeedbacksScreen({super.key});

  static String _str(dynamic v) => v == null ? '' : v.toString();

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Stream<List<Map<String, dynamic>>> get _feedbackStream {
    return FirebaseFirestore.instance
        .collection('feedbacks')
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBrown,
      body: Column(children: [

      // ── Brown header ──────────────────────────────
      Container(
        color: kBrown,
        width: double.infinity,
        padding: EdgeInsets.only(
            top: topPad + 20, left: 16, right: 20, bottom: 24),
        child: Stack(alignment: Alignment.center, children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 34),
            ),
          ),
          const Text('Feedbacks Clients',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w800)),
        ]),
      ),

      // ── White rounded body ────────────────────────
      Expanded(
        child: Container(
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _feedbackStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                    color: kBrown));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}',
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.red, fontSize: 13)));
              }

              final docs = snapshot.data ?? [];

              // Sort by date descending
              docs.sort((a, b) {
                final ad = a['date'];
                final bd = b['date'];
                if (ad is Timestamp && bd is Timestamp) {
                  return bd.compareTo(ad);
                }
                return 0;
              });

              if (docs.isEmpty) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64, color: kBrown.withOpacity(0.15)),
                    const SizedBox(height: 12),
                    Text("Aucun feedback pour l'instant",
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.4), fontSize: 15)),
                  ],
                ));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data    = docs[i];
                  final name    = _str(data['clientnom']);
                  final comment = _str(data['comment']);
                  final product = _str(data['consommablesnom']);
                  final rating  = _int(data['rating']);
                  return _FeedbackCard(
                    name:    name.isNotEmpty ? name : 'Client',
                    comment: comment,
                    product: product,
                    rating:  rating.clamp(0, 5),
                  );
                },
              );
            },
          ),
        ),
      ),
      ]),
    );
  }
}

// ── Feedback card ─────────────────────────────────────────
class _FeedbackCard extends StatelessWidget {
  final String name, comment, product;
  final int    rating;

  const _FeedbackCard({
    required this.name,   required this.comment,
    required this.product, required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: kInputBg,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Left — name + comment
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown, fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(comment,
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.65),
                        fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right — stars + product pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Star icons from assets
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.asset(
                    'assets/icons/star.png',
                    width: 14, height: 14,
                    color: i < rating
                        ? const Color(0xFFD4A017)
                        : kBrown.withOpacity(0.2),
                    errorBuilder: (_, __, ___) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 14, color: const Color(0xFFD4A017)),
                  ),
                )),
              ),
              const SizedBox(height: 8),
              if (product.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: kBrown.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(product,
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}