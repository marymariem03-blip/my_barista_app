import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import '../core/services/firebase_service.dart';
import 'main_screen.dart';

class LeaveReviewScreen extends StatefulWidget {
  final AppOrder order;
  const LeaveReviewScreen({super.key, required this.order});

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  int _rating = 0;
  final _reviewCtrl = TextEditingController();
  bool _submitting  = false;

  @override
  void dispose() { _reviewCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a star rating', style: TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: kBrown, behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _submitting = true);

    // ✅ Save to local fake DB
    AppDB.reviewOrder(widget.order.id, _rating, _reviewCtrl.text.trim());

    // ✅ Save to Firebase Firestore
    final uid = FirebaseService.currentUser?.uid;
    if (uid != null) {
      await FirebaseService.addFeedback(
        clientId:    uid,
        commandeId:  widget.order.id,
        note:        _rating,
        commentaire: _reviewCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final firstItem = widget.order.items.first;
    final imgPath   = firstItem.product.image;
    final isHttp    = imgPath.startsWith('http');

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(alignment: Alignment.centerLeft,
                child: GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 34))),
            const Text('Leave a Review', style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
        ),

        // ── Content ─────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 32),

            // ✅ Supports network (Firebase Storage) + asset images
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isHttp
                  ? Image.network(imgPath, width: 160, height: 160, fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => _imgPlaceholder())
                  : Image.asset(imgPath, width: 160, height: 160, fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => _imgPlaceholder()),
            ),
            const SizedBox(height: 20),

            Text(firstItem.product.name, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Text("We'd love to know what you\nthink of your dish.", textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 16, height: 1.5)),
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
                      isFilled ? 'assets/icons/star_filled.png' : 'assets/icons/star.png',
                      key: ValueKey('star_${i}_$_rating'),
                      width: 36, height: 36,
                      errorBuilder: (ctx, e, s) => Icon(isFilled ? Icons.star : Icons.star_border, color: kBrown, size: 36),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            Text('Leave us your feedback!', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 16)),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(color: kInputBg, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _reviewCtrl, maxLines: 5,
                style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 14),
                decoration: InputDecoration(hintText: 'Write Review....',
                    hintStyle: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown.withOpacity(0.35), fontSize: 14),
                    border: InputBorder.none, isDense: true),
              ),
            ),
            const SizedBox(height: 32),

            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Center(child: Text('Cancel',
                    style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 16, fontWeight: FontWeight.w600))),
              )),
              Expanded(child: GestureDetector(
                onTap: _submit,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(color: kBrown, borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit', style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              )),
            ]),
            const SizedBox(height: 32),
          ]),
        )),
      ]),

      // Bottom nav
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(color: kBrown, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _NavBtn(path: 'assets/icons/home.png', fallback: Icons.home_rounded,
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: kTabHome)), (r) => false)),
          _NavBtn(path: 'assets/icons/order.png', fallback: Icons.receipt_long_outlined,
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: kTabOrders)), (r) => false)),
          _NavBtn(path: 'assets/icons/cup.png', fallback: Icons.local_cafe_outlined,
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: kTabTrack)), (r) => false)),
        ]),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(width: 160, height: 160,
      decoration: BoxDecoration(color: kInputBg, borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.coffee, color: kBrownLight, size: 60));
}

class _NavBtn extends StatelessWidget {
  final String path; final IconData fallback; final VoidCallback onTap;
  const _NavBtn({required this.path, required this.fallback, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(8),
        child: Image.asset(path, width: 28, height: 28, color: Colors.white38,
            errorBuilder: (ctx, e, s) => Icon(fallback, color: Colors.white38, size: 28))),
  );
}