import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/service_locator.dart';
import '../page2_login_screen.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});
  @override State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final _service = ServiceLocator.platService;

  bool   _editMode = false;
  bool   _saving   = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late String _selectedAvatar;

  static const _avatars = ['☕', '🧑‍💼', '👩‍💼', '🧑‍🍳', '👨‍🍳', '⭐'];

  @override
  void initState() {
    super.initState();
    _nameCtrl       = TextEditingController(text: _service.managerName);
    _emailCtrl      = TextEditingController(text: _service.managerEmail);
    _selectedAvatar = _service.managerAvatarAsset.isEmpty ? '☕' : _service.managerAvatarAsset;
  }

  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  void _toggleEdit() {
    if (_editMode) {
      setState(() => _saving = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        _service.updateManagerProfile(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), avatarAsset: _selectedAvatar);
        if (mounted) setState(() { _saving = false; _editMode = false; });
      });
    } else {
      setState(() => _editMode = true);
    }
  }

  void _cancelEdit() {
    setState(() {
      _nameCtrl.text  = _service.managerName;
      _emailCtrl.text = _service.managerEmail;
      _selectedAvatar = _service.managerAvatarAsset.isEmpty ? '☕' : _service.managerAvatarAsset;
      _editMode = false;
    });
  }

  void _showAvatarPicker() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Choisir un avatar', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _avatars.map((av) {
          final isSel = av == _selectedAvatar;
          return GestureDetector(
            onTap: () { setState(() => _selectedAvatar = av); Navigator.pop(context); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 54, height: 54,
              decoration: BoxDecoration(color: isSel ? kBrown : kInputBg, shape: BoxShape.circle, border: Border.all(color: isSel ? kBrown : Colors.transparent, width: 2)),
              child: Center(child: Text(av, style: const TextStyle(fontSize: 26))),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),
      ]),
    ));
  }

  void _showLogout() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 20),
        const Text('Se deconnecter ?', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Vous serez redirige vers la connexion.', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown.withOpacity(0.55), fontSize: 13)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(height: 50, decoration: BoxDecoration(color: kInputBg, borderRadius: BorderRadius.circular(32)), alignment: Alignment.center, child: const Text('Annuler', style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 16, fontWeight: FontWeight.w700))))),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () { Navigator.pop(context); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false); },
            child: Container(height: 50, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(32)), alignment: Alignment.center, child: const Text('Deconnecter', style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
          )),
        ]),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(children: [
      // ── Header ───────────────────────────────────────
      Container(
        color: kBrown,
        padding: EdgeInsets.only(top: topPad + 14, left: 20, right: 20, bottom: 28),
        child: Column(children: [
          // Edit / Save / Cancel row
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (_editMode) GestureDetector(onTap: _cancelEdit, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: const Text('Annuler', style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white, fontSize: 12)),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _toggleEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: _editMode ? Colors.white : Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _saving
                      ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _editMode ? kBrown : Colors.white))
                      : Icon(_editMode ? Icons.check : Icons.edit_outlined, color: _editMode ? kBrown : Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(_editMode ? 'Enregistrer' : 'Modifier', style: TextStyle(fontFamily: 'LeagueSpartan', color: _editMode ? kBrown : Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Avatar
          Stack(children: [
            Container(width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 2)),
                child: Center(child: Text(_selectedAvatar, style: const TextStyle(fontSize: 36)))),
            if (_editMode) Positioned(bottom: 0, right: 0, child: GestureDetector(
              onTap: _showAvatarPicker,
              child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: kBrown, size: 14)),
            )),
          ]),
          const SizedBox(height: 12),

          // Name
          _editMode
              ? _HeaderField(controller: _nameCtrl, hint: 'Votre nom')
              : Text(_service.managerName, style: const TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),

          // Email
          _editMode
              ? _HeaderField(controller: _emailCtrl, hint: 'Votre email', small: true)
              : Text(_service.managerEmail, style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white.withOpacity(0.6), fontSize: 13)),
        ]),
      ),

      // ── Content ──────────────────────────────────────
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Stats
            Row(children: [
              Expanded(child: _StatMini(label: 'Plats', value: '${_service.totalPlats}', icon: Icons.restaurant_menu_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _StatMini(label: 'Commandes', value: '${_service.totalFakeOrders}', icon: Icons.receipt_long_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _StatMini(label: 'Ventes DT', value: _service.totalFakeSales.toStringAsFixed(0), icon: Icons.attach_money)),
            ]),
            const SizedBox(height: 16),

            // Info card
            _InfoCard(title: 'Informations', items: [
              _InfoRow(icon: Icons.person_outline, label: 'Nom', value: _service.managerName),
              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: _service.managerEmail),
              _InfoRow(icon: Icons.shield_outlined, label: 'Role', value: 'Manager'),
              _InfoRow(icon: Icons.info_outline, label: 'Version', value: '1.0.0'),
            ]),
            const SizedBox(height: 24),

            // Logout
            GestureDetector(
              onTap: _showLogout,
              child: Container(width: double.infinity, height: 52,
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.red.withOpacity(0.3))),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Se deconnecter', style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700)),
                  ])),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _HeaderField extends StatelessWidget {
  final TextEditingController controller; final String hint; final bool small;
  const _HeaderField({required this.controller, required this.hint, this.small = false});
  @override Widget build(BuildContext context) => Container(
    width: 220,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
    child: TextField(controller: controller, textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white, fontSize: small ? 13 : 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontFamily: 'LeagueSpartan', color: Colors.white54, fontSize: small ? 13 : 16), border: InputBorder.none, isDense: true)),
  );
}

class _StatMini extends StatelessWidget {
  final String label; final String value; final IconData icon;
  const _StatMini({required this.label, required this.value, required this.icon});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]),
    child: Column(children: [
      Icon(icon, color: kBrown, size: 22), const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 2),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown.withOpacity(0.5), fontSize: 10)),
    ]),
  );
}

class _InfoCard extends StatelessWidget {
  final String title; final List<_InfoRow> items;
  const _InfoCard({required this.title, required this.items});
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: Text(title, style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 14, fontWeight: FontWeight.w800))),
      Divider(color: kBrown.withOpacity(0.08), height: 1),
      ...items.map((item) => Column(children: [item, if (item != items.last) Divider(color: kBrown.withOpacity(0.06), height: 1, indent: 52)])),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: kInputBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: kBrown, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown.withOpacity(0.5), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 14, fontWeight: FontWeight.w600)),
      ])),
    ]),
  );
}