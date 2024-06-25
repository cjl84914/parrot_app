import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TopPParameter extends StatelessWidget {
  const TopPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'top_p',
          tips: "与temperature类似，但是不要和随机性一起改",
          inputValue: session.model.topP,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.topP = value;
            session.notify();
          }
        );
      }
    );
  }
}
