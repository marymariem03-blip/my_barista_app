// lib/core/services/cloudinary_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
class CloudinaryService {

  static const String _cloudName    = 'dme1fc8qw';
  static const String _uploadPreset = 'my_barista_preset';

  static const String _folderPlats    = 'my_barista/plats';
  static const String _folderAvatars  = 'my_barista/avatars';
  static const String _folderSipShare = 'my_barista/sip_share';

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // ════════════════════════════════════════════════════
  // MOBILE — File upload
  // ════════════════════════════════════════════════════

  static Future<String> uploadPlatImage(File file) =>
      _uploadFile(file: file, folder: _folderPlats);

  static Future<String> uploadAvatar(File file) =>
      _uploadFile(file: file, folder: _folderAvatars);

  static Future<String> uploadSipShareImage(File file) =>
      _uploadFile(file: file, folder: _folderSipShare);

  // ════════════════════════════════════════════════════
  // WEB — Bytes upload
  // ════════════════════════════════════════════════════

  static Future<String> uploadPlatImageBytes({
    required Uint8List bytes,
    required String fileName,
  }) =>
      _uploadBytes(bytes: bytes, fileName: fileName, folder: _folderPlats);

  //  This was missing — now added
  static Future<String> uploadAvatarBytes({
    required Uint8List bytes,
    required String fileName,
  }) =>
      _uploadBytes(bytes: bytes, fileName: fileName, folder: _folderAvatars);

  static Future<String> uploadSipShareBytes({
    required Uint8List bytes,
    required String fileName,
  }) =>
      _uploadBytes(bytes: bytes, fileName: fileName, folder: _folderSipShare);

  // ════════════════════════════════════════════════════
  // PRIVATE — File upload (mobile)
  // ════════════════════════════════════════════════════

  static Future<String> _uploadFile({
    required File file,
    required String folder,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder']        = folder;
      request.files.add(
          await http.MultipartFile.fromPath('file', file.path));
      return await _sendRequest(request);
    } on CloudinaryException { rethrow; }
    catch (e) { throw CloudinaryException('Upload error: $e'); }
  }

  // ════════════════════════════════════════════════════
  // PRIVATE — Bytes upload (web)
  // ════════════════════════════════════════════════════

  static Future<String> _uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder']        = folder;
      request.files.add(http.MultipartFile.fromBytes(
          'file', bytes, filename: fileName));
      return await _sendRequest(request);
    } on CloudinaryException { rethrow; }
    catch (e) { throw CloudinaryException('Upload error: $e'); }
  }

  // ════════════════════════════════════════════════════
  // PRIVATE — Send + parse response
  // ════════════════════════════════════════════════════

  static Future<String> _sendRequest(http.MultipartRequest request) async {
    final streamed = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () =>
          throw CloudinaryException('Timeout. Check your connection.'),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final url  = data['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        throw CloudinaryException('No URL returned.');
      }
      return url;
    } else {
      final error = json.decode(response.body);
      throw CloudinaryException(
          'Failed (${response.statusCode}): '
          '${error['error']?['message'] ?? 'Unknown error'}');
    }
  }

  // ════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════

  static bool isNetworkUrl(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  static bool isAsset(String path) => path.startsWith('assets/');

  static const String defaultPlaceholder = 'assets/images/macchiato.png';
}

// ── Custom exception ──────────────────────────────────
class CloudinaryException implements Exception {
  final String message;
  const CloudinaryException(this.message);
  @override String toString() => 'CloudinaryException: $message';
}