// lib/core/services/firebase_plat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plat.dart';
import 'i_plat_service.dart';

class FirebasePlatService implements IPlatService {

  static final FirebasePlatService _instance = FirebasePlatService._internal();
  factory FirebasePlatService() => _instance;
  FirebasePlatService._internal();

  final _db = FirebaseFirestore.instance;

  // Local cache — populated by watchAll() stream
  final List<Plat> _cache = [];

  // Manager profile
  String _managerName        = 'Manager Barista';
  String _managerEmail       = 'manager@barista.com';
  String _managerAvatarAsset = '';

  // ── Stream ────────────────────────────────────────────
  // Call once and listen; the stream updates _cache automatically.

  Stream<List<Plat>> watchAll() {
    return _db.collection('consommables').snapshots().map((snap) {
      _cache
        ..clear()
        ..addAll(snap.docs.map((doc) {
          final data = doc.data();
          return Plat(
            id:           doc.id,
            name:         data['nom']          as String?  ?? '',
            // ✅ handles both the old typo "catagorie" and correct "categorie"
            category:     (data['categorie'] ?? data['catagorie'] ?? 'hot_drinks') as String,
            price:        (data['prix']  as num?)?.toDouble() ?? 0.0,
            image:        data['image']        as String?  ?? '',
            isBestSeller: data['isBestSeller'] as bool?   ?? false,
          );
        }));
      return List.unmodifiable(_cache);
    });
  }

  // ── CRUD ──────────────────────────────────────────────

  @override
  List<Plat> getAll() => List.unmodifiable(_cache);

  @override
  Plat? getById(String id) {
    try { return _cache.firstWhere((p) => p.id == id); }
    catch (_) { return null; }
  }

  @override
  Plat add({
    required String name,
    required double price,
    required String category,
    required String image,
    bool isBestSeller = false,
  }) {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final plat   = Plat(id: tempId, name: name, price: price,
        category: category, image: image, isBestSeller: isBestSeller);

    // ✅ Write correct field name "categorie" (no typo)
    _db.collection('consommables').add({
      'nom':          name,
      'categorie':    category,   // ← correct spelling
      'prix':         price,
      'image':        image,
      'isBestSeller': isBestSeller,
    });

    return plat;
  }

  @override
  Plat update({
    required String id,
    required String name,
    required double price,
    required String category,
    required String image,
    bool isBestSeller = false,
  }) {
    // ✅ Also fix any old docs that had the "catagorie" typo
    _db.collection('consommables').doc(id).update({
      'nom':          name,
      'categorie':    category,   // ← correct spelling
      'prix':         price,
      'image':        image,
      'isBestSeller': isBestSeller,
    });

    final updated = Plat(id: id, name: name, price: price,
        category: category, image: image, isBestSeller: isBestSeller);
    final index = _cache.indexWhere((p) => p.id == id);
    if (index != -1) _cache[index] = updated;
    return updated;
  }

  @override
  void delete(String id) {
    _db.collection('consommables').doc(id).delete();
    _cache.removeWhere((p) => p.id == id);
  }

  // ── Stats ─────────────────────────────────────────────

  @override int get totalPlats      => _cache.length;
  @override int get totalFakeOrders => 20;
  @override double get totalFakeSales => 204.5;
  @override String get mostOrderedPlat =>
      _cache.isNotEmpty ? _cache.first.name : '---';

  @override Map<int, int> getOrdersPerHour()  => {};
  @override int getMostActiveHour()           => 12;

  // ── Manager profile ───────────────────────────────────

  @override String get managerName        => _managerName;
  @override String get managerEmail       => _managerEmail;
  @override String get managerAvatarAsset => _managerAvatarAsset;

  @override
  void updateManagerProfile({
    required String name,
    required String email,
    required String avatarAsset,
  }) {
    _managerName        = name;
    _managerEmail       = email;
    _managerAvatarAsset = avatarAsset;

    _db.collection('managers').doc('current').set({
      'nom':    name,
      'email':  email,
      'avatar': avatarAsset,
    }, SetOptions(merge: true));
  }
}