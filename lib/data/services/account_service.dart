import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

/// Service zur Durchführung von Konto-Operationen
/// wie dem Bearbeiten von Attributen oder dem Löschen des Accounts.
class AccountService {
  static Future<void> editName(final BuildContext context) async {}

  static Future<void> editUsername(BuildContext context) async {}

  static Future<void> resetEmail(BuildContext context) async {}

  static Future<void> resetPassword(BuildContext context) async {}

  static Future<void> changePassword(BuildContext context) async {}

  static Future<File?> changeProfilepicture() async {
    File? _imageFile;
    /* TODO: Image Picker kompatible Version finden
    final ImagePicker _picker = ImagePicker();

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      return _imageFile;
    }*/
    return null;
  }

  /// Löscht den gerade eingeloggten Benutzer [AuthService.user] und meldet ihn mit [AuthService.logout] ab.
  /// Gibt zurück, ob der Benutzer erfolgreich gelöscht wurde, oder nicht.
  static Future<bool> deleteAccount() async {
    if (AuthService.instance.user == null) {
      return false;
    }

    // Lokale Nutzer einlesen
    Map<String, dynamic> usersAsJson = await AuthService.instance.readUsers();
    Map<String, dynamic> passwordsAsJson =
        await AuthService.instance.readPasswords();

    String username = AuthService.instance.user!.username;
    if (!passwordsAsJson.containsKey(username) ||
        !usersAsJson.containsKey(username)) {
      SnackBarService.showMessage('User existiert nicht');
      return false;
    }

    usersAsJson.remove(username);
    passwordsAsJson.remove(username);

    AuthService.instance.writeUsers(usersAsJson);
    AuthService.instance.writePasswords(passwordsAsJson);

    return AuthService.instance.logout();
  }
}
