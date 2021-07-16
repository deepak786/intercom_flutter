# intercom_flutter

[![Pub](https://img.shields.io/pub/v/intercom_flutter.svg)](https://pub.dev/packages/intercom_flutter)
![CI](https://github.com/v3rm0n/intercom_flutter/workflows/CI/badge.svg)

Flutter wrapper for Intercom [Android](https://github.com/intercom/intercom-android) and [iOS](https://github.com/intercom/intercom-ios) projects. <br/>
Now it also supports [Web](https://developers.intercom.com/installing-intercom/docs/basic-javascript).

## Usage

Import `package:intercom_flutter/intercom_flutter.dart` and use the methods in `Intercom` class.

Example:
```dart
import 'package:intercom_flutter/intercom_flutter.dart';

void main() async {
    await Intercom.initialize('appIdHere', iosApiKey: 'iosKeyHere', androidApiKey: 'androidKeyHere');
    runApp(App());
}

class App extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return FlatButton(
            child: Text('Open Intercom'),
            onPressed: () async {
                await Intercom.displayMessenger();
            },
        );
    }
}

```

See Intercom Android and iOS package documentation for more information.

### Android

Permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Optional permissions:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

Enable AndroidX + Jetifier support in your android/gradle.properties file (see example app):

```
android.useAndroidX=true
android.enableJetifier=true
```

#### Push notifications in combination with FCM
This plugin works in combination with the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) plugin to receive Push Notifications. To set this up:

* First, implement [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) and check if it works: https://pub.dev/packages/firebase_messaging#android-integration
* Then, add the Firebase server key to Intercom, as described here: https://developers.intercom.com/installing-intercom/docs/android-fcm-push-notifications#section-step-3-add-your-server-key-to-intercom-for-android-settings (you can skip 1 and 2)
* Add the following to your  `AndroidManifest.xml` file, so incoming messages are handled by Intercom:

```
    <service
        android:name="io.maido.intercom.PushInterceptService"
        android:enabled="true"
        android:exported="true">
        <intent-filter>
          <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
```
_just above the closing `</application>` tag._

* Ask FireBaseMessaging for the FCM token that we need to send to Intercom, and give it to Intercom (so Intercam can send push messages to the correct device):

```dart
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
token = await _firebaseMessaging.getToken();

Intercom.sendTokenToIntercom(token);
```

Now, if either FireBase direct (e.g. by your own backend server) or Intercom sends you a message, it will be delivered your Android phone.

#### Firebase Background Messages

If you are [handling background messages in `firebase_messaging`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_messaging#optionally-handle-background-messages) you need to do some extra work for everything to work together:

1. Remove the above mentioned `<service android:name="io.maido.intercom.PushInterceptService" ...` from your `AndroidManifest.xml`.
2. In your background messages handler, pass the relevant messages to Intercom:

```dart
import 'package:intercom_flutter/intercom_flutter.dart' show Intercom;

Future<dynamic> backgroundMessageHandler(Map<String, dynamic> message) async {
    final data = (message['data'] as Map).cast<String, dynamic>();

    if (await Intercom.isIntercomPush(data)) {
        await Intercom.handlePush(data);
        return;
    }

    // Here you can handle your own background messages
}
```

### iOS
Make sure that you have a `NSPhotoLibraryUsageDescription` entry in your `Info.plist`.

### Web
Add the below script inside body tag in the index.html file located under web folder
```html
<script>
    window.intercomSettings = {
        hide_default_launcher: true, // set this to false, if you want to show the default launcher
    };
    (function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');ic('update',w.intercomSettings);}else{var d=document;var i=function(){i.c(arguments);};i.q=[];i.c=function(args){i.q.push(args);};w.Intercom=i;var l=function(){var s=d.createElement('script');s.type='text/javascript';s.async=true;s.src='https://widget.intercom.io/widget/';var x=d.getElementsByTagName('script')[0];x.parentNode.insertBefore(s, x);};if(document.readyState==='complete'){l();}else if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}}})();
</script>
```
#### Following functions are not yet supported on Web:

- [ ] unreadConversationCount
- [ ] setInAppMessagesVisibility
- [ ] displayHelpCenter
- [ ] sendTokenToIntercom
- [ ] handlePushMessage
- [ ] isIntercomPush
- [ ] handlePush
