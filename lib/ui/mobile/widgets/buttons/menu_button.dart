import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
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
              Icons.add,
              size: 24,
              color: Colors.black,
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
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c){
              return const CharacterCustomizationPage();
            }));
          },
          child: const Text('创建助手'),
        ),
      ],
    );
  }
}