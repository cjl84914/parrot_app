import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parrot/classes/baidu_ai_model.dart';
import 'package:parrot/classes/google_gemini_model.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/classes/lingyi_ai_model.dart';
import 'package:parrot/classes/llama_cpp_model.dart';
import 'package:parrot/classes/mistral_ai_model.dart';
import 'package:parrot/classes/moon_ai_model.dart';
import 'package:parrot/classes/ollama_model.dart';
import 'package:parrot/classes/open_ai_model.dart';
import 'package:parrot/classes/qwen_ai_model.dart';
import 'package:parrot/classes/zhipu_ai_model.dart';
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
  LargeLanguageModel model = LargeLanguageModel();
  ChatNodeTree chat = ChatNodeTree();
  Character character = Character();

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
    name = "新的对话";
    chat = ChatNodeTree();
    model = LargeLanguageModel(listener: notify);
    character = Character();
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
    character = session.character;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      newSession();
      return;
    }

    _name = inputJson['name'] ?? "New Chat";

    chat.root = ChatNode.fromMap(inputJson['chat'] ?? {});
    character = Character.fromMap(inputJson['character'] ?? {});

    final type = LargeLanguageModelType
        .values[inputJson['llm_type'] ?? LargeLanguageModelType.llamacpp.index];

    switch (type) {
      case LargeLanguageModelType.openAI:
        switchOpenAI();
        break;
      case LargeLanguageModelType.ollama:
        switchOllama();
        break;
      case LargeLanguageModelType.mistralAI:
        switchMistralAI();
        break;
      case LargeLanguageModelType.baiduAI:
        switchBaiduAI();
        break;
      case LargeLanguageModelType.gemini:
        switchGemini();
        break;
      case LargeLanguageModelType.zhiPuAI:
        switchZhiPuAI();
        break;
      case LargeLanguageModelType.lingYiAI:
        switchLingYiAI();
        break;
      case LargeLanguageModelType.moonshotAI:
        switchMoonshotAI();
        break;
      case LargeLanguageModelType.qWenAi:
        switchQWenAI();
        break;
      default:
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
      'character': character.toMap()
    };
  }

  void prompt(BuildContext context) async {
    final user = context.read<User>();
    final tts = context.read<TTS>();
    final system = Utilities.formatPlaceholders(
        character.system, user.name, character.name);

    List<ChatNode> messages = [];

    messages.add(
        ChatNode(key: UniqueKey(), role: ChatRole.system, content: system));
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
    // if (model is LlamaCppModel) {
    //   (model as LlamaCppModel).stop();
    //   Logger.log('Local generation stopped');
    // }
    notifyListeners();
  }

  void finalise() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("last_session", json.encode(toMap()));
    });

    notifyListeners();
  }

  /// -------------------------------------- Model Switching --------------------------------------

  // void switchLlamaCpp() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   Map<String, dynamic> lastLlamaCpp =
  //       json.decode(prefs.getString("llama_cpp_model") ?? "{}");
  //   Logger.log(lastLlamaCpp.toString());
  //
  //   if (lastLlamaCpp.isNotEmpty) {
  //     model = LlamaCppModel.fromMap(notify, lastLlamaCpp);
  //   } else {
  //     model = LlamaCppModel(listener: notify);
  //   }
  //
  //   prefs.setInt("llm_type", model.type.index);
  //   notifyListeners();
  // }

  void switchOpenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI =
        json.decode(prefs.getString("open_ai_model") ?? "{}");
    // Logger.log(lastOpenAI.toString());

    if (lastOpenAI.isNotEmpty) {
      model = OpenAiModel.fromMap(notify, lastOpenAI);
    } else {
      model = OpenAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOllama() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama =
        json.decode(prefs.getString("ollama_model") ?? "{}");
    // Logger.log(lastOllama.toString());

    if (lastOllama.isNotEmpty) {
      model = OllamaModel.fromMap(notify, lastOllama);
    } else {
      model = OllamaModel(listener: notify);
      model.reset();
      await model.resetUri();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchMistralAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI =
        json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    // Logger.log(lastMistralAI.toString());

    if (lastMistralAI.isNotEmpty) {
      model = MistralAiModel.fromMap(notify, lastMistralAI);
    } else {
      model = MistralAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchGemini() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastGemini =
        json.decode(prefs.getString("google_gemini_model") ?? "{}");
    // Logger.log(lastGemini.toString());

    if (lastGemini.isNotEmpty) {
      model = GoogleGeminiModel.fromMap(notify, lastGemini);
    } else {
      model = GoogleGeminiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchBaiduAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel =
        json.decode(prefs.getString("baidu_ai_model") ?? "{}");
    // Logger.log(lastModel.toString());

    if (lastModel.isNotEmpty) {
      model = BaiduAiModel.fromMap(notify, lastModel);
    } else {
      model = BaiduAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchZhiPuAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel =
    json.decode(prefs.getString("zhipu_ai_model") ?? "{}");
    // Logger.log(lastModel.toString());

    if (lastModel.isNotEmpty) {
      model = ZhiPuAiModel.fromMap(notify, lastModel);
    } else {
      model = ZhiPuAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchLingYiAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel =
    json.decode(prefs.getString("lingyi_ai_model") ?? "{}");
    // Logger.log(model.toString());

    if (lastModel.isNotEmpty) {
      model = LingYiAiModel.fromMap(notify, lastModel);
    } else {
      model = LingYiAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchMoonshotAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel =
    json.decode(prefs.getString("moon_ai_model") ?? "{}");
    // Logger.log(model.toString());

    if (lastModel.isNotEmpty) {
      model = MoonAiModel.fromMap(notify, lastModel);
    } else {
      model = MoonAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchQWenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel =
    json.decode(prefs.getString("qwen_ai_model") ?? "{}");
    // Logger.log(model.toString());

    if (lastModel.isNotEmpty) {
      model = QWenAiModel.fromMap(notify, lastModel);
    } else {
      model = QWenAiModel(listener: notify);
      model.reset();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }
}
