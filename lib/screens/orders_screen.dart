// lib/screens/orders_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'menu_screen.dart';
import 'main_screen.dart';
import 'leave_review_screen.dart';
import 'cancel_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _tab = 0;

  // Active = pending + in_preparation + ready
  // Completed = served
  // Cancelled = cancelled
  // All comparisons done in lowercase — handles 'Pending', 'pending', 'PENDING' etc.
  static const _activeStatuses    = ['pending', 'in_preparation', 'ready',
                                     'in preparation']; // legacy
  static const _completedStatuses = ['served'];
  static const _cancelledStatuses = ['cancelled'];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final uid    = FirebaseService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: kBrown,
      body: Column(children: [

        // ── Brown header ──────────────────────────────
        Padding(
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  final state = context
                      .findAncestorStateOfType<MainScreenState>();
                  if (state != null) {
                    state.switchTab(kTabHome);
                  } else {
                    Navigator.maybePop(context);
                  }
                },
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('My Orders',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ]),
        ),

        // ── White body ────────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(children: [

              // Tab row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Tab(label: 'Active',    isActive: _tab == 0,
                        onTap: () => setState(() => _tab = 0)),
                    const SizedBox(width: 8),
                    _Tab(label: 'Completed', isActive: _tab == 1,
                        onTap: () => setState(() => _tab = 1)),
                    const SizedBox(width: 8),
                    _Tab(label: 'Cancelled', isActive: _tab == 2,
                        onTap: () => setState(() => _tab = 2)),
                  ],
                ),
              ),

              Expanded(
                child: uid.isEmpty
                    ? const Center(child: Text('Non connecté',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown)))
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Commande')
                            .where('idCl', isEqualTo: uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: kBrown));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text(
                                'Erreur: ${snapshot.error}',
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.red, fontSize: 13)));
                          }

                          final allDocs = snapshot.data?.docs ?? [];

                          // Filter client-side by status group
                          final List<String> targetStatuses = _tab == 0
                              ? _activeStatuses
                              : _tab == 1
                                  ? _completedStatuses
                                  : _cancelledStatuses;

                          final docs = allDocs.where((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final s = ((d['statut'] ?? '') as String).toLowerCase().trim();
                            return targetStatuses.contains(s);
                          }).toList();

                          // Normalize statuses to lowercase for comparison

                          // Sort by date descending client-side
                          docs.sort((a, b) {
                            final aDate = (a.data() as Map)['date'];
                            final bDate = (b.data() as Map)['date'];
                            if (aDate is Timestamp && bDate is Timestamp) {
                              return bDate.compareTo(aDate);
                            }
                            return 0;
                          });

                          if (docs.isEmpty) {
                            return _EmptyState(tab: _tab);
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: docs.length,
                            itemBuilder: (_, i) {
                              final data = docs[i].data()
                                  as Map<String, dynamic>;
                              return _OrderCard(
                                docId:     docs[i].id,
                                data:      data,
                                onRefresh: () => setState(() {}),
                              );
                            },
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Tab pill ──────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? kBrown : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: isActive ? kBrown : Colors.black26, width: 1.2),
      ),
      child: Text(label,
          style: TextStyle(fontFamily: 'LeagueSpartan',
              color: isActive ? Colors.white : kBrown.withOpacity(0.6),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
    ),
  );
}

// ── Empty state ───────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final int tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final msgs = [
      "You don't have any\nactive orders at this\ntime",
      "You don't have any\ncompleted orders yet",
      "You don't have any\ncancelled orders",
    ];
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icons/order.png',
            width: 110, height: 110,
            color: kBrown.withOpacity(0.15),
            errorBuilder: (ctx, e, s) => Icon(
                Icons.receipt_long_outlined,
                size: 100, color: kBrown.withOpacity(0.15))),
        const SizedBox(height: 24),
        Text(msgs[tab], textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontSize: 22,
                fontWeight: FontWeight.w800, height: 1.35)),
      ],
    ));
  }
}

