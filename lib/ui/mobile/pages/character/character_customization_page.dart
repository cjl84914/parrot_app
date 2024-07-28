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
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0.0,
            title: const Text("助手设置"),
          ),
          body: SessionBusyOverlay(
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
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
                TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) {
                        return const ModelSettingPage();
                      }));
                    },
                    child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 226, 86, 61),
                                Color.fromARGB(255, 255, 210, 110)
                              ],
                              stops: [0.25, 0.75],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        // This blend mode applies the shader to the text color.
                        child: Text(
                            session.model.name == ''
                                ? "选择模型"
                                : session.model.name,
                            style: const TextStyle(fontSize: 20)))),
                const SizedBox(height: 10.0),
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
          )));
    });
  }
}
