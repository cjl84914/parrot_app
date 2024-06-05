import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parrot/classes/baidu_ai_model.dart';
import 'package:parrot/classes/google_gemini_model.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/classes/llama_cpp_model.dart';
import 'package:parrot/classes/mistral_ai_model.dart';
import 'package:parrot/classes/ollama_model.dart';
import 'package:parrot/classes/open_ai_model.dart';
import 'package:parrot/providers/character.dart';
import 'package:parrot/providers/tts.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/static/utilities.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node.dart';
import 'package:parrot/ui/mobile/widgets/llm/chat_node_tree.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  Key _key = UniqueKey();
  LargeLanguageModel model = LlamaCppModel();
  ChatNodeTree chat = ChatNodeTree();

  String _name = "";

  String get name => _name;

  Key get key => _key;

  set busy(bool value) {
    notifyListeners();
  }

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Session() {
    newSession();
  }

  Session.from(Session session) {
    from(session);
  }

  Session.fromMap(Map<String, dynamic> inputJson) {
    fromMap(inputJson);
  }

  void newSession() {
    name = "New Chat";
    chat = ChatNodeTree();
    model = LlamaCppModel(listener: notify);
    notifyListeners();
  }

  Session copy() {
    return Session.from(this);
  }

  void from(Session session) {
    _key = session.key;
    _name = session.name;
    chat = session.chat;
    model = session.model;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      newSession();
      return;
    }

    _name = inputJson['name'] ?? "New Chat";

    chat.root = ChatNode.fromMap(inputJson['chat'] ?? {});

    final type = LargeLanguageModelType
        .values[inputJson['llm_type'] ?? LargeLanguageModelType.llamacpp.index];

    switch (type) {
      case LargeLanguageModelType.llamacpp:
        switchLlamaCpp();
        break;
      case LargeLanguageModelType.openAI:
        switchOpenAI();
        break;
      case LargeLanguageModelType.ollama:
        switchOllama();
        break;
      case LargeLanguageModelType.mistralAI:
        switchMistralAI();
        break;
      case LargeLanguageModelType.baidu:
        switchBaiduAI();
        break;
      default:
        switchLlamaCpp();
        break;
    }

    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'chat': chat.root.toMap(),
      'llm_type': model.type.index,
      'model': model.toMap(),
    };
  }

  void prompt(BuildContext context) async {
    final user = context.read<User>();
    final character = context.read<Character>();
    final tts = context.read<TTS>();
    final description = Utilities.formatPlaceholders(
        character.description, user.name, character.name);
    final personality = Utilities.formatPlaceholders(
        character.personality, user.name, character.name);
    final scenario = Utilities.formatPlaceholders(
        character.scenario, user.name, character.name);
    final system = Utilities.formatPlaceholders(
        character.system, user.name, character.name);

    final preprompt =
        'Description: $description\nPersonality: $personality\nScenario: $scenario\nSystem: $system';

    List<ChatNode> messages = [];

    messages.add(
        ChatNode(key: UniqueKey(), role: ChatRole.system, content: preprompt));
    messages.addAll(chat.getChat());

    Logger.log("Prompting with ${model.type.name}");

    final stringStream = model.prompt(messages);

    await for (var message in stringStream) {
      chat.tail.content += message;
      notifyListeners();
    }
    chat.tail.finalised = true;
    tts.autoPlay(chat.tail.content);
    notifyListeners();
  }

  Future<String> getTips() async {
    List<ChatNode> messages = [
      ChatNode(
          key: UniqueKey(), content: chat.tail.content, role: ChatRole.user)
    ];
    String tips = '';
    final stringStream = model.prompt(messages);
    await for (var message in stringStream) {
      tips += message;
    }
    return tips;
  }

  void regenerate(Key key, BuildContext context) {
    var parent = chat.parentOf(key);
    if (parent == null) {
      return;
    }
    parent.currentChild = null;
    chat.add(UniqueKey(), role: ChatRole.assistant);

    prompt(context);
    notifyListeners();
  }

  void edit(Key key, String message, BuildContext context) {
    var parent = chat.parentOf(key);
    if (parent != null) {
      parent.currentChild = null;
    }
    chat.add(UniqueKey(), role: ChatRole.user, content: message);
    chat.add(UniqueKey(), role: ChatRole.assistant);

    prompt(context);
    notifyListeners();
  }

  void stop() {
    if (model is LlamaCppModel) {
      (model as LlamaCppModel).stop();
      Logger.log('Local generation stopped');
    }
    notifyListeners();
  }

  void finalise() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("last_session", json.encode(toMap()));
    });

    notifyListeners();
  }

  /// -------------------------------------- Model Switching --------------------------------------

  void switchLlamaCpp() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastLlamaCpp =
        json.decode(prefs.getString("llama_cpp_model") ?? "{}");
    Logger.log(lastLlamaCpp.toString());

    if (lastLlamaCpp.isNotEmpty) {
      model = LlamaCppModel.fromMap(notify, lastLlamaCpp);
    } else {
      model = LlamaCppModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOpenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI =
        json.decode(prefs.getString("open_ai_model") ?? "{}");
    Logger.log(lastOpenAI.toString());

    if (lastOpenAI.isNotEmpty) {
      model = OpenAiModel.fromMap(notify, lastOpenAI);
    } else {
      model = OpenAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOllama() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama =
        json.decode(prefs.getString("ollama_model") ?? "{}");
    Logger.log(lastOllama.toString());

    if (lastOllama.isNotEmpty) {
      model = OllamaModel.fromMap(notify, lastOllama);
    } else {
      model = OllamaModel(listener: notify);
      await model.resetUri();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchMistralAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI =
        json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    Logger.log(lastMistralAI.toString());

    if (lastMistralAI.isNotEmpty) {
      model = MistralAiModel.fromMap(notify, lastMistralAI);
    } else {
      model = MistralAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchGemini() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastGemini =
        json.decode(prefs.getString("google_gemini_model") ?? "{}");
    Logger.log(lastGemini.toString());

    if (lastGemini.isNotEmpty) {
      model = GoogleGeminiModel.fromMap(notify, lastGemini);
    } else {
      model = GoogleGeminiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchBaiduAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastBaidu =
        json.decode(prefs.getString("baidu_ai_model") ?? "{}");
    Logger.log(lastBaidu.toString());

    if (lastBaidu.isNotEmpty) {
      model = BaiduAiModel.fromMap(notify, lastBaidu);
    } else {
      model = BaiduAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }
}
