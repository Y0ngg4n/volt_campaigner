import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:volt_campaigner/auth/login.dart';
import 'package:google_fonts/google_fonts.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  print(dotenv.env['REST_API_URL']);
  runApp(EasyDynamicThemeWidget(child: VoltCampaignerApp()));
}

class VoltCampaignerApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var lightThemeData = new ThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromARGB(255, 80, 35, 121),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
    );

    var darkThemeData = ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 80, 35, 121),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme));

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
