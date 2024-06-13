import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TtsState { initialized, playing, stopped, paused, continued }

class TTS with ChangeNotifier {
  late SharedPreferences prefs;
  late FlutterTts flutterTts;
  dynamic ttsSetting = {"volume": 1.0, "pitch": 1.0, "rate": 0.5};
  bool isCurrentLanguageInstalled = false;
  TtsState ttsState = TtsState.stopped;

  double volume = 1.0;
  double pitch = 0.5;
  double rate = 0.5;
  bool isMuted = false;

  TTS() {
    if (isSupportingOS()) {
      init();
    }
  }

  bool isSupportingOS() {
    if (kIsWeb) {
      return true;
    }
    return Platform.isIOS ||
            Platform.isAndroid ||
            Platform.isWindows ||
            Platform.isWindows
        ? true
        : false;
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    flutterTts = FlutterTts();
    _setAwaitOptions();
    if(!kIsWeb) {
      if (Platform.isIOS) {
        await flutterTts.setSharedInstance(true);
        await flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers
            ],
            IosTextToSpeechAudioMode.voicePrompt);
      }
    }
    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
      print("playing");
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setCancelHandler(() {
      ttsState = TtsState.stopped;
      print("cancel");
      notifyListeners();
    });

    flutterTts.setPauseHandler(() {
      ttsState = TtsState.paused;
      print("paused");
      notifyListeners();
    });

    flutterTts.setContinueHandler(() {
      ttsState = TtsState.continued;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
      notifyListeners();
    });
    initSetting();
  }

  initSetting() {
    String? ttsString = prefs.getString("ttsSetting");
    if (ttsString != null) {
      ttsSetting = jsonDecode(ttsString);
      volume = ttsSetting["volume"];
      rate = ttsSetting["rate"];
      pitch = ttsSetting["pitch"];
    }
  }

  saveSetting() {
    ttsSetting = {"volume": volume, "pitch": pitch, "rate": rate};
    prefs.setString("ttsSetting", jsonEncode(ttsSetting));
  }

  void setVolume(double volume) async {
    this.volume = volume;
    flutterTts.setVolume(volume);
  }

  void setSpeechRate(double rate) async {
    this.rate = rate;
    flutterTts.setSpeechRate(rate);
  }

  void setPitch(double pitch) async {
    this.pitch = pitch;
    flutterTts.setPitch(pitch);
  }

  Future speak(text) async {
    if (isSupportingOS()) {
      if (text != null && text != "") {
        if (ttsState == TtsState.playing) {
          await stop();
        }
        await flutterTts.speak(text);
      }
    }
  }

  Future stop() async {
    flutterTts.stop();
  }

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> getEngines() async => await flutterTts.getEngines;

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<bool> isSupport(String language) async {
    return await flutterTts.isLanguageAvailable(language);
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?,
          child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(type as String, maxLines: 1))));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      if (type.toString().startsWith("zh")) {
        items.add(DropdownMenuItem(
            value: type as String?, child: Text(type as String)));
      }
    }
    return items;
  }

  void notify() {
    notifyListeners();
  }

  void autoPlay(text) {
    if (!isMuted) {
      speak(text);
    }
  }
}
