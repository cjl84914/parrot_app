import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/n_keep_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/penalize_nl_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/mirostat_eta_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/mirostat_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/mirostat_tau_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/n_batch_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/n_ctx_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/n_threads_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/penalty_frequency_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/penalty_last_n_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/penalty_present_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/penalty_repeat_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/tfs_z_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/top_k_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/typical_p_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/url_parameter.dart';
import 'package:parrot/ui/mobile/widgets/parameter_widgets/use_default.dart';
import 'package:parrot/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OllamaPage extends StatelessWidget {
  const OllamaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Ollama Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<Session>(
          builder: (context, session, child) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("ollama_model", json.encode(session.model.toMap()));
            });

            return ListView(
              children: [
                Align(
                  alignment: Alignment.center, // Center the button horizontally
                  child: FilledButton(
                    onPressed: () {
                      session.model.reset();
                    },
                    child: Text(
                      "Reset",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const ApiKeyParameter(),
                Divider(
                  height: 20,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const UrlParameter(),
                const SizedBox(height: 8.0),
                const SeedParameter(),
                const UseDefaultParameter(),
                if (!session.model.useDefault) ...[
                  const SizedBox(height: 20.0),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const PenalizeNlParameter(),
                  const NThreadsParameter(),
                  const NCtxParameter(),
                  const NBatchParameter(),
                  const NPredictParameter(),
                  const NKeepParameter(),
                  const TopKParameter(),
                  const TopPParameter(),
                  const TfsZParameter(),
                  const TypicalPParameter(),
                  const TemperatureParameter(),
                  const PenaltyLastNParameter(),
                  const PenaltyRepeatParameter(),
                  const PenaltyFrequencyParameter(),
                  const PenaltyPresentParameter(),
                  const MirostatParameter(),
                  const MirostatTauParameter(),
                  const MirostatEtaParameter()
                ]
              ]
            );
          },
        )
      )
    );
  }
}
