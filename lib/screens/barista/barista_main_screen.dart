// lib/screens/barista/barista_main_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/services/notification_service.dart';
import '../page2_login_screen.dart';

class BaristaMainScreen extends StatefulWidget {
  const BaristaMainScreen({super.key});
  @override State<BaristaMainScreen> createState() => _BaristaMainScreenState();
}

class _BaristaMainScreenState extends State<BaristaMainScreen> {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _name  = '';
  String _email = '';
  int    _tab   = 0;

  static const _tabs = [
    _TabConfig('Pending',        Color(0xFF8B0000), 'pending'),
    _TabConfig('In Preparation', Color(0xFFD4A017), 'in_preparation'),
    _TabConfig('Ready',          Color(0xFF2E7D32), 'ready'),
    _TabConfig('Served',         Color(0xFF1565C0), 'served'),
  ];

  @override
  void initState() {
    super.initState();
    _loadBarista();
  }

  Future<void> _loadBarista() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (mounted) setState(() {
      final data = doc.data() ?? {};
      _name  = (data['nom']   as String?) ?? '';
      _email = (data['email'] as String?) ?? _auth.currentUser?.email ?? '';
    });
  }

  void _logout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.black12,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          const Text('Se déconnecter ?', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: kBrown,
              fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(height: 50,
                decoration: BoxDecoration(color: kInputBg,
                    borderRadius: BorderRadius.circular(32)),
                alignment: Alignment.center,
                child: const Text('Annuler', style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: kBrown,
                    fontSize: 15, fontWeight: FontWeight.w700))),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await _auth.signOut();
                if (mounted) Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false);
              },
              child: Container(height: 50,
                decoration: BoxDecoration(color: Colors.red,
                    borderRadius: BorderRadius.circular(32)),
                alignment: Alignment.center,
                child: const Text('Déconnecter', style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: Colors.white,
                    fontSize: 15, fontWeight: FontWeight.w700))),
            )),
          ]),
        ]),
      ),
    );
  }

  // ── Order details bottom sheet ────────────────────────
  void _showOrderDetails(QueryDocumentSnapshot doc) {
    final data    = doc.data() as Map<String, dynamic>;
    final client  = (data['clientnom']       as String?) ?? 'Client';
    final item    = (data['consommablesnom'] as String?) ?? '—';
    final payment = (data['paymentmethode'] as String?) ?? '';
    final total   = data['total'] ?? 0;
    final statut  = (data['statut'] as String?) ?? 'Pending';
    final docId   = doc.id;

    String _selectedStatus = statut; // snake_case value

    final payColor = payment.toLowerCase().contains('cash')
        ? const Color(0xFF008080)
        : const Color(0xFF7B2FBE);

    final isCash = payment.toLowerCase().contains('cash');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          margin: const EdgeInsets.fromLTRB(12, 60, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B1F0E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Title ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Column(children: [
                  Text('Order $client',
                      style: const TextStyle(fontFamily: 'LeagueSpartan',
                          color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.white24),
                ]),
              ),

              // ── Items + Total card ─────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C3317),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  // Item row
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('X1', style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item, style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700))),
                    Text('${total}dt', style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 10),
                  // Total row
                  Row(children: [
                    const Text('Total', style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${total}dt', style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700)),
                  ]),
                ]),
              ),

              // ── Payment method ─────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCash
                      ? const Color(0xFF007B7B)
                      : const Color(0xFF5B2D8E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Image.asset('assets/icons/methodes_de_payement.png',
                      width: 36, height: 36, color: Colors.white,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.payment, color: Colors.white, size: 30)),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Payement Method:', style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white70, fontSize: 12)),
                    Text(payment.toUpperCase(), style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w800)),
                  ]),
                ]),
              ),

              // ── Update Order Status ────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Align(alignment: Alignment.centerLeft,
                  child: Text('Update Order Status',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w800))),
              ),

              // Status pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF5C3317),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: _tabs.map((t) {
                      final active = _selectedStatus == t.statut;
                      return Expanded(child: GestureDetector(
                        onTap: () => setSheet(
                            () => _selectedStatus = t.statut),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                              color: active ? t.color : Colors.transparent,
                              borderRadius: BorderRadius.circular(24)),
                          alignment: Alignment.center,
                          child: Text(t.label,
                              style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : t.color)),
                        ),
                      ));
                    }).toList(),
                  ),
                ),
              ),

              // ── Actions ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Text('Annuler', style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white70, fontSize: 16,
                        fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await _db.collection('Commande').doc(docId)
                          .set({'statut': _selectedStatus},
                              SetOptions(merge: true));

                      // ── Send notification to client ──
                      final clientId = (data['idCl'] as String?) ?? '';
                      if (clientId.isNotEmpty) {
                        if (_selectedStatus == 'in_preparation') {
                          await NotificationService.notifyInPreparation(
                              clientId: clientId, orderId: docId);
                        } else if (_selectedStatus == 'ready') {
                          await NotificationService.notifyReady(
                              clientId: clientId, orderId: docId);
                        } else if (_selectedStatus == 'served') {
                          await NotificationService.notifyServed(
                              clientId: clientId, orderId: docId);
                        }
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(24)),
                      child: const Text('Confirm Status',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 15,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad   = MediaQuery.of(context).padding.top;
    final tabColor = _tabs[_tab].color;
    final statut   = _tabs[_tab].statut;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ────────────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 16, left: 20, right: 16, bottom: 20),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello ${_name.isNotEmpty ? _name : 'Barista'}',
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(_email, style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.white60, fontSize: 13)),
              ],
            )),
            // Bell
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: Stack(children: [
                Center(child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset('assets/icons/notification.png',
                      color: kBrown, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.notifications_outlined, color: kBrown, size: 22)),
                )),
                Positioned(top: 8, right: 8,
                  child: Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFD4A017), shape: BoxShape.circle))),
              ]),
            ),
            const SizedBox(width: 8),
            // Logout
            GestureDetector(
              onTap: _logout,
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset('assets/icons/Log_out.png', fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade700, size: 22)),
                )),
            ),
          ]),
        ),

        // ── Status tabs ──────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          height: 44,
          decoration: BoxDecoration(color: kInputBg,
              borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: _tabs.asMap().entries.map((e) {
              final i = e.key; final t = e.value;
              final active = i == _tab;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: active ? t.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.center,
                  child: Text(t.label, style: TextStyle(
                      fontFamily: 'LeagueSpartan', fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : t.color)),
                ),
              ));
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Orders list ──────────────────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('Commande')
                .where('idbarista', isEqualTo: _auth.currentUser?.uid ?? '')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: kBrown));
              }
              // Filter client-side — handles any casing (Pending/pending/PENDING)
              final allDocs = snap.data?.docs ?? [];
              final docs = allDocs.where((d) {
                final s = ((d.data() as Map<String, dynamic>)['statut'] ?? '')
                    .toString().toLowerCase().trim();
                // normalize legacy values
                final normalized = s == 'in preparation' ? 'in_preparation' : s;
                return normalized == statut;
              }).toList();
              if (docs.isEmpty) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64,
                        color: tabColor.withOpacity(0.25)),
                    const SizedBox(height: 12),
                    Text('No $statut orders',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            fontSize: 18, fontWeight: FontWeight.w600,
                            color: tabColor.withOpacity(0.4))),
                  ],
                ));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _OrderCard(
                  doc:   docs[i],
                  color: tabColor,
                  onDetails: () => _showOrderDetails(docs[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ── Tab config ────────────────────────────────────────────
class _TabConfig {
  final String label, statut;
  final Color  color;
  const _TabConfig(this.label, this.color, this.statut);
}

// ── Order card ────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Color        color;
  final VoidCallback onDetails;
  const _OrderCard({required this.doc, required this.color,
      required this.onDetails});

  @override
  Widget build(BuildContext context) {
    final data    = doc.data() as Map<String, dynamic>;
    final client  = (data['clientnom']       as String?) ?? 'Client';
    final item    = (data['consommablesnom'] as String?) ?? '—';
    final payment = (data['paymentmethode'] as String?) ?? '';
    final payColor = payment.toLowerCase().contains('cash')
        ? const Color(0xFF008080)
        : const Color(0xFF7B2FBE);

    return Container(
      decoration: BoxDecoration(color: kInputBg,
          borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(children: [
          Container(width: 6, color: color),
          Expanded(child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client, style: const TextStyle(
                    fontFamily: 'LeagueSpartan', color: kBrown,
                    fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(item, style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.6), fontSize: 13)),
                const SizedBox(height: 6),
                Row(children: [
                  Text(payment.toUpperCase(), style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: payColor,
                      fontSize: 13, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDetails,
                    child: Text('View Details →',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.55), fontSize: 13)),
                  ),
                ]),
              ],
            ),
          )),
        ]),
      ),
    );
  }
}