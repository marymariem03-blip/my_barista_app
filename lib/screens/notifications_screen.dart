// lib/screens/notifications_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import '../core/services/notification_service.dart';
import 'games_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final width     = MediaQuery.of(context).size.width;
    final height    = MediaQuery.of(context).size.height;
    final uid       = FirebaseService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: width, height: height,
        child: Stack(children: [

          // ── Dim overlay — tap to close ──────────────
          Positioned(
            left: 0, top: 0, bottom: 0,
            width: width * 0.22,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),

          // ── Drawer panel ────────────────────────────
          Positioned(
            right: 0, top: 0, bottom: 0,
            width: width * 0.78,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1008),
                borderRadius: BorderRadius.only(
                    topLeft:    Radius.circular(28),
                    bottomLeft: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPad + 20),

                  // ── Header ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(children: [
                      Image.asset('assets/icons/notification.png',
                          width: 26, height: 26, color: Colors.white,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.notifications,
                              color: Colors.white, size: 26)),
                      const SizedBox(width: 12),
                      const Text('Notifications',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 28,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // Divider
                  const Divider(color: Colors.white,
                      thickness: 1, indent: 24, endIndent: 24, height: 1),

                  // ── List ────────────────────────────
                  Expanded(
                    child: uid.isEmpty
                        ? const Center(child: Text('Non connecté',
                            style: TextStyle(color: Colors.white38)))
                        : StreamBuilder<QuerySnapshot>(
                            stream: NotificationService.streamForUser(uid),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white38,
                                        strokeWidth: 2));
                              }
                              final docs = snap.data?.docs.toList() ?? [];
                              // Sort client-side by createdAt descending
                              docs.sort((a, b) {
                                final ad = (a.data() as Map)['createdAt'];
                                final bd = (b.data() as Map)['createdAt'];
                                if (ad is Timestamp && bd is Timestamp) {
                                  return bd.compareTo(ad);
                                }
                                return 0;
                              });
                              if (docs.isEmpty) {
                                return Center(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none,
                                        color: Colors.white24, size: 56),
                                    const SizedBox(height: 12),
                                    const Text('No notifications yet',
                                        style: TextStyle(
                                            fontFamily: 'LeagueSpartan',
                                            color: Colors.white38,
                                            fontSize: 15)),
                                  ],
                                ));
                              }
                              return ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: docs.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(color: Colors.white,
                                        thickness: 1, indent: 24,
                                        endIndent: 24, height: 1),
                                itemBuilder: (_, i) {
                                  final doc  = docs[i];
                                  final data = doc.data()
                                      as Map<String, dynamic>;
                                  final title   = (data['title']   as String?) ?? '';
                                  final message = (data['message'] as String?) ?? '';
                                  final type    = (data['type']    as String?) ?? '';
                                  final isRead  = (data['isRead']  as bool?)   ?? false;
                                  return _NotifItem(
                                    docId:   doc.id,
                                    title:   title,
                                    message: message,
                                    type:    type,
                                    isRead:  isRead,
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  SizedBox(height: bottomPad + 24),
                ],
              ),
            ),
          ),

          // ── Back arrow ──────────────────────────────
          Positioned(
            top: topPad + 20, left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 28),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Notification item ─────────────────────────────────
class _NotifItem extends StatelessWidget {
  final String docId, title, message, type;
  final bool   isRead;
  const _NotifItem({required this.docId, required this.title,
      required this.message, required this.type, required this.isRead});

  String get _iconAsset {
    switch (type) {
      case 'new_order':
      case 'in_preparation': return 'assets/icons/dish.png';
      case 'game':           return 'assets/icons/games.png';
      case 'ready':
      case 'served':         return 'assets/icons/order.png';
      default:               return 'assets/icons/notification.png';
    }
  }

  IconData get _iconFallback {
    switch (type) {
      case 'game':  return Icons.sports_esports_outlined;
      case 'ready':
      case 'served': return Icons.shopping_bag_outlined;
      default:      return Icons.notifications_outlined;
    }
  }

  void _handleTap(BuildContext context) async {
    await NotificationService.markRead(docId);
    if (type == 'game' && context.mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const GamesScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: Container(
        color: isRead ? Colors.transparent : Colors.white.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(children: [
          // Icon box — same style as _DrawerItem
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(_iconAsset,
                  fit: BoxFit.contain,
                  color: const Color(0xFF8D491E),
                  errorBuilder: (_, __, ___) => Icon(
                      _iconFallback,
                      color: const Color(0xFF8D491E), size: 20)),
            ),
          ),
          const SizedBox(width: 16),

          // Message
          Expanded(child: Row(children: [
            Expanded(child: Text(
              message.isNotEmpty ? message : title,
              style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isRead
                      ? FontWeight.w400
                      : FontWeight.w600,
                  height: 1.4),
            )),
            if (!isRead)
              Container(width: 8, height: 8,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: const BoxDecoration(
                      color: Color(0xFFD4A017),
                      shape: BoxShape.circle)),
          ])),
        ]),
      ),
    );
  }
}