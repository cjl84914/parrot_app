import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/appbars/generic_app_bar.dart';
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
    return Scaffold(
        appBar: const GenericAppBar(title: "助手设置"),
        body: Consumer<Session>(
          builder: (context, session, child) {
            nameController =
                TextEditingController(text: session.character.name);
            systemController =
                TextEditingController(text: session.character.system);

            return SessionBusyOverlay(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  FutureAvatar(
                    key: session.character.key,
                    image: session.character.profile,
                    radius: 75,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () async{
                          regenerate = true;
                          await storageOperationDialog(
                              context, session.character.importImage);
                          session.notify();
                        },
                        child: const Text(
                          "修改头像",
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      FilledButton(
                        onPressed: () {
                          regenerate = true;
                          session.character.reset();
                          setState(() {

                          });
                        },
                        child: const Text(
                          "还原默认",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
          },
        ));
  }
}
