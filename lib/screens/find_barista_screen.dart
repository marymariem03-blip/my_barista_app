// lib/screens/find_barista_screen.dart

import 'dart:math';
import 'package:flutter/foundation.dart'; // ← for ValueNotifier
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'main_screen.dart';

// ✅ Global notifier — import this from home_screen.dart too:
//    import 'find_barista_screen.dart' show branchNotifier;
final ValueNotifier<Branch?> branchNotifier =
    ValueNotifier<Branch?>(AppDB.selectedBranch);

class FindBaristaScreen extends StatefulWidget {
  final bool fromDrawer;
  const FindBaristaScreen({super.key, this.fromDrawer = false});

  @override
  State<FindBaristaScreen> createState() => _FindBaristaScreenState();
}

class _FindBaristaScreenState extends State<FindBaristaScreen> {
  final _searchCtrl  = TextEditingController();
  List<Branch> _filtered = kBranches;
  Branch? _closestBranch;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _findClosestBranch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? kBranches
          : kBranches
              .where((b) =>
                  b.name.toLowerCase().contains(q) ||
                  b.address.toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _findClosestBranch() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      Branch? closest;
      double minDist = double.infinity;
      for (final b in kBranches) {
        final d = _distanceKm(pos.latitude, pos.longitude, b.lat, b.lng);
        if (d < minDist) { minDist = d; closest = b; }
      }
      setState(() { _closestBranch = closest; _locating = false; });
    } catch (_) {
      setState(() => _locating = false);
    }
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double d) => d * pi / 180;

  void _selectBranch(Branch branch) {
    AppDB.selectedBranch  = branch;
    branchNotifier.value  = branch; // ✅ notifies HomeBody instantly

    if (widget.fromDrawer) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ───────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 12, left: 16, right: 16, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 8),
                const Text("Find your Barista's",
                    style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 14),
              Container(
                height: 44,
                decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(22)),
                child: Row(children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontFamily: 'LeagueSpartan',
                          fontSize: 14, color: kBrown),
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
                            color: Colors.black38, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                        color: kBrown, shape: BoxShape.circle),
                    child: const Icon(Icons.search,
                        color: Colors.white, size: 18),
                  ),
                ]),
              ),
            ],
          ),
        ),

        // ── Location loading ──────────────────────────
        if (_locating)
          Container(
            color: kBrownLight.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(children: [
              SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: kBrown)),
              SizedBox(width: 10),
              Text('Finding your location...', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 13)),
            ]),
          ),

        // ── Closest branch banner ─────────────────────
        if (!_locating && _closestBranch != null)
          GestureDetector(
            onTap: () => _selectBranch(_closestBranch!),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kBrownLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBrownLight.withOpacity(0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.location_on, color: kBrownLight, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Closest Barista's", style: TextStyle(
                        fontFamily: 'LeagueSpartan', color: kBrown,
                        fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(_closestBranch!.name, style: const TextStyle(
                        fontFamily: 'LeagueSpartan', color: kBrown,
                        fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(_closestBranch!.address, style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.6), fontSize: 11)),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                      color: kBrown, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Select', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ),

        // ── Branch grid ──────────────────────────────
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Text('No branches found',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.5), fontSize: 16)))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _BranchCard(
                    branch:    _filtered[i],
                    isClosest: _filtered[i].id == _closestBranch?.id,
                    onSelect:  () => _selectBranch(_filtered[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final bool isClosest;
  final VoidCallback onSelect;
  const _BranchCard({required this.branch, required this.isClosest,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(16),
        border: isClosest ? Border.all(color: kBrownLight, width: 2) : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _BranchImage(imagePath: branch.image)),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
          child: Text(branch.name, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontSize: 12, fontWeight: FontWeight.w700,
                  height: 1.2)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
          child: Text(branch.plusCode, maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.55), fontSize: 10)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: GestureDetector(
            onTap: onSelect,
            child: Container(
              width: double.infinity, height: 32,
              decoration: BoxDecoration(
                  color: kBrown, borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: const Text('Select', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: Colors.white,
                  fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _BranchImage extends StatelessWidget {
  final String imagePath;
  const _BranchImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return _placeholder();
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath,
          width: double.infinity, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(color: kBrown.withOpacity(0.05),
                child: const Center(child: CircularProgressIndicator(
                    strokeWidth: 2, color: kBrown)));
          },
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return Image.asset(imagePath,
        width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() => Container(
      color: kBrown.withOpacity(0.08),
      child: Center(child: Icon(Icons.storefront_outlined,
          color: kBrown.withOpacity(0.3), size: 40)));
}