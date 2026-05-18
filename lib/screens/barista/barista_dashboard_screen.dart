// lib/screens/barista/barista_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import '../../core/models/barista_order.dart';
import 'barista_orders_screen.dart';

class BaristaDashboardScreen extends StatefulWidget {
  const BaristaDashboardScreen({super.key});

  @override
  State<BaristaDashboardScreen> createState() =>
      _BaristaDashboardScreenState();
}

class _BaristaDashboardScreenState extends State<BaristaDashboardScreen> {
  String _name  = '';
  String _email = '';
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid != null) {
      final data = await FirebaseService.getUser(uid);
      if (mounted) {
        setState(() {
          _name    = data?['nom']   as String? ?? 'Barista';
          _email   = data?['email'] as String? ?? '';
          _loading = false;
        });
      }
    } else {
      setState(() => _loading = false);
    }
  }

  // ── Fake stats from kFakeBaristaOrders ───────────────
  int get _todayTotal     => kFakeBaristaOrders.length;
  int get _todayDrinks    =>
      kFakeBaristaOrders.fold(0, (s, o) => s + o.totalDrinks);
  int get _pending        =>
      kFakeBaristaOrders.where((o) =>
          o.status == BaristaOrderStatus.pending).length;
  int get _preparing      =>
      kFakeBaristaOrders.where((o) =>
          o.status == BaristaOrderStatus.preparing).length;
  int get _ready          =>
      kFakeBaristaOrders.where((o) =>
          o.status == BaristaOrderStatus.ready).length;
  int get _completed      =>
      kFakeBaristaOrders.where((o) =>
          o.status == BaristaOrderStatus.completed).length;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(children: [

      // ── Header ────────────────────────────────────────
      Container(
        color: kBrown,
        padding: EdgeInsets.only(
            top: topPad + 14, left: 20, right: 20, bottom: 20),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: Colors.white24,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.coffee, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: _loading
              ? Container(height: 16, width: 120,
                  decoration: BoxDecoration(color: Colors.white24,
                      borderRadius: BorderRadius.circular(6)))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_name, style: const TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(_email, style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white.withOpacity(0.6), fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ])),
          // Notification bell
          Stack(children: [
            Container(width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.white24,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 22)),
            if (_pending > 0)
              Positioned(top: 6, right: 6,
                child: Container(width: 10, height: 10,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle)),
              ),
          ]),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Notifications banner ─────────────────
              if (_pending > 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.notifications_active_outlined,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      '$_pending nouvelle${_pending > 1 ? 's' : ''} commande${_pending > 1 ? 's' : ''} en attente!',
                      style: const TextStyle(fontFamily: 'LeagueSpartan',
                          color: Colors.orange, fontSize: 13,
                          fontWeight: FontWeight.w700))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              // ── Today's stats ─────────────────────────
              const Text("Aujourd'hui", style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(child: _StatCard(label: 'Commandes',
                    value: '$_todayTotal',
                    icon: Icons.receipt_long_outlined,
                    bgColor: const Color(0xFFEDE8F5),
                    iconColor: const Color(0xFF6A1B9A))),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Boissons',
                    value: '$_todayDrinks',
                    icon: Icons.local_cafe_outlined,
                    bgColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFE65100))),
              ]),
              const SizedBox(height: 16),

              // ── Queue overview ────────────────────────
              const Text('File d\'attente', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(child: _QueueCard(label: 'En attente',
                    count: _pending, color: Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _QueueCard(label: 'Préparation',
                    count: _preparing, color: kBrownLight)),
                const SizedBox(width: 8),
                Expanded(child: _QueueCard(label: 'Prêtes',
                    count: _ready, color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _QueueCard(label: 'Faites',
                    count: _completed, color: Colors.grey)),
              ]),
              const SizedBox(height: 20),

              // ── Peak hour chart ───────────────────────
              const Text('Activité du jour', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _PeakHourChart(),
              const SizedBox(height: 20),

              // ── Active orders shortcut ────────────────
              const Text('Commandes actives', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              ...kFakeBaristaOrders
                  .where((o) => o.status != BaristaOrderStatus.completed)
                  .map((order) => _OrderPreviewCard(
                    order: order,
                    onStatusChange: () => setState(() {}),
                  )),

              if (kFakeBaristaOrders
                  .where((o) => o.status != BaristaOrderStatus.completed)
                  .isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  alignment: Alignment.center,
                  child: Column(children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: Colors.green.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text('Tout est prêt !',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown.withOpacity(0.5),
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ]),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ── Peak hour bar chart (fake data) ──────────────────────
class _PeakHourChart extends StatelessWidget {
  final Map<int, int> hours = const {
    8: 2, 9: 5, 10: 8, 11: 6, 12: 10,
    13: 7, 14: 4, 15: 3, 16: 6, 17: 9,
  };

  _PeakHourChart();

  @override
  Widget build(BuildContext context) {
    final max    = hours.values.reduce((a, b) => a > b ? a : b);
    final peak   = hours.entries.reduce(
        (a, b) => a.value > b.value ? a : b).key;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        SizedBox(
          height: 80,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end,
              children: hours.entries.map((e) {
            final isActive = e.key == peak;
            final ratio    = e.value / max;
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (isActive) Text('${e.value}',
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown, fontSize: 9,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Container(height: (ratio * 65).clamp(4.0, 65.0),
                    decoration: BoxDecoration(
                        color: isActive ? kBrown : kBrown.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4))),
              ]),
            ));
          }).toList()),
        ),
        const SizedBox(height: 6),
        Row(children: hours.keys.map((h) {
          final isActive = h == peak;
          return Expanded(child: Text('${h}h',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 9,
                  color: isActive ? kBrown : kBrown.withOpacity(0.35),
                  fontWeight: isActive
                      ? FontWeight.w800 : FontWeight.w400)));
        }).toList()),
      ]),
    );
  }
}

// ── Order preview card (dashboard) ───────────────────────
class _OrderPreviewCard extends StatelessWidget {
  final BaristaOrder order;
  final VoidCallback onStatusChange;
  const _OrderPreviewCard(
      {required this.order, required this.onStatusChange});

  Color get _statusColor {
    switch (order.status) {
      case BaristaOrderStatus.pending:   return Colors.orange;
      case BaristaOrderStatus.preparing: return kBrownLight;
      case BaristaOrderStatus.ready:     return Colors.green;
      case BaristaOrderStatus.completed: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        // Status dot
        Container(width: 10, height: 10,
            decoration: BoxDecoration(
                color: _statusColor, shape: BoxShape.circle)),
        const SizedBox(width: 12),

        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.clientName, style: const TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown,
                fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(order.items.map((i) => '${i.quantity}× ${i.name}').join(', '),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.55), fontSize: 12)),
          ],
        )),
        const SizedBox(width: 8),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Text(order.statusLabel,
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: _statusColor, fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),

        // Next action button
        if (order.nextStatus != null)
          GestureDetector(
            onTap: () {
              order.status = order.nextStatus!;
              onStatusChange();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: kBrown,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(order.nextStatusLabel,
                  style: const TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bgColor, iconColor;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.bgColor, required this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 40,
          decoration: BoxDecoration(color: bgColor,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 22)),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 24, fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.5), fontSize: 12)),
    ]),
  );
}

// ── Queue card ────────────────────────────────────────────
class _QueueCard extends StatelessWidget {
  final String label;
  final int    count;
  final Color  color;
  const _QueueCard(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Text('$count', style: TextStyle(fontFamily: 'LeagueSpartan',
          color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'LeagueSpartan',
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    ]),
  );
}