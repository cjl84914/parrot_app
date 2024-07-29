import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LingYiAiModel extends LargeLanguageModel {
  static const String defaultUrl = 'https://api.lingyiwanwu.com/v1';

  @override
  LargeLanguageModelType get type => LargeLanguageModelType.lingYiAI;

  LingYiAiModel({
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

  LingYiAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    uri = json['url'] ?? defaultUrl;
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 1024;
    topP = json['topP'] ?? 0.9;
    temperature = json['temperature'] ?? 0.3;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
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
        case ChatRole
              .system: // Under normal circumstances, this should only be used for preprompt
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
              maxTokens: nPredict,
              topP: topP
          ));

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
    try {
      final url = Uri.parse('https://api.lingyiwanwu.com/v1/models');

      final headers = {
        'Content-Type': 'application/json',
        'Accept':'application/json',
        'Authorization':'Bearer $token',
      };

      final request = Request("GET", url)
        ..headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode == 200) {
        print(response.statusCode);
        final body = await response.stream.bytesToString();
        final data = json.decode(body);
        Logger.log('Data: $data');

        final models = data['data'] as List<dynamic>?;

        if (models != null) {
          return models
              .map((model) => model['id'] as String)
              .toList();
        } else {
          throw Exception('Model Data is null');
        }
      } else {
        throw Exception('Failed to update options: ${response.statusCode}');
      }
    } catch (e) {
      Logger.log('Error: $e');
      return [
        "yi-large",
        "yi-medium",
        "yi-vision",
        "yi-medium-200k",
        "yi-spark",
        "yi-large-rag",
        "yi-large-turbo",
        "yi-large-preview"
      ];
    }
  }

  @override
  Future<void> resetUri() async {
    uri = defaultUrl;
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("lingyi_ai_model", json.encode(toMap()));
    });
  }

  @override
  void reset() {
    fromMap({});
  }
}
