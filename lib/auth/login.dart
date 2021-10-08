import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:googleapis_auth/auth_io.dart"
    show
        AuthClient,
        ClientId,
        PromptUserForConsent,
        ServiceAccountCredentials,
        clientViaUserConsent,
        obtainAccessCredentialsViaUserConsent,
        refreshCredentials,
        autoRefreshingClient,
        AccessCredentials,
        AccessToken;
import 'package:url_launcher/url_launcher.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../drawer.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  late SharedPreferences prefs;
  String? accessTokenData, accessTokenType, refreshToken, idToken, restApiToken;
  int? expiry;

  final clientId =
      ClientId((dotenv.env['CLIENT_ID']!), (dotenv.env['CLIENT_SECRET']!));
  final scopes = <String>['https://www.googleapis.com/auth/userinfo.email'];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          accessTokenData =
              prefs.getString(SharedPrefsSlugs.googleAccessTokenData);
          accessTokenType =
              prefs.getString(SharedPrefsSlugs.googleAccessTokenType);
          refreshToken = prefs.getString(SharedPrefsSlugs.googleRefreshToken);
          idToken = prefs.getString(SharedPrefsSlugs.googleIdToken);
          expiry = prefs.getInt(SharedPrefsSlugs.googleExpiry);
          restApiToken = prefs.getString(SharedPrefsSlugs.restApiToken);
          print("Calling Sign in");
          _signIn(false);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      _signIn(true);
                    },
                    child: Text("Login with your Volt Europa Account"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<GoogleSignInAccount?> _signIn(bool button) async {
    var client = http.Client();
    if (expiry == null ||
        accessTokenData == null ||
        accessTokenType == null ||
        refreshToken == null ||
        idToken == null ||
        expiry == null ||
        restApiToken == null) {
      if (button) {
        print("Logging in");
        getCredentials(client);
      }
    } else {
      DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry!);
      DateTime? restExpiryDate = Jwt.getExpiryDate(restApiToken!);
      DateTime now = DateTime.now();
      if (now.isAfter(expiryDate)) {
        try {
          print("Refreshing Credentials");
          AccessCredentials refreshedCredentials = await refreshCredentials(
              clientId,
              AccessCredentials(
                  AccessToken(
                      accessTokenType!, accessTokenData!, expiryDate.toUtc()),
                  refreshToken,
                  scopes,
                  idToken: idToken),
              client);
          await _saveCredentials(refreshedCredentials);
        } catch (e) {
          print(e);
          Messenger.showError(
              context, AppLocalizations.of(context)!.errorLogin);
        } finally {
          // client.close();
        }
      }
      if (now.isAfter(restExpiryDate!)) {
        print("Gettings JWT");
        await _getJWT(accessTokenData!);
      }
      if (!now.isAfter(restExpiryDate) && !now.isAfter(expiryDate)) {
        print("Allready logged in");
        _goToDrawer();
      }
    }
  }

  _goToDrawer() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => DrawerView(
              apiToken: restApiToken!,
            )));
  }

  void getCredentials(http.Client client) {
    print("Getting Google Login Credentials");
    try {
      obtainAccessCredentialsViaUserConsent(clientId, scopes, client, prompt)
          .then((AccessCredentials credentials) async {
        await _saveCredentials(credentials);
        await _getJWT(credentials.accessToken.data);
        client.close();
      });
    } catch (e) {
      print(e);
      Messenger.showError(context, AppLocalizations.of(context)!.errorLogin);
    }
  }

  _getJWT(String authToken) async {
    print("Getting JWT");
    try {
      String? jwt = await AuthApiUtils.getJWT(authToken);
      if (jwt != null) {
        prefs.setString(SharedPrefsSlugs.restApiToken, jwt);
        setState(() {
          restApiToken = jwt;
        });
      } else {
        throw new Exception("Wrong API Secret");
      }
    } catch (e) {
      print("Could not login into API");
      Messenger.showError(context, AppLocalizations.of(context)!.errorLogin);
    }
    _goToDrawer();
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

  Future _saveCredentials(AccessCredentials accessCredentials) async {
    await prefs.setString(SharedPrefsSlugs.googleAccessTokenData,
        accessCredentials.accessToken.data);
    await prefs.setString(SharedPrefsSlugs.googleAccessTokenType,
        accessCredentials.accessToken.type);
    if (accessCredentials.refreshToken != null)
      await prefs.setString(
          SharedPrefsSlugs.googleRefreshToken, accessCredentials.refreshToken!);
    if (accessCredentials.idToken != null)
      await prefs.setString(
          SharedPrefsSlugs.googleIdToken, accessCredentials.idToken!);
    await prefs.setInt(SharedPrefsSlugs.googleExpiry,
        accessCredentials.accessToken.expiry.millisecondsSinceEpoch);
  }
}
