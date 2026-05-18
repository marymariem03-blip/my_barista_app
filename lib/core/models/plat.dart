// lib/core/models/plat.dart

class Plat {
  final String id;
  String name;
  double price;
  String category;
  String image;
  bool isBestSeller;

  Plat({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    this.isBestSeller = false,
  });

  String get formattedPrice =>
      '${price.toStringAsFixed(3).replaceAll('.', ',')} DT';

  // ── Category label (shown in manager card badge) ──────
  String get categoryLabel {
    switch (category) {
      case 'hot_drinks':  return 'Hot Drinks';
      case 'cold_drinks': return 'Cold Drinks';
      case 'sweet':       return 'Sweet';
      case 'savory':      return 'Savory';
      default:            return category;
    }
  }

  // ── Default image per category ─────────────────────────
  static String defaultImageFor(String category) {
    switch (category) {
      case 'hot_drinks':  return 'assets/images/macchiato.png';
      case 'cold_drinks': return 'assets/images/iced_macchiato.png';
      case 'sweet':       return 'assets/images/cachuete.png';
      case 'savory':      return 'assets/images/salade_cesar.png';
      default:            return 'assets/images/macchiato.png';
    }
  }

  static const List<String> availableImages = [
    'assets/images/macchiato.png',
    'assets/images/frappuccino.png',
    'assets/images/iced_macchiato.png',
    'assets/images/cachuete.png',
    'assets/images/salade_cesar.png',
  ];

  Plat copyWith({
    String? name,
    double? price,
    String? category,
    String? image,
    bool? isBestSeller,
  }) {
    return Plat(
      id:           id,
      name:         name         ?? this.name,
      price:        price        ?? this.price,
      category:     category     ?? this.category,
      image:        image        ?? this.image,
      isBestSeller: isBestSeller ?? this.isBestSeller,
    );
  }
}