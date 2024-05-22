import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:parrot/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
            const SizedBox(height: 30.0),
            Text(
              'Parrot Assistant',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20.0),
            Linkify(
                onOpen: _onOpen,
                text:
                    'Maid is a cross-platform open source app for interacting with GGUF Large Language Models. '
                    'This app is distributed under the MIT License. The source code of this project can be found '
                    'on github ( https://github.com/MaidFoundation/Maid ). Maid is not affiliated with Meta, '
                    'OpenAI or any other company that provides a model which can be used with this app. Model files are '
                    'not included with this app and must be downloaded separately. Model files can be downloaded online '
                    'at https://huggingface.co',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20.0),
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
