// lib/screens/barista/barista_orders_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/barista_order.dart';

class BaristaOrdersScreen extends StatefulWidget {
  const BaristaOrdersScreen({super.key});

  @override
  State<BaristaOrdersScreen> createState() => _BaristaOrdersScreenState();
}

class _BaristaOrdersScreenState extends State<BaristaOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _tabs = const [
    _Tab(label: 'En attente', status: BaristaOrderStatus.pending),
    _Tab(label: 'Préparation', status: BaristaOrderStatus.preparing),
    _Tab(label: 'Prêtes', status: BaristaOrderStatus.ready),
    _Tab(label: 'Complétées', status: BaristaOrderStatus.completed),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<BaristaOrder> _ordersFor(BaristaOrderStatus status) =>
      kFakeBaristaOrders.where((o) => o.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // ── Header ────────────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
            top: topPad + 14,
            left: 20,
            right: 20,
            bottom: 0,
          ),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Commandes',
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 13,
                ),
                tabs: _tabs.map((t) {
                  final count = _ordersFor(t.status).length;
                  return Tab(text: '${t.label} ($count)');
                }).toList(),
              ),
            ],
          ),
        ),

        // ── Tab views ─────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: _tabs.map((t) {
              final orders = _ordersFor(t.status);
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _emptyIcon(t.status),
                        size: 64,
                        color: kBrown.withOpacity(0.15),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _emptyLabel(t.status),
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.4),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) => _OrderCard(
                  order: orders[i],
                  onStatusChange: () => setState(() {}),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _emptyIcon(BaristaOrderStatus s) {
    switch (s) {
      case BaristaOrderStatus.pending:
        return Icons.hourglass_empty_outlined;
      case BaristaOrderStatus.preparing:
        return Icons.blender_outlined;
      case BaristaOrderStatus.ready:
        return Icons.check_circle_outline;
      case BaristaOrderStatus.completed:
        return Icons.done_all;
    }
  }

  String _emptyLabel(BaristaOrderStatus s) {
    switch (s) {
      case BaristaOrderStatus.pending:
        return 'Aucune commande en attente';
      case BaristaOrderStatus.preparing:
        return 'Aucune commande en préparation';
      case BaristaOrderStatus.ready:
        return 'Aucune commande prête';
      case BaristaOrderStatus.completed:
        return 'Aucune commande complétée';
    }
  }
}

// ── Full order card ───────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final BaristaOrder order;
  final VoidCallback onStatusChange;
  const _OrderCard({required this.order, required this.onStatusChange});

  Color get _statusColor {
    switch (order.status) {
      case BaristaOrderStatus.pending:
        return Colors.orange;
      case BaristaOrderStatus.preparing:
        return kBrownLight;
      case BaristaOrderStatus.ready:
        return Colors.green;
      case BaristaOrderStatus.completed:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card header ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _statusColor.withOpacity(0.15),
                  child: Text(
                    order.clientName[0],
                    style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: _statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName,
                        style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        order.elapsed,
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Items ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: kBrown.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: kBrown,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.customization.isNotEmpty)
                                  Text(
                                    '• ${item.customization}',
                                    style: TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrownLight,
                                      fontSize: 11,
                                    ),
                                  ),
                                if (item.notes.isNotEmpty)
                                  Text(
                                    '📝 ${item.notes}',
                                    style: TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrown.withOpacity(0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // ── Action buttons ───────────────────────────
          if (order.nextStatus != null) ...[
            const Divider(height: 1, color: Color(0xFFEEE8E3)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Reject / back button (only for pending)
                  if (order.status == BaristaOrderStatus.pending) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Future: handle reject
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Refuser',
                            style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Primary action button
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        order.status = order.nextStatus!;
                        onStatusChange();
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: kBrown,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          order.nextStatusLabel,
                          style: const TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _Tab {
  final String label;
  final BaristaOrderStatus status;
  const _Tab({required this.label, required this.status});
}
