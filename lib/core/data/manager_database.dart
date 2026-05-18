// ── Manager Fake Database ─────────────────────────────
// All data is in-memory. No Firebase, no backend.

class Plat {
  final String id;
  String name;
  double price;
  String category; // 'drink' | 'sweet' | 'savory'

  Plat({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  String get formattedPrice =>
      '${price.toStringAsFixed(3).replaceAll('.', ',')} DT';
}

class ManagerDB {
  // ── Fake plats list ─────────────────────────────────
  static final List<Plat> plats = [
    Plat(id: 'p1', name: 'Macchiato Pistachio',       price: 11.0, category: 'drink'),
    Plat(id: 'p2', name: 'Macchiato Hazelnut',        price: 7.0,  category: 'drink'),
    Plat(id: 'p3', name: 'Frappuccino Caramel',       price: 11.5, category: 'drink'),
    Plat(id: 'p4', name: 'Iced Macchiato Caramel',    price: 9.5,  category: 'drink'),
    Plat(id: 'p5', name: 'Red Velvet',                price: 10.5, category: 'sweet'),
    Plat(id: 'p6', name: 'Cachuète',                  price: 10.5, category: 'savory'),
    Plat(id: 'p7', name: 'Salade César',              price: 12.0, category: 'savory'),
  ];

  // ── Fake orders for dashboard stats ─────────────────
  static final List<FakeOrder> orders = [
    FakeOrder(platName: 'Macchiato Pistachio',    total: 11.0),
    FakeOrder(platName: 'Frappuccino Caramel',    total: 23.0),
    FakeOrder(platName: 'Macchiato Pistachio',    total: 11.0),
    FakeOrder(platName: 'Red Velvet',             total: 10.5),
    FakeOrder(platName: 'Macchiato Hazelnut',     total: 7.0),
    FakeOrder(platName: 'Macchiato Pistachio',    total: 11.0),
    FakeOrder(platName: 'Iced Macchiato Caramel', total: 9.5),
    FakeOrder(platName: 'Frappuccino Caramel',    total: 11.5),
    FakeOrder(platName: 'Macchiato Pistachio',    total: 11.0),
    FakeOrder(platName: 'Cachuète',               total: 10.5),
  ];

  // ── Stats ────────────────────────────────────────────
  static int get totalOrders => orders.length;

  static double get totalSales =>
      orders.fold(0.0, (sum, o) => sum + o.total);

  static String get mostPopularPlat {
    final counts = <String, int>{};
    for (final o in orders) {
      counts[o.platName] = (counts[o.platName] ?? 0) + 1;
    }
    if (counts.isEmpty) return '—';
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  // ── CRUD ─────────────────────────────────────────────
  static void addPlat(Plat p) => plats.add(p);

  static void updatePlat(String id, String name, double price,
      String category) {
    final i = plats.indexWhere((p) => p.id == id);
    if (i != -1) {
      plats[i].name     = name;
      plats[i].price    = price;
      plats[i].category = category;
    }
  }

  static void deletePlat(String id) =>
      plats.removeWhere((p) => p.id == id);

  static String generateId() =>
      'p${DateTime.now().millisecondsSinceEpoch}';
}

class FakeOrder {
  final String platName;
  final double total;
  FakeOrder({required this.platName, required this.total});
}