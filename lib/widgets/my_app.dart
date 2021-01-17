import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kifu_viewer/configs/app_themes.dart';
import 'package:kifu_viewer/localizations.dart';
import 'package:kifu_viewer/widgets/home_screen/home_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizationsDelegate.supportedLocals,
      theme: AppThemes.light,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
