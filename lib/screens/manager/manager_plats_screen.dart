// lib/screens/manager/manager_plats_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/plat.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/firebase_plat_service.dart';
import '../../core/services/cloudinary_service.dart';
import 'manager_add_edit_plat_screen.dart';

class ManagerPlatsScreen extends StatefulWidget {
  const ManagerPlatsScreen({super.key});
  @override State<ManagerPlatsScreen> createState() => _ManagerPlatsScreenState();
}

class _ManagerPlatsScreenState extends State<ManagerPlatsScreen> {
  final _service = ServiceLocator.platService;

  // ── Stream (only used when Firebase is active) ────────
  Stream<List<Plat>>? _stream;

  @override
  void initState() {
    super.initState();
    if (_service is FirebasePlatService) {
      _stream = (_service as FirebasePlatService).watchAll();
    }
  }

  void _openAdd() => Navigator.push(context, MaterialPageRoute(
      builder: (_) => ManagerAddEditPlatScreen(onSaved: () {})));

  void _openEdit(Plat plat) => Navigator.push(context, MaterialPageRoute(
      builder: (_) => ManagerAddEditPlatScreen(plat: plat, onSaved: () {})));

  void _confirmDelete(Plat plat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le plat', style: TextStyle(
            fontFamily: 'LeagueSpartan', color: kBrown, fontWeight: FontWeight.w800)),
        content: Text('Supprimer "${plat.name}" ?',
            style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown)),
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

    // If Firebase: drive UI from stream so it always reflects Firestore
    if (_stream != null) {
      return StreamBuilder<List<Plat>>(
        stream: _stream,
        builder: (context, snapshot) {
          final plats = snapshot.data ?? [];
          return _buildScaffold(topPad, plats);
        },
      );
    }

    // Fallback: fake/local service
    return _buildScaffold(topPad, _service.getAll());
  }

  Widget _buildScaffold(double topPad, List<Plat> plats) {
    return Column(children: [

      // ── Header ─────────────────────────────────────────
      Container(
        color: kBrown,
        padding: EdgeInsets.only(
            top: topPad + 14, left: 20, right: 20, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gestion des plats', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.w800)),
              Text('${plats.length} plat${plats.length == 1 ? '' : 's'}',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white.withOpacity(0.6), fontSize: 12)),
            ]),
            GestureDetector(
              onTap: _openAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.add, color: kBrown, size: 18),
                  SizedBox(width: 4),
                  Text('Ajouter', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── List ───────────────────────────────────────────
      Expanded(
        child: plats.isEmpty
            ? _EmptyState(onAdd: _openAdd)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: plats.length,
                itemBuilder: (_, i) => _PlatCard(
                  plat:     plats[i],
                  onEdit:   () => _openEdit(plats[i]),
                  onDelete: () => _confirmDelete(plats[i]),
                ),
              ),
      ),
    ]);
  }
}

// ── Plat card ─────────────────────────────────────────────
class _PlatCard extends StatelessWidget {
  final Plat plat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PlatCard({required this.plat, required this.onEdit, required this.onDelete});

  // Category badge colours
  Color get _catBg {
    switch (plat.category) {
      case 'hot_drinks':  return const Color(0xFFFFF3E0);
      case 'cold_drinks': return const Color(0xFFE3F2FD);
      case 'sweet':       return const Color(0xFFFCE4EC);
      case 'savory':      return const Color(0xFFE8F5E9);
      default:            return kInputBg;
    }
  }

  Color get _catColor {
    switch (plat.category) {
      case 'hot_drinks':  return const Color(0xFFE65100);
      case 'cold_drinks': return const Color(0xFF1565C0);
      case 'sweet':       return const Color(0xFFC62828);
      case 'savory':      return Colors.green.shade700;
      default:            return kBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [

        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CloudinaryService.isNetworkUrl(plat.image)
              ? Image.network(plat.image,
                  width: 62, height: 62, fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(width: 62, height: 62, color: _catBg,
                        child: const Center(child: CircularProgressIndicator(
                            color: kBrown, strokeWidth: 1.5)));
                  },
                  errorBuilder: (_, __, ___) => _fallback())
              : Image.asset(plat.image,
                  width: 62, height: 62, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback()),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plat.name, style: const TextStyle(
                fontFamily: 'LeagueSpartan', color: kBrown,
                fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Row(children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: _catBg,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(plat.categoryLabel, style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: _catColor,
                    fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(plat.formattedPrice, style: const TextStyle(
                  fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 13, fontWeight: FontWeight.w700)),
              if (plat.isBestSeller) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star, color: Colors.amber, size: 14),
              ],
            ]),
          ],
        )),

        // Actions
        Column(children: [
          _ActionBtn(icon: Icons.edit_outlined,
              color: kInputBg, iconColor: kBrown, onTap: onEdit),
          const SizedBox(height: 6),
          _ActionBtn(icon: Icons.delete_outline,
              color: Colors.red.withOpacity(0.1),
              iconColor: Colors.red, onTap: onDelete),
        ]),
      ]),
    );
  }

  Widget _fallback() => Container(width: 62, height: 62,
      color: _catBg,
      child: Icon(Icons.fastfood_outlined, color: _catColor, size: 28));
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color,
      required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 34, height: 34,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 18)),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) =>
      Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined,
              size: 90, color: kBrown.withOpacity(0.15)),
          const SizedBox(height: 20),
          Text('Aucun plat', style: TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrown.withOpacity(0.5),
              fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Ajoutez votre premier plat', style: TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrown.withOpacity(0.4), fontSize: 14)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 13),
              decoration: BoxDecoration(
                  color: kBrown,
                  borderRadius: BorderRadius.circular(32)),
              child: const Text('Ajouter un plat', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ));
}