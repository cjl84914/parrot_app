import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/static/utilities.dart';

class User extends ChangeNotifier {
  static File? _customImage;

  static Future<File> get customImageFuture async {
    return _customImage ?? await Utilities.fileFromAssetImage("blankCustomUser.png");
  }

  Key _key = UniqueKey();
  File? _profile;
  String _name = "用户";

  User() {
    reset();
  }

  User.from(User user) {
    _key = user.key;
    _profile = user.profileFile;
    _name = user.name;
  }

  User.fromMap(Map<String, dynamic> inputMap) {
    fromMap(inputMap);
  }

  Future<File> get profile async {
    return _profile ?? await Utilities.fileFromAssetImage("chadUser.png");
  }

  File? get profileFile => _profile;
  String get name => _name;
  
  Key get key => _key;

  set profile(Future<File> value) {
    value.then((File file) {
      _profile = file;
      notifyListeners();
    });
  }

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputMap) async {
    if (inputMap.isEmpty) {
      reset();
      return;
    }

    if (inputMap["customImage"] != null) {
      _customImage = File(inputMap["customImage"]);
    } else {
      _customImage = await Utilities.fileFromAssetImage("blankCustomUser.png");
    }

    if (inputMap["profile"] != null) {
      _profile = File(inputMap["profile"]);
    } else {
      _profile = await Utilities.fileFromAssetImage("chadUser.png");
    }

    _name = inputMap["name"];
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      "customImage": _customImage?.path,
      "profile": _profile!.path,
      "name": _name,
    };
  }

  void reset() async {
    _customImage = await Utilities.fileFromAssetImage("blankCustomUser.png");
    _profile = await Utilities.fileFromAssetImage("chadUser.png");
    _name = "用户";
    notifyListeners();
  }

  void loadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Load Custom User Image",
        type: FileType.image,
      );

      if (result != null) {
        _customImage = File(result.files.single.path!);
        _profile = _customImage;
        notifyListeners();
      }
    } catch (e) {
      Logger.log("Failed to load image: $e");
    }
  }

  @override
  void notifyListeners() {
    _key = UniqueKey();
    super.notifyListeners();
  }
}
