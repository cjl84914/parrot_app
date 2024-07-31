import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/chat_widgets/chat_message.dart';
import 'package:parrot/ui/mobile/widgets/chat_widgets/chat_field.dart';
import 'package:parrot/ui/mobile/widgets/appbars/home_app_bar.dart';
import 'package:parrot/ui/mobile/widgets/home_drawer.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node.dart';
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
    return
      SafeArea(child:
      Scaffold(
        appBar: const HomeAppBar(),
        drawer: const HomeDrawer(),
        body: _buildBody()));
  }

  Widget _buildBody() {
    return Consumer2<Session, User>(
      builder: (context, session, user, child) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });

        List<ChatNode> chat = session.chat.getChat();

        chatWidgets.clear();
        for (final message in chat) {
          chatWidgets.add(ChatMessage(
            key: message.key,
          ));
        }
        _setStateAndMoreToListViewEnd();
        return Builder(
          builder: (BuildContext context) =>
              GestureDetector(
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
                        color: Theme
                            .of(context)
                            .colorScheme
                            .background,
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

  _setStateAndMoreToListViewEnd() {
    if(mounted) {
      try {
        _consoleScrollController.jumpTo(
            _consoleScrollController.position.maxScrollExtent);
      } catch (e) {
        // if (kDebugMode) {
        //   print(e);
        // }
      }
    }
  }
}