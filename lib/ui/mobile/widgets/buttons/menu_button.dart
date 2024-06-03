import 'package:flutter/material.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/about_page.dart';
import 'package:parrot/ui/mobile/pages/model_page.dart';
import 'package:parrot/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({super.key});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  final iconButtonKey = GlobalKey();
  static List<String> cache = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
          return IconButton(
            key: iconButtonKey,
            icon: const Icon(
              Icons.settings,
              size: 24,
            ),
            onPressed: () =>onPressed(context, session, child ),
          );
      }
    );
  }

  void onPressed(context, Session session, child)  {
    final RenderBox renderBox = iconButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

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
            title: const Text('清除上下文'),
            onTap: () {
              Navigator.pop(context);
              session.chat = ChatNodeTree();
              session.notify();
            },
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