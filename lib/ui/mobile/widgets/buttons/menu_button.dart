import 'package:flutter/material.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/about_page.dart';
import 'package:parrot/ui/mobile/pages/model_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:parrot/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:parrot/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/openai_page.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({super.key});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  final iconButtonKey = GlobalKey();
  static LargeLanguageModelType lastModelType = LargeLanguageModelType.none;
  static DateTime lastCheck = DateTime.now();
  static List<String> cache = [];
  List<String> options = [];

  bool canUseCache(Session session) {
    if (cache.isEmpty && session.model.type != LargeLanguageModelType.llamacpp) return false;

    if (session.model.type != lastModelType) return false;

    if (DateTime.now().difference(lastCheck).inMinutes > 1) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        if (canUseCache(session)) {
          options = cache;
          return IconButton(
            key: iconButtonKey,
            icon: const Icon(
              Icons.settings,
              size: 24,
            ),
            onPressed: onPressed,
          );
        }
        else {
          lastModelType = session.model.type;
          lastCheck = DateTime.now();

          return FutureBuilder(
            future: session.model.options,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                options = snapshot.data as List<String>;
                cache = options;

                return IconButton(
                  key: iconButtonKey,
                  icon: const Icon(
                    Icons.settings,
                    size: 24,
                  ),
                  onPressed: onPressed,
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),  // Adjust padding to match the visual space of the IconButton
                  child: SizedBox(
                    width: 24,  // Width of the CircularProgressIndicator
                    height: 24,  // Height of the CircularProgressIndicator
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,  // Adjust the thickness of the spinner here
                      ),
                    ),
                  ),
                );
              }
            }
          );
        }
      }
    );
  }

  void onPressed() {
    final RenderBox renderBox = iconButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    List<PopupMenuEntry<dynamic>> modelOptions = options.map((String modelName) => PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Consumer<Session>(
        builder: 
          (context, session, child) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              title: Text(modelName),
              onTap: () {
                session.model.name = modelName;
              },
              tileColor: session.model.name == modelName ? Theme.of(context).colorScheme.secondary : null,
            );
          }
    )))
    .toList();
    
    showMenu(
      context: context,
      // Calculate the position based on the button's position and size
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx,
        offset.dy,
      ),
      items: [
        ...modelOptions,
        if (modelOptions.isNotEmpty)
          const PopupMenuDivider(
            height: 10,
          ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('模型设置'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)
              {
                return const ModelSettingPage();
              }
              ));},
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('应用设置'),
            onTap: () {
              cache.clear();
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('关于'),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ),
      ],
    );
  }
}