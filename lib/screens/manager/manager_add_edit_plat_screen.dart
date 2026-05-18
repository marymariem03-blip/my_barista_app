// lib/screens/manager/manager_add_edit_plat_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/models/plat.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/cloudinary_service.dart';

class ManagerAddEditPlatScreen extends StatefulWidget {
  final Plat? plat;
  final VoidCallback onSaved;
  const ManagerAddEditPlatScreen({
    super.key,
    this.plat,
    required this.onSaved,
  });

  @override
  State<ManagerAddEditPlatScreen> createState() =>
      _ManagerAddEditPlatScreenState();
}

class _ManagerAddEditPlatScreenState
    extends State<ManagerAddEditPlatScreen> {
  final _service   = ServiceLocator.platService;
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _picker    = ImagePicker();

  // ✅ Default to hot_drinks — matches the menu screen's first tab
  String  _category     = 'hot_drinks';
  bool    _isBestSeller = false;

  File?   _pickedFile;
  String  _imageUrl  = '';
  bool    _uploading = false;
  String? _uploadError;

  bool get _hasPickedFile => _pickedFile != null;
  bool get _hasNetworkUrl => CloudinaryService.isNetworkUrl(_imageUrl);
  bool get _isEdit        => widget.plat != null;

  // ✅ Categories now match the home screen menu tabs exactly
  static const _categories = [
    _CatOpt('hot_drinks',  'Hot Drinks',  Icons.coffee_outlined),
    _CatOpt('cold_drinks', 'Cold Drinks', Icons.local_drink_outlined),
    _CatOpt('sweet',       'Sweet',       Icons.cake_outlined),
    _CatOpt('savory',      'Savory',      Icons.restaurant_outlined),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text  = widget.plat!.name;
      _priceCtrl.text =
          widget.plat!.price.toStringAsFixed(3).replaceAll('.', ',');
      _category     = widget.plat!.category;
      _isBestSeller = widget.plat!.isBestSeller;
      _imageUrl     = widget.plat!.image;
    } else {
      _imageUrl = Plat.defaultImageFor(_category);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Pick image ────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source:       ImageSource.gallery,
        maxWidth:     800,
        maxHeight:    800,
        imageQuality: 60,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedFile  = File(picked.path);
          _uploadError = null;
        });
      }
    } catch (e) {
      if (mounted) _showSnack('Impossible d\'acceder a la galerie.');
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.black12,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          const Text('Image du plat', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: kBrown,
              fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _OptionTile(
                icon: Icons.photo_library_outlined, label: 'Galerie',
                onTap: () { Navigator.pop(context); _pickImage(); })),
            const SizedBox(width: 12),
            Expanded(child: _OptionTile(
                icon: Icons.image_outlined, label: 'Defaut',
                onTap: () { Navigator.pop(context); _showAssetPicker(); })),
          ]),
        ]),
      ),
    );
  }

  void _showAssetPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Images par defaut', style: TextStyle(
              fontFamily: 'LeagueSpartan', color: kBrown,
              fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: Plat.availableImages.length,
            itemBuilder: (_, i) {
              final img   = Plat.availableImages[i];
              final isSel = img == _imageUrl && !_hasPickedFile;
              return GestureDetector(
                onTap: () {
                  setState(() { _imageUrl = img; _pickedFile = null; });
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSel ? kBrown : Colors.transparent,
                        width: 2.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(img, fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) => Container(
                            color: kInputBg,
                            child: const Icon(Icons.image_outlined,
                                color: kBrownLight, size: 20))),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _onCategoryChanged(String cat) {
    setState(() {
      _category = cat;
      if (!_isEdit && !_hasPickedFile && !_hasNetworkUrl) {
        _imageUrl = Plat.defaultImageFor(cat);
      }
    });
  }

  // ── Save ──────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name  = _nameCtrl.text.trim();
    final price = double.tryParse(
            _priceCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    setState(() { _uploading = true; _uploadError = null; });

    String finalImageUrl = _imageUrl;

    if (_hasPickedFile) {
      try {
        finalImageUrl =
            await CloudinaryService.uploadPlatImage(_pickedFile!);
      } on CloudinaryException catch (e) {
        if (mounted) setState(() { _uploading = false; _uploadError = e.message; });
        return;
      } catch (e) {
        if (mounted) setState(() { _uploading = false; _uploadError = 'Erreur: $e'; });
        return;
      }
    }

    try {
      if (_isEdit) {
        _service.update(id: widget.plat!.id, name: name, price: price,
            category: _category, image: finalImageUrl, isBestSeller: _isBestSeller);
      } else {
        _service.add(name: name, price: price,
            category: _category, image: finalImageUrl, isBestSeller: _isBestSeller);
      }
    } catch (e) {
      if (mounted) setState(() { _uploading = false; _uploadError = 'Erreur Firestore: $e'; });
      return;
    }

    if (!mounted) return;
    setState(() => _uploading = false);
    widget.onSaved();
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'LeagueSpartan')),
      backgroundColor: kBrown,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // Header
        Container(
          color: kBrown,
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
            Text(
              _isEdit ? 'Modifier le plat' : 'Ajouter un plat',
              style: const TextStyle(fontFamily: 'LeagueSpartan',
                  color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w800),
            ),
          ]),
        ),

        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Image ──────────────────────────
                    const _Label('Photo du plat'),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: _uploading ? null : _showImageOptions,
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildImagePreview(),
                          ),
                          if (_uploading)
                            Positioned.fill(child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Center(child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                            )),
                          if (!_uploading)
                            Positioned(bottom: 8, right: 8,
                              child: Container(width: 36, height: 36,
                                decoration: BoxDecoration(
                                    color: kBrown, shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 18)),
                            ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(child: Text(
                      _uploading
                          ? 'Upload en cours...'
                          : _hasPickedFile
                              ? 'Image selectionnee — sera uploadee a la sauvegarde'
                              : 'Appuyer pour changer l\'image',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: _uploading
                              ? kBrown
                              : _hasPickedFile
                                  ? Colors.green.shade700
                                  : kBrown.withOpacity(0.4),
                          fontSize: 11),
                    )),
                    if (_hasPickedFile && !_uploading) ...[
                      const SizedBox(height: 4),
                      Center(child: GestureDetector(
                        onTap: () => setState(() => _pickedFile = null),
                        child: Text('Annuler la selection',
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: Colors.red.withOpacity(0.6),
                                fontSize: 11,
                                decoration: TextDecoration.underline)),
                      )),
                    ],
                    if (_uploadError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_uploadError!,
                              style: const TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: Colors.red, fontSize: 12))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // ── Name ───────────────────────────
                    const _Label('Nom du plat'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _nameCtrl,
                      hint: 'Ex: Macchiato Pistachio',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Price ──────────────────────────
                    const _Label('Prix (DT)'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _priceCtrl,
                      hint: 'Ex: 11,500',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Champ requis';
                        final p = double.tryParse(v.trim().replaceAll(',', '.'));
                        if (p == null || p <= 0) return 'Prix invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Category ───────────────────────
                    const _Label('Categorie'),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                      children: _categories.map((cat) {
                        final sel = _category == cat.value;
                        return GestureDetector(
                          onTap: () => _onCategoryChanged(cat.value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                                color: sel ? kBrown : kInputBg,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(cat.icon,
                                    color: sel ? Colors.white
                                        : kBrown.withOpacity(0.5),
                                    size: 18),
                                const SizedBox(width: 6),
                                Text(cat.label,
                                    style: TextStyle(
                                        fontFamily: 'LeagueSpartan',
                                        color: sel ? Colors.white
                                            : kBrown.withOpacity(0.6),
                                        fontSize: 12,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.w400)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Best Seller ────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: kInputBg,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.star_outline, color: kBrown, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Best Seller',
                            style: TextStyle(fontFamily: 'LeagueSpartan',
                                color: kBrown, fontSize: 14,
                                fontWeight: FontWeight.w600))),
                        Switch(
                          value: _isBestSeller,
                          onChanged: (v) => setState(() => _isBestSeller = v),
                          activeColor: Colors.white,
                          activeTrackColor: kBrown,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 32),

                    // ── Save button ────────────────────
                    GestureDetector(
                      onTap: _uploading ? null : _save,
                      child: Container(
                        width: double.infinity, height: 52,
                        decoration: BoxDecoration(
                            color: _uploading
                                ? kBrown.withOpacity(0.5)
                                : kBrown,
                            borderRadius: BorderRadius.circular(32)),
                        alignment: Alignment.center,
                        child: _uploading
                            ? const SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _isEdit ? 'Mettre a jour' : 'Enregistrer',
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildImagePreview() {
    const w = 140.0;
    const h = 140.0;
    final placeholder = Container(width: w, height: h, color: kInputBg,
        child: const Icon(Icons.image_outlined, color: kBrownLight, size: 56));

    if (_hasPickedFile) {
      return Image.file(_pickedFile!, width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }
    if (CloudinaryService.isNetworkUrl(_imageUrl)) {
      return Image.network(_imageUrl, width: w, height: h, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(width: w, height: h, color: kInputBg,
                child: const Center(child: CircularProgressIndicator(
                    color: kBrown, strokeWidth: 2)));
          },
          errorBuilder: (_, __, ___) => placeholder);
    }
    return Image.asset(_imageUrl, width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder);
  }
}

// ── Helpers ───────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.label, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: kInputBg,
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Container(width: 48, height: 48,
            decoration: BoxDecoration(color: kBrown.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: kBrown, size: 24)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 15, fontWeight: FontWeight.w700));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const _Field({required this.controller, required this.hint,
      this.keyboardType = TextInputType.text, this.validator});
  @override Widget build(BuildContext context) => TextFormField(
    controller: controller, keyboardType: keyboardType, validator: validator,
    style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown, fontSize: 14),
    decoration: InputDecoration(hintText: hint,
        hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
            color: kBrown.withOpacity(0.35), fontSize: 14),
        filled: true, fillColor: kInputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        errorStyle: const TextStyle(fontFamily: 'LeagueSpartan', color: Colors.red)),
  );
}

class _CatOpt {
  final String value; final String label; final IconData icon;
  const _CatOpt(this.value, this.label, this.icon);
}