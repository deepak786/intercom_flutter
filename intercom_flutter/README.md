# intercom_flutter

[![Pub](https://img.shields.io/pub/v/intercom_flutter.svg)](https://pub.dev/packages/intercom_flutter)
![CI](https://github.com/v3rm0n/intercom_flutter/workflows/CI/badge.svg)

Flutter wrapper for Intercom [Android](https://github.com/intercom/intercom-android), [iOS](https://github.com/intercom/intercom-ios), and [Web](https://developers.intercom.com/installing-intercom/docs/basic-javascript) projects.

- Uses Intercom Android SDK Version `17.4.2`.
- The minimum Android SDK `minSdk` required is 21.
- The compile Android SDK `compileSdk` required is 35.
- Uses Intercom iOS SDK Version `19.4.1`.
- The minimum iOS target version required is 15.
- The Xcode version required is 15.

## Usage

Import `package:intercom_flutter/intercom_flutter.dart` and use the methods in `Intercom` class.

Example:
```dart
import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

void main() async {
    // initialize the flutter binding.
    WidgetsFlutterBinding.ensureInitialized();
    // initialize the Intercom.
    // make sure to add keys from your Intercom workspace.
    // don't forget to set up the custom application class on Android side.
    await Intercom.instance.initialize('appIdHere', iosApiKey: 'iosKeyHere', androidApiKey: 'androidKeyHere');
    runApp(App());
}

class App extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return FlatButton(
            child: Text('Open Intercom'),
            onPressed: () async {
                // messenger will load the messages only if the user is registered in Intercom.
                // either identified or unidentified.
                await Intercom.instance.displayMessenger();
            },
        );
    }
}

```

See Intercom [Android](https://developers.intercom.com/installing-intercom/docs/intercom-for-android) and [iOS](https://developers.intercom.com/installing-intercom/docs/intercom-for-ios) package documentation for more information.

### Android

Make sure that your app's `MainActivity` extends `FlutterFragmentActivity` (you can check the example).

Permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Optional permissions:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Enable AndroidX + Jetifier support in your android/gradle.properties file (see example app):

```
android.useAndroidX=true
android.enableJetifier=true
```

According to the documentation, Intercom must be initialized in the Application onCreate. So follow the below steps to achieve the same:
- Setup custom application class if you don't have any.
    - Create a custom `android.app.Application` class named `MyApp`.
    - Add an `onCreate()` override. The class should look like this:
    ```kotlin
    import android.app.Application

    class MyApp: Application() {

        override fun onCreate() {
            super.onCreate()
        }
    }
    ```
    - Open your `AndroidManifest.xml` and find the `application` tag. In it, add an `android:name` attribute, and set the value to your class' name, prefixed by a dot (.).
    ```xml
    <application
      android:name=".MyApp" >
    ```
- Now initialize the Intercom SDK inside the `onCreate()` of custom application class according to the following:
```kotlin
import android.app.Application
import io.maido.intercom.IntercomFlutterPlugin

class MyApp : Application() {
  override fun onCreate() {
    super.onCreate()

    // Add this line with your keys
    IntercomFlutterPlugin.initSdk(this, appId = "appId", androidApiKey = "androidApiKey")
  }
}
```

### iOS
Make sure that you have a `NSPhotoLibraryUsageDescription` entry in your `Info.plist`.

### Push notifications setup
This plugin works in combination with the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) plugin to receive Push Notifications. To set this up:

* First, implement [`firebase_messaging`](https://pub.dev/packages/firebase_messaging)
* Then, add the Firebase server key to Intercom, as described [here](https://developers.intercom.com/installing-intercom/docs/android-fcm-push-notifications#section-step-3-add-your-server-key-to-intercom-for-android-settings) (you can skip 1 and 2 as you have probably done them while configuring `firebase_messaging`)
* Follow the steps as described [here](https://developers.intercom.com/installing-intercom/docs/ios-push-notifications) to enable push notification in iOS.
* Starting from Android 13 you may need to ask for notification permissions (as of version 13 `firebase_messaging` should support that)
* Ask FirebaseMessaging for the token that we need to send to Intercom, and give it to Intercom (so Intercom can send push messages to the correct device), please note that in order to receive push notifications in your iOS app, you have to send the APNS token to Intercom. The example below uses [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) to get either the FCM or APNS token based on the platform:

```dart
final firebaseMessaging = FirebaseMessaging.instance;
final intercomToken = Platform.isIOS ? await firebaseMessaging.getAPNSToken() : await firebaseMessaging.getToken();

Intercom.instance.sendTokenToIntercom(intercomToken);
```

Now, if either Firebase direct (e.g. by your own backend server) or Intercom sends you a message, it will be delivered to your app.

### Web
You don't need to do any extra steps for the web. Intercom script will be automatically injected.
But you can pre-define some Intercom settings, if you want (optional).
```html
<script>
    window.intercomSettings = {
        hide_default_launcher: true, // hide the default launcher
    };
</script>
```
#### Following functions are not yet supported on Web:

- [ ] unreadConversationCount
- [ ] setInAppMessagesVisibility
- [ ] sendTokenToIntercom
- [ ] handlePushMessage
- [ ] isIntercomPush
- [ ] handlePush
- [ ] displayCarousel
- [ ] displayHelpCenterCollections

## Using Intercom keys with `--dart-define`

Use `--dart-define` variables to avoid hardcoding Intercom keys. 

### Pass the Intercom keys with `flutter run` or `flutter build` command using `--dart-define`.
```dart
flutter run --dart-define="INTERCOM_APP_ID=appID" --dart-define="INTERCOM_ANDROID_KEY=androidKey" --dart-define="INTERCOM_IOS_KEY=iosKey"
```
Note: You can also use `--dart-define-from-file` which is introduced in Flutter 3.7.

### Reading keys in Dart side and initialize the SDK.
```dart
String appId = String.fromEnvironment("INTERCOM_APP_ID", "");
String androidKey = String.fromEnvironment("INTERCOM_ANDROID_KEY", "");
String iOSKey = String.fromEnvironment("INTERCOM_IOS_KEY", "");

Intercom.instance.initialize(appId, iosApiKey: iOSKey, androidApiKey: androidKey);
```

### Reading keys in Android native side and initialize the SDK.

* Add the following code to `build.gradle`.
```
def dartEnvironmentVariables = []
if (project.hasProperty('dart-defines')) {
  dartEnvironmentVariables = project.property('dart-defines')
      .split(',')
      .collectEntries { entry ->
        def pair = new String(entry.decodeBase64(), 'UTF-8').split('=')
        [(pair.first()): pair.last()]
      }
}
```

* Place `dartEnvironmentVariables` inside the build config
```
defaultConfig {
    ...
    buildConfigField 'String', 'INTERCOM_APP_ID', "\"${dartEnvironmentVariables.INTERCOM_APP_ID}\""
    buildConfigField 'String', 'INTERCOM_ANDROID_KEY', "\"${dartEnvironmentVariables.INTERCOM_ANDROID_KEY}\""
}
```

* Read the build config fields
```kotlin
import android.app.Application
import android.os.Build
import io.maido.intercom.IntercomFlutterPlugin

class MyApp : Application() {
  override fun onCreate() {
    super.onCreate()
    
    // Add this line with your keys
    IntercomFlutterPlugin.initSdk(this, 
      appId = BuildConfig.INTERCOM_APP_ID, 
      androidApiKey = BuildConfig.INTERCOM_ANDROID_KEY)
  }
}
```

## Support

If you find this package helpful, you can support the development by:

- [Buy Me A Coffee](https://buymeacoffee.com/deepakdroid)
- [PayPal](https://paypal.me/deepakdroid)
