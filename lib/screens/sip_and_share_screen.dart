// lib/screens/sip_and_share_screen.dart

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/colors.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/firebase_service.dart';
import 'app_header_icons.dart';

class SipAndShareScreen extends StatefulWidget {
  const SipAndShareScreen({super.key});
  @override State<SipAndShareScreen> createState() => _SipAndShareScreenState();
}

class _SipAndShareScreenState extends State<SipAndShareScreen> {
  int _tab = 0; // 0 = All Posts, 1 = My Posts
  final String _uid = FirebaseService.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Brown header ──────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 16, right: 16, bottom: 16),
          child: Row(children: [
            Image.asset('assets/icons/sip_share.png',
                width: 32, height: 32, color: Colors.white,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.people_alt_outlined,
                        color: Colors.white, size: 28)),
            const SizedBox(width: 10),
            const Text('Sip & Share',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            const AppHeaderIcons(),
          ]),
        ),

        // ── Tab bar + add button ──────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(children: [
            _TabPill(label: 'All Posts', active: _tab == 0,
                onTap: () => setState(() => _tab = 0)),
            const SizedBox(width: 10),
            _TabPill(label: 'My Posts', active: _tab == 1,
                onTap: () => setState(() => _tab = 1)),
            const Spacer(),
            // + button
            GestureDetector(
              onTap: () => _openNewPost(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: kBrownLight.withOpacity(0.25),
                    shape: BoxShape.circle),
                child: const Icon(Icons.add, color: kBrown, size: 22),
              ),
            ),
          ]),
        ),

        // ── Feed ─────────────────────────────────────
        Expanded(child: _uid.isEmpty
            ? const Center(child: Text('Please log in',
                style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown)))
            : _PostFeed(tab: _tab, uid: _uid)),
      ]),
    );
  }

  void _openNewPost(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const _NewPostScreen()));
  }
}

// ── Post feed ─────────────────────────────────────────────
class _PostFeed extends StatelessWidget {
  final int    tab;
  final String uid;
  const _PostFeed({required this.tab, required this.uid});

  Stream<QuerySnapshot> get _stream {
    if (tab == 1) {
      // No orderBy to avoid composite index — sort client-side
      return FirebaseFirestore.instance
          .collection('community_posts')
          .where('userId', isEqualTo: uid)
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kBrown));
        }
        var docs = snap.data?.docs ?? [];
        // Sort client-side for My Posts tab (avoids composite index)
        if (tab == 1) {
          docs = List.from(docs)..sort((a, b) {
            final at = (a.data() as Map)['createdAt'];
            final bt = (b.data() as Map)['createdAt'];
            if (at is Timestamp && bt is Timestamp) return bt.compareTo(at);
            return 0;
          });
        }
        if (docs.isEmpty) {
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 64, color: kBrown.withOpacity(0.15)),
              const SizedBox(height: 14),
              Text(tab == 1
                  ? "You haven't posted yet"
                  : "No posts yet. Be the first!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.45), fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _PostCard(
              docId:     docs[i].id,
              data:      data,
              currentUid: uid,
            );
          },
        );
      },
    );
  }
}

// ── Post card ─────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final String               docId;
  final Map<String, dynamic> data;
  final String               currentUid;
  const _PostCard({required this.docId, required this.data,
      required this.currentUid});

  Future<void> _like() async {
    final raw = data['likes'];
    final current = raw is int ? raw
                  : raw is double ? raw.toInt()
                  : int.tryParse(raw?.toString() ?? '0') ?? 0;
    await FirebaseFirestore.instance
        .collection('community_posts').doc(docId)
        .update({'likes': current + 1});
  }

  @override
  Widget build(BuildContext context) {
    final name     = (data['userNom']    ?? 'User').toString();
    final avatar   = (data['userAvatar'] ?? '').toString();
    final caption  = (data['caption']    ?? '').toString();
    final imageUrl = (data['imageUrl']   ?? '').toString();
    final likesRaw = data['likes'];
    final likes    = likesRaw is int ? likesRaw
                   : likesRaw is double ? likesRaw.toInt()
                   : int.tryParse(likesRaw?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFD4B896).withOpacity(0.35),
          borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Post image
        if (imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl:    imageUrl,
            width:       double.infinity,
            height:      260,
            fit:         BoxFit.cover,
            placeholder: (_, __) => Container(height: 260, color: kInputBg,
                child: const Center(child: CircularProgressIndicator(
                    color: kBrown, strokeWidth: 2))),
            errorWidget: (_, __, ___) => Container(height: 260,
                color: kInputBg,
                child: const Icon(Icons.broken_image_outlined,
                    color: kBrownLight, size: 48)),
          ),

        // Bottom: user info + like
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: kInputBg,
                backgroundImage: avatar.isNotEmpty
                    ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person, color: kBrownLight, size: 22)
                    : null,
              ),
              const SizedBox(width: 10),

              // Name + caption
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(caption,
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.65), fontSize: 12,
                          height: 1.3)),
                ],
              )),

              // Like button
              GestureDetector(
                onTap: _like,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded,
                        color: kBrown.withOpacity(0.55), size: 24),
                    if (likes > 0)
                      Text('$likes',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.55),
                              fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── New post screen ───────────────────────────────────────
class _NewPostScreen extends StatefulWidget {
  const _NewPostScreen();
  @override State<_NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<_NewPostScreen> {
  final _captionCtrl = TextEditingController();
  final _picker      = ImagePicker();

  File?      _file;
  Uint8List? _bytes;
  String?    _fileName;
  bool       _uploading = false;
  String?    _error;

  @override
  void dispose() { _captionCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (picked == null || !mounted) return;
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() { _bytes = bytes; _fileName = picked.name; _file = null; });
    } else {
      setState(() { _file = File(picked.path); _bytes = null; });
    }
  }

  Future<void> _publish() async {
    if (_file == null && _bytes == null) {
      setState(() => _error = 'Please select a photo.');
      return;
    }
    if (_captionCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please write a caption.');
      return;
    }

    setState(() { _uploading = true; _error = null; });

    try {
      final uid  = FirebaseService.currentUser?.uid ?? '';
      final user = await FirebaseService.getUser(uid);
      final nom   = (user?['nom']    as String?) ?? 'User';
      final avatar = (user?['avatar'] as String?) ?? '';

      // Upload to Cloudinary
      String imageUrl;
      if (kIsWeb && _bytes != null) {
        imageUrl = await CloudinaryService.uploadPlatImageBytes(
            bytes: _bytes!, fileName: _fileName ?? 'post.jpg');
      } else {
        imageUrl = await CloudinaryService.uploadPlatImage(_file!);
      }

      // Save post to Firestore
      await FirebaseFirestore.instance.collection('community_posts').add({
        'userId':    uid,
        'userNom':   nom,
        'userAvatar': avatar,
        'caption':   _captionCtrl.text.trim(),
        'imageUrl':  imageUrl,
        'likes':     0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Award +10 beans
      final clientDoc = await FirebaseFirestore.instance
          .collection('client').doc(uid).get();
      final currentBeans = (clientDoc.data()?['beans'] as int?) ?? 0;
      await FirebaseFirestore.instance
          .collection('client').doc(uid)
          .set({'beans': currentBeans + 10}, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Post shared! +10 Beans 🎉',
            style: TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown, behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } on CloudinaryException catch (e) {
      setState(() { _error = e.message; _uploading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _uploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hasImage = _file != null || _bytes != null;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // Header
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 12, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(alignment: Alignment.centerLeft,
                child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 34))),
            const Text('New Post',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 8),

            // Image picker
            GestureDetector(
              onTap: _uploading ? null : _pickImage,
              child: Container(
                width: double.infinity, height: 240,
                decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: kBrown.withOpacity(0.15), width: 1.5)),
                clipBehavior: Clip.hardEdge,
                child: hasImage
                    ? _buildPreview()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: kBrown.withOpacity(0.3), size: 52),
                          const SizedBox(height: 10),
                          Text('Tap to select a photo',
                              style: TextStyle(fontFamily: 'LeagueSpartan',
                                  color: kBrown.withOpacity(0.4),
                                  fontSize: 14)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Caption field
            Container(
              decoration: BoxDecoration(color: kInputBg,
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _captionCtrl,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write a caption... #hashtag',
                  hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.35), fontSize: 14),
                  border: InputBorder.none, isDense: true,
                ),
              ),
            ),

            // Beans hint
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.circle, color: kBrownLight, size: 8),
              const SizedBox(width: 6),
              Text('+10 Beans for every post you share',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrownLight, fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(_error!,
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.red, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 32),

            // Publish button
            GestureDetector(
              onTap: _uploading ? null : _publish,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                    color: _uploading
                        ? kBrown.withOpacity(0.5) : kBrown,
                    borderRadius: BorderRadius.circular(32)),
                alignment: Alignment.center,
                child: _uploading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Share Post',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _buildPreview() {
    if (kIsWeb && _bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.cover,
          width: double.infinity, height: 240);
    }
    if (_file != null) {
      return Image.file(_file!, fit: BoxFit.cover,
          width: double.infinity, height: 240);
    }
    return const SizedBox();
  }
}

// ── Tab pill ──────────────────────────────────────────────
class _TabPill extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _TabPill({required this.label, required this.active,
      required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          color: active ? kBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: active ? kBrown : Colors.black26, width: 1.2)),
      child: Text(label,
          style: TextStyle(fontFamily: 'LeagueSpartan',
              color: active ? Colors.white : kBrown.withOpacity(0.6),
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
    ),
  );
}