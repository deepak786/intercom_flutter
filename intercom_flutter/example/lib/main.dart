import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: make sure to add keys from your Intercom workspace.
  await Intercom.instance.initialize(
    'appId',
    androidApiKey: 'androidApiKey',
    iosApiKey: 'iosApiKey',
  );
  // TODO: don't forget to set up the custom application class on Android side.
  runApp(SampleApp());
}

class SampleApp extends StatefulWidget {
  @override
  _SampleAppState createState() => _SampleAppState();
}

class _SampleAppState extends State<SampleApp> {
  StreamSubscription? _windowDidHideSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for when the Intercom window is hidden
    _windowDidHideSubscription =
        Intercom.instance.getWindowDidHideStream().listen((_) {
      // This will be called when the Intercom window is closed
      // Only works on iOS
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intercom window was closed!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _windowDidHideSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Intercom example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // NOTE:
                  // Messenger will load the messages only if the user is registered
                  // in Intercom.
                  // Either identified or unidentified.
                  // So make sure to login the user in Intercom first before opening
                  // the intercom messenger.
                  // Otherwise messenger will not load.
                  Intercom.instance.displayMessenger();
                },
                child: Text('Show messenger'),
              ),
              SizedBox(height: 20),
              Text(
                'Close the Intercom window to see the notification!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