// ── Order card ────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final String               docId;
  final Map<String, dynamic> data;
  final VoidCallback         onRefresh;

  const _OrderCard({required this.docId, required this.data,
      required this.onRefresh});

  String _str(String key) => (data[key] ?? '').toString();
  String get _statut      => _str('statut');
  String get _total       => _str('total');
  String get _consomName  => _str('consommablesnom');
  String get _imageUrl    => _str('image');

  // Only pending orders can be cancelled
  bool get _canCancel => _statut == 'pending';

  // Status display label
  String get _statusLabel {
    switch (_statut) {
      case 'pending':        return 'Pending';
      case 'in_preparation': return 'In Preparation';
      case 'ready':          return 'Ready for pickup';
      case 'served':         return 'Served';
      case 'cancelled':      return 'Cancelled';
      default:               return _statut;
    }
  }

  Color get _statusColor {
    switch (_statut) {
      case 'pending':        return const Color(0xFF8B0000);
      case 'in_preparation': return const Color(0xFFD4A017);
      case 'ready':          return const Color(0xFF2E7D32);
      case 'served':         return const Color(0xFF1565C0);
      case 'cancelled':      return Colors.red;
      default:               return kBrown;
    }
  }

  String get _dateStr {
    final raw = data['date'];
    if (raw is Timestamp) {
      return DateFormat('dd MMM, hh:mm a').format(raw.toDate());
    }
    if (raw is String && raw.isNotEmpty) return raw;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image
            _consomName.isNotEmpty || _imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(_imageUrl))
                : _ItemImageLoader(docId: docId),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _consomName.isNotEmpty
                      ? Text(_consomName,
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 14,
                              fontWeight: FontWeight.w700))
                      : _ItemNameLoader(docId: docId),

                  const SizedBox(height: 2),
                  if (_dateStr.isNotEmpty)
                    Text(_dateStr,
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.45), fontSize: 11)),
                  const SizedBox(height: 4),

                  // Status badge
                  Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: _statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(_statusLabel, style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: _statusColor, fontSize: 11,
                        fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 8),

                  // Action buttons
                  Row(children: [
                    // Cancel — only when pending
                    if (_canCancel)
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) =>
                                CancelOrderScreen(docId: docId))),
                        child: const _ActionBtn(
                            label: 'Cancel Order', filled: true),
                      ),

                    // Served — Leave review + Order Again
                    if (_statut == 'served') ...[
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) =>
                                LeaveReviewScreen(
                                  docId:    docId,
                                  itemName: _consomName,
                                  imageUrl: _imageUrl,
                                ))),
                        child: const _ActionBtn(
                            label: 'Leave a review', filled: true),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const MenuScreen())),
                        child: const _ActionBtn(
                            label: 'Order Again', filled: false),
                      ),
                    ],
                    
                  
                  ]),
                ],
              ),
            ),

            // Price
            if (_total.isNotEmpty)
              Text('${_total}DT',
                  style: const TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 13,
                      fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      Divider(color: kBrown.withOpacity(0.12), thickness: 1, height: 1),
    ]);
  }

  static Widget _buildImage(String img) {
    const w = 72.0; const h = 72.0;
    final placeholder = Container(
        width: w, height: h, color: kInputBg,
        child: const Center(child: Icon(Icons.coffee,
            color: kBrownLight, size: 28)));

    if (img.startsWith('http://') || img.startsWith('https://')) {
      return CachedNetworkImage(
          imageUrl: img, width: w, height: h, fit: BoxFit.cover,
          placeholder: (_, __) => placeholder,
          errorWidget: (_, __, ___) => placeholder);
    }
    if (img.startsWith('assets/')) {
      return Image.asset(img, width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }
    return placeholder;
  }
}

// ── Item image from subcollection ─────────────────────
class _ItemImageLoader extends StatelessWidget {
  final String docId;
  const _ItemImageLoader({required this.docId});

  @override
  Widget build(BuildContext context) {
    const w = 72.0; const h = 72.0;
    final placeholder = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(width: w, height: h, color: kInputBg,
          child: const Center(child: Icon(Icons.coffee,
              color: kBrownLight, size: 28))),
    );
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Commande').doc(docId)
          .collection('items').limit(1).get(),
      builder: (_, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) return placeholder;
        final img = (snap.data!.docs.first.data()
            as Map<String, dynamic>)['image'] as String? ?? '';
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _OrderCard._buildImage(img),
        );
      },
    );
  }
}

// ── Item name from subcollection ──────────────────────
class _ItemNameLoader extends StatelessWidget {
  final String docId;
  const _ItemNameLoader({required this.docId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Commande').doc(docId)
          .collection('items').limit(1).get(),
      builder: (_, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Text('Commande',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontSize: 14,
                  fontWeight: FontWeight.w700));
        }
        final d = snap.data!.docs.first.data() as Map<String, dynamic>;
        final name = (d['consommablesNom'] ?? d['consommablesnom']
            ?? 'Commande') as String;
        return Text(name, style: const TextStyle(
            fontFamily: 'LeagueSpartan', color: kBrown,
            fontSize: 14, fontWeight: FontWeight.w700));
      },
    );
  }
}

// ── Action button ─────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final bool   filled;
  const _ActionBtn({required this.label, required this.filled});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
        color: filled ? kBrown : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: filled ? kBrown : kBrown.withOpacity(0.35), width: 1)),
    child: Text(label,
        style: TextStyle(fontFamily: 'LeagueSpartan',
            color: filled ? Colors.white : kBrown,
            fontSize: 11, fontWeight: FontWeight.w600)),
  );
}