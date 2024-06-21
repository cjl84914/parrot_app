import 'package:flutter/material.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/ui/mobile/pages/platforms/baiduai_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/openai_page.dart';
import 'package:parrot/ui/mobile/pages/platforms/zhipuai_page.dart';
import 'package:parrot/ui/mobile/widgets/dropdowns/llm_dropdown.dart';
import 'package:provider/provider.dart';

class ModelSettingPage extends StatefulWidget {
  const ModelSettingPage({super.key});

  @override
  State<ModelSettingPage> createState() => _ModelSettingPageState();
}

class _ModelSettingPageState extends State<ModelSettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0.0,
          actions: const [
            LlmDropdown(),
          ],
        ),
        body: Consumer<Session>(builder: (context, session, child) {
          switch (session.model.type) {
            // case LargeLanguageModelType.llamacpp:
            //   return const LlamaCppPage();
            case LargeLanguageModelType.ollama:
              return const OllamaPage();
            case LargeLanguageModelType.openAI:
              return const OpenAiPage();
            case LargeLanguageModelType.mistralAI:
              return const MistralAiPage();
            case LargeLanguageModelType.gemini:
              return const GoogleGeminiPage();
            case LargeLanguageModelType.baiduAI:
              return const BaiduAiPage();
            case LargeLanguageModelType.ZhiPuAI:
              return const ZhiPuAiPage();
            default:
              return Container();
          }
        }));
  }
}
