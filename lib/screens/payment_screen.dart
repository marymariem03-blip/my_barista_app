// lib/screens/payment_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import '../core/services/firebase_service.dart';
import '../core/services/notification_service.dart';
import 'order_confirmed_screen.dart';
import 'main_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int  _paymentMethod = 0;
  bool _loading       = false;

  Future<void> _placeOrder() async {
    setState(() => _loading = true);

    final uid    = FirebaseService.currentUser?.uid ?? '';
    final cart   = AppDB.cart;
    final branch = AppDB.selectedBranch?.name ?? '';
    final total  = AppDB.cartTotal;
    final method = _paymentMethod == 0 ? 'Credit Card' : 'Cash';

    String clientNom = '';
    if (uid.isNotEmpty) {
      final userData = await FirebaseService.getUser(uid);
      clientNom = userData?['nom'] as String? ?? '';
    }

    try {
      // ── Step 1: Create Commande doc ───────────────
      final docRef = await FirebaseFirestore.instance
          .collection('Commande')
          .add({
        'clientnom':       clientNom,
        'consommablesnom': cart.isNotEmpty ? cart.first.product.name : '',
        'image':           cart.isNotEmpty ? cart.first.product.image : '',
        'idCl':            uid,
        'idbarista':       '',
        'paymentmethode':  method,
        'statut':          'pending',
        'total':           total.toStringAsFixed(3).replaceAll('.', ','),
        'date':            FieldValue.serverTimestamp(),
      });

      // ── Step 2: Add items subcollection ───────────
      for (final item in cart) {
        await docRef.collection('items').add({
          'consommablesId':  item.product.id,
          'consommablesNom': item.product.name,
          'image':           item.product.image,
          'prix':            item.product.price,
          'quantité':        item.quantity,
        });
      }

      // ── Step 3: Find barista by selected branch ──
      final selectedBranchName = AppDB.selectedBranch?.name ?? '';
      String baristaUid = '';

      if (selectedBranchName.isNotEmpty) {
        final baristaSnap = await FirebaseFirestore.instance
            .collection('barista')
            .where('branchName', isEqualTo: selectedBranchName)
            .limit(1)
            .get();

        if (baristaSnap.docs.isNotEmpty) {
          baristaUid = baristaSnap.docs.first.id;
        }
      }

      // ── Step 4: Save idbarista on the order ───────
      if (baristaUid.isNotEmpty) {
        await docRef.set({'idbarista': baristaUid}, SetOptions(merge: true));
      }

      // ── Step 5: Notify only that barista ─────────
      if (baristaUid.isNotEmpty) {
        await NotificationService.notifyNewOrder(
          baristaId:  baristaUid,
          clientName: clientNom.isNotEmpty ? clientNom : 'A client',
          itemName:   cart.isNotEmpty ? cart.first.product.name : 'an item',
          orderId:    docRef.id,
          clientId:   uid,
        );
      }

      // ── Step 4: Clear cart ────────────────────────
      AppDB.clearCart();

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const OrderConfirmedScreen()),
          (route) => route.isFirst);

    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e',
            style: const TextStyle(fontFamily: 'LeagueSpartan')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Payment Method',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _PaymentOption(
            icon: Icons.credit_card,
            label: 'Credit Card',
            selected: _paymentMethod == 0,
            onTap: () { setState(() => _paymentMethod = 0); Navigator.pop(context); },
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            icon: Icons.payments_outlined,
            label: 'Cash',
            selected: _paymentMethod == 1,
            onTap: () { setState(() => _paymentMethod = 1); Navigator.pop(context); },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad      = MediaQuery.of(context).padding.top;
    final cart        = AppDB.cart;
    final branch      = AppDB.selectedBranch?.name ?? "Barista's Menzah 9";
    final total       = AppDB.cartTotalFormatted;
    final methodLabel = _paymentMethod == 0 ? 'Credit Card' : 'Cash';
    final methodIcon  = _paymentMethod == 0
        ? Icons.credit_card : Icons.payments_outlined;

    return Scaffold(
      backgroundColor: kBrown,
      bottomNavigationBar: SharedNavBar(activeIndex: -1),
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('Payment', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
        ),

        // ── White body ───────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Your Barista's
                  const Text("Your Barista's",
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: kInputBg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      const Icon(Icons.location_on_outlined,
                          color: kBrown, size: 18),
                      const SizedBox(width: 8),
                      Flexible(child: Text(branch,
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 14,
                              fontWeight: FontWeight.w500))),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Summary',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      _EditChip(onTap: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...cart.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Expanded(child: Text(item.product.name,
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.7), fontSize: 13))),
                      Text('${item.quantity} item${item.quantity > 1 ? 's' : ''}',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.5), fontSize: 12)),
                    ]),
                  )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(total, style: const TextStyle(
                        fontFamily: 'LeagueSpartan', color: kBrown,
                        fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: kBrown.withOpacity(0.1), height: 1),
                  const SizedBox(height: 20),

                  // Payment Method
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Method',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      _EditChip(onTap: _showPaymentPicker),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(methodIcon, color: kBrown, size: 28),
                    const SizedBox(width: 10),
                    Text(methodLabel,
                        style: const TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    if (_paymentMethod == 0) ...[
                      const Spacer(),
                      Text('*** *** *** 43 /00 /000',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.5), fontSize: 12)),
                    ],
                  ]),
                  const SizedBox(height: 24),
                  Divider(color: kBrown.withOpacity(0.1), height: 1),
                  const SizedBox(height: 20),

                  // Delivery Time
                  const Text('Delivery Time',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown, fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Delivery',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.6), fontSize: 13)),
                      const Text('15 mins',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Pay Now
                  _loading
                      ? const Center(child: CircularProgressIndicator(
                          color: kBrown))
                      : GestureDetector(
                          onTap: _placeOrder,
                          child: Container(
                            width: double.infinity, height: 52,
                            decoration: BoxDecoration(color: kBrown,
                                borderRadius: BorderRadius.circular(32)),
                            alignment: Alignment.center,
                            child: const Text('Pay Now',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.white, fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Payment option tile ───────────────────────────────
class _PaymentOption extends StatelessWidget {
  final IconData icon; final String label;
  final bool selected; final VoidCallback onTap;
  const _PaymentOption({required this.icon, required this.label,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: selected ? kBrown.withOpacity(0.08) : kInputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? kBrown : Colors.transparent, width: 1.5)),
      child: Row(children: [
        Icon(icon, color: kBrown, size: 26),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
            style: const TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontSize: 15, fontWeight: FontWeight.w600))),
        if (selected)
          Container(
            width: 20, height: 20,
            decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
      ]),
    ),
  );
}

// ── Edit chip ─────────────────────────────────────────
class _EditChip extends StatelessWidget {
  final VoidCallback onTap;
  const _EditChip({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(color: kInputBg,
          borderRadius: BorderRadius.circular(16)),
      child: const Text('Edit', style: TextStyle(
          fontFamily: 'LeagueSpartan', color: kBrown,
          fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );
}