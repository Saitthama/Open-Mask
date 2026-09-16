import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/main.dart';

/// Service zur Speicherung der Login-Daten und Durchführung des automatischen Logins.
class AutomaticLoginService {
  /// Privater Konstruktor für das Singleton-Pattern.
  AutomaticLoginService._internal();

  /// Singleton-Instanz.
  static final AutomaticLoginService instance =
      AutomaticLoginService._internal();

  /// Gibt an, ob die Benutzerdaten für die Zukunft gespeichert werden sollen,
  /// um eine automatische Anmeldung zu ermöglichen.
  bool _rememberMe = false;

  /// Gibt an, ob die Benutzerdaten für die Zukunft gespeichert werden sollen,
  /// um eine automatische Anmeldung zu ermöglichen.
  bool get rememberMe => _rememberMe;

  /// Speichert die Login-Daten lokal mit [FlutterSecureStorage].
  Future<void> saveLoginData(
      final String username, final String password) async {
    _rememberMe = true;

    await secureStorage.write(key: 'username', value: username);
    await secureStorage.write(key: 'password', value: password);
    await secureStorage.write(key: 'rememberMe', value: 'true');
  }

  /// Löscht die Login-Daten.
  Future<void> clearLoginData() async {
    _rememberMe = false;

    await secureStorage.delete(key: 'username');
    await secureStorage.delete(key: 'password');
    await secureStorage.write(key: 'rememberMe', value: 'false');
  }

  /// Meldet den Benutzer automatisch an.
  Future<void> autoLogin() async {
    String? remember = await secureStorage.read(key: 'rememberMe');

    _rememberMe = remember == 'true';

    if (_rememberMe) {
      String username = await secureStorage.read(key: 'username') ?? '';

      String password = await secureStorage.read(key: 'password') ?? '';

      bool success = await AuthService.instance.login(username, password);

      if (!success) {
        await clearLoginData();
        return;
      }
    }
  }
}
