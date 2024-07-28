import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parrot/ui/mobile/pages/about_page.dart';
import 'package:parrot/ui/mobile/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("更多")),
      body: Column(children: [
        Card(
            elevation: 0,
            margin: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  title: const Text("应用设置"),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()));
                  }),
              Divider(
                height: 0.0,
              ),
              ListTile(
                  title: const Text("关于"),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return const AboutPage();
                    }));
                  }),
            ])),
      ]),
    );
  }
}
