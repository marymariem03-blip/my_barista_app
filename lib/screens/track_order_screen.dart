// lib/screens/track_order_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import '../core/services/firebase_service.dart';
import 'main_screen.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  // ── Active statuses to query ──────────────────────
  static const _activeStatuses = ['pending', 'in_preparation', 'ready'];

  // ── Delivery time per status ──────────────────────
  static String _deliveryTime(String statut) {
    switch (statut) {
      case 'pending':        return '15 mins';
      case 'in_preparation': return '10 mins';
      case 'ready':          return '0 mins';
      default:               return '15 mins';
    }
  }

  // ── Timeline steps per status ─────────────────────
  static List<_StepData> _steps(String statut) {
    final accepted    = _StepData('Your order has been accepted',         '2 min');
    final preparing   = _StepData('The barista is preparing your order',  '5 min');
    final readyStep   = _StepData('Your order is ready for pickup',       '0 min');

    switch (statut) {
      case 'pending':
        return [
          accepted.done(),
          preparing.pending(),
        ];
      case 'in_preparation':
        return [
          accepted.done(),
          preparing.done(),
          readyStep.pending(),
        ];
      case 'ready':
        return [
          accepted.done(),
          preparing.done(),
          readyStep.done(),
        ];
      default:
        return [accepted.done(), preparing.pending()];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final branch = AppDB.selectedBranch?.name ?? "Barista's Menzah 9";
    final uid    = FirebaseService.currentUser?.uid ?? '';

    return Column(children: [

      // ── Header ────────────────────────────────────
      Container(
        color: kBrown,
        padding: EdgeInsets.only(
            top: topPad + 14, left: 20, right: 20, bottom: 16),
        child: Stack(alignment: Alignment.center, children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                final state = context
                    .findAncestorStateOfType<MainScreenState>();
                state?.switchTab(kTabHome);
              },
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 34),
            ),
          ),
          const Text('Delivery time',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w800)),
        ]),
      ),

      // ── Content ───────────────────────────────────
      Expanded(
        child: uid.isEmpty
            ? _buildEmpty(context)
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Commande')
                    .where('idCl', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        color: kBrown));
                  }

                  final allDocs = snapshot.data?.docs ?? [];

                  // Filter to active statuses only, sort by date desc
                  final activeDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final s = ((data['statut'] ?? '') as String)
                        .toLowerCase().trim();
                    return _activeStatuses.contains(s);
                  }).toList();

                  activeDocs.sort((a, b) {
                    final ad = (a.data() as Map)['date'];
                    final bd = (b.data() as Map)['date'];
                    if (ad is Timestamp && bd is Timestamp) {
                      return bd.compareTo(ad);
                    }
                    return 0;
                  });

                  if (activeDocs.isEmpty) return _buildEmpty(context);

                  final data = activeDocs.first.data()
                      as Map<String, dynamic>;
                  final productName =
                      (data['consommablesnom'] ?? 'Your order') as String;
                  final statut = ((data['statut'] ?? 'pending') as String)
                      .toLowerCase().trim();

                  return _buildTracking(
                    context:     context,
                    branch:      branch,
                    productName: productName,
                    statut:      statut,
                  );
                },
              ),
      ),
    ]);
  }

  // ── Empty state ───────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 16),

            Image.asset('assets/icons/track.png',
                width: 180, height: 180, fit: BoxFit.contain,
                color: kBrown.withOpacity(0.15),
                errorBuilder: (ctx, e, s) => Icon(
                    Icons.local_cafe_rounded,
                    color: kBrown.withOpacity(0.15), size: 150)),
            const SizedBox(height: 28),

            const Text("You don't have\nany order",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 22,
                    fontWeight: FontWeight.w800, height: 1.35)),
            const SizedBox(height: 8),
            Text('Place an order to track it here',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.5), fontSize: 13)),
            const SizedBox(height: 32),

            GestureDetector(
              onTap: () {
                final state = context
                    .findAncestorStateOfType<MainScreenState>();
                if (state != null) {
                  state.switchTab(kTabMenu);
                } else {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) =>
                          const MainScreen(initialIndex: kTabMenu)),
                      (r) => false);
                }
              },
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(color: kBrown,
                    borderRadius: BorderRadius.circular(32)),
                alignment: Alignment.center,
                child: const Text('Order Now',
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  // ── Active order tracking ─────────────────────────
  Widget _buildTracking({
    required BuildContext context,
    required String branch,
    required String productName,
    required String statut,
  }) {
    final steps       = _steps(statut);
    final deliveryTime = _deliveryTime(statut);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Your Barista's
              const Text("Your Barista's",
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: kInputBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.location_on_outlined,
                      color: kBrown, size: 18),
                  const SizedBox(width: 8),
                  Flexible(child: Text(branch,
                      style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 14,
                          fontWeight: FontWeight.w500))),
                ]),
              ),
              const SizedBox(height: 28),

              // Track icon
              Center(
                child: Image.asset('assets/icons/track.png',
                    width: 220, height: 220, fit: BoxFit.contain,
                    color: kBrown,
                    errorBuilder: (ctx, e, s) => Icon(
                        Icons.local_cafe_rounded,
                        color: kBrown, size: 180)),
              ),
              const SizedBox(height: 28),

              // Delivery Time
              const Text('Delivery Time',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated Delivery',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.55),
                          fontSize: 13)),
                  Text(deliveryTime,
                      style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              // Timeline steps
              ...steps.asMap().entries.map((e) {
                final i    = e.key;
                final step = e.value;
                return _TrackStep(
                  label:    step.label,
                  time:     step.time,
                  isDone:   step.isDone,
                  showLine: i < steps.length - 1,
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step data model ───────────────────────────────────────
class _StepData {
  final String label, time;
  final bool isDone;
  const _StepData(this.label, this.time, {this.isDone = false});
  _StepData done()    => _StepData(label, time, isDone: true);
  _StepData pending() => _StepData(label, time, isDone: false);
}

// ── Track step widget ─────────────────────────────────────
class _TrackStep extends StatelessWidget {
  final String label, time;
  final bool isDone, showLine;
  const _TrackStep({required this.label, required this.time,
      required this.isDone, required this.showLine});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 20, child: Column(children: [
        Container(
          width: 12, height: 12,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
              color: isDone ? kBrown : kBrown.withOpacity(0.25),
              shape: BoxShape.circle),
        ),
        if (showLine)
          Container(width: 1.5, height: 28,
              color: kBrown.withOpacity(0.2)),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label,
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: isDone
                        ? kBrown
                        : kBrown.withOpacity(0.4),
                    fontSize: 13,
                    fontWeight: isDone
                        ? FontWeight.w600
                        : FontWeight.w400))),
            const SizedBox(width: 8),
            Text(time, style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.5),
                fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      )),
    ],
  );
}