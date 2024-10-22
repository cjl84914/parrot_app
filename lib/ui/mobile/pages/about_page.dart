import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parrot/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "";

  @override
  void initState() {
    getVersion();
    super.initState();
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GenericAppBar(title: "关于语鹦助手"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
          child: Column(children: [
            const SizedBox(height: 20.0),
            Image.asset(
              "assets/parrot.png",
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 10.0),
            Text(
              'Parrot Assistant',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10.0),
            Text("版本: $version"),
            const SizedBox(height: 30.0),
            Linkify(
                onOpen: _onOpen,
                text:
                    '语鹦助手是一个跨平台的免费开源的AI助手，用于聊天、学习英语、辅助教学等。该项目基于Flutter开发，用于远程与智谱AI、通义千问、零一万物、Moonshot、Ollama、Mistral、Google Gemini和OpenAI模型接口。',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30.0),
            Text(
              '开发者',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Dane Madsen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Alex Cai',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'sfiannaca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'gardner',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]),
        ));
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }
}
