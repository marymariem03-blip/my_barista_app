// lib/screens/manager/manager_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/i_plat_service.dart';
import '../../core/services/firebase_plat_service.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});
  @override State<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final _db      = FirebaseFirestore.instance;
  final _service = ServiceLocator.platService;
  Stream<int>? _platCountStream;

  @override
  void initState() {
    super.initState();
    if (_service is FirebasePlatService) {
      _platCountStream = (_service as FirebasePlatService)
          .watchAll()
          .map((list) => list.length);
    }
  }

  Stream<QuerySnapshot> get _baristaStream =>
      _db.collection('barista').snapshots();

  // ── Fetch user info for a barista uid ────────────────
  Future<Map<String, dynamic>?> _getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (_) { return null; }
  }

  // ── Add barista using a secondary Firebase App ────────
  // This prevents Firebase from switching the current
  // manager session to the newly created barista account.
  void _showAddBaristaDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    final formKey   = GlobalKey<FormState>();
    bool   saving   = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Ajouter un Barista',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown, fontWeight: FontWeight.w800)),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DlgField(ctrl: nameCtrl,  hint: 'Nom complet',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Requis' : null),
              const SizedBox(height: 12),
              _DlgField(ctrl: emailCtrl, hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Email invalide' : null),
              const SizedBox(height: 12),
              _DlgField(ctrl: passCtrl,  hint: 'Mot de passe',
                  icon: Icons.lock_outline, obscure: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Min 6 caracteres' : null),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(
                    color: Colors.red, fontSize: 12,
                    fontFamily: 'LeagueSpartan')),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBrown,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: saving ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setDlg(() { saving = true; error = null; });

                FirebaseApp? secondaryApp;
                try {
                  // ✅ Use a secondary Firebase app so the manager
                  // session is NOT replaced by the new barista auth.
                  secondaryApp = await Firebase.initializeApp(
                    name: 'secondaryApp_${DateTime.now().millisecondsSinceEpoch}',
                    options: Firebase.app().options,
                  );

                  final secondaryAuth = FirebaseAuth.instanceFor(
                      app: secondaryApp);

                  // 1. Create barista Auth account (secondary app)
                  final cred = await secondaryAuth
                      .createUserWithEmailAndPassword(
                        email:    emailCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                      );
                  final uid = cred.user!.uid;

                  // 2. Sign out from secondary app immediately
                  await secondaryAuth.signOut();

                  // 3. Write users doc (primary db, manager still authed)
                  await _db.collection('users').doc(uid).set({
                    'nom':    nameCtrl.text.trim(),
                    'email':  emailCtrl.text.trim(),
                    'role':   'barista',
                    'phone':  '',
                    'dob':    '',
                    'avatar': '',
                  });

                  // 4. Write barista doc
                  await _db.collection('barista').doc(uid).set({
                    'idbarista': uid,
                    'userid':    uid,
                  });

                  if (ctx.mounted) Navigator.pop(ctx);

                } on FirebaseAuthException catch (e) {
                  setDlg(() {
                    saving = false;
                    error  = e.message ?? 'Erreur Firebase Auth';
                  });
                } catch (e) {
                  setDlg(() {
                    saving = false;
                    error  = 'Erreur: $e';
                  });
                } finally {
                  // Always delete the secondary app to free resources
                  await secondaryApp?.delete();
                }
              },
              child: saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Ajouter', style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete barista ────────────────────────────────────
  void _confirmDeleteBarista(String uid, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le barista',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontWeight: FontWeight.w800)),
        content: Text('Supprimer le compte de "$name" ?',
            style: const TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Future.wait([
                _db.collection('barista').doc(uid).delete()
                    .catchError((_) {}),
                _db.collection('users').doc(uid).delete()
                    .catchError((_) {}),
              ]);
            },
            child: const Text('Supprimer', style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: Colors.red,
                fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(children: [

      // Header
      Container(
        color: kBrown,
        padding: EdgeInsets.only(
            top: topPad + 14, left: 20, right: 20, bottom: 20),
        child: Row(children: [
          Container(width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.white24,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.person, color: Colors.white, size: 26)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_service.managerName, style: const TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.w700)),
            Text("Barista's Admin Panel", style: TextStyle(
                fontFamily: 'LeagueSpartan',
                color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ]),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            const SizedBox(height: 4),
            const Text('Apercu', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown,
                fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),

            // Stat cards
            Row(children: [
              Expanded(child: _platCountStream != null
                  ? StreamBuilder<int>(
                      stream: _platCountStream,
                      builder: (_, snap) => _StatCard(
                        icon: Icons.restaurant_menu_outlined,
                        label: 'Plats', value: '${snap.data ?? 0}',
                        bgColor: const Color(0xFFEDE8F5),
                        iconColor: const Color(0xFF6A1B9A),
                      ))
                  : _StatCard(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Plats', value: '${_service.totalPlats}',
                      bgColor: const Color(0xFFEDE8F5),
                      iconColor: const Color(0xFF6A1B9A))),
              const SizedBox(width: 12),
              Expanded(child: StreamBuilder<QuerySnapshot>(
                stream: _baristaStream,
                builder: (_, snap) => _StatCard(
                  icon: Icons.coffee_outlined,
                  label: 'Baristas',
                  value: '${snap.data?.docs.length ?? 0}',
                  bgColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                ),
              )),
            ]),
            const SizedBox(height: 12),

            _WideCard(icon: Icons.attach_money,
                label: 'Ventes totales',
                value: '${_service.totalFakeSales
                    .toStringAsFixed(3).replaceAll('.', ',')} DT'),
            const SizedBox(height: 12),

            _WideCard(icon: Icons.local_cafe_outlined,
                label: 'Plat le plus commande',
                value: _service.mostOrderedPlat,
                secondary: true),
            const SizedBox(height: 28),

            // ── Barista management ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gestion des Baristas', style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: kBrown,
                    fontSize: 20, fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: _showAddBaristaDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: kBrown,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Row(children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Ajouter', style: TextStyle(
                          fontFamily: 'LeagueSpartan', color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ✅ StreamBuilder drives the list — always up to date
            StreamBuilder<QuerySnapshot>(
              stream: _baristaStream,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                      color: kBrown));
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Icon(Icons.coffee_outlined,
                          size: 48, color: kBrown.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('Aucun barista', style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.4),
                          fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Ajoutez votre premier barista',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.3),
                              fontSize: 12)),
                    ]),
                  );
                }

                // ✅ Build list from snapshot docs directly
                return Column(
                  children: docs.map((doc) {
                    final uid  = doc.id;
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getUser(uid),
                      builder: (_, userSnap) {
                        final name   = userSnap.data?['nom']    as String? ?? 'Barista';
                        final email  = userSnap.data?['email']  as String? ?? '';
                        final avatar = userSnap.data?['avatar'] as String? ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))]),
                          child: Row(children: [

                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFFFF3E0),
                              backgroundImage: avatar.isNotEmpty &&
                                      avatar.startsWith('http')
                                  ? NetworkImage(avatar) : null,
                              child: (avatar.isEmpty || !avatar.startsWith('http'))
                                  ? Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'B',
                                      style: const TextStyle(
                                          fontFamily: 'LeagueSpartan',
                                          color: Color(0xFFE65100),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800))
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Info
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(
                                    fontFamily: 'LeagueSpartan', color: kBrown,
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(email,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'LeagueSpartan',
                                        color: kBrown.withOpacity(0.5),
                                        fontSize: 12)),
                              ],
                            )),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('Barista', style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: Color(0xFFE65100),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),

                            // Delete
                            GestureDetector(
                              onTap: () => _confirmDeleteBarista(uid, name),
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 18),
                              ),
                            ),
                          ]),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 28),
            _OrdersPerHourSection(service: _service),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    ]);
  }
}

// ── Dialog field ──────────────────────────────────────────
class _DlgField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const _DlgField({required this.ctrl, required this.hint,
      required this.icon, this.obscure = false,
      this.keyboardType = TextInputType.text, this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: obscure,
    keyboardType: keyboardType, validator: validator,
    style: const TextStyle(fontFamily: 'LeagueSpartan',
        color: kBrown, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: kBrown.withOpacity(0.4), size: 20),
      hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.35), fontSize: 14),
      filled: true, fillColor: kInputBg,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      errorStyle: const TextStyle(fontFamily: 'LeagueSpartan',
          color: Colors.red, fontSize: 11),
    ),
  );
}

// ── Orders per hour ───────────────────────────────────────
class _OrdersPerHourSection extends StatelessWidget {
  final IPlatService service;
  const _OrdersPerHourSection({required this.service});

  @override
  Widget build(BuildContext context) {
    final perHour    = service.getOrdersPerHour();
    final activeHour = service.getMostActiveHour();
    final hours      = perHour.keys.toList()..sort();
    final maxCount   = perHour.values.isEmpty ? 1
        : perHour.values.reduce((a, b) => a > b ? a : b);

    if (perHour.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Activite par heure', style: TextStyle(
            fontFamily: 'LeagueSpartan', color: kBrown,
            fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: kBrown,
              borderRadius: BorderRadius.circular(10)),
          child: Text('Peak: ${activeHour}h', style: const TextStyle(
              fontFamily: 'LeagueSpartan', color: Colors.white,
              fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ]),
      const SizedBox(height: 4),
      Text('${perHour.values.fold(0, (a, b) => a + b)} commandes',
          style: TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown.withOpacity(0.5), fontSize: 12)),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          SizedBox(
            height: 100,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                children: hours.map((hour) {
              final count    = perHour[hour] ?? 0;
              final isActive = hour == activeHour;
              final ratio    = count / maxCount;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                  if (isActive) Text('$count', style: const TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 10, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Container(height: (ratio * 80).clamp(4.0, 80.0),
                      decoration: BoxDecoration(
                          color: isActive ? kBrown : kBrown.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4))),
                ]),
              ));
            }).toList()),
          ),
          const SizedBox(height: 8),
          Row(children: hours.map((hour) {
            final isActive = hour == activeHour;
            return Expanded(child: Text('${hour}h',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 9,
                    color: isActive ? kBrown : kBrown.withOpacity(0.35),
                    fontWeight: isActive
                        ? FontWeight.w800 : FontWeight.w400)));
          }).toList()),
        ]),
      ),
    ]);
  }
}

// ── Stat card ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value;
  final Color bgColor; final Color iconColor;
  const _StatCard({required this.icon, required this.label,
      required this.value, required this.bgColor, required this.iconColor});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 40,
          decoration: BoxDecoration(color: bgColor,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 22)),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.5), fontSize: 12)),
    ]),
  );
}

// ── Wide card ─────────────────────────────────────────────
class _WideCard extends StatelessWidget {
  final IconData icon; final String label;
  final String value; final bool secondary;
  const _WideCard({required this.icon, required this.label,
      required this.value, this.secondary = false});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: secondary ? const Color(0xFFF5F0EB) : kBrown,
        borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 46, height: 46,
          decoration: BoxDecoration(
              color: secondary ? kBrown.withOpacity(0.1) : Colors.white24,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon,
              color: secondary ? kBrown : Colors.white, size: 24)),
      const SizedBox(width: 14),
      Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
            color: secondary ? kBrown.withOpacity(0.6)
                : Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontFamily: 'LeagueSpartan',
            color: secondary ? kBrown : Colors.white,
            fontSize: 16, fontWeight: FontWeight.w800)),
      ])),
    ]),
  );
}