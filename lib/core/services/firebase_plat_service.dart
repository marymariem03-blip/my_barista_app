// lib/core/services/firebase_plat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plat.dart';
import 'i_plat_service.dart';

class FirebasePlatService implements IPlatService {

  static final FirebasePlatService _instance =
      FirebasePlatService._internal();
  factory FirebasePlatService() => _instance;
  FirebasePlatService._internal();

  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final List<Plat> _cache = [];

  String _managerName        = 'Manager Barista';
  String _managerEmail       = 'manager@barista.com';
  String _managerAvatarAsset = '';

  static double _parsePrice(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  // ── Stream ────────────────────────────────────────────
  Stream<List<Plat>> watchAll() {
    final user = _auth.currentUser;
    print('▶ FirebasePlatService.watchAll() — '
        'user: ${user?.uid ?? "NOT LOGGED IN"}');

    return _db.collection('consommables').snapshots().map((snap) {
      print('▶ consommables snapshot: ${snap.docs.length} docs');

      final plats = snap.docs.map((doc) {
        final data = doc.data();
        return Plat(
          id:           doc.id,
          name:         data['nom']           as String? ?? '',
          category:     (data['categorie'] ??
                         data['catagorie']    ??
                         'hot_drinks')        as String,
          price:        _parsePrice(data['prix']),
          image:        data['image']         as String? ?? '',
          // ✅ reads description, empty string if missing
          description:  data['description']   as String? ?? '',
          isBestSeller: data['isBestSeller']  as bool?   ?? false,
        );
      }).toList();

      _cache
        ..clear()
        ..addAll(plats);

      return List<Plat>.unmodifiable(plats);
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
    String description  = '',
    bool   isBestSeller = false,
  }) {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final plat   = Plat(id: tempId, name: name, price: price,
        category: category, image: image,
        description: description, isBestSeller: isBestSeller);

    _db.collection('consommables').add({
      'nom':          name,
      'categorie':    category,
      'prix':         price,
      'image':        image,
      'description':  description, // ✅
      'isBestSeller': isBestSeller,
    }).then((ref) {
      print('▶ Plat added: ${ref.id}');
    }).catchError((e) {
      print('▶ Error adding plat: $e');
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
    String description  = '',
    bool   isBestSeller = false,
  }) {
    _db.collection('consommables').doc(id).update({
      'nom':          name,
      'categorie':    category,
      'prix':         price,
      'image':        image,
      'description':  description, // ✅
      'isBestSeller': isBestSeller,
    }).then((_) {
      print('▶ Plat updated: $id');
    }).catchError((e) {
      print('▶ Error updating plat: $e');
    });

    final updated = Plat(id: id, name: name, price: price,
        category: category, image: image,
        description: description, isBestSeller: isBestSeller);
    final index = _cache.indexWhere((p) => p.id == id);
    if (index != -1) _cache[index] = updated;
    return updated;
  }

  @override
  void delete(String id) {
    _db.collection('consommables').doc(id).delete()
        .then((_) => print('▶ Plat deleted: $id'))
        .catchError((e) => print('▶ Error deleting: $e'));
    _cache.removeWhere((p) => p.id == id);
  }

  // ── Stats ─────────────────────────────────────────────

  @override int    get totalPlats      => _cache.length;
  @override int    get totalFakeOrders => 20;
  @override double get totalFakeSales  => 204.5;
  @override String get mostOrderedPlat =>
      _cache.isNotEmpty ? _cache.first.name : '---';

  @override Map<int, int> getOrdersPerHour() => {};
  @override int getMostActiveHour()          => 12;

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