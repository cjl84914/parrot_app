import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/static/logger.dart';
import 'package:parrot/main.dart';
import 'package:parrot/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:parrot/ui/mobile/widgets/code_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info2/system_info2.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static int ram = -1;
  @override
  void initState() {
    if(!kIsWeb) {
      if (!Platform.isIOS) {
        ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "应用设置"),
      body: Consumer<MainProvider>(
        builder: (context, mainProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                    child: Row(
                    children: [
                      const Expanded(
                        child: Text("主题模式"),
                      ),
                      DropdownMenu<ThemeMode>(
                        hintText: "选择主题",
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry<ThemeMode>(
                            value: ThemeMode.system,
                            label: "系统默认",
                          ),
                          DropdownMenuEntry<ThemeMode>(
                            value: ThemeMode.light,
                            label: "浅色",
                          ),
                          DropdownMenuEntry<ThemeMode>(
                            value: ThemeMode.dark,
                            label: "深色",
                          )
                        ],
                        onSelected: (ThemeMode? value) {
                          if (value != null) {
                            mainProvider.themeMode = value;
                          }
                        },
                        initialSelection: mainProvider.themeMode,
                        width: 200,
                      )
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.clear();
                      mainProvider.reset();
                      context.read<User>().reset();
                      context.read<Session>().newSession();
                      setState(() {
                        Logger.clear();
                      });
                    });
                  },
                  child: const Text("清除所有缓存"),
                ),
                Divider(
                  height: 20,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: CodeBox(code: Logger.getLog)),
                Text(
                  ram == -1 ? 'RAM: Unknown' : 'RAM: $ram GB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8) / 8) ??
                            Colors.red,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
