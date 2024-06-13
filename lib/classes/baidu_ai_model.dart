import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaiduAiModel extends LargeLanguageModel {
  static const String defaultUrl = 'https://aip.baidubce.com';

  @override
  LargeLanguageModelType get type => LargeLanguageModelType.baidu;

  BaiduAiModel(
      {super.listener,
      super.name = 'yi_34b_chat',
      super.uri = defaultUrl,
      super.token,
      super.useDefault,
      super.seed,
      super.temperature,
      super.topK,
      super.topP});

  BaiduAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  List<String> get missingRequirements {
    List<String> missing = [];

    if (token.isEmpty) {
      missing.add('- 请输入API Key.\n');
    }

    if (name.isEmpty) {
      missing.add('- 请选择一个模型.\n');
    }

    return missing;
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    uri = json['url'] ?? defaultUrl;
    notifyListeners();
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    List<Map<String, dynamic>> chat = [];
    for (var message in messages) {
      Logger.log("Message: ${message.content}");
      if (message.content.isEmpty) {
        continue;
      }
      switch (message.role) {
        case ChatRole.user:
          chat.add({
            'role': "user",
            'content': message.content,
          });
          break;
        case ChatRole.assistant:
          chat.add({
            'role': "assistant",
            'content': message.content,
          });
          break;
        default:
          break;
      }
    }
    try {
      final url = Uri.parse(
          '$uri/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/$name?access_token=$token');
      final headers = {'content-type': 'application/json'};
      final body = {'messages': chat, 'stream': true};
      var request = Request("POST", url)
        ..headers.addAll(headers)
        ..body = jsonEncode(body);
      final response = await request.send();
      final stream = response.stream.transform(utf8.decoder);
      await for (var line in stream) {
        dynamic data = jsonDecode(line.replaceAll('data:', ''));
        final errorMsg = data['error_msg'];
        if (errorMsg == null) {
          final content = data['result'] as String?;
          if (content != null && content.isNotEmpty) {
            yield content;
          }
        } else {
          yield errorMsg;
          Logger.log(errorMsg);
        }
      }
    } catch (e) {
      yield e.toString();
      Logger.log(e.toString());
    }
  }

  @override
  Future<List<String>> get options async {
    return ["yi_34b_chat"];
  }

  @override
  Future<void> resetUri() async {
    uri = defaultUrl;
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("baidu_ai_model", json.encode(toMap()));
    });
  }

  @override
  void reset() {
    fromMap({});
  }
}
