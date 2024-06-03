import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/character/character_browser_page.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
import 'package:parrot/ui/mobile/widgets/tiles/character_tile.dart';
import 'package:parrot/ui/mobile/widgets/tiles/session_tile.dart';
import 'package:parrot/ui/mobile/widgets/tiles/user_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<Session> sessions = [];
  Key current = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String sessionsJson = prefs.getString("sessions") ?? '[]';
    final List sessionsList = json.decode(sessionsJson);

    setState(() {
      sessions.clear();
      for (final characterMap in sessionsList) {
        sessions.add(Session.fromMap(characterMap));
      }
    });
  }

  @override
  void dispose() {
    saveSessions();
    super.dispose();
  }

  Future<void> saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    sessions.removeWhere((session) => session.key == current);
    final String sessionsJson = json.encode(sessions.map((session) => session.toMap()).toList());
    await prefs.setString("sessions", sessionsJson);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        current = session.key;

        var contains = false;

        for (var element in sessions) {
          if (element.key == current) {
            contains = true;
            break;
          }
        }

        if (!contains) {
          sessions.insert(0, session.copy());
        }

        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });

        return Drawer(
          backgroundColor: Theme.of(context).colorScheme.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
              child: Column(children: [
                UserTile()
              ]
            )
          )
        );
      },
    );
  }
}
