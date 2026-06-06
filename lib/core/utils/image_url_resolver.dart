import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/api_config.dart';

class ImageUrlResolver {
  static String resolve(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return trimmedUrl;

    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      if (kIsWeb) return trimmedUrl;
      final uri = Uri.tryParse(trimmedUrl);
      if (uri == null || (uri.host != 'localhost' && uri.host != '127.0.0.1')) {
        return trimmedUrl;
      }
      return uri.replace(host: '10.0.2.2').toString();
    }

    if (trimmedUrl.startsWith('/api/') || trimmedUrl.startsWith('/uploads/')) {
      final serverPath = trimmedUrl.startsWith('/uploads/')
          ? '/api$trimmedUrl'
          : trimmedUrl;
      final base = ApiConfig.baseUrl;
      if (kIsWeb) {
        final origin = Uri.base;
        return '${origin.scheme}://${origin.host}:${origin.port}$serverPath';
      }
      final serverRoot = base.endsWith('/api')
          ? base.substring(0, base.length - 4)
          : base;
      return '$serverRoot$serverPath';
    }

    return trimmedUrl;
  }

  static bool isServerImageUrl(String url) {
    final trimmedUrl = url.trim();
    return trimmedUrl.startsWith('http://') ||
        trimmedUrl.startsWith('https://') ||
        trimmedUrl.startsWith('/api/uploads/') ||
        trimmedUrl.startsWith('/uploads/');
  }
}
