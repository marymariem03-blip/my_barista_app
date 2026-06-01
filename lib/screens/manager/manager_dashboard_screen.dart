import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';


import '../../core/data/app_database.dart'; // ← for kBranches & Branch

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});
  @override State<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final _db      = FirebaseFirestore.instance;



  int _statTab    = 0;
  int _periodDays = 7;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _managerName = 'Manager';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
    _loadManagerName();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadManagerName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (mounted) setState(() =>
        _managerName = doc.data()?['nom'] as String? ?? 'Manager');
  }

  Stream<QuerySnapshot> get _baristaStream =>
      _db.collection('barista').snapshots();

  Stream<QuerySnapshot> get _commandeStream =>
      _db.collection('Commande').snapshots();

  Future<Map<String, dynamic>?> _getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> _getBaristaDoc(String uid) async {
    try {
      final doc = await _db.collection('barista').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (_) { return null; }
  }

  String get _dateString {
    final now  = DateTime.now();
    const days   = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    const months = ['Jan','Fév','Mar','Avr','Mai','Jun',
        'Jul','Aoû','Sep','Oct','Nov','Déc'];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  List<double> get _chartData => _periodDays == 7
      ? [120, 180, 150, 220, 190, 280, 310]
      : [800, 950, 870, 1100, 980, 1200, 1050, 1300, 1150, 900, 1000, 1250, 1400, 1100, 1000, 1200, 1300, 1150, 1050, 980, 1100, 1250, 1400, 1300, 1200, 1100, 1050, 980, 1200, 1300];

  // ── Branch picker bottom sheet ────────────────────────────────────────────
  Future<Branch?> _pickBranch(BuildContext context) async {
    Branch? selected;
    await showModalBottomSheet<Branch>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (ctx, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text("Choisir une Barista's",
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ),
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: kBranches.length,
                itemBuilder: (_, i) {
                  final b = kBranches[i];
                  return GestureDetector(
                    onTap: () {
                      selected = b;
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _BranchThumb(imagePath: b.image)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                            child: Text(b.name, maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan', color: kBrown,
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    height: 1.2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Text(b.plusCode, maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: kBrown.withOpacity(0.5),
                                    fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
    return selected;
  }

  // ── Add barista dialog ────────────────────────────────────────────────────
  void _showAddBaristaDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    final formKey   = GlobalKey<FormState>();
    Branch? pickedBranch;
    bool    saving = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: kBrown,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: const Text("Ajouter une Barista's",
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w800)),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              // Nom du Barista's
              _DlgField(ctrl: nameCtrl,
                  hint: "Nom du Barista's",
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Requis' : null),
              const SizedBox(height: 12),

              // Localisation — tappable picker
              GestureDetector(
                onTap: () async {
                  final b = await _pickBranch(ctx);
                  if (b != null) setDlg(() => pickedBranch = b);
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.location_on_outlined,
                        color: kBrown.withOpacity(0.4), size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: pickedBranch == null
                        ? Text('Localisation',
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: kBrown.withOpacity(0.4), fontSize: 14))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(pickedBranch!.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrown, fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              Text(pickedBranch!.plusCode,
                                  style: TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: kBrown.withOpacity(0.5),
                                      fontSize: 10)),
                            ],
                          )),
                    Icon(Icons.chevron_right,
                        color: kBrown.withOpacity(0.35), size: 20),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // Email
              _DlgField(ctrl: emailCtrl, hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Email invalide' : null),
              const SizedBox(height: 12),

              // Mot de passe
              _DlgField(ctrl: passCtrl, hint: 'Mot de passe',
                  icon: Icons.lock_outline, obscure: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Min 6 caractères' : null),

              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(
                    color: Colors.redAccent, fontSize: 12,
                    fontFamily: 'LeagueSpartan')),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBrownLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: saving ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setDlg(() { saving = true; error = null; });
                FirebaseApp? secondaryApp;
                try {
                  secondaryApp = await Firebase.initializeApp(
                    name: 'secondaryApp_${DateTime.now().millisecondsSinceEpoch}',
                    options: Firebase.app().options,
                  );
                  final secondaryAuth =
                      FirebaseAuth.instanceFor(app: secondaryApp);
                  final cred = await secondaryAuth
                      .createUserWithEmailAndPassword(
                        email:    emailCtrl.text.trim(),
                        password: passCtrl.text.trim());
                  final uid = cred.user!.uid;
                  await secondaryAuth.signOut();

                  // Save to users collection
                  await _db.collection('users').doc(uid).set({
                    'nom':   nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'role':  'barista',
                    
                  });

                  // Save to barista collection — include branch info
                  await _db.collection('barista').doc(uid).set({
                    'idbarista':    uid,
                    'userid':       uid,
                    'branchName':   pickedBranch?.name    ?? '',
                    'branchImage':  pickedBranch?.image   ?? '',
                    'branchAddress': pickedBranch?.address ?? '',
                    'branchPlusCode': pickedBranch?.plusCode ?? '',
                  });

                  if (ctx.mounted) Navigator.pop(ctx);
                } on FirebaseAuthException catch (e) {
                  setDlg(() { saving = false; error = e.message; });
                } catch (e) {
                  setDlg(() { saving = false; error = 'Erreur: $e'; });
                } finally {
                  await secondaryApp?.delete();
                }
              },
              child: saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Ajouter', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete barista ────────────────────────────────────────────────────────
  void _confirmDeleteBarista(String uid, String name) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Supprimer le barista',
          style: TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown, fontWeight: FontWeight.w800)),
      content: Text('Supprimer "$name" ?',
          style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown))),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await Future.wait([
              _db.collection('barista').doc(uid).delete().catchError((_) {}),
              _db.collection('users').doc(uid).delete().catchError((_) {}),
            ]);
          },
          child: const Text('Supprimer', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: Colors.red,
              fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(children: [

      // ── Dark header
      Container(
        color: kBrown,
        width: double.infinity,
        padding: EdgeInsets.only(
            top: topPad + 20, left: 20, right: 20, bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Salut $_managerName',
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 32,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(_dateString, style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.w500)),
        ]),
      ),

      // ── Scrollable body
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 3 KPI cards — real Firestore data only
              StreamBuilder<QuerySnapshot>(
                stream: _commandeStream,
                builder: (_, cmdSnap) {
                  final docs      = cmdSnap.data?.docs ?? [];
                  final cmdCount  = docs.length;

                  // Total revenue — handles both num and String (e.g. "10,000")
                  final totalRevenue = docs.fold<double>(0, (sum, d) {
                    final data  = d.data() as Map<String, dynamic>;
                    final raw   = data['total'];
                    double val  = 0;
                    if (raw is num) {
                      val = raw.toDouble();
                    } else if (raw is String) {
                      val = double.tryParse(
                          raw.replaceAll(',', '.').replaceAll(' ', '')) ?? 0;
                    }
                    return sum + val;
                  });

                  // Most ordered item
                  final Map<String, int> itemCount = {};
                  for (final d in docs) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['consommablesnom'] ?? '') as String;
                    if (name.isNotEmpty) {
                      itemCount[name] = (itemCount[name] ?? 0) + 1;
                    }
                  }
                  final topVente = itemCount.isEmpty
                      ? '—'
                      : itemCount.entries
                          .reduce((a, b) => a.value >= b.value ? a : b)
                          .key;

                  return Row(children: [
                    Expanded(child: _KpiCard(
                      label: 'CA Total',
                      value: '${totalRevenue.toStringAsFixed(2)} DT',
                      sub: '')),
                    const SizedBox(width: 10),
                    Expanded(child: _KpiCard(
                      label: 'Commandes',
                      value: '$cmdCount',
                      sub: '')),
                    const SizedBox(width: 10),
                    Expanded(child: _KpiCard(
                      label: 'Top Vente',
                      value: topVente,
                      sub: '')),
                  ]);
                },
              ),
              const SizedBox(height: 24),

              // ── Statistiques
              const Text('Statistiques:',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 20, fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline)),
              const SizedBox(height: 14),

              Container(
                height: 40,
                decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  _StatTab(label: 'Ventes',          active: _statTab == 0,
                      onTap: () => setState(() => _statTab = 0)),
                  _StatTab(label: 'Heures de pointe',active: _statTab == 1,
                      onTap: () => setState(() => _statTab = 1)),
                  _StatTab(label: 'Plats',           active: _statTab == 2,
                      onTap: () => setState(() => _statTab = 2)),
                ]),
              ),
              const SizedBox(height: 12),

              if (_statTab == 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _PeriodBtn(label: '7j',     active: _periodDays == 7,
                        onTap: () => setState(() => _periodDays = 7)),
                    const SizedBox(width: 10),
                    _PeriodBtn(label: '1 mois', active: _periodDays == 30,
                        onTap: () => setState(() => _periodDays = 30)),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ── Chart + stats per tab
              if (_statTab == 0) ...[
                // Ventes — bar chart
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                      color: kInputBg,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chiffre D'affaires",
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      _BarChart(data: _chartData),
                    ],
                  ),
                ),
              ] else if (_statTab == 1) ...[
                // Heures de pointe — real Firestore data
                StreamBuilder<QuerySnapshot>(
                  stream: _commandeStream,
                  builder: (_, snap) {
                    final docs = snap.data?.docs ?? [];

                    // Count orders per hour
                    final Map<int, int> hourCount = {};
                    for (final d in docs) {
                      final data = d.data() as Map<String, dynamic>;
                      try {
                        final ts = data['date'] as Timestamp?;
                        if (ts != null) {
                          final h = ts.toDate().hour;
                          hourCount[h] = (hourCount[h] ?? 0) + 1;
                        }
                      } catch (_) {}
                    }

                    // Build 24h data for chart
                    final chartVals = List<double>.generate(
                        24, (h) => (hourCount[h] ?? 0).toDouble());

                    // Top 3 peak hours
                    final sorted = hourCount.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final top3 = sorted.take(3).toList();

                    return Column(children: [
                      // Bar chart
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                            color: kInputBg,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Commandes Par Heure',
                                style: TextStyle(fontFamily: 'LeagueSpartan',
                                    color: kBrown, fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            _BarChart(data: chartVals.any((v) => v > 0)
                                ? chartVals : [1,2,1,2,1,2,1]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Top 3 peak hours list
                      if (top3.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: kInputBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Top 3 Heures De Pointe',
                                  style: TextStyle(fontFamily: 'LeagueSpartan',
                                      color: kBrown, fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              ...top3.asMap().entries.map((e) {
                                final rank  = e.key + 1;
                                final hour  = e.value.key;
                                final count = e.value.value;
                                final colors = [
                                  const Color(0xFFD4A017),
                                  const Color(0xFF8B6914),
                                  Colors.grey,
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(children: [
                                    Text('#$rank : ',
                                        style: TextStyle(
                                            fontFamily: 'LeagueSpartan',
                                            color: colors[rank - 1],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800)),
                                    Text('${hour}h',
                                        style: const TextStyle(
                                            fontFamily: 'LeagueSpartan',
                                            color: kBrown, fontSize: 15,
                                            fontWeight: FontWeight.w700)),
                                    Expanded(child: Text(
                                        '............',
                                        style: TextStyle(
                                            fontFamily: 'LeagueSpartan',
                                            color: kBrown.withOpacity(0.3),
                                            fontSize: 15,
                                            letterSpacing: 2))),
                                    Text('$count Commandes',
                                        style: const TextStyle(
                                            fontFamily: 'LeagueSpartan',
                                            color: kBrown, fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                  ]),
                                );
                              }),
                            ],
                          ),
                        ),
                    ]);
                  },
                ),
              ] else ...[
                // Plats — Top 3 from real Commande data
                StreamBuilder<QuerySnapshot>(
                  stream: _commandeStream,
                  builder: (_, snap) {
                    final docs = snap.data?.docs ?? [];

                    // Count each item across all orders
                    final Map<String, int> itemCount = {};
                    for (final d in docs) {
                      final data = d.data() as Map<String, dynamic>;
                      final name = (data['consommablesnom'] ?? '') as String;
                      if (name.isNotEmpty) {
                        itemCount[name] = (itemCount[name] ?? 0) + 1;
                      }
                    }

                    final sorted = itemCount.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final top3 = sorted.take(3).toList();

                    if (top3.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: kInputBg,
                            borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.center,
                        child: Text("Aucune commande pour l'instant",
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: kBrown.withOpacity(0.4), fontSize: 14)),
                      );
                    }

                    final crowns = ['gold', 'bronze', null];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top 3 Meilleures Ventes',
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: kBrown, fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...top3.asMap().entries.map((e) {
                          final rank  = e.key;
                          final name  = e.value.key;
                          final count = e.value.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                color: kInputBg,
                                borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontFamily: 'LeagueSpartan',
                                          color: kBrown, fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text('$count vendus',
                                      style: TextStyle(
                                          fontFamily: 'LeagueSpartan',
                                          color: kBrown.withOpacity(0.45),
                                          fontSize: 13)),
                                ],
                              )),
                              Image.asset(
                                'assets/icons/${crowns[rank]}.png',
                                width: 52, height: 52,
                                errorBuilder: (_, __, ___) => Icon(
                                    Icons.emoji_events_rounded,
                                    color: rank == 0
                                        ? const Color(0xFFD4A017)
                                        : rank == 1
                                            ? const Color(0xFF8B6914)
                                            : Colors.grey,
                                    size: 40),
                              ),
                            ]),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 28),

              // ── Gestion des Baristas
              const Text('Gestion Des Baristas:',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown, fontSize: 20, fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline)),
              const SizedBox(height: 14),

              // Search + Add row
              Row(children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(22)),
                    child: Row(children: [
                      const SizedBox(width: 14),
                      Expanded(child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.4), fontSize: 14),
                          border: InputBorder.none, isDense: true,
                        ),
                      )),
                      Container(
                          width: 36, height: 36,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: const BoxDecoration(
                              color: kBrown, shape: BoxShape.circle),
                          child: const Icon(Icons.search,
                              color: Colors.white, size: 18)),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showAddBaristaDialog,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(22)),
                    child: const Row(children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Ajouter', style: TextStyle(
                          fontFamily: 'LeagueSpartan', color: Colors.white,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Barista list — now reads branchImage from barista doc
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
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      child: Text('Aucun barista',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.4), fontSize: 15)),
                    );
                  }
                  return Column(
                    children: docs.map((doc) {
                      final uid         = doc.id;
                      final bData       = doc.data() as Map<String, dynamic>;
                      final branchImage = bData['branchImage'] as String? ?? '';
                      final branchName  = bData['branchName']  as String? ?? '';

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _getUser(uid),
                        builder: (_, userSnap) {
                          final name   = userSnap.data?['nom']   as String? ?? 'Barista';
                          final email  = userSnap.data?['email'] as String? ?? '';

                          if (_searchQuery.isNotEmpty &&
                              !name.toLowerCase().contains(_searchQuery) &&
                              !branchName.toLowerCase().contains(_searchQuery) &&
                              !email.toLowerCase().contains(_searchQuery)) {
                            return const SizedBox.shrink();
                          }

                          return _BaristaCard(
                            name:        name,
                            branchName:  branchName.isNotEmpty ? branchName : email,
                            branchImage: branchImage,
                            onDelete:    () => _confirmDeleteBarista(uid, name),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ── KPI card ──────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value, sub;
  final bool subPositive;
  const _KpiCard({required this.label, required this.value,
      required this.sub, this.subPositive = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: kInputBg,
        borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 13, fontWeight: FontWeight.w800, height: 1.2)),
      if (sub.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontFamily: 'LeagueSpartan',
            color: subPositive ? Colors.green : Colors.red,
            fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    ]),
  );
}

// ── Stat tab ──────────────────────────────────────────────
class _StatTab extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _StatTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: active ? kBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(16)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: active ? Colors.white : kBrown.withOpacity(0.55),
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
    ),
  ));
}

