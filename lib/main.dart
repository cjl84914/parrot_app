import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/ui/mobile/pages/home_page.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/providers/character.dart';
import 'package:parrot/static/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  String? lastUserString = prefs.getString("last_user");
  Map<String, dynamic> lastUser = json.decode(lastUserString ?? "{}");
  User user = User.fromMap(lastUser);

  String? lastCharacterString = prefs.getString("last_character");
  Map<String, dynamic> lastCharacter = json.decode(lastCharacterString ?? "{}");
  Character character = Character.fromMap(lastCharacter);

  String? lastSessionString = prefs.getString("last_session");
  Map<String, dynamic> lastSession = json.decode(lastSessionString ?? "{}");
  Session session = Session.fromMap(lastSession);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainProvider()),
        ChangeNotifierProvider(create: (context) => user),
        ChangeNotifierProvider(create: (context) => character),
        ChangeNotifierProvider(create: (context) => session),
      ],
      child: const ParrotApp(),
    ),
  );
}

class MainProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  void reset() {
    notifyListeners();
  }
}

class ParrotApp extends StatefulWidget {
  const ParrotApp({super.key});

  @override
  ParrotAppState createState() => ParrotAppState();
}

class ParrotAppState extends State<ParrotApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '语鹦助手',
          theme: Themes.lightTheme(),
          darkTheme: Themes.darkTheme(),
          themeMode: mainProvider.themeMode,
          home: const HomePage(title: "语鹦助手")
        );
      },
    );
  }
}
