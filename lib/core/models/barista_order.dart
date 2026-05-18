// lib/core/models/barista_order.dart
//
// Future-ready model — swap fake data for Firestore stream later.

enum BaristaOrderStatus { pending, preparing, ready, completed }

class BaristaOrderItem {
  final String name;
  final int    quantity;
  final String customization; // e.g. "No sugar, oat milk"
  final String notes;

  const BaristaOrderItem({
    required this.name,
    required this.quantity,
    this.customization = '',
    this.notes         = '',
  });
}

class BaristaOrder {
  final String             id;
  final String             clientName;
  final List<BaristaOrderItem> items;
  final DateTime           createdAt;
  BaristaOrderStatus       status;
  final String             branchId;

  BaristaOrder({
    required this.id,
    required this.clientName,
    required this.items,
    required this.createdAt,
    required this.branchId,
    this.status = BaristaOrderStatus.pending,
  });

  int get totalDrinks =>
      items.fold(0, (sum, i) => sum + i.quantity);

  String get statusLabel {
    switch (status) {
      case BaristaOrderStatus.pending:   return 'En attente';
      case BaristaOrderStatus.preparing: return 'En préparation';
      case BaristaOrderStatus.ready:     return 'Prête';
      case BaristaOrderStatus.completed: return 'Complétée';
    }
  }

  /// Returns the next logical status (for the action button).
  BaristaOrderStatus? get nextStatus {
    switch (status) {
      case BaristaOrderStatus.pending:   return BaristaOrderStatus.preparing;
      case BaristaOrderStatus.preparing: return BaristaOrderStatus.ready;
      case BaristaOrderStatus.ready:     return BaristaOrderStatus.completed;
      case BaristaOrderStatus.completed: return null;
    }
  }

  String get nextStatusLabel {
    switch (status) {
      case BaristaOrderStatus.pending:   return 'Accepter';
      case BaristaOrderStatus.preparing: return 'Marquer Prête';
      case BaristaOrderStatus.ready:     return 'Complétée';
      case BaristaOrderStatus.completed: return '';
    }
  }

  // Elapsed time since order was placed
  String get elapsed {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    return 'Il y a ${diff.inHours}h';
  }
}

// ── Fake data — replace with Firestore stream ──────────
// ignore: non_constant_identifier_names
List<BaristaOrder> kFakeBaristaOrders = [
  BaristaOrder(
    id: 'cmd_001',
    clientName: 'Lina B.',
    branchId:   'branch_01',
    createdAt:  DateTime.now().subtract(const Duration(minutes: 3)),
    status:     BaristaOrderStatus.pending,
    items: const [
      BaristaOrderItem(name: 'Macchiato Caramel', quantity: 1,
          customization: 'Sans sucre', notes: 'Extra chaud'),
      BaristaOrderItem(name: 'Cachuète',          quantity: 2),
    ],
  ),
  BaristaOrder(
    id: 'cmd_002',
    clientName: 'Sarra M.',
    branchId:   'branch_01',
    createdAt:  DateTime.now().subtract(const Duration(minutes: 8)),
    status:     BaristaOrderStatus.preparing,
    items: const [
      BaristaOrderItem(name: 'Frappuccino Caramel', quantity: 1,
          customization: 'Lait d\'avoine'),
    ],
  ),
  BaristaOrder(
    id: 'cmd_003',
    clientName: 'Amir K.',
    branchId:   'branch_01',
    createdAt:  DateTime.now().subtract(const Duration(minutes: 15)),
    status:     BaristaOrderStatus.ready,
    items: const [
      BaristaOrderItem(name: 'Iced Macchiato', quantity: 2),
    ],
  ),
  BaristaOrder(
    id: 'cmd_004',
    clientName: 'Mariem T.',
    branchId:   'branch_01',
    createdAt:  DateTime.now().subtract(const Duration(hours: 1)),
    status:     BaristaOrderStatus.completed,
    items: const [
      BaristaOrderItem(name: 'Strawberry Matcha', quantity: 1,
          customization: 'Extra matcha'),
    ],
  ),
  BaristaOrder(
    id: 'cmd_005',
    clientName: 'Youssef H.',
    branchId:   'branch_01',
    createdAt:  DateTime.now().subtract(const Duration(hours: 2)),
    status:     BaristaOrderStatus.completed,
    items: const [
      BaristaOrderItem(name: 'Red Velvet',      quantity: 1),
      BaristaOrderItem(name: 'Mexican Salad',   quantity: 1),
    ],
  ),
];