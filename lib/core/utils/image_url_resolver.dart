import '../config/api_config.dart';

class ImageUrlResolver {
  static String resolve(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/api/') || url.startsWith('/uploads/')) {
      final base = ApiConfig.baseUrl;
      final serverRoot = base.endsWith('/api')
          ? base.substring(0, base.length - 4)
          : base;
      return '$serverRoot$url';
    }
    return url;
  }
}
