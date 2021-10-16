import 'package:flutter/material.dart';

import 'google_login_manager_stub.dart'
    if (dart.library.io) 'google_login_manager_other.dart'
    if (dart.library.html) 'google_login_manager_html.dart';
import "package:http/http.dart" as http;

typedef OnLogin = Function();

abstract class GoogleLoginManager {

  Future<AccessedCredentials?> getCredentials(BuildContext context,
      http.Client client, String clientId, String clientSecret, String webClientId, String webClientSecret, List<String> scopes);

  Future<UserData> getUserData(http.Client client, AccessedCredentials accessedCredentials);

  Future<AccessedCredentials> refresh(String clientId, String clientSecret, String webClientId, String webClientSecret, AccessedCredentials accessedCredentials, http.Client client);

  factory GoogleLoginManager(OnLogin onLogin) => getManager(onLogin);
}

class ClientedId{
  /// The identifier used to identify this application to the server.
  final String identifier;

  /// The client secret used to identify this application to the server.
  final String? secret;

  ClientedId(this.identifier, this.secret);

  ClientedId.serviceAccount(this.identifier) : secret = null;

  factory ClientedId.fromJson(Map<String, dynamic> json) => ClientedId(
    json['identifier'] as String,
    json['secret'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    if (secret != null) 'secret': secret,
  };
}


class AccessedCredentials {
  /// An access token.
  final AccessedToken accessToken;

  /// A refresh token, which can be used to refresh the access credentials.
  final String? refreshToken;

  /// A JWT used in calls to Google APIs that accept an id_token param.
  final String? idToken;

  /// Scopes these credentials are valid for.
  final List<String> scopes;

  AccessedCredentials(
      this.accessToken,
      this.refreshToken,
      this.scopes, {
        this.idToken,
      });

  factory AccessedCredentials.fromJson(Map<String, dynamic> json) =>
      AccessedCredentials(
        AccessedToken.fromJson(json['accessToken'] as Map<String, dynamic>),
        json['refreshToken'] as String?,
        (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
        idToken: json['idToken'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'scopes': scopes,
  };
}

class AccessedToken {
  /// The token type, usually "Bearer"
  final String type;

  /// The access token data.
  final String data;

  /// Time at which the token will be expired (UTC time)
  final DateTime expiry;

  /// [expiry] must be a UTC `DateTime`.
  AccessedToken(this.type, this.data, this.expiry) {
    if (!expiry.isUtc) {
      throw ArgumentError.value(
        expiry,
        'expiry',
        'The expiry date must be a Utc DateTime.',
      );
    }
  }

  factory AccessedToken.fromJson(Map<String, dynamic> json) => AccessedToken(
    json['type'] as String,
    json['data'] as String,
    DateTime.parse(json['expiry'] as String),
  );

  bool get hasExpired => DateTime.now().toUtc().isAfter(expiry);

  @override
  String toString() => 'AccessToken(type=$type, data=$data, expiry=$expiry)';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'data': data,
    'expiry': expiry.toIso8601String(),
  };
}

class UserData{
  String? displayName;
  String? photoUrl;
  String? emailAddress;

  UserData(this.displayName, this.photoUrl, this.emailAddress);


}