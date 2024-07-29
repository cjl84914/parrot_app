import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QWenAiModel extends LargeLanguageModel {
  static const String defaultUrl = 'https://dashscope.aliyuncs.com/compatible-mode/v1';

  @override
  LargeLanguageModelType get type => LargeLanguageModelType.qWenAi;

  QWenAiModel({
    super.listener,
    super.name,
    super.uri = defaultUrl,
    super.token,
    super.seed,
    super.nPredict,
    super.topP,
    super.penaltyPresent,
    super.penaltyFreq,
  });

  QWenAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    uri = json['url'] ?? defaultUrl;
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 1500;
    temperature = json['temperature'] ?? 0.8;
    topP = json['topP'] ?? 0.8;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyRepeat = json['penaltyRepeat'] ?? 0.0;
    notifyListeners();
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    List<ChatMessage> chatMessages = [];

    for (var message in messages) {
      Logger.log("Message: ${message.content}");
      if (message.content.isEmpty) {
        continue;
      }

      switch (message.role) {
        case ChatRole.user:
          chatMessages.add(ChatMessage.humanText(message.content));
          break;
        case ChatRole.assistant:
          chatMessages.add(ChatMessage.ai(message.content));
          break;
        case ChatRole.system: // Under normal circumstances, this should only be used for preprompt
          chatMessages.add(ChatMessage.system(message.content));
          break;
        default:
          break;
      }
    }
    try {
      final chat = ChatOpenAI(
        baseUrl: uri,
        apiKey: token,
        defaultOptions: ChatOpenAIOptions(
          model: name,
          temperature: temperature,
          frequencyPenalty: penaltyFreq,
          presencePenalty: penaltyPresent,
          maxTokens: nPredict,
          topP: topP
        )
      );
      final stream = chat.stream(PromptValue.chat(chatMessages));
      await for(var line in stream){
        yield line.output.content;
      }
    } catch (e) {
      final exception = e as OpenAIClientException;
      yield exception.toString();
      Logger.log('Error: $e');
    }
  }

  @override
  Future<List<String>> get options async {
    return ["qwen-long" ,"qwen-turbo" ,"qwen-plus","qwen-max","qwen-max-0428","qwen-max-0403","qwen-max-0107","qwen-max-longcontext"];
  }

  @override
  Future<void> resetUri() async {
    uri = defaultUrl;
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("qwen_ai_model", json.encode(toMap()));
    });
  }

  @override
  void reset() {
    fromMap({});
  }
}