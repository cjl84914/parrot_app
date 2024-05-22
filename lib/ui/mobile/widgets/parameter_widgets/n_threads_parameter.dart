import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NThreadsParameter extends StatelessWidget {
  const NThreadsParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      return SliderListTile(
          labelText: 'n_threads',
          inputValue: session.model.nThread,
          sliderMin: 1.0,
          sliderMax: session.model.type == LargeLanguageModelType.llamacpp
              ? Platform.numberOfProcessors.toDouble()
              : 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            if (value.round() > Platform.numberOfProcessors) {
              session.model.nThread = Platform.numberOfProcessors;
            } else {
              session.model.nThread = value.round();
            }

            session.notify();
          });
    });
  }
}
