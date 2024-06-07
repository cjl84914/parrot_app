import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parrot/providers/tts.dart';
import 'package:parrot/ui/mobile/widgets/code_box.dart';
import 'package:parrot/ui/mobile/widgets/dialogs.dart';
import 'package:parrot/providers/character.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/ui/mobile/widgets/future_avatar.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node.dart';
import 'package:parrot/ui/mobile/widgets/typing_indicator.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    required super.key,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with SingleTickerProviderStateMixin {
  late ChatNode node;
  bool editing = false;

  Widget messageBuilder(String message) {
    List<Widget> widgets = [];
    List<String> parts = message.split('```');
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) {
        widgets.add(SelectableText(part,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            )));
      } else {
        widgets.addAll([
          const SizedBox(height: 10),
          CodeBox(code: part),
          // Assuming CodeBox is a widget you've defined for displaying code.
          const SizedBox(height: 10),
        ]);
      }
    }

    return

      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        node = session.chat.find(widget.key!)!;

        int currentIndex = session.chat.indexOf(widget.key!);
        int siblingCount = session.chat.siblingCountOf(widget.key!);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10.0),
              FutureAvatar(
                key: node.role == ChatRole.user ? user.key : character.key,
                image: node.role == ChatRole.user
                    ? user.profile
                    : character.profile,
                radius: 16,
              ),
              const SizedBox(width: 10.0),
              Text(
                node.role == ChatRole.user ? user.name : character.name,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 226, 86, 61),
                  // This color is needed, but it will be overridden by the shader.
                  fontSize: 14,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          Padding(
              // left padding 30 right 10
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: editing ? editingColumn() : standardColumn(),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (node.finalised) ...messageOptions(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        if (!session.chat.tail.finalised) return;
                        session.chat.last(node.key);
                        session.notify();
                      },
                      icon: Icon(Icons.arrow_left,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  Text('${currentIndex + 1}/$siblingCount',
                      style: Theme.of(context).textTheme.labelLarge),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      if (!session.chat.tail.finalised) return;
                      session.chat.next(node.key);
                      session.notify();
                    },
                    icon: Icon(Icons.arrow_right,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              )
            ],
          ),
        ]);
      },
    );
  }

  List<Widget> messageOptions() {
    return node.role == ChatRole.user ? userOptions() : assistantOptions();
  }

  List<Widget> userOptions() {
    return [
      IconButton(
        onPressed: () {
          if (!context.read<Session>().chat.tail.finalised) return;

          if (context.read<Session>().model.missingRequirements.isNotEmpty) {
            showMissingRequirementsDialog(context);
          } else {
            setState(() {
              editing = true;
            });
          }
        },
        icon: const Icon(Icons.edit, size: 18),
      ),
    ];
  }

  List<Widget> assistantOptions() {
    var ttsState = context.watch<TTS>().ttsState;
    return [
      IconButton(
        onPressed: () {
          if (ttsState == TtsState.playing) {
            context.read<TTS>().stop();
          } else {
            context.read<TTS>().speak(node.content);
          }
        },
        icon: Icon(ttsState == TtsState.playing ? Icons.stop : Icons.play_arrow,
            size: 18),
      ),
      !kIsWeb?Visibility(
          visible: Platform.isIOS || Platform.isAndroid,
          child:
      IconButton(
        onPressed: () {
          showTranslateTextDialog(context, node.content);
        },
        icon: const Icon(Icons.translate, size: 18),
      )):Container(),
      IconButton(
        onPressed: () {
          showSmartReplyDialog(context, node.content);
        },
        icon: const Icon(Icons.tips_and_updates_outlined, size: 18),
      ),
      const Expanded(child: SizedBox()),
      IconButton(
        onPressed: () {
          if (!context.read<Session>().chat.tail.finalised) return;

          if (context.read<Session>().model.missingRequirements.isNotEmpty) {
            showMissingRequirementsDialog(context);
          } else {
            context.read<Session>().regenerate(node.key, context);
            setState(() {});
          }
        },
        icon: const Icon(Icons.refresh, size: 18),
      ),
    ];
  }

  List<Widget> editingColumn() {
    final messageController = TextEditingController(text: node.content);

    return [
      TextField(
        controller: messageController,
        autofocus: true,
        cursorColor: Theme.of(context).colorScheme.secondary,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: "Edit Message",
          fillColor: Theme.of(context).colorScheme.background,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
      Row(children: [
        InkWell
        (
            onTap: () {
              if (!context.read<Session>().chat.tail.finalised) return;

              if (context
                  .read<Session>()
                  .model
                  .missingRequirements
                  .isNotEmpty) {
                showMissingRequirementsDialog(context);
              } else {
                setState(() {
                  editing = false;
                });
                context
                    .read<Session>()
                    .edit(node.key, messageController.text, context);
              }
            },
            child: const Icon(Icons.done)),
        const SizedBox(width: 16),
        InkWell
          (
            onTap: () {
              setState(() {
                editing = false;
              });
            },
            child: const Icon(Icons.close))
      ])
    ];
  }

  List<Widget> standardColumn() {
    return [
      if (!node.finalised)
        const TypingIndicator() // Assuming TypingIndicator is a custom widget you've defined.
      else
        messageBuilder(node.content),
    ];
  }
}
