import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/static/themes.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
import 'package:parrot/ui/mobile/widgets/future_avatar.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node_tree.dart';
import 'package:parrot/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';

class CharacterDetail extends StatefulWidget {
  const CharacterDetail({super.key});

  @override
  State<CharacterDetail> createState() => _CharacterDetailState();
}

class _CharacterDetailState extends State<CharacterDetail> {
  bool regenerate = true;
  late TextEditingController nameController;
  late TextEditingController systemController;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    systemController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      nameController = TextEditingController(text: session.character.name);
      systemController = TextEditingController(text: session.character.system);
      return
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                    child: GestureDetector(
                        onTap: () async {},
                        child: FutureAvatar(
                          key: session.character.key,
                          image: session.character.profile,
                          radius: 75,
                        ))),
                const SizedBox(height: 10.0),
                Text(session.character.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10.0),
                Text(session.model.name,
                    style: Theme.of(context).textTheme.bodyMedium),
                Container(
                    margin: const EdgeInsets.all(24),
                    width: 250,
                    child:
                Text(session.character.system,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey))),
                Card(
                    elevation: 0,
                    margin: const EdgeInsets.all(16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text("修改助手设定 "),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c){
                              return const CharacterCustomizationPage();
                            }));
                          }),
                    ])),
                Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(
                          leading: const Icon(Icons.cleaning_services),
                          title: const Text("清除上下文"),
                          onTap: () {
                            session.chat = ChatNodeTree();
                            session.notify();
                          }),
                    ])),
              ],
            ),
          ));
    });
  }
}
