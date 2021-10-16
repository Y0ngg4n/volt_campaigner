import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/auth/google_login_manager.dart';
import "package:googleapis_auth/auth_browser.dart"
    show
        AccessCredentials,
        AuthClient,
        authenticatedClient,
        AccessToken,
        BrowserOAuth2Flow,
        createImplicitBrowserFlow,
        refreshCredentials,
        ClientId;
import "package:http/http.dart" as http;

class GoogleLoginManagerHtlm implements GoogleLoginManager {
  OnLogin onLogin;

  GoogleLoginManagerHtlm(this.onLogin);

  @override
  Future<AccessedCredentials?> getCredentials(BuildContext context,
      http.Client client, String clientId, String clientSecret, String webClientId, String webClientSecret, List<String> scopes) async {
    BrowserOAuth2Flow flow = await createImplicitBrowserFlow(
        ClientId(webClientId, webClientSecret), scopes);
    AccessCredentials accessCredentials =
        await flow.obtainAccessCredentialsViaUserConsent();
    flow.close();
    return AccessedCredentials(
        AccessedToken(
            accessCredentials.accessToken.type,
            accessCredentials.accessToken.data,
            accessCredentials.accessToken.expiry),
        accessCredentials.refreshToken,
        accessCredentials.scopes,
        idToken: accessCredentials.idToken);
    // Credentials are available in [credentials].
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
    }else return UserData(null, null, null);
  }

  @override
  Future<AccessedCredentials> refresh(String clientId, String clientSecret, String webClientId, String webClientSecret,
      AccessedCredentials accessedCredentials, http.Client client) async {
    AccessCredentials accessCredentials = await refreshCredentials(
        ClientId(webClientId, webClientId),
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
    GoogleLoginManagerHtlm(onLogin);
