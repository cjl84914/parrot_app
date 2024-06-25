import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NPredictParameter extends StatelessWidget {
  const NPredictParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      return SliderListTile(
          labelText: 'max_tokens',
          tips: "聊天完成时生成的最大 token 数",
          inputValue: session.model.nPredict,
          sliderMin: 1.0,
          sliderMax: 4096.0,
          sliderDivisions: 4095,
          onValueChanged: (value) {
            session.model.nPredict = value.round();
            session.notify();
          });
    });
  }
}
