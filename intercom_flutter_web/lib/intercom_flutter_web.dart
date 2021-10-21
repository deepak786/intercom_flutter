import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intercom_flutter_platform_interface/intercom_flutter_platform_interface.dart';
import 'package:uuid/uuid.dart';

/// export the enum [IntercomVisibility]
export 'package:intercom_flutter_platform_interface/intercom_flutter_platform_interface.dart'
    show IntercomVisibility;

/// A web implementation of the IntercomFlutter plugin.
class IntercomFlutterWeb extends IntercomFlutterPlatform {
  static void registerWith(Registrar registrar) {
    IntercomFlutterPlatform.instance = IntercomFlutterWeb();
  }

  @override
  Stream<dynamic> getUnreadStream() {
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    // ignore: close_sinks
    StreamController<dynamic> _unreadController =
        StreamController<dynamic>.broadcast();
    _unreadController.onListen = () {
      js.context.callMethod('Intercom', [
        'onUnreadCountChange',
        js.allowInterop((unreadCount) {
          _unreadController.add(unreadCount);
        }),
      ]);
    };
    return _unreadController.stream;
  }

  @override
  Future<void> initialize(
    String appId, {
    String? androidApiKey,
    String? iosApiKey,
  }) async {
    await js.context.callMethod('Intercom', [
      'boot',
      convertJsObjectToDartObject(updateIntercomSettings('app_id', appId)),
    ]);
    print("initialized");
  }

  @override
  Future<void> setUserHash(String userHash) async {
    await js.context.callMethod('Intercom', [
      'update',
      js.JsObject.jsify({
        'user_hash': userHash,
      }),
    ]);
    print("user hash added");
  }

  @override
  Future<void> registerIdentifiedUser({String? userId, String? email}) async {
    if (userId?.isNotEmpty ?? false) {
      if (email?.isNotEmpty ?? false) {
        throw ArgumentError(
            'The parameter `email` must be null if `userId` is provided.');
      }
      // register the user with userId
      await js.context.callMethod('Intercom', [
        'update',
        js.JsObject.jsify({
          'user_id': userId,
        }),
      ]);
      print("user created");
    } else if (email?.isNotEmpty ?? false) {
      // register the user with email
      await js.context.callMethod('Intercom', [
        'update',
        js.JsObject.jsify({
          'email': email,
        }),
      ]);
      print("user created");
    } else {
      throw ArgumentError(
          'An identification method must be provided as a parameter, either `userId` or `email`.');
    }
  }

  @override
  Future<void> registerUnidentifiedUser() async {
    // to register an unidentified user, a unique id will be created using the package uuid
    String userId = Uuid().v1();
    await js.context.callMethod('Intercom', [
      'update',
      js.JsObject.jsify({
        'user_id': userId,
      }),
    ]);
    print("user created");
  }

  @override
  Future<void> updateUser({
    String? email,
    String? name,
    String? phone,
    String? company,
    String? companyId,
    String? userId,
    int? signedUpAt,
    String? language,
    Map<String, dynamic>? customAttributes,
  }) async {
    Map<String, dynamic> userAttributes = {};

    if (name != null) {
      userAttributes['name'] = name;
    }

    if (email != null) {
      userAttributes['email'] = email;
    }

    if (phone != null) {
      userAttributes['phone'] = phone;
    }

    if (userId != null) {
      userAttributes['user_id'] = userId;
    }

    if (company != null && companyId != null) {
      Map<String, dynamic> companyObj = {};
      companyObj['company_id'] = companyId;
      companyObj['name'] = company;

      userAttributes['company'] = companyObj;
    }

    if (customAttributes != null) {
      customAttributes.forEach((key, value) {
        userAttributes[key] = value;
      });
    }

    if (signedUpAt != null) {
      userAttributes['created_at'] = signedUpAt;
    }

    if (language != null) {
      userAttributes['language_override'] = language;
    }

    await js.context.callMethod('Intercom', [
      'update',
      js.JsObject.jsify(userAttributes),
    ]);
    print("User updated");
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? metaData]) async {
    await js.context.callMethod('Intercom', [
      'trackEvent',
      name,
      metaData != null ? js.JsObject.jsify(metaData) : null,
    ]);

    print("Logged event");
  }

  @override
  Future<void> setLauncherVisibility(IntercomVisibility visibility) async {
    await js.context.callMethod('Intercom', [
      'update',
      convertJsObjectToDartObject(updateIntercomSettings(
        'hide_default_launcher',
        visibility == IntercomVisibility.visible ? false : true,
      )),
    ]);

    print("Showing launcher: $visibility");
  }

  @override
  Future<void> logout() async {
    await js.context.callMethod('Intercom', ['shutdown']);
    print("logout");
  }

  @override
  Future<void> displayMessenger() async {
    await js.context.callMethod('Intercom', ['show']);
    print("Launched");
  }

  @override
  Future<void> hideMessenger() async {
    await js.context.callMethod('Intercom', ['hide']);
    print("Hidden");
  }

  @override
  Future<void> displayMessageComposer(String message) async {
    await js.context.callMethod('Intercom', ['showNewMessage', message]);
    print("Message composer displayed");
  }

  @override
  Future<void> setBottomPadding(int padding) async {
    await js.context.callMethod('Intercom', [
      'update',
      convertJsObjectToDartObject(updateIntercomSettings(
        'vertical_padding',
        padding,
      ))
    ]);

    print("Bottom padding set");
  }

  /// get the [window.IntercomSettings]
  js.JsObject getIntercomSettings() {
    if (js.context.hasProperty('intercomSettings')) {
      return js.JsObject.fromBrowserObject(js.context['intercomSettings']);
    }

    return js.JsObject.jsify({});
  }

  /// add/update property to [window.IntercomSettings]
  /// and returns the updated object
  js.JsObject updateIntercomSettings(String key, dynamic value) {
    var intercomSettings = getIntercomSettings();
    intercomSettings[key] = value;
    return intercomSettings;
  }

  /// convert the [js.JsObject] to [Map]
  Object convertJsObjectToDartObject(js.JsObject jsObject) {
    return json.decode(js.context["JSON"].callMethod("stringify", [
      jsObject,
    ]));
  }
}
