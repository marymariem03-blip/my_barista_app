// lib/screens/manager/manager_plats_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/models/plat.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/cloudinary_service.dart';
import 'manager_add_edit_plat_screen.dart';

class ManagerPlatsScreen extends StatefulWidget {
  const ManagerPlatsScreen({super.key});
  @override State<ManagerPlatsScreen> createState() =>
      _ManagerPlatsScreenState();
}

class _ManagerPlatsScreenState extends State<ManagerPlatsScreen> {
  final _service = ServiceLocator.platService;

  final Stream<QuerySnapshot> _rawStream =
      FirebaseFirestore.instance.collection('consommables').snapshots();

  String _selectedCat = 'all';
  String _searchQuery = '';
  final _searchCtrl   = TextEditingController();

  static const _tabs = [
    _Tab('all',         'All'),
    _Tab('hot_drinks',  'Hot Drinks'),
    _Tab('cold_drinks', 'Cold Drinks'),
    _Tab('sweet',       'Sweet'),
    _Tab('savory',      'Savory'),
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static double _parsePrice(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  List<Plat> _parseDocs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Plat(
        id:           doc.id,
        name:         data['nom']         as String? ?? '',
        category:     (data['categorie'] ?? data['catagorie'] ?? 'hot_drinks') as String,
        price:        _parsePrice(data['prix']),
        image:        data['image']       as String? ?? '',
        description:  data['description'] as String? ?? '',
        isBestSeller: data['isBestSeller'] as bool? ?? false,
      );
    }).toList();
  }

  List<Plat> _applyFilters(List<Plat> all) {
    var list = _selectedCat == 'all'
        ? all
        : all.where((p) => p.category == _selectedCat).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) =>
          p.name.toLowerCase().contains(_searchQuery) ||
          p.description.toLowerCase().contains(_searchQuery)).toList();
    }
    return list;
  }

  void _openAdd() => Navigator.push(context, MaterialPageRoute(
      builder: (_) => ManagerAddEditPlatScreen(onSaved: () {})));

  void _openEdit(Plat plat) => Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
          ManagerAddEditPlatScreen(plat: plat, onSaved: () {})));

  void _confirmDelete(Plat plat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le plat',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown, fontWeight: FontWeight.w800)),
        content: Text('Supprimer "${plat.name}" ?',
            style: const TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown)),
          ),
          TextButton(
            onPressed: () {
              _service.delete(plat.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return StreamBuilder<QuerySnapshot>(
      stream: _rawStream,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _shell(topPad,
              child: const Center(child: CircularProgressIndicator(
                  color: kBrown)));
        }

        if (snapshot.hasError) {
          return _shell(topPad,
              child: Center(child: Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.red, fontSize: 13))));
        }

        final allPlats = _parseDocs(snapshot.data?.docs ?? []);
        final filtered = _applyFilters(allPlats);

        if (allPlats.isEmpty) {
          return _shell(topPad, child: _EmptyState(onAdd: _openAdd));
        }

        return _shell(topPad,
          child: Column(children: [
            const SizedBox(height: 16),

            // ── Category pills ──────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tab    = _tabs[i];
                  final active = _selectedCat == tab.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCat = tab.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                          color: active ? kBrown : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active ? kBrown : Colors.black26,
                              width: 1.2)),
                      child: Text(tab.label,
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: active
                                  ? Colors.white
                                  : kBrown.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Search + Add ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(21)),
                    child: Row(children: [
                      const SizedBox(width: 12),
                      Expanded(child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.4),
                              fontSize: 13),
                          border: InputBorder.none, isDense: true,
                        ),
                      )),
                      Container(
                        width: 32, height: 32,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(
                            color: kBrown, shape: BoxShape.circle),
                        child: const Icon(Icons.search,
                            color: Colors.white, size: 17),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openAdd,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(21)),
                    child: const Row(children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text('Ajouter Un Plat',
                          style: TextStyle(fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),

            // ── List ────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text('Aucun résultat',
                      style: TextStyle(fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.4), fontSize: 15)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                          color: kBrown.withOpacity(0.1),
                          height: 1, thickness: 1),
                      itemBuilder: (_, i) => _PlatCard(
                        plat:     filtered[i],
                        onEdit:   () => _openEdit(filtered[i]),
                        onDelete: () => _confirmDelete(filtered[i]),
                      ),
                    ),
            ),
          ]),
        );
      },
    );
  }

  Widget _shell(double topPad, {required Widget child}) {
    return Scaffold(
      backgroundColor: kBrown,
      body: Column(children: [
        // Brown header
        Padding(
          padding: EdgeInsets.only(
              top: topPad + 14, left: 12, right: 12, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            const Text('Gestion des plats',
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
        // White rounded body
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        ),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: kBg,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/dish.png',
              width:  size.width * 0.55,
              height: size.width * 0.55,
              color:  kBrown.withOpacity(0.2),
              errorBuilder: (_, __, ___) => Icon(
                  Icons.dinner_dining_outlined,
                  size: size.width * 0.45,
                  color: kBrown.withOpacity(0.2))),
          SizedBox(height: size.height * 0.04),
          Text('Aucun Plat',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.65),
                  fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Ajouter votre premier plat',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.4), fontSize: 14)),
          SizedBox(height: size.height * 0.05),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                  color: kBrown,
                  borderRadius: BorderRadius.circular(32)),
              alignment: Alignment.center,
              child: const Text('Ajouter un plat',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plat card ─────────────────────────────────────────────
class _PlatCard extends StatelessWidget {
  final Plat plat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PlatCard({required this.plat, required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImage(),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plat.name,
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown, fontSize: 14,
                    fontWeight: FontWeight.w700)),
            if (plat.description.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(plat.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: kBrown.withOpacity(0.5),
                      fontSize: 11, height: 1.3)),
            ],
            const SizedBox(height: 4),
            Text(plat.formattedPrice,
                style: TextStyle(fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.8),
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        )),

        // Edit + Delete
        Column(children: [
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined,
                color: Colors.green, size: 22)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: Colors.red, size: 22)),
        ]),
      ]),
    );
  }

  Widget _buildImage() {
    const w = 72.0; const h = 72.0;
    final ph = Container(width: w, height: h, color: kInputBg,
        child: Icon(Icons.fastfood_outlined,
            color: kBrown.withOpacity(0.2), size: 32));

    if (CloudinaryService.isNetworkUrl(plat.image)) {
      return CachedNetworkImage(
          imageUrl: plat.image, width: w, height: h, fit: BoxFit.cover,
          placeholder: (_, __) => Container(width: w, height: h,
              color: kInputBg,
              child: const Center(child: CircularProgressIndicator(
                  color: kBrown, strokeWidth: 1.5))),
          errorWidget: (_, __, ___) => ph);
    }
    return Image.asset(plat.image, width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ph);
  }
}

class _Tab {
  final String key;
  final String label;
  const _Tab(this.key, this.label);
}