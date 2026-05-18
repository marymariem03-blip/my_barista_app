import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'main_screen.dart';

// ── TrackOrderScreen ──────────────────────────────────
// Lives inside MainScreen's IndexedStack — NO Scaffold,
// NO bottom nav bar (MainScreen owns both).
class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final branch = AppDB.selectedBranch?.name ?? "Barista's Menzah 9";

    return Column(
      children: [

        // ── Header ─────────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<MainScreenState>();
                    state?.switchTab(kTabHome);
                  },
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 34),
                ),
              ),
              const Text('Delivery time',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        // ── Scrollable content ─────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Your Barista's
                    const Text("Your Barista's",
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),

                    // Branch pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: kInputBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined,
                            color: kBrown, size: 18),
                        const SizedBox(width: 8),
                        Text(branch,
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ),
                    const SizedBox(height: 28),

                    // ── Track icon ─────────────────────
                    Center(
                      child: Image.asset(
                        'assets/icons/track.png',
                        width: 256,
                        height: 256,
                        fit: BoxFit.contain,
                        color: kBrown,
                        errorBuilder: (ctx, e, s) => Icon(
                            Icons.local_cafe_rounded,
                            color: kBrown,
                            size: 200),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Delivery Time ───────────────────
                    const Text('Delivery Time',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Delivery',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown.withOpacity(0.55),
                                fontSize: 13)),
                        const Text('15 mins',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Steps ───────────────────────────
                    _TrackStep(
                      label: 'Your order has been accepted',
                      time: '2 min',
                      isDone: true,
                      showLine: true,
                    ),
                    _TrackStep(
                      label: 'The restaurant is preparing your order',
                      time: '5 min',
                      isDone: false,
                      showLine: false,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Track step ────────────────────────────────────────
class _TrackStep extends StatelessWidget {
  final String label;
  final String time;
  final bool isDone;
  final bool showLine;

  const _TrackStep({
    required this.label,
    required this.time,
    required this.isDone,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Dot + vertical line
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 12, height: 12,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isDone ? kBrown : kBrown.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
              if (showLine)
                Container(
                  width: 1.5,
                  height: 28,
                  color: kBrown.withOpacity(0.2),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Label + time
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.75),
                          fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Text(time,
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: kBrown.withOpacity(0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}