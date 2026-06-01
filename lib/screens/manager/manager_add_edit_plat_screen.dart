// lib/screens/manager/manager_add_edit_plat_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
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
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _picker    = ImagePicker();

  String _category     = 'hot_drinks';
  bool   _isBestSeller = false;

  File?      _pickedFile;
  Uint8List? _pickedBytes;
  String?    _pickedName;
  String     _imageUrl  = '';
  bool       _uploading = false;
  String?    _uploadError;

  bool get _hasPickedFile =>
      kIsWeb ? _pickedBytes != null : _pickedFile != null;
  bool get _hasNetworkUrl =>
      CloudinaryService.isNetworkUrl(_imageUrl);
  bool get _isEdit => widget.plat != null;

  static const _categories = [
    _CatOpt('hot_drinks',  'Hot Drinks',  'assets/icons/hdrinks.png',  Icons.coffee_outlined),
    _CatOpt('cold_drinks', 'Cold Drinks', 'assets/icons/cdrinks.png',  Icons.local_drink_outlined),
    _CatOpt('sweet',       'Sweet',       'assets/icons/sweet.png',    Icons.cake_outlined),
    _CatOpt('savory',      'Savory',      'assets/icons/savory.png',   Icons.restaurant_outlined),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text  = widget.plat!.name;
      _descCtrl.text  = widget.plat!.description;
      _priceCtrl.text =
          widget.plat!.price.toStringAsFixed(3).replaceAll('.', ',');
      _category       = widget.plat!.category;
      _isBestSeller   = widget.plat!.isBestSeller;
      _imageUrl       = widget.plat!.image;
    } else {
      _imageUrl = Plat.defaultImageFor(_category);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source:       ImageSource.gallery,
        maxWidth:     800,
        maxHeight:    800,
        imageQuality: 60,
      );
      if (picked == null || !mounted) return;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedBytes = bytes;
          _pickedName  = picked.name;
          _pickedFile  = null;
          _uploadError = null;
        });
      } else {
        setState(() {
          _pickedFile  = File(picked.path);
          _pickedBytes = null;
          _pickedName  = null;
          _uploadError = null;
        });
      }
    } catch (_) {
      if (mounted) _showSnack('Impossible d\'acceder a la galerie.');
    }
  }

  void _onCategoryChanged(String cat) {
    setState(() {
      _category = cat;
      if (!_isEdit && !_hasPickedFile && !_hasNetworkUrl) {
        _imageUrl = Plat.defaultImageFor(cat);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name  = _nameCtrl.text.trim();
    final desc  = _descCtrl.text.trim();
    final price = double.tryParse(
            _priceCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    setState(() { _uploading = true; _uploadError = null; });

    String finalImageUrl = _imageUrl;

    if (_hasPickedFile) {
      try {
        if (kIsWeb && _pickedBytes != null) {
          finalImageUrl = await CloudinaryService.uploadPlatImageBytes(
              bytes: _pickedBytes!, fileName: _pickedName ?? 'plat.jpg');
        } else if (_pickedFile != null) {
          finalImageUrl =
              await CloudinaryService.uploadPlatImage(_pickedFile!);
        }
      } on CloudinaryException catch (e) {
        if (mounted) setState(() {
          _uploading = false; _uploadError = e.message;
        });
        return;
      } catch (e) {
        if (mounted) setState(() {
          _uploading = false; _uploadError = 'Erreur: $e';
        });
        return;
      }
    }

    try {
      if (_isEdit) {
        _service.update(
            id: widget.plat!.id, name: name, price: price,
            category: _category, image: finalImageUrl,
            description: desc, isBestSeller: _isBestSeller);
      } else {
        _service.add(
            name: name, price: price, category: _category,
            image: finalImageUrl, description: desc,
            isBestSeller: _isBestSeller);
      }
    } catch (e) {
      if (mounted) setState(() {
        _uploading = false; _uploadError = 'Erreur Firestore: $e';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _uploading = false);
    widget.onSaved();
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'LeagueSpartan')),
      backgroundColor: kBrown,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Header ────────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 12, right: 12, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            Text(_isEdit ? 'Modifier le plat' : 'Ajouter un plat',
                style: const TextStyle(fontFamily: 'LeagueSpartan',
                    color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ]),
        ),

        // ── Form ──────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Image — centered, camera overlay ──
                  const _SectionLabel('Photo du plat'),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: _uploading ? null : _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildImagePreview(),
                          ),
                          if (_uploading)
                            Positioned.fill(child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius:
                                      BorderRadius.circular(20)),
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2)),
                            )),
                          // Camera icon overlay
                          Container(
                            width: 36, height: 36,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: kBrown,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2)),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(child: Text(
                    _uploading
                        ? 'Upload en cours...'
                        : _hasPickedFile
                            ? '✓ Image sélectionnée'
                            : 'Appuyer pour changer l\'image',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: _uploading
                            ? kBrown
                            : _hasPickedFile
                                ? Colors.green.shade700
                                : kBrown.withOpacity(0.45),
                        fontSize: 12),
                  )),
                  if (_hasPickedFile && !_uploading) ...[
                    const SizedBox(height: 4),
                    Center(child: GestureDetector(
                      onTap: () => setState(() {
                        _pickedFile  = null;
                        _pickedBytes = null;
                      }),
                      child: Text('Annuler',
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
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

                  // ── Nom ───────────────────────────────
                  const _SectionLabel('Nom du plat'),
                  const SizedBox(height: 8),
                  _PillField(
                    controller: _nameCtrl,
                    hint: 'Pistachio Macchiato',
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Description ───────────────────────
                  const _SectionLabel('Description'),
                  const SizedBox(height: 8),
                  _PillField(
                    controller: _descCtrl,
                    hint: 'Ex: Café, lait et sirop de pistache',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // ── Prix ──────────────────────────────
                  const _SectionLabel('Prix (DT)'),
                  const SizedBox(height: 8),
                  _PillField(
                    controller: _priceCtrl,
                    hint: '11,500',
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Champ requis';
                      final p = double.tryParse(
                          v.trim().replaceAll(',', '.'));
                      if (p == null || p <= 0) return 'Prix invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Catégorie — 2×2 grid with icons ───
                  const _SectionLabel('Catégorie'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    children: _categories.map((cat) {
                      final sel = _category == cat.value;
                      return GestureDetector(
                        onTap: () => _onCategoryChanged(cat.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                              color: sel ? kBrown : kInputBg,
                              borderRadius:
                                  BorderRadius.circular(16)),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              // Try asset icon first
                              Image.asset(cat.assetIcon,
                                  width: 24, height: 24,
                                  color: sel
                                      ? Colors.white
                                      : kBrown.withOpacity(0.5),
                                  errorBuilder: (_, __, ___) =>
                                      Icon(cat.fallback,
                                          color: sel
                                              ? Colors.white
                                              : kBrown.withOpacity(
                                                  0.5),
                                          size: 22)),
                              const SizedBox(width: 8),
                              Text(cat.label,
                                  style: TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      color: sel
                                          ? Colors.white
                                          : kBrown.withOpacity(0.6),
                                      fontSize: 13,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Best Seller ───────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      const Icon(Icons.star_outline,
                          color: kBrown, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Best Seller',
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kBrown, fontSize: 14,
                              fontWeight: FontWeight.w600))),
                      Switch(
                        value: _isBestSeller,
                        onChanged: (v) =>
                            setState(() => _isBestSeller = v),
                        activeColor: Colors.white,
                        activeTrackColor: kBrown,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // ── Save button — centered pill ────────
                  Center(
                    child: GestureDetector(
                      onTap: _uploading ? null : _save,
                      child: Container(
                        width: 180,
                        height: 52,
                        decoration: BoxDecoration(
                            color: _uploading
                                ? kBrown.withOpacity(0.5)
                                : kBrown,
                            borderRadius: BorderRadius.circular(32)),
                        alignment: Alignment.center,
                        child: _uploading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2))
                            : Text(
                                _isEdit ? 'Mettre à jour' : 'Ajouter',
                                style: const TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildImagePreview() {
    const w = 160.0;
    const h = 160.0;
    final placeholder = Container(
        width: w, height: h, color: kInputBg,
        child: const Icon(Icons.image_outlined,
            color: kBrownLight, size: 56));

    if (kIsWeb && _pickedBytes != null) {
      return Image.memory(_pickedBytes!,
          width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }
    if (_pickedFile != null) {
      return Image.file(_pickedFile!,
          width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }
    if (CloudinaryService.isNetworkUrl(_imageUrl)) {
      return Image.network(_imageUrl,
          width: w, height: h, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(width: w, height: h, color: kInputBg,
                child: const Center(child: CircularProgressIndicator(
                    color: kBrown, strokeWidth: 2)));
          },
          errorBuilder: (_, __, ___) => placeholder);
    }
    return Image.asset(_imageUrl,
        width: w, height: h, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => placeholder);
  }
}

// ── Section label ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown, fontSize: 16, fontWeight: FontWeight.w700));
}

// ── Pill text field ───────────────────────────────────────
class _PillField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  const _PillField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller:   controller,
    keyboardType: keyboardType,
    validator:    validator,
    maxLines:     maxLines,
    style: const TextStyle(fontFamily: 'LeagueSpartan',
        color: kBrown, fontSize: 14),
    decoration: InputDecoration(
      hintText:       hint,
      hintStyle:      TextStyle(fontFamily: 'LeagueSpartan',
          color: kBrown.withOpacity(0.35), fontSize: 14),
      filled:         true,
      fillColor:      kInputBg,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none),
      errorStyle: const TextStyle(
          fontFamily: 'LeagueSpartan', color: Colors.red),
    ),
  );
}

// ── Category option ───────────────────────────────────────
class _CatOpt {
  final String   value;
  final String   label;
  final String   assetIcon;
  final IconData fallback;
  const _CatOpt(this.value, this.label, this.assetIcon, this.fallback);
}