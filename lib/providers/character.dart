import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/static/utilities.dart';
import 'package:path_provider/path_provider.dart';

class Character {
  File? _profile;
  String _name = "";
  String _system = "";

  Character() {
    reset();
  }

  Character.fromMap(Map<String, dynamic> inputJson) {
    fromMap(inputJson);
  }

  Character copy() {
    Character newCharacter = Character();
    newCharacter.from(this);
    return newCharacter;
  }

  void from(Character character) async {
    _profile = await character.profile;
    _name =  character.name;
    _system = character.system;
  }

  Future<void> fromMap(Map<String, dynamic> inputJson) async {
    if (inputJson["profile"] != null) {
      _profile = File(inputJson["profile"]);
    } else if (_profile == null ||
        _profile!.path.contains("defaultCharacter")) {
      _profile = await Utilities.fileFromAssetImage("defaultCharacter.png");
    }
    fromMCFMap(inputJson);
  }

  void fromMCFMap(Map<String, dynamic> inputJson) {
    _name = inputJson["name"] ?? "Unknown";
    _system = inputJson["system_prompt"] ?? "";
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["profile"] = _profile?.path;
    jsonCharacter["name"] = _name;
    jsonCharacter["system_prompt"] = _system;

    return jsonCharacter;
  }

  set name(String newName) {
    _name = newName;
  }

  set system(String newSystem) {
    _system = newSystem;
  }

  Future<File> get profile async {
    return _profile ??=
        await Utilities.fileFromAssetImage("defaultCharacter.png");
  }

  String get hash {
    Uint8List bytes;

    if (_profile != null) {
      bytes = _profile!.readAsBytesSync();
    } else {
      List<String> hashList = [
        _name,
        _system,
      ];

      bytes = utf8.encode(hashList.join());
    }

    return sha256.convert(bytes).toString();
  }

  Key get key => ValueKey(hash);

  String get name => _name;

  String get system => _system;

  Future<void> reset() async {
    _profile = await Utilities.fileFromAssetImage("defaultCharacter.png");
    final jsonString =
        await rootBundle.loadString('assets/default_character.json');

    Map<String, dynamic> jsonCharacter = json.decode(jsonString);

    await fromMap(jsonCharacter);

    Logger.log("Character reset");
  }

  Future<String> importImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          dialogTitle: "Load Character Image",
          type: FileType.image,
          allowMultiple: false,
          allowCompression: false);

      File file;
      if (result != null && result.files.isNotEmpty) {
        Logger.log("File selected: ${result.files.single.path}");
        file = File(result.files.single.path!);
      } else {
        Logger.log("No file selected");
        throw Exception("File is null");
      }

      final bytes = file.readAsBytesSync();

      final image = decodeImage(bytes);

      bool characterLoaded = false;
      if (image != null && image.textData != null) {
        if (image.textData!["Chara"] != null ||
            image.textData!["chara"] != null) {
          Uint8List utf8Character = base64
              .decode(image.textData!["Chara"] ?? image.textData!["chara"]!);
          String stringCharacter = utf8.decode(utf8Character);
          Map<String, dynamic> jsonCharacter = json.decode(stringCharacter);

          await fromMap(jsonCharacter);
          characterLoaded = true;
        }
      }

      Directory docDir = await getApplicationDocumentsDirectory();
      File newProfileFile = File('${docDir.path}/$_name.png');
      await newProfileFile.writeAsBytes(bytes);

      _profile = newProfileFile;

      if (characterLoaded) {
        return "Character Successfully Loaded";
      } else {
        return "Image Successfully Loaded";
      }

    } catch (e) {
      await reset();
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }
}
