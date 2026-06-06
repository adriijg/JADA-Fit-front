import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:jada_fit/core/network/auth_http_client.dart';
import 'package:jada_fit/core/storage/secure_storage_service.dart';

class FakeSecureStorage extends SecureStorageService {
  @override
  Future<String?> getToken() async => 'fake_test_token';

  @override
  Future<void> deleteToken() async {}
}

class EmptyStorage extends SecureStorageService {
  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> deleteToken() async {}
}

void main() {
  group('AuthHttpClient', () {
    tearDown(() {
      AuthHttpClient.onUnauthorized = null;
    });

    test('llama onUnauthorized al recibir 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final authClient = AuthHttpClient(
        client: mockClient,
        storageService: FakeSecureStorage(),
      );

      bool unauthorizedCalled = false;
      AuthHttpClient.onUnauthorized = () {
        unauthorizedCalled = true;
      };

      final response = await authClient.get(
        Uri.parse('http://example.com/test'),
      );

      expect(response.statusCode, 401);
      expect(unauthorizedCalled, isTrue);
    });

    test('NO llama onUnauthorized en respuestas exitosas', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"ok": true}', 200);
      });

      final authClient = AuthHttpClient(
        client: mockClient,
        storageService: FakeSecureStorage(),
      );

      bool unauthorizedCalled = false;
      AuthHttpClient.onUnauthorized = () {
        unauthorizedCalled = true;
      };

      await authClient.get(Uri.parse('http://example.com/test'));

      expect(unauthorizedCalled, isFalse);
    });

    test('inyecta el token en el header Authorization', () async {
      String? authHeader;
      final mockClient = MockClient((request) async {
        authHeader = request.headers['Authorization'];
        return http.Response('OK', 200);
      });

      final authClient = AuthHttpClient(
        client: mockClient,
        storageService: FakeSecureStorage(),
      );

      await authClient.get(Uri.parse('http://example.com/test'));

      expect(authHeader, 'Bearer fake_test_token');
    });

    test('NO inyecta token si no hay sesión', () async {
      String? authHeader;
      final mockClient = MockClient((request) async {
        authHeader = request.headers['Authorization'];
        return http.Response('OK', 200);
      });

      final authClient = AuthHttpClient(
        client: mockClient,
        storageService: EmptyStorage(),
      );

      await authClient.get(Uri.parse('http://example.com/test'));

      expect(authHeader, isNull);
    });
  });
}
