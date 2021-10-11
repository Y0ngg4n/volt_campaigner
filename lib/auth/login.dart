import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'package:volt_campaigner/auth/volunteer.dart';
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:googleapis_auth/auth_io.dart"
    show
        AccessCredentials,
        AccessToken,
        AuthClient,
        ClientId,
        PromptUserForConsent,
        ServiceAccountCredentials,
        authenticatedClient,
        autoRefreshingClient,
        clientViaUserConsent,
        obtainAccessCredentialsViaUserConsent,
        refreshCredentials;
import 'package:url_launcher/url_launcher.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../drawer.dart';
import 'package:googleapis/people/v1.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  late SharedPreferences prefs;
  String? accessTokenData, accessTokenType, refreshToken, idToken, restApiToken;
  String? displayName, photoUrl, emailAddress;
  int? expiry;
  final clientId =
      ClientId((dotenv.env['CLIENT_ID']!), (dotenv.env['CLIENT_SECRET']!));
  final scopes = <String>[
    'https://www.googleapis.com/auth/userinfo.email',
    "https://www.googleapis.com/auth/userinfo.profile"
  ];

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
          displayName = prefs.getString(SharedPrefsSlugs.googleDisplayName);
          photoUrl = prefs.getString(SharedPrefsSlugs.googlePhotoUrl);
          emailAddress = prefs.getString(SharedPrefsSlugs.googleEmailAddress);
          print("Calling Sign in");
          _signIn(false);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
              "https://play-lh.googleusercontent.com/91sCbYPZw3tYXc9n2Gjn3mwXlY_oSuJpDWxnVsPtUWUxf8y709Nc1gqRGPO6NOrQSg=s180"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      _signIn(true);
                    },
                    child: Text(AppLocalizations.of(context)!.loginVoltEuropa)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => VolunteerLogin()));
                    },
                    child:
                        Text(AppLocalizations.of(context)!.loginAsVolunteer)),
              ),
            ],
          ),
        ],
      ),
    ));
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
          await _checkUserData(client);
          await _checkReady(refreshedCredentials.accessToken.expiry, restExpiryDate, now, client);
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
      await _checkReady(expiryDate, restExpiryDate, now, client);
    }
  }

  _checkReady(DateTime expiryDate, DateTime? restExpiryDate, DateTime now, http.Client client) async {
    if (!now.isAfter(restExpiryDate!) && !now.isAfter(expiryDate)) {
      print("Allready logged in");
      await _checkUserData(client);
      _goToDrawer();
    }
  }

  _checkUserData(http.Client client) async {
    AccessCredentials accessCredentials = AccessCredentials(
        AccessToken(accessTokenType!, accessTokenData!,
            DateTime.fromMillisecondsSinceEpoch(expiry!).toUtc()),
        refreshToken,
        scopes,
        idToken: idToken);
    if (photoUrl == null || displayName == null || emailAddress == null) {
      print("Getting User Data");
      await _getUserData(client, accessCredentials);
    }
  }

  _goToDrawer() {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => DrawerView(
                      apiToken: restApiToken!,
                      displayName: displayName,
                      emailAddress: emailAddress,
                      photoUrl: photoUrl,
                    )),
            (route) => false);
      });
    });
  }

  void getCredentials(http.Client client) {
    print("Getting Google Login Credentials");
    try {
      obtainAccessCredentialsViaUserConsent(clientId, scopes, client, prompt)
          .then((AccessCredentials credentials) async {
        await _saveCredentials(credentials);
        await _getJWT(credentials.accessToken.data);
        await _getUserData(client, credentials);
        client.close();
      });
    } catch (e) {
      print(e);
      Messenger.showError(context, AppLocalizations.of(context)!.errorLogin);
    }
  }

  _getUserData(http.Client client, AccessCredentials credentials) async {
    AuthClient authClient = authenticatedClient(client, credentials);
    http.Response response = await authClient.get(Uri.parse(
        "https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses,photos"));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      String? displayName = json['names'][0]['displayName'];
      if (displayName != null)
        await prefs.setString(SharedPrefsSlugs.googleDisplayName, displayName);
      String? photoUrl = json['photos'][0]['url'];
      if (photoUrl != null)
        await prefs.setString(SharedPrefsSlugs.googlePhotoUrl, photoUrl);
      String? emailAddresses = json['emailAddresses'][0]['value'];
      if (emailAddresses != null)
        await prefs.setString(
            SharedPrefsSlugs.googleEmailAddress, emailAddresses);

      setState(() {
        this.displayName = displayName;
        this.photoUrl = photoUrl;
        this.emailAddress = emailAddress;
      });
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
        _goToDrawer();
      } else {
        throw new Exception("Wrong API Secret");
      }
    } catch (e) {
      print("Could not login into API");
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

  Future _saveCredentials(AccessCredentials accessCredentials) async {
    print("Saving credentials");
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
    setState(() {
      accessTokenData = accessCredentials.accessToken.data;
      accessTokenType = accessCredentials.accessToken.type;
      refreshToken = accessCredentials.refreshToken;
      idToken = accessCredentials.idToken;
      expiry = accessCredentials.accessToken.expiry.millisecondsSinceEpoch;
    });
  }
}
