import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'order_cancelled_screen.dart';

class CancelOrderScreen extends StatefulWidget {
  final AppOrder order;
  final VoidCallback onCancelled;

  const CancelOrderScreen({
    super.key,
    required this.order,
    required this.onCancelled,
  });

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  // Pre-defined cancellation reasons
  final List<String> _reasons = [
    'I placed the order by mistake.',
    'Wait time is too long',
    'I made a mistake in my order.',
  ];

  String? _selectedReason;
  final _otherCtrl = TextEditingController();
  bool _showOther = false;

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // Determine the final reason
    final reason = _showOther
        ? _otherCtrl.text.trim()
        : _selectedReason;

    if (reason == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason'),
          backgroundColor: kBrown,
        ),
      );
      return;
    }

    // Cancel the order in the fake database
    AppDB.cancelOrder(widget.order.id, reason);
    widget.onCancelled();

    // Go to order cancelled confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderCancelledScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [

          // ── Header ───────────────────────────────────
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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 34),
                  ),
                ),
                const Text('Cancel Order',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "We're sorry to see you go! Please let us know the\nreason for your cancellation so we can improve\nyour next experience.",
                    style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Reason options ────────────────────
                  ..._reasons.map((reason) => _ReasonTile(
                        label: reason,
                        isSelected: _selectedReason == reason &&
                            !_showOther,
                        onTap: () => setState(() {
                          _selectedReason = reason;
                          _showOther = false;
                        }),
                      )),

                  const SizedBox(height: 16),

                  // ── Others section ────────────────────
                  const Text('Others',
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () => setState(() {
                      _showOther = true;
                      _selectedReason = null;
                    }),
                    child: Container(
                      width: double.infinity,
                      height: 90,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _showOther
                              ? kBrownLight
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _otherCtrl,
                        onTap: () => setState(() {
                          _showOther = true;
                          _selectedReason = null;
                        }),
                        maxLines: 3,
                        style: const TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Others reason...',
                          hintStyle: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.4),
                              fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit button ─────────────────────
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Submit',
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reason tile ───────────────────────────────────────
class _ReasonTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kBrownLight : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: kBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kBrownLight : Colors.black26,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: kBrownLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}