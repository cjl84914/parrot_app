import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyFrequencyParameter extends StatelessWidget {
  const PenaltyFrequencyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'penalty_freq',
            tips: "值越大，越有可能降低重复字词",
          inputValue: session.model.penaltyFreq,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.penaltyFreq = value;
            session.notify();
          }
        );
      }
    );
  }
}
