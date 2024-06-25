import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
import 'package:provider/provider.dart';

class SessionTile extends StatefulWidget {
  final Session session;
  final void Function() onDelete;
  final void Function(String) onRename;

  const SessionTile(
      {super.key,
      required this.session,
      required this.onDelete,
      required this.onRename});

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        String displayMessage = widget.session.name;
        if (displayMessage.length > 30) {
          displayMessage = '${displayMessage.substring(0, 30)}...';
        }
        return GestureDetector(
            onLongPressStart: onLongPressStart,
            child: ListTile(
              onTap: () {
                if (!session.chat.tail.finalised) return;
                session.from(widget.session);
                Navigator.pop(context);
              },
              title: Text(
                displayMessage,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              subtitle: Text(
                widget.session.model.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              )
            ));
      },
    );
  }

  void onSecondaryTapUp(TapUpDetails details) =>
      showContextMenu(details.globalPosition);

  void onLongPressStart(LongPressStartDetails details) =>
      showContextMenu(details.globalPosition);

  void showContextMenu(Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          onTap: widget.onDelete,
          child: const Text('删除'),
        ),
        PopupMenuItem(
          onTap: showModifyDialog,
          child: const Text('更改'),
        ),
      ],
    );
  }

  void showModifyDialog() {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CharacterCustomizationPage()));
  }

  void showRenameDialog() {
    final TextEditingController controller =
        TextEditingController(text: widget.session.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "对话名称",
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "请输入名称",
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "取消",
              ),
            ),
            FilledButton(
              onPressed: () {
                widget.onRename(controller.text);

                Navigator.of(context).pop();
              },
              child: Text(
                "确认",
              ),
            ),
          ],
        );
      },
    );
  }
}
