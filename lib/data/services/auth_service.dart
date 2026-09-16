import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_mask/data/model/user.dart';
import 'package:open_mask/data/services/automatic_login_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/main.dart';
import 'package:uuid/uuid.dart';

/// Service zur Durchführung von Authentifizierungsoperationen wie Registrierung und Anmeldung.
class AuthService extends ChangeNotifier {
  /// Privater Konstruktor für das Singleton-Pattern.
  AuthService._internal();

  /// Singleton-Instanz.
  static final AuthService instance = AuthService._internal();

  /// Gibt an, ob ein Benutzer eingeloggt ist.
  bool _loggedIn = false;

  /// Gibt an, ob ein Benutzer eingeloggt ist.
  bool get loggedIn => _loggedIn;

  /// Usermodel des Users.
  User? _user;

  /// Aktuell eingeloggter [User].
  User? get user => _user;

  /// Hilfsfunktion zum Hashen von Passwörtern
  String _hashPassword(final String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Meldet den Benutzer lokal an und liefert true zurück, wenn die Anmeldung erfolgreich war.
  Future<bool> login(final String username, final String password) async {
    // Lokale Nutzer einlesen
    Map<String, dynamic> usersAsJson = await readUsers();
    Map<String, dynamic> passwordsAsJson = await readPasswords();

    if (!passwordsAsJson.containsKey(username) ||
        !usersAsJson.containsKey(username)) {
      SnackBarService.showMessage('User existiert nicht');
      return false;
    }

    String passwordHash = passwordsAsJson[username];
    String inputHash = _hashPassword(password);

    if (inputHash != passwordHash) {
      SnackBarService.showMessage('Passwort ist falsch!');
      return false;
    }

    _user = User.fromJson(usersAsJson[username]);
    bool success = true;

    _loggedIn = success;
    notifyListeners();
    FilterStore.instance
        .initialize(); // asynchron im Hintergrund die Filter initialisieren
    return success;
  }

  /// Meldet den Benutzer ab.
  /// Dafür wird das Property [user] gecleared, [loggedIn] auf false gesetzt und
  /// [notifyListeners] zur Benachrichtigung der Änderungen aufgerufen.
  /// Außerdem werden die Nutzerdaten aus dem [AutomaticLoginService] gelöscht.
  Future<bool> logout() async {
    _loggedIn = false;
    _user = null;
    FilterStore.instance.clear();
    AutomaticLoginService.instance.clearLoginData();
    notifyListeners();
    // TODO: implement backend communication
    return !_loggedIn;
  }

  /// Registriert den Benutzer lokal.
  /// Liefert false zurück, wenn der Benutzer bereits existiert.
  Future<bool> register(final String email, final String password,
      final String username, final String name) async {
    String uuid = const Uuid().v4();

    User user = User(
        uuid: uuid,
        username: username,
        displayName: username,
        name: name,
        email: email);

    String passwordHash = _hashPassword(password);

    // Lokale Nutzer einlesen
    Map<String, dynamic> usersAsJson = await readUsers();
    Map<String, dynamic> passwordsAsJson = await readPasswords();

    // Überprüfen, ob Nutzername bereits existiert
    if (usersAsJson.containsKey(username) ||
        passwordsAsJson.containsKey(username)) {
      SnackBarService.showMessage('Benutzername existiert bereits');
      return false;
    }

    usersAsJson.putIfAbsent(username, user.toJSON);
    passwordsAsJson.putIfAbsent(username, () => passwordHash);

    // Nutzer und Passwörter speichern
    await writeUsers(usersAsJson);
    await writePasswords(passwordsAsJson);

    SnackBarService.showMessage('Registrierung erfolgreich!');
    return true;
  }

  /// Liest die Benutzer aus dem [FlutterSecureStorage] ein.
  Future<Map<String, dynamic>> readUsers() async {
    String? usersAsString = await secureStorage.read(key: 'users');
    Map<String, dynamic> usersAsJson = usersAsString == null
        ? {}
        : jsonDecode(usersAsString) as Map<String, dynamic>;
    return usersAsJson;
  }

  /// Liest die Passwörter aus dem [FlutterSecureStorage] ein.
  Future<Map<String, dynamic>> readPasswords() async {
    String? passwordsAsString = await secureStorage.read(key: 'passwords');
    Map<String, dynamic> passwordsAsJson = passwordsAsString == null
        ? {}
        : jsonDecode(passwordsAsString) as Map<String, dynamic>;
    return passwordsAsJson;
  }

  /// Schreibt die Benutzer in den [FlutterSecureStorage].
  Future<void> writeUsers(final Map<String, dynamic> usersAsJson) async {
    await secureStorage.write(key: 'users', value: jsonEncode(usersAsJson));
  }

  /// Schreibt die Passwörter in den [FlutterSecureStorage].
  Future<void> writePasswords(
      final Map<String, dynamic> passwordsAsJson) async {
    await secureStorage.write(
        key: 'passwords', value: jsonEncode(passwordsAsJson));
  }
}
