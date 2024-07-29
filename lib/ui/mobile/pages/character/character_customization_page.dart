import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/model_page.dart';
import 'package:parrot/ui/mobile/widgets/dialogs.dart';
import 'package:parrot/ui/mobile/widgets/future_avatar.dart';
import 'package:parrot/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:parrot/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  State<CharacterCustomizationPage> createState() =>
      _CharacterCustomizationPageState();
}

class _CharacterCustomizationPageState
    extends State<CharacterCustomizationPage> {
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
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0.0,
            title: const Text("助手设置"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () async {
                      regenerate = true;
                      await storageOperationDialog(
                          context, session.character.importImage);
                      session.notify();
                    },
                    child: FutureAvatar(
                      key: session.character.key,
                      image: session.character.profile,
                      radius: 75,
                    )),
                const SizedBox(height: 10),
                ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) {
                        return const ModelSettingPage();
                      }));
                    },
                    title: Column(children: [
                      const Text("模型"),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey.shade300,
                          ),
                          child: Row(children: [
                            Expanded(
                                child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    session.model.name == ""
                                        ? "选择模型"
                                        : session.model.name,
                                    style: const TextStyle(fontSize: 16))),
                            const Icon(Icons.keyboard_arrow_down)
                          ]))
                    ])),
                const SizedBox(height: 10),
                TextFieldListTile(
                  headingText: '名字',
                  labelText: '请输入助手名字',
                  controller: nameController,
                  onChanged: (value) {
                    session.character.name = value;
                  },
                  multiline: false,
                ),
                TextFieldListTile(
                  headingText: '角色设定',
                  labelText: '请输入Prompt提示词',
                  controller: systemController,
                  onChanged: (value) {
                    session.character.system = value;
                  },
                  multiline: true,
                ),
              ],
            ),
          ));
    });
  }
}
