import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:volt_campaigner/auth/login.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  print(dotenv.env['REST_API_URL']);
  runApp(EasyDynamicThemeWidget(child: VoltCampaignerApp()));
}

class VoltCampaignerApp extends StatelessWidget {
  var lightThemeData = new ThemeData(
    brightness: Brightness.light,
    primaryColor: Color.fromARGB(255, 80, 35, 121),
  );

  var darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color.fromARGB(255, 80, 35, 121),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Volt Campaigner",
        theme: lightThemeData,
        darkTheme: darkThemeData,
        themeMode: EasyDynamicTheme.of(context).themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginView());
  }
}
