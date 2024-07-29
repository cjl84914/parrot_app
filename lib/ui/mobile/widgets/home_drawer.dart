import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/more_page.dart';
import 'package:parrot/ui/mobile/widgets/tiles/session_tile.dart';
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
    final String sessionsJson =
        json.encode(sessions.map((session) => session.toMap()).toList());
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
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0)),
            ),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: Row(children: [
                  Container(
                      padding: const EdgeInsets.all(12),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage("assets/parrot.png"),
                        radius: 28,
                      )),
                  const Text("语鹦助手")
                ])),
                IconButton(
                    onPressed: () async {
                      if (!session.chat.tail.finalised) return;
                      final newSession = Session();
                      sessions.insert(0, newSession);
                      session.from(newSession);
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.add))
              ]),
              Divider(
                height: 0,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return SessionTile(
                        session: sessions[index],
                        onDelete: () {
                          if (!session.chat.tail.finalised) return;
                          setState(() {
                            if (sessions[index].key == session.key) {
                              session.from(sessions.firstOrNull ?? Session());
                            }
                            sessions.removeAt(index);
                          });
                        },
                        onRename: (value) {
                          setState(() {
                            session.character.name = value;
                          });
                        },
                      );
                    }),
              ),
              Divider(
                height: 0,
                color: Theme.of(context).colorScheme.primary,
              ),
              ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return const MorePage();
                    }));
                  },
                  title: const Text("更多"),
                  trailing: const Icon(Icons.keyboard_arrow_right))
              // const UserTile(),
            ]));
      },
    );
  }
}
