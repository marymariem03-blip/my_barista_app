// lib/core/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseAuth      _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db   = FirebaseFirestore.instance;

  // ── Collection names ──────────────────────────────────
  static const _colUsers        = 'users';
  static const _colClient       = 'client';
  static const _colManager      = 'manager';
  static const _colBarista      = 'barista';
  static const _colConsommables = 'consommables';
  static const _colCommande     = 'Commande';
  static const _colFeedbacks    = 'feedbacks';
  static const _subQteCmd       = 'quantitesCommandees';
  static const _subPersonnal    = 'personnalisations';

  // ════════════════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════════════════

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } catch (_) { return null; }
  }

  static Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } catch (_) { return null; }
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  // ════════════════════════════════════════════════════
  // USERS
  // ════════════════════════════════════════════════════

  /// Create user doc + role-specific doc after registration.
  static Future<void> createUser({
    required String uid,
    required String nom,
    required String email,
    required String role, // 'client' | 'manager' | 'barista'
  }) async {
    await _db.collection(_colUsers).doc(uid).set({
      'nom':    nom,
      'email':  email,
      'role':   role,
      'phone':  '',
      'dob':    '',
      'avatar': '',
    });

    switch (role) {
      case 'client':
        await _db.collection(_colClient).doc(uid).set({
          'idCl': uid, 'preferences': '',
        });
        break;
      case 'manager':
        await _db.collection(_colManager).doc(uid).set({
          'idmanager': uid, 'userid': uid,
        });
        break;
      case 'barista':
        await _db.collection(_colBarista).doc(uid).set({
          'idbarista': uid, 'userid': uid,
        });
        break;
    }
  }

  /// Fetch a user document by UID.
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection(_colUsers).doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Get the role string for a UID. Defaults to 'client'.
  static Future<String> getUserRole(String uid) async {
    final data = await getUser(uid);
    return (data?['role'] as String?) ?? 'client';
  }

  /// Update name + email in users doc.
  static Future<void> updateUserProfile({
    required String uid,
    required String nom,
    required String email,
  }) {
    return _db.collection(_colUsers).doc(uid).update({
      'nom':   nom,
      'email': email,
    });
  }

  ///   Update extra profile fields: phone, dob, avatar URL.
  static Future<void> updateUserExtra({
    required String uid,
    required String phone,
    required String dob,
    required String avatar,
  }) {
    return _db.collection(_colUsers).doc(uid).update({
      'phone':  phone,
      'dob':    dob,
      'avatar': avatar,
    });
  }

  // ════════════════════════════════════════════════════
  // CONSOMMABLES (plats)
  // ════════════════════════════════════════════════════

  /// Real-time stream of all consommables.
  static Stream<QuerySnapshot> watchConsommables() =>
      _db.collection(_colConsommables).snapshots();

  // kept for backwards compatibility
  static Stream<QuerySnapshot> getConsommables() => watchConsommables();

  static Future<DocumentReference> addConsommable({
    required String nom,
    required String categorie,
    required double prix,
    required String image,
    bool isBestSeller = false,
  }) {
    return _db.collection(_colConsommables).add({
      'nom': nom, 'categorie': categorie,
      'prix': prix, 'image': image,
      'isBestSeller': isBestSeller,
    });
  }

  static Future<void> updateConsommable({
    required String id,
    required String nom,
    required String categorie,
    required double prix,
    required String image,
    bool isBestSeller = false,
  }) {
    return _db.collection(_colConsommables).doc(id).update({
      'nom': nom, 'categorie': categorie,
      'prix': prix, 'image': image,
      'isBestSeller': isBestSeller,
    });
  }

  static Future<void> deleteConsommable(String id) =>
      _db.collection(_colConsommables).doc(id).delete();

  // ════════════════════════════════════════════════════
  // COMMANDES (orders)
  // ════════════════════════════════════════════════════

  static Future<DocumentReference> createCommande({
    required String clientId,
  }) {
    return _db.collection(_colCommande).add({
      'clientId': clientId,
      'date':     FieldValue.serverTimestamp(),
      'statut':   'active',
    });
  }

  static Future<void> addQuantiteCommandee({
    required String commandeId,
    required String consommableId,
    required int nombre,
  }) {
    return _db
        .collection(_colCommande).doc(commandeId)
        .collection(_subQteCmd)
        .add({'consommableId': consommableId, 'nombre': nombre});
  }

  static Future<void> updateStatutCommande(
      String commandeId, String statut) =>
      _db.collection(_colCommande).doc(commandeId)
          .update({'statut': statut});

  static Future<void> cancelCommande(String commandeId, String reason) =>
      _db.collection(_colCommande).doc(commandeId).update({
        'statut': 'cancelled', 'cancelReason': reason,
      });

  /// Stream of orders for a specific client.
  static Stream<QuerySnapshot> watchCommandesClient(String clientId) =>
      _db.collection(_colCommande)
          .where('clientId', isEqualTo: clientId)
          .orderBy('date', descending: true)
          .snapshots();

  // kept for backwards compatibility
  static Stream<QuerySnapshot> getCommandesClient(String clientId) =>
      watchCommandesClient(clientId);

  /// Stream of all orders (manager/barista view).
  static Stream<QuerySnapshot> watchAllCommandes() =>
      _db.collection(_colCommande)
          .orderBy('date', descending: true)
          .snapshots();

  // kept for backwards compatibility
  static Stream<QuerySnapshot> getAllCommandes() => watchAllCommandes();

  static Stream<QuerySnapshot> watchQuantitesCommandee(String commandeId) =>
      _db.collection(_colCommande).doc(commandeId)
          .collection(_subQteCmd).snapshots();

  // kept for backwards compatibility
  static Stream<QuerySnapshot> getQuantitesCommandee(String commandeId) =>
      watchQuantitesCommandee(commandeId);

  // ════════════════════════════════════════════════════
  // PERSONNALISATIONS
  // ════════════════════════════════════════════════════

  static Future<void> addPersonnalisation({
    required String consommableId,
    required String typeLait,
    required String niveauSucre,
    required String saveur,
    required String temperature,
  }) {
    return _db.collection(_colConsommables).doc(consommableId)
        .collection(_subPersonnal)
        .add({
      'typeLait': typeLait, 'niveauSucre': niveauSucre,
      'saveur': saveur, 'temperature': temperature,
    });
  }

  // ════════════════════════════════════════════════════
  // FEEDBACKS
  // ════════════════════════════════════════════════════

  static Future<void> addFeedback({
    required String clientId,
    required String commandeId,
    required int note,
    required String commentaire,
  }) {
    return _db.collection(_colFeedbacks).add({
      'clientId':    clientId,
      'commandeId':  commandeId,
      'note':        note,
      'commentaire': commentaire,
      'date':        FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> watchFeedbacksCommande(String commandeId) =>
      _db.collection(_colFeedbacks)
          .where('commandeId', isEqualTo: commandeId)
          .snapshots();

  // kept for backwards compatibility
  static Stream<QuerySnapshot> getFeedbacksCommande(String commandeId) =>
      watchFeedbacksCommande(commandeId);

  // ════════════════════════════════════════════════════
  // BRANCHES
  // ════════════════════════════════════════════════════

  static Stream<QuerySnapshot> getBranches() =>
      _db.collection('branches').snapshots();
}