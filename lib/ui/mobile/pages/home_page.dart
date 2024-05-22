import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/providers/character.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/static/utilities.dart';
import 'package:parrot/ui/mobile/widgets/chat_widgets/chat_message.dart';
import 'package:parrot/ui/mobile/widgets/chat_widgets/chat_field.dart';
import 'package:parrot/ui/mobile/widgets/appbars/home_app_bar.dart';
import 'package:parrot/ui/mobile/widgets/home_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ScrollController _consoleScrollController = ScrollController();
  List<ChatMessage> chatWidgets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const HomeAppBar(),
        drawer: const HomeDrawer(),
        body: _buildBody());
  }

  Widget _buildBody() {
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });
        
        List<ChatNode> chat = session.chat.getChat();
        if (
          chat.isEmpty && 
          character.useGreeting && 
          character.greetings.isNotEmpty
        ) {
          final index = Random().nextInt(character.greetings.length);

          if (character.greetings[index].isNotEmpty) {
            final message = ChatNode(
              key: UniqueKey(),
              role: ChatRole.assistant,
              content: Utilities.formatPlaceholders(character.greetings[index], user.name, character.name),
              finalised: true
            );
  
            session.chat.addNode(message);
            chat = [message];
          }
        }

        chatWidgets.clear();
        for (final message in chat) {
          chatWidgets.add(ChatMessage(
            key: message.key,
          ));
        }

        return Builder(
          builder: (BuildContext context) => GestureDetector(
            onHorizontalDragEnd: (details) {
              // Check if the drag is towards right with a certain velocity
              if (details.primaryVelocity! > 100) {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _consoleScrollController,
                        itemCount: chatWidgets.length,
                        itemBuilder: (BuildContext context, int index) {
                          return chatWidgets[index];
                        },
                      ),
                    ),
                    const ChatField(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
