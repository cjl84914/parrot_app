import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
import 'package:provider/provider.dart';

Future storageOperationDialog(BuildContext context,
    Future<String> Function(BuildContext context) storageFunction) async{
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<String>(
        future: storageFunction(context),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AlertDialog(
              title: Text(snapshot.data!, textAlign: TextAlign.center),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Close",
                  ),
                ),
              ],
            );
          } else {
            return const AlertDialog(
                title: Text("Storage Operation Pending",
                    textAlign: TextAlign.center),
                content: Center(
                  heightFactor: 1.0,
                  child: CircularProgressIndicator(),
                ));
          }
        },
      );
    },
  );
}

void showMissingRequirementsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final requirement = context.read<Session>().model.missingRequirements;

      return AlertDialog(
        title: const Text("请按照提示操作", textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(requirement.join()),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c){
                return const CharacterCustomizationPage();
              }));
            },
            child: const Text(
              "去设置",
            ),
          ),
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "关闭",
              style: TextStyle(color: Colors.grey)
            ),
          ),
        ],
      );
    },
  );
}

void showTranslateTextDialog(BuildContext context, String content) async {
  final onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.chinese);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        content: SingleChildScrollView(
            child: FutureBuilder(
                future: onDeviceTranslator.translateText(content),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    var response = snapshot.data;
                    return SelectableText("$content\n\n$response");
                  }
                })),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Close",
            ),
          ),
        ],
      );
    },
  );
}

void showSmartReplyDialog(BuildContext context, String content) async {
  String translateText = "";
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            scrollable: true,
            content: SingleChildScrollView(
                child: FutureBuilder(
                    future: context.read<Session>().getTips(),
                    builder: (c, AsyncSnapshot s) {
                      if (s.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Column(children: [
                          SelectableText(s.data),
                          !kIsWeb
                              ? Visibility(
                                  visible: Platform.isIOS || Platform.isAndroid,
                                  child:
                                      StatefulBuilder(builder: (c, setState) {
                                    return translateText == ""
                                        ? IconButton(
                                            onPressed: () async {
                                              final onDeviceTranslator =
                                                  OnDeviceTranslator(
                                                      sourceLanguage:
                                                          TranslateLanguage
                                                              .english,
                                                      targetLanguage:
                                                          TranslateLanguage
                                                              .chinese);
                                              translateText =
                                                  await onDeviceTranslator
                                                      .translateText(s.data);
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.translate,
                                                size: 18),
                                          )
                                        : Text(translateText);
                                  }))
                              : Container()
                        ]);
                      }
                    })),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Close",
                ),
              ),
            ]);
      });
}
