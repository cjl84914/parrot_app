import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parrot/providers/character.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
import 'package:provider/provider.dart';

class CharacterBrowserTile extends StatefulWidget {
  final Character character;
  final void Function() onDelete;

  const CharacterBrowserTile(
      {super.key, required this.character, required this.onDelete});

  @override
  State<CharacterBrowserTile> createState() => _CharacterBrowserTileState();
}

class _CharacterBrowserTileState extends State<CharacterBrowserTile> {
  Timer? longPressTimer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<File>(
            future: widget.character.profile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Icon(Icons.error);
                } else {
                  return Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
              } else {
                return const CircularProgressIndicator();
              }
            }
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: Colors.black.withOpacity(0.1),
              highlightColor: Colors.black.withOpacity(0.2),
              splashColor: Colors.black.withOpacity(0.2),
              onTapDown: onTapDown,
              onTapUp: onTapUp,
              onSecondaryTapUp: (details) => showContextMenu(details.globalPosition),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black, Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.character.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.character.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            )
          )
        ],
      )
    );
  }

  void onTapDown(TapDownDetails details) {
    longPressTimer = Timer(const Duration(seconds: 1), () {
      showContextMenu(details.globalPosition);
    });
  }

  void onTapUp(TapUpDetails details) {
    if (longPressTimer?.isActive ?? false) {
      longPressTimer?.cancel();
      context.read<Character>().from(widget.character);
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            const CharacterCustomizationPage()
        )
      );
    }
  }      

  void showContextMenu(Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final TextEditingController controller =
        TextEditingController(text: widget.character.name);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          onTap: widget.onDelete,
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          child: const Text('Rename'),
          onTap: () {
            // Delayed execution to allow the popup menu to close properly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showRenameDialog(context, controller);
            });
          },
        ),
      ],
    );
  }

  void _showRenameDialog(
      BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Rename Session",
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter new name",
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
              ),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  String oldName = widget.character.name;
                  Logger.log(
                      "Updating character $oldName ====> ${controller.text}");
                  widget.character.name = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                "Rename",
              ),
            ),
          ],
        );
      },
    );
  }
}
