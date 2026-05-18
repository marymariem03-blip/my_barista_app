import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import '../core/services/cloudinary_service.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl   = TextEditingController();
  final _picker    = ImagePicker();

  String     _avatarUrl   = '';
  XFile?     _pickedXFile;
  Uint8List? _pickedBytes;

  bool    _loading       = true;
  bool    _saving        = false;
  bool    _uploadingPhoto = false;
  bool    _editMode      = false;
  String? _errorMsg;
  String? _successMsg;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }

    final data = await FirebaseService.getUser(uid);
    if (mounted) {
      setState(() {
        _nameCtrl.text  = data?['nom']    as String? ?? '';
        _emailCtrl.text = data?['email']  as String? ?? '';
        _phoneCtrl.text = data?['phone']  as String? ?? '';
        _dobCtrl.text   = data?['dob']    as String? ?? '';
        _avatarUrl      = data?['avatar'] as String? ?? '';
        _loading        = false;
      });
    }
  }

  Future<void> _pickAvatar() async {
    if (!_editMode) return;
    try {
      final picked = await _picker.pickImage(
        source:       ImageSource.gallery,
        maxWidth:     600,
        maxHeight:    600,
        imageQuality: 70,
      );
      if (picked != null && mounted) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedXFile = picked;
          _pickedBytes = bytes;
          _errorMsg    = null;
        });
      }
    } catch (e) {
      _showSnack('Impossible d\'acceder a la galerie: $e');
    }
  }

  Future<void> _save() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final dob   = _dobCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() => _errorMsg = 'Nom et email sont requis.');
      return;
    }

    setState(() {
      _saving   = true;
      _errorMsg = null;
      _successMsg = null;
    });

    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) {
      setState(() { _saving = false; _errorMsg = 'Utilisateur non connecte.'; });
      return;
    }

    // ── Step 1: Upload photo if picked ──────────────────
    String finalAvatarUrl = _avatarUrl;

    if (_pickedXFile != null && _pickedBytes != null) {
      setState(() => _uploadingPhoto = true);

      try {
        String uploadedUrl;

        if (kIsWeb) {
          // Web: upload bytes
          uploadedUrl = await CloudinaryService.uploadAvatarBytes(
            bytes:    _pickedBytes!,
            fileName: _pickedXFile!.name,
          );
        } else {
          // Mobile: upload file
          uploadedUrl = await CloudinaryService.uploadAvatar(
            File(_pickedXFile!.path),
          );
        }

        // ✅ Upload succeeded
        finalAvatarUrl = uploadedUrl;
        debugPrint('✅ Avatar uploaded: $finalAvatarUrl');

      } catch (e) {
        debugPrint('❌ Avatar upload failed: $e');
        if (mounted) {
          setState(() {
            _uploadingPhoto = false;
            _saving         = false;
            _errorMsg       = 'Upload photo echoue: ${e.toString()}';
          });
        }
        return; // ← stop here, don't save with broken photo
      }

      setState(() => _uploadingPhoto = false);
    }

    // ── Step 2: Save text fields + avatar URL ───────────
    try {
      // Save nom + email
      await FirebaseService.updateUserProfile(
        uid:   uid,
        nom:   name,
        email: email,
      );

      // Save phone + dob + avatar URL
      await FirebaseService.updateUserExtra(
        uid:    uid,
        phone:  phone,
        dob:    dob,
        avatar: finalAvatarUrl,
      );

      debugPrint('✅ Profile saved. Avatar URL: $finalAvatarUrl');

      if (mounted) {
        setState(() {
          _avatarUrl      = finalAvatarUrl;
          _pickedXFile    = null;
          _pickedBytes    = null;
          _saving         = false;
          _editMode       = false;
          _successMsg     = 'Profil mis a jour avec succes !';
        });
      }
    } catch (e) {
      debugPrint('❌ Firestore save failed: $e');
      if (mounted) {
        setState(() {
          _saving   = false;
          _errorMsg = 'Erreur Firestore: ${e.toString()}';
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _editMode       = false;
      _pickedXFile    = null;
      _pickedBytes    = null;
      _errorMsg       = null;
      _successMsg     = null;
    });
    _loadProfile();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'LeagueSpartan')),
      backgroundColor: kBrown,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _buildAvatar() {
    const size = 110.0;
    Widget imageWidget;

    if (_pickedBytes != null) {
      // Local preview
      imageWidget = Image.memory(_pickedBytes!,
          width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (ctx, e, s) => _defaultAvatar());
    } else if (_avatarUrl.isNotEmpty &&
        CloudinaryService.isNetworkUrl(_avatarUrl)) {
      // Cloudinary URL — ValueKey forces reload when URL changes
      imageWidget = Image.network(_avatarUrl,
          key: ValueKey(_avatarUrl),
          width: size, height: size, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(width: size, height: size, color: kInputBg,
                child: const Center(child: CircularProgressIndicator(
                    color: kBrown, strokeWidth: 2)));
          },
          errorBuilder: (ctx, e, s) => _defaultAvatar());
    } else {
      imageWidget = Image.asset('assets/images/pic.png',
          width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (ctx, e, s) => _defaultAvatar());
    }

    return GestureDetector(
      onTap: _editMode ? _pickAvatar : null,
      child: Stack(children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(color: kInputBg,
              borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(borderRadius: BorderRadius.circular(16),
              child: imageWidget),
        ),
        // Upload spinner overlay
        if (_uploadingPhoto)
          Positioned.fill(child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))),
          )),
        // Edit overlay
        if (_editMode && !_uploadingPhoto)
          Positioned.fill(child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(color: Colors.black38,
                child: const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 28),
                    SizedBox(height: 4),
                    Text('Changer', style: TextStyle(fontFamily: 'LeagueSpartan',
                        color: Colors.white, fontSize: 11)),
                  ],
                ))),
          )),
        // Camera badge
        Positioned(bottom: 0, right: 0,
          child: Container(width: 32, height: 32,
            decoration: BoxDecoration(
                color: _editMode ? kBrownLight : kBrown,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)),
            child: const Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 16)),
        ),
      ]),
    );
  }

  Widget _defaultAvatar() =>
      const Icon(Icons.person, color: kBrownLight, size: 60);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(color: kBrown,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _NavBtn(path: 'assets/icons/home.png', fallback: Icons.home_rounded,
              onTap: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
                  (r) => false)),
          _NavBtn(path: 'assets/icons/order.png',
              fallback: Icons.receipt_long_outlined,
              onTap: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 1)),
                  (r) => false)),
          _NavBtn(path: 'assets/icons/cup.png',
              fallback: Icons.local_cafe_outlined,
              onTap: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
                  (r) => false)),
        ]),
      ),
      body: Column(children: [

        // ── Header ────────────────────────────────────
        Container(
          width: double.infinity, color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 20),
          child: Stack(alignment: Alignment.center, children: [
            Align(alignment: Alignment.centerLeft,
                child: GestureDetector(onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 34))),
            const Text('My profile', style: TextStyle(
                fontFamily: 'LeagueSpartan', color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.w800)),
            Align(alignment: Alignment.centerRight,
              child: _editMode
                  ? GestureDetector(onTap: _cancelEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white24,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Annuler', style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: Colors.white, fontSize: 13))))
                  : GestureDetector(
                      onTap: () => setState(() {
                        _editMode = true; _successMsg = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white24,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min,
                            children: [
                          Icon(Icons.edit_outlined,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Modifier', style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: Colors.white, fontSize: 13)),
                        ]))),
            ),
          ]),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kBrown))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Center(child: _buildAvatar()),
                      const SizedBox(height: 8),
                      Center(child: Text(
                        _uploadingPhoto
                            ? 'Upload en cours...'
                            : _pickedBytes != null
                                ? '✓ Nouvelle photo selectionnee'
                                : _editMode
                                    ? 'Appuyer pour changer la photo'
                                    : '',
                        style: TextStyle(fontFamily: 'LeagueSpartan',
                            color: _uploadingPhoto
                                ? kBrown
                                : _pickedBytes != null
                                    ? Colors.green.shade700
                                    : kBrown.withOpacity(0.5),
                            fontSize: 11),
                      )),
                      const SizedBox(height: 24),

                      // Success
                      if (_successMsg != null) ...[
                        Container(width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.3))),
                          child: Row(children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_successMsg!,
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.green, fontSize: 13))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Error
                      if (_errorMsg != null) ...[
                        Container(width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.2))),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMsg!,
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.red, fontSize: 13))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Fields
                      const _FieldLabel('Full Name'),
                      const SizedBox(height: 8),
                      _editMode
                          ? _EditField(controller: _nameCtrl,
                              hint: 'Votre nom complet')
                          : _ReadOnlyField(value: _nameCtrl.text.isEmpty
                              ? '—' : _nameCtrl.text),
                      const SizedBox(height: 20),

                      const _FieldLabel('Date of Birth'),
                      const SizedBox(height: 8),
                      _editMode
                          ? _EditField(controller: _dobCtrl,
                              hint: 'DD / MM / YYYY',
                              keyboardType: TextInputType.datetime)
                          : _ReadOnlyField(value: _dobCtrl.text.isEmpty
                              ? '—' : _dobCtrl.text),
                      const SizedBox(height: 20),

                      const _FieldLabel('Email'),
                      const SizedBox(height: 8),
                      _editMode
                          ? _EditField(controller: _emailCtrl,
                              hint: 'example@example.com',
                              keyboardType: TextInputType.emailAddress)
                          : _ReadOnlyField(value: _emailCtrl.text.isEmpty
                              ? '—' : _emailCtrl.text),
                      const SizedBox(height: 20),

                      const _FieldLabel('Phone Number'),
                      const SizedBox(height: 8),
                      _editMode
                          ? _EditField(controller: _phoneCtrl,
                              hint: '+216 XX XXX XXX',
                              keyboardType: TextInputType.phone)
                          : _ReadOnlyField(value: _phoneCtrl.text.isEmpty
                              ? '—' : _phoneCtrl.text),
                      const SizedBox(height: 48),

                      if (_editMode)
                        _saving
                            ? Column(children: [
                                const Center(child: CircularProgressIndicator(
                                    color: kBrown)),
                                const SizedBox(height: 8),
                                Center(child: Text(
                                  _uploadingPhoto
                                      ? 'Upload de la photo...'
                                      : 'Sauvegarde en cours...',
                                  style: TextStyle(fontFamily: 'LeagueSpartan',
                                      color: kBrown.withOpacity(0.6),
                                      fontSize: 12),
                                )),
                              ])
                            : PrimaryButton(
                                label: 'Save Changes', onTap: _save),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _EditField({required this.controller, required this.hint,
      this.keyboardType = TextInputType.text});
  @override Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboardType,
    style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 15),
    decoration: InputDecoration(hintText: hint,
        hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown.withOpacity(0.35), fontSize: 15),
        filled: true, fillColor: kInputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: kBrown.withOpacity(0.4), width: 1.5))),
  );
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField({required this.value});
  @override Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(color: kInputBg,
        borderRadius: BorderRadius.circular(32)),
    child: Text(value, style: const TextStyle(fontFamily: 'LeagueSpartan',
        color: kBrown, fontSize: 15, fontWeight: FontWeight.w500)),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown,
          fontSize: 16, fontWeight: FontWeight.w700));
}

class _NavBtn extends StatelessWidget {
  final String path; final IconData fallback; final VoidCallback onTap;
  const _NavBtn({required this.path, required this.fallback, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(8),
        child: Image.asset(path, width: 28, height: 28, color: Colors.white38,
            errorBuilder: (ctx, e, s) =>
                Icon(fallback, color: Colors.white38, size: 28))),
  );
}