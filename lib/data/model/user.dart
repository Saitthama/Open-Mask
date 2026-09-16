import 'package:uuid/uuid.dart';

class User {
  /// Standard-Konstruktor.
  const User(
      {required this.uuid,
      required this.username,
      required this.displayName,
      required this.name,
      required this.email});

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory User.fromJson(final Map<String, dynamic> json) => User(
      uuid: json['uuid'] ?? const Uuid().v4(),
      username: json['username'],
      displayName: (json['displayName'] != null)
          ? json['displayName']
          : json['username'],
      name: json['name'],
      email: json['email']);

  /// Die eindeutige id des Users.
  final String uuid;

  /// Die Email des Users.
  final String email;

  /// Der Username des Users.
  final String username;

  /// Der richtige Name des Users.
  final String name;

  /// Der Anzeigename des Users.
  /// Wenn keiner gesetzt ist, gilt displayName = Username.
  final String displayName;

  /// Methode zur JSON‑Serialisierung.
  Map<String, dynamic> toJSON() => {
        'uuid': uuid,
        'username': username,
        'displayName': displayName,
        'email': email,
        'name': name
      };
}