// ── Period button ─────────────────────────────────────────
class _PeriodBtn extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _PeriodBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      decoration: BoxDecoration(
          color: active ? kBrown : kInputBg,
          borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: active ? Colors.white : kBrown.withOpacity(0.5),
          fontSize: 13, fontWeight: FontWeight.w700)),
    ),
  );
}

// ── Bar chart ─────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<double> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((v) {
          final ratio = v / max;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              height: (ratio * 120).clamp(8.0, 120.0),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: kBrown, width: 2),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8))),
            ),
          ));
        }).toList(),
      ),
    );
  }
}

// ── Barista card — shows branch photo ────────────────────
class _BaristaCard extends StatelessWidget {
  final String name, branchName, branchImage;
  final VoidCallback onDelete;
  const _BaristaCard({required this.name, required this.branchName,
      required this.branchImage, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 6, offset: const Offset(0, 2))]),
    child: Row(children: [

      // Branch photo (same image from FindBaristaScreen)
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _BranchThumb(imagePath: branchImage, size: 52),
      ),
      const SizedBox(width: 12),

      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontFamily: 'LeagueSpartan',
              color: kBrown, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(branchName, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.5), fontSize: 11)),
        ],
      )),

      GestureDetector(
        onTap: onDelete,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
      ),
    ]),
  );
}

// ── Shared branch thumbnail ───────────────────────────────
class _BranchThumb extends StatelessWidget {
  final String imagePath;
  final double size;
  const _BranchThumb({required this.imagePath, this.size = double.infinity});

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (imagePath.isEmpty) {
      img = _placeholder();
    } else if (imagePath.startsWith('http')) {
      img = Image.network(imagePath,
          width: size == double.infinity ? double.infinity : size,
          height: size == double.infinity ? double.infinity : size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    } else {
      img = Image.asset(imagePath,
          width: size == double.infinity ? double.infinity : size,
          height: size == double.infinity ? double.infinity : size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    if (size != double.infinity) {
      return SizedBox(width: size, height: size, child: img);
    }
    return img;
  }

  Widget _placeholder() => Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      color: kInputBg,
      child: const Icon(Icons.storefront_outlined,
          color: kBrownLight, size: 28));
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      errorStyle: const TextStyle(fontFamily: 'LeagueSpartan',
          color: Colors.redAccent, fontSize: 11),
    ),
  );
}