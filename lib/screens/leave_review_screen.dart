import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'main_screen.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String docId;
  final String itemName;
  final String imageUrl;

  const LeaveReviewScreen({
    super.key,
    required this.docId,
    required this.itemName,
    required this.imageUrl,
  });

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  int  _rating     = 0;
  bool _submitting = false;
  final _reviewCtrl = TextEditingController();

  @override
  void dispose() { _reviewCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a star rating',
            style: TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown, behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _submitting = true);

    try {
      final uid      = FirebaseService.currentUser?.uid ?? '';
      final userData = uid.isNotEmpty ? await FirebaseService.getUser(uid) : null;
      final clientNom = userData?['nom'] as String? ?? '';

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'clientnom':       clientNom,
        'consommablesnom': widget.itemName,
        'comment':         _reviewCtrl.text.trim(),
        'rating':          _rating,
        'date':            FieldValue.serverTimestamp(),
        'commandeId':      widget.docId,
        'clientId':        uid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Review submitted! Thank you ☕',
            style: TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown, behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e',
            style: const TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final img    = widget.imageUrl;
    final isHttp = img.startsWith('http');

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(alignment: Alignment.centerLeft,
                child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 34))),
            const Text('Leave a Review',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ]),
        ),

        // ── Content ─────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 32),

            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isHttp
                  ? CachedNetworkImage(
                      imageUrl: img, width: 160, height: 160,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imgPlaceholder(),
                      errorWidget: (_, __, ___) => _imgPlaceholder())
                  : img.startsWith('assets/')
                      ? Image.asset(img, width: 160, height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder())
                      : _imgPlaceholder(),
            ),
            const SizedBox(height: 20),

            Text(widget.itemName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Text("We'd love to know what you\nthink of your dish.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 16, height: 1.5)),
            const SizedBox(height: 24),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final isFilled = i < _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Image.asset(
                      isFilled
                          ? 'assets/icons/star_filled.png'
                          : 'assets/icons/star.png',
                      key: ValueKey('star_${i}_$_rating'),
                      width: 36, height: 36,
                      errorBuilder: (ctx, e, s) => Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: kBrown, size: 36),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            Text('Leave us your feedback!',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 16)),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(color: kInputBg,
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _reviewCtrl, maxLines: 5,
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write Review....',
                  hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.35), fontSize: 14),
                  border: InputBorder.none, isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Center(child: Text('Cancel',
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown, fontSize: 16,
                        fontWeight: FontWeight.w600))),
              )),
              Expanded(child: GestureDetector(
                onTap: _submit,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(color: kBrown,
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Submit',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              )),
            ]),
            const SizedBox(height: 32),
          ]),
        )),
      ]),

      bottomNavigationBar: SharedNavBar(activeIndex: -1),
    );
  }

  Widget _imgPlaceholder() => Container(
      width: 160, height: 160,
      decoration: BoxDecoration(color: kInputBg,
          borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.coffee, color: kBrownLight, size: 60));
}