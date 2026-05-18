// lib/core/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // ── Auth ──────────────────────────────────────────────

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  // ── Users ─────────────────────────────────────────────

  static Future<void> createUser({
    required String uid,
    required String nom,
    required String email,
    required String role, // 'client' | 'manager' | 'barista'
  }) async {
    // Create in users collection
    await _db.collection('users').doc(uid).set({
      'nom': nom,
      'email': email,
      'role': role,
    });

    // Create role-specific document
    if (role == 'client') {
      await _db.collection('clients').doc(uid).set({
        'idCl': uid,
        'preferences': '',
      });
    } else if (role == 'manager') {
      await _db.collection('managers').doc(uid).set({
        'idManager': uid,
        'userId': uid,
      });
    } else if (role == 'barista') {
      await _db.collection('baristas').doc(uid).set({
        'idBarista': uid,
        'userId': uid,
      });
    }
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<String> getUserRole(String uid) async {
    final data = await getUser(uid);
    return data?['role'] ?? 'client';
  }

  static Future<void> updateUserProfile({
    required String uid,
    required String nom,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).update({'nom': nom, 'email': email});
  }

  // ── Consommables (Plats) ──────────────────────────────

  static Stream<QuerySnapshot> getConsommables() =>
      _db.collection('consommables').snapshots();

  static Future<DocumentReference> addConsommable({
    required String nom,
    required String categorie,
    required double prix,
    required String image,
    bool isBestSeller = false,
  }) {
    return _db.collection('consommables').add({
      'nom': nom,
      'categorie': categorie,
      'prix': prix,
      'image': image,
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
    return _db.collection('consommables').doc(id).update({
      'nom': nom,
      'categorie': categorie,
      'prix': prix,
      'image': image,
      'isBestSeller': isBestSeller,
    });
  }

  static Future<void> deleteConsommable(String id) =>
      _db.collection('consommables').doc(id).delete();

  // ── Commandes ─────────────────────────────────────────

  static Future<DocumentReference> createCommande({required String clientId}) {
    return _db.collection('commandes').add({
      'clientId': clientId,
      'date': FieldValue.serverTimestamp(),
      'statut': 'active',
    });
  }

  static Future<void> addQuantiteCommandee({
    required String commandeId,
    required String consommableId,
    required int nombre,
  }) {
    return _db
        .collection('commandes')
        .doc(commandeId)
        .collection('quantitesCommandees')
        .add({'consommableId': consommableId, 'nombre': nombre});
  }

  static Future<void> updateStatutCommande(String commandeId, String statut) =>
      _db.collection('commandes').doc(commandeId).update({'statut': statut});

  static Future<void> cancelCommande(String commandeId, String reason) => _db
      .collection('commandes')
      .doc(commandeId)
      .update({'statut': 'cancelled', 'cancelReason': reason});

  static Stream<QuerySnapshot> getCommandesClient(String clientId) => _db
      .collection('commandes')
      .where('clientId', isEqualTo: clientId)
      .orderBy('date', descending: true)
      .snapshots();

  static Stream<QuerySnapshot> getAllCommandes() =>
      _db.collection('commandes').orderBy('date', descending: true).snapshots();

  static Stream<QuerySnapshot> getQuantitesCommandee(String commandeId) => _db
      .collection('commandes')
      .doc(commandeId)
      .collection('quantitesCommandees')
      .snapshots();

  // ── Personnalisation ──────────────────────────────────

  static Future<void> addPersonnalisation({
    required String consommableId,
    required String typeLait,
    required String niveauSucre,
    required String saveur,
    required String temperature,
  }) {
    return _db
        .collection('consommables')
        .doc(consommableId)
        .collection('personnalisations')
        .add({
          'typeLait': typeLait,
          'niveauSucre': niveauSucre,
          'saveur': saveur,
          'temperature': temperature,
        });
  }

  // ── Feedback ──────────────────────────────────────────

  static Future<void> addFeedback({
    required String clientId,
    required String commandeId,
    required int note,
    required String commentaire,
  }) {
    return _db.collection('feedbacks').add({
      'clientId': clientId,
      'commandeId': commandeId,
      'note': note,
      'commentaire': commentaire,
      'date': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getFeedbacksCommande(String commandeId) => _db
      .collection('feedbacks')
      .where('commandeId', isEqualTo: commandeId)
      .snapshots();

  // ── Branches ──────────────────────────────────────────

  static Stream<QuerySnapshot> getBranches() =>
      _db.collection('branches').snapshots();
}
