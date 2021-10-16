import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:volt_campaigner/auth/google_login_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:googleapis_auth/auth_io.dart"
    show
        AccessCredentials,
        AccessToken,
        AuthClient,
        ClientId,
        authenticatedClient,
        obtainAccessCredentialsViaUserConsent,
        refreshCredentials;
import "package:http/http.dart" as http;
import 'package:volt_campaigner/utils/messenger.dart';

class GoogleLoginManagerOther implements GoogleLoginManager {
  OnLogin onLogin;

  GoogleLoginManagerOther(this.onLogin);

  Future<AccessedCredentials?> getCredentials(BuildContext context,
      http.Client client, String clientId, String clientSecret, String webClientId, String webClientSecret, List<String> scopes) async {
    print("Getting Google Login Credentials");
    try {
      AccessCredentials accessCredentials =
          await obtainAccessCredentialsViaUserConsent(
              ClientId(clientId, clientSecret),
              scopes,
              client,
              prompt,
              hostedDomain: "volteuropa.org");
      return AccessedCredentials(
          AccessedToken(
              accessCredentials.accessToken.type,
              accessCredentials.accessToken.data,
              accessCredentials.accessToken.expiry),
          accessCredentials.refreshToken,
          accessCredentials.scopes,
          idToken: accessCredentials.idToken);
    } catch (e) {
      print(e);
      Messenger.showError(context, AppLocalizations.of(context)!.errorLogin);
    }
  }

  void prompt(String url) {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");
    launchUrl(url);
  }

  void launchUrl(String url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  @override
  Future<UserData> getUserData(
      http.Client client, AccessedCredentials accessedCredentials) async {
    AuthClient authClient = authenticatedClient(
        client,
        AccessCredentials(
            AccessToken(
                accessedCredentials.accessToken.type,
                accessedCredentials.accessToken.data,
                accessedCredentials.accessToken.expiry),
            accessedCredentials.refreshToken,
            accessedCredentials.scopes,
            idToken: accessedCredentials.idToken));
    http.Response response = await authClient.get(Uri.parse(
        "https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses,photos"));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return UserData(json['names'][0]['displayName'], json['photos'][0]['url'],
          json['emailAddresses'][0]['value']);
    } else
      return UserData(null, null, null);
  }

  @override
  Future<AccessedCredentials> refresh(String clientId, String clientSecret, String webClientId, String webClientSecret,
      AccessedCredentials accessedCredentials, http.Client client) async {
    AccessCredentials accessCredentials = await refreshCredentials(
        ClientId(clientId, clientSecret),
        AccessCredentials(
            AccessToken(
                accessedCredentials.accessToken.type,
                accessedCredentials.accessToken.data,
                accessedCredentials.accessToken.expiry),
            accessedCredentials.refreshToken,
            accessedCredentials.scopes,
            idToken: accessedCredentials.idToken),
        client);

    return AccessedCredentials(
        AccessedToken(
            accessCredentials.accessToken.type,
            accessCredentials.accessToken.data,
            accessCredentials.accessToken.expiry),
        accessCredentials.refreshToken,
        accessCredentials.scopes,
        idToken: accessCredentials.idToken);
  }
}

GoogleLoginManager getManager(OnLogin onLogin) =>
    GoogleLoginManagerOther(onLogin);
