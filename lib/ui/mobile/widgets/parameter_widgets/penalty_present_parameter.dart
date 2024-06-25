import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyPresentParameter extends StatelessWidget {
  const PenaltyPresentParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'penalty_present',
          tips: "值越大，越有可能扩张到新话题",
          inputValue: session.model.penaltyPresent,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.penaltyPresent = value;
            session.notify();
          }
        );
      }
    );
  }
}
