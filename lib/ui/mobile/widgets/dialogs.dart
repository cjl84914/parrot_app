  
import 'package:flutter/material.dart';
import 'package:parrot/providers/session.dart';
import 'package:provider/provider.dart';

void storageOperationDialog(BuildContext context, Future<String> Function(BuildContext context) storageFunction) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<String>(
        future: storageFunction(context),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AlertDialog(
              title: Text(
                snapshot.data!,
                textAlign: TextAlign.center
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            );
          } else {
            return const AlertDialog(
              title: Text(
                "Storage Operation Pending",
                textAlign: TextAlign.center
              ),
              content: Center(
                heightFactor: 1.0,
                child: CircularProgressIndicator(),
              )
            );
          }
        },
      );
    },
  );
}

void showMissingRequirementsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final requirement = context.read<Session>().model.missingRequirements;

      return AlertDialog(
        title: const Text(
          "请按照提示操作",
          textAlign: TextAlign.center
        ),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(
          requirement.join()
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "OK",
              style: Theme.of(context).textTheme.labelLarge
            ),
          ),
        ],
      );
    },
  );
}