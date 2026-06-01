// lib/core/services/notification_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _db = FirebaseFirestore.instance;

  // ── Write a notification doc ──────────────────────
  static Future<void> _write({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? orderId,
    String? clientId,
  }) async {
    if (userId.isEmpty) return; 
    await _db.collection('notifications').add({
      'userId':    userId,
      'title':     title,
      'message':   message,
      'type':      type,
      'orderId':   orderId  ?? '',
      'clientId':  clientId ?? '',
      'isRead':    false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── 1. Client places order → notify the assigned barista only ──
  // userId = idbarista (the UID of the barista assigned to the branch)
  static Future<void> notifyNewOrder({
    required String baristaId,  // = order.idbarista
    required String clientName,
    required String itemName,
    required String orderId,
    required String clientId,
  }) async {
    if (baristaId.isEmpty) return;
    await _write(
      userId:   baristaId,
      title:    'New Order',
      message:  '$clientName ordered $itemName',
      type:     'new_order',
      orderId:  orderId,
      clientId: clientId,
    );
  }

  // ── 2. Barista sets in_preparation → notify client ──
  // userId = order.idCl (the client's UID)
  static Future<void> notifyInPreparation({
    required String clientId,  // = order.idCl
    required String orderId,
  }) async {
    if (clientId.isEmpty) return;
    await _write(
      userId:  clientId,
      title:   'Order In Preparation',
      message: 'Your order is now being prepared.',
      type:    'in_preparation',
      orderId: orderId,
    );
    await _write(
      userId:  clientId,
      title:   'Wanna play a game?',
      message: 'Play while waiting for your order ',
      type:    'game',
      orderId: orderId,
    );
  }

  // ── 3. Barista sets ready → notify client ──────────
  static Future<void> notifyReady({
    required String clientId,
    required String orderId,
  }) async {
    if (clientId.isEmpty) return;
    await _write(
      userId:  clientId,
      title:   'Your order is ready',
      message: 'Come pick it up!',
      type:    'ready',
      orderId: orderId,
    );
  }

  // ── 4. Barista sets served → notify client ─────────
  static Future<void> notifyServed({
    required String clientId,
    required String orderId,
  }) async {
    if (clientId.isEmpty) return;
    await _write(
      userId:  clientId,
      title:   'Order Served',
      message: 'Enjoy your order! Come back soon ',
      type:    'served',
      orderId: orderId,
    );
  }

  // ── Mark notification as read ──────────────────────
  static Future<void> markRead(String notifId) async {
    await _db.collection('notifications').doc(notifId)
        .set({'isRead': true}, SetOptions(merge: true));
  }

  // ── Stream notifications for a user (no orderBy = no index needed) ──
  static Stream<QuerySnapshot> streamForUser(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}