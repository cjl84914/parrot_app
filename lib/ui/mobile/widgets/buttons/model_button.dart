import 'package:flutter/material.dart';
import 'package:parrot/classes/large_language_model.dart';
import 'package:parrot/providers/session.dart';
import 'package:provider/provider.dart';

class ModelButton extends StatefulWidget {
  const ModelButton({super.key});

  @override
  State<ModelButton> createState() => _ModelButtonState();
}

class _ModelButtonState extends State<ModelButton> {
  final iconButtonKey = GlobalKey();
  LargeLanguageModelType lastModelType = LargeLanguageModelType.none;
  List<String> options = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      return ListTile(
          title: Row(
        children: [
          const Expanded(
            child: Text("Model Name"),
          ),
          Builder(builder: (c) {
            lastModelType = session.model.type;
            if(session.model.options==null){
              return Container();
            }
            return FutureBuilder(
                future: session.model.options,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    options = snapshot.data as List<String>;
                    List<DropdownMenuEntry<dynamic>> modelOptions = options
                        .map((String modelName) => DropdownMenuEntry(
                              label: modelName,
                              value: modelName,
                            ))
                        .toList();
                    return DropdownMenu(
                      hintText: "Select Model",
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      dropdownMenuEntries: modelOptions,
                      enabled: modelOptions.isNotEmpty,
                      onSelected: (value) {
                        if (value != null) {
                          session.model.name = value;
                          session.notify();
                        }
                      },
                      initialSelection: session.model.name,
                      width: 200,
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      // Adjust padding to match the visual space of the IconButton
                      child: SizedBox(
                        width: 24,
                        // Width of the CircularProgressIndicator
                        height: 24,
                        // Height of the CircularProgressIndicator
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth:
                                3.0, // Adjust the thickness of the spinner here
                          ),
                        ),
                      ),
                    );
                  }
                });
          })
        ],
      ));
    });
  }
}
