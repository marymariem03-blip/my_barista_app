import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/colors.dart';
import '../page2_login_screen.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});
  @override State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _name   = '';
  String _email  = '';
  String _avatar = '';
  bool   _loading = true;
  bool   _editMode = false;
  bool   _saving   = false;

  late TextEditingController _nameCtrl;
  File?       _pickedImage;
  Uint8List?  _imageBytes;

  static const _cloudName    = 'dme1fc8qw';
  static const _uploadPreset = 'my_barista_preset';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    final doc = await _db.collection('users').doc(uid).get();
    if (mounted) setState(() {
      final data = doc.data() ?? {};
      _name   = (data['nom']    as String?) ?? '';
      _email  = (data['email']  as String?) ?? _auth.currentUser?.email ?? '';
      _avatar = (data['avatar'] as String?) ?? '';
      _nameCtrl.text = _name;
      _loading = false;
    });
  }

  // ── Pick image ────────────────────────────────────────
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() { _imageBytes = bytes; _pickedImage = null; });
    } else {
      setState(() { _pickedImage = File(picked.path); _imageBytes = null; });
    }
  }

  // ── Upload to Cloudinary ──────────────────────────────
  Future<String?> _uploadImage() async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset;
    if (kIsWeb && _imageBytes != null) {
      req.files.add(http.MultipartFile.fromBytes(
          'file', _imageBytes!, filename: 'profile.jpg'));
    } else if (_pickedImage != null) {
      req.files.add(await http.MultipartFile.fromPath('file', _pickedImage!.path));
    } else {
      return null;
    }
    final res = await req.send();
    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['secure_url'] as String?;
    }
    return null;
  }

  // ── Save ──────────────────────────────────────────────
  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);

    try {
      String finalAvatar = _avatar;

      if (_pickedImage != null || _imageBytes != null) {
        final url = await _uploadImage();
        if (url != null) finalAvatar = url;
      }

      await _db.collection('users').doc(uid).set({
        'nom':    _nameCtrl.text.trim(),
        'email':  _email,
        'role':   'manager',
        'avatar': finalAvatar,
      }, SetOptions(merge: true));

      if (mounted) setState(() {
        _name   = _nameCtrl.text.trim();
        _avatar = finalAvatar;
        _pickedImage = null;
        _editMode = false;
        _saving   = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur: $e',
                style: const TextStyle(fontFamily: 'LeagueSpartan')),
            backgroundColor: Colors.red));
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _nameCtrl.text = _name;
      _pickedImage   = null;
      _imageBytes    = null;
      _editMode      = false;
    });
  }

  void _showLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.black12,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          const Text('Se déconnecter ?', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: kBrown,
              fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Vous serez redirigé vers la connexion.',
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(height: 50,
                  decoration: BoxDecoration(color: kInputBg,
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Annuler', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 15, fontWeight: FontWeight.w700))),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await _auth.signOut();
                if (mounted) Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false);
              },
              child: Container(height: 50,
                  decoration: BoxDecoration(color: Colors.red,
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Déconnecter', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontSize: 15, fontWeight: FontWeight.w700))),
            )),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    if (_loading) return const Center(
        child: CircularProgressIndicator(color: kBrown));

    // Avatar to show — picked image takes priority
    Widget avatarWidget;
    if (_imageBytes != null) {
      avatarWidget = Image.memory(_imageBytes!, fit: BoxFit.cover);
    } else if (_pickedImage != null) {
      avatarWidget = Image.file(_pickedImage!, fit: BoxFit.cover);
    } else if (_avatar.isNotEmpty) {
      avatarWidget = CachedNetworkImage(imageUrl: _avatar, fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.person,
              color: Colors.white54, size: 48));
    } else {
      avatarWidget = const Icon(Icons.person, color: Colors.white54, size: 48);
    }

    return Column(children: [

      // ── Dark header ───────────────────────────────────
      Container(
        color: kBrown,
        width: double.infinity,
        padding: EdgeInsets.only(
            top: topPad + 12, left: 20, right: 20, bottom: 32),
        child: Column(children: [

          // Top buttons row
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (_editMode) ...[
              GestureDetector(
                onTap: _cancelEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white24,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Annuler', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: _editMode ? _save : () => setState(() => _editMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: _editMode ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: _saving
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kBrown))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_editMode ? Icons.check : Icons.edit_outlined,
                            color: kBrown, size: 14),
                        const SizedBox(width: 5),
                        Text(_editMode ? 'Enregistrer' : 'Modifier',
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan', color: kBrown,
                                fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Avatar
          Stack(children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                color: Colors.white24,
              ),
              child: ClipOval(child: avatarWidget),
            ),
            if (_editMode)
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        color: kBrown, size: 16),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 14),

          // Name — editable in edit mode
          _editMode
              ? Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _nameCtrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Votre nom',
                        hintStyle: TextStyle(color: Colors.white54)),
                  ),
                )
              : Text(
                  (_name.isNotEmpty) ? _name : "Manager Barista's",
                  style: const TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
          const SizedBox(height: 4),

          // Email (not editable)
          Text(
            (_email.isNotEmpty) ? _email : 'manager@barista.com',
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
        ]),
      ),

      // ── Content ───────────────────────────────────────
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [

            // Info card
            Container(
              decoration: BoxDecoration(
                  color: kInputBg, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Text('Informations', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                _divider(),
                _InfoRowAsset(asset: 'assets/icons/profmanager.png',
                    fallback: Icons.person_outlined, label: 'Nom',
                    value: (_name.isNotEmpty) ? _name : '—'),
                _divider(indent: 64),
                _InfoRowAsset(asset: 'assets/icons/mail.png',
                    fallback: Icons.email_outlined, label: 'Email',
                    value: (_email.isNotEmpty) ? _email : '—'),
                _divider(indent: 64),
                _InfoRowAsset(asset: 'assets/icons/role.png',
                    fallback: Icons.shield_outlined, label: 'Role',
                    value: 'Manager'),
                _divider(indent: 64),
                _InfoRowAsset(asset: 'assets/icons/info.png',
                    fallback: Icons.info_outline, label: 'Version',
                    value: '1.0.0'),
              ]),
            ),
            const SizedBox(height: 32),

            // Log Out
            GestureDetector(
              onTap: _showLogout,
              child: Container(
                width: 180, height: 52,
                decoration: BoxDecoration(color: Colors.red,
                    borderRadius: BorderRadius.circular(32)),
                alignment: Alignment.center,
                child: const Text('Log Out', style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    ]);
  }

  Widget _divider({double indent = 0}) =>
      Divider(color: kBrown.withOpacity(0.08), height: 1, indent: indent);
}

// ── Info row with asset icon ─────────────────────────────
class _InfoRowAsset extends StatelessWidget {
  final String asset, label, value;
  final IconData fallback;
  const _InfoRowAsset({required this.asset, required this.label,
      required this.value, required this.fallback});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(children: [
      Container(width: 36, height: 36,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(7),
          child: Image.asset(asset, color: kBrown,
              errorBuilder: (_, __, ___) =>
                  Icon(fallback, color: kBrown, size: 18))),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown.withOpacity(0.5), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown, fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );
}