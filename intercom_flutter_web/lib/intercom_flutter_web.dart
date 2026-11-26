import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intercom_flutter_platform_interface/enumeral.dart';
import 'package:intercom_flutter_platform_interface/intercom_flutter_platform_interface.dart';
import 'package:intercom_flutter_platform_interface/intercom_status_callback.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

/// export the enum [IntercomVisibility]
export 'package:intercom_flutter_platform_interface/enumeral.dart'
    show IntercomVisibility, IntercomTheme;
export 'package:intercom_flutter_platform_interface/intercom_status_callback.dart'
    show IntercomStatusCallback, IntercomError;

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
      globalContext.callMethod(
        'Intercom'.toJS,
        'onUnreadCountChange'.toJS,
        ((JSAny unreadCount) {
          _unreadController.add(unreadCount);
        }).toJS,
      );
    };
    return _unreadController.stream;
  }

  @override
  Future<void> initialize(
    String appId, {
    String? androidApiKey,
    String? iosApiKey,
  }) async {
    if (globalContext.getProperty('Intercom'.toJS) == null) {
      // Intercom script is not added yet
      // Inject it from here in the body
      web.HTMLScriptElement script =
          web.document.createElement("script") as web.HTMLScriptElement;
      script.text = """
          window.intercomSettings = ${jsonEncode(updateIntercomSettings('app_id', appId))};
          (function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');ic('update',w.intercomSettings);}else{var d=document;var i=function(){i.c(arguments);};i.q=[];i.c=function(args){i.q.push(args);};w.Intercom=i;var l=function(){var s=d.createElement('script');s.type='text/javascript';s.async=true;s.src='https://widget.intercom.io/widget/' + '$appId';var x=d.getElementsByTagName('script')[0];x.parentNode.insertBefore(s, x);};if(document.readyState==='complete'){l();}else if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}}})();  
      """;
      if (web.document.body != null) {
        web.document.body!.appendChild(script);
      }
    } else {
      // boot the Intercom
      globalContext.callMethod(
        'Intercom'.toJS,
        'boot'.toJS,
        updateIntercomSettings('app_id', appId).jsify(),
      );
    }
    print("initialized");
  }

  @override
  Future<void> setUserHash(String userHash) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings('user_hash', userHash).jsify(),
    );
    print("user hash added");
  }

  @override
  Future<void> loginIdentifiedUser({
    String? userId,
    String? email,
    IntercomStatusCallback? statusCallback,
  }) async {
    if (userId?.isNotEmpty ?? false) {
      if (email?.isNotEmpty ?? false) {
        throw ArgumentError(
            'The parameter `email` must be null if `userId` is provided.');
      }
      // register the user with userId
      globalContext.callMethod(
        'Intercom'.toJS,
        'update'.toJS,
        updateIntercomSettings('user_id', userId).jsify(),
      );
      // send the success callback only as web does not support the statusCallback.
      statusCallback?.onSuccess?.call();
    } else if (email?.isNotEmpty ?? false) {
      // register the user with email
      globalContext.callMethod(
        'Intercom'.toJS,
        'update'.toJS,
        updateIntercomSettings('email', email).jsify(),
      );
      // send the success callback only as web does not support the statusCallback.
      statusCallback?.onSuccess?.call();
    } else {
      throw ArgumentError(
          'An identification method must be provided as a parameter, either `userId` or `email`.');
    }
  }

  @override
  Future<void> loginUnidentifiedUser(
      {IntercomStatusCallback? statusCallback}) async {
    // to register an unidentified user, a unique id will be created using the package uuid
    String userId = Uuid().v1();
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings('user_id', userId).jsify(),
    );
    // send the success callback only as web does not support the statusCallback.
    statusCallback?.onSuccess?.call();
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
    IntercomStatusCallback? statusCallback,
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

    globalContext.callMethod(
        'Intercom'.toJS, 'update'.toJS, userAttributes.jsify());
    // send the success callback only as web does not support the statusCallback.
    statusCallback?.onSuccess?.call();
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? metaData]) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'trackEvent'.toJS,
      name.toJS,
      metaData != null ? metaData.jsify() : null,
    );

    print("Logged event");
  }

  @override
  Future<void> setLauncherVisibility(IntercomVisibility visibility) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings(
        'hide_default_launcher',
        visibility == IntercomVisibility.visible ? false : true,
      ).jsify(),
    );

    print("Showing launcher: $visibility");
  }

  @override
  Future<void> logout() async {
    // shutdown will effectively clear out any user data that you have been passing through the JS API.
    // but not from intercomSettings
    // so manually clear some intercom settings
    removeIntercomSettings([
      'user_hash',
      'intercom_user_jwt',
      'user_id',
      'email',
      'auth_tokens',
    ]);
    // shutdown
    globalContext.callMethod('Intercom'.toJS, 'shutdown'.toJS);
    print("logout");
  }

  @override
  Future<void> displayMessenger() async {
    globalContext.callMethod('Intercom'.toJS, 'show'.toJS);
    print("Launched");
  }

  @override
  Future<void> hideMessenger() async {
    globalContext.callMethod('Intercom'.toJS, 'hide'.toJS);
    print("Hidden");
  }

  @override
  Future<void> displayHelpCenter() async {
    globalContext.callMethod('Intercom'.toJS, 'showSpace'.toJS, 'help'.toJS);
    print("Launched the Help Center");
  }

  @override
  Future<void> displayMessageComposer(String message) async {
    globalContext.callMethod(
        'Intercom'.toJS, 'showNewMessage'.toJS, message.toJS);
    print("Message composer displayed");
  }

  @override
  Future<void> displayMessages() async {
    globalContext.callMethod('Intercom'.toJS, 'showMessages'.toJS);
    print("Launched the Messenger with the message list");
  }

  @override
  Future<void> setBottomPadding(int padding) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings(
        'vertical_padding',
        padding,
      ).jsify(),
    );

    print("Bottom padding set");
  }

  @override
  Future<void> displayArticle(String articleId) async {
    globalContext.callMethod(
        'Intercom'.toJS, 'showArticle'.toJS, articleId.toJS);
  }

  @override
  Future<void> displaySurvey(String surveyId) async {
    globalContext.callMethod(
        'Intercom'.toJS, 'startSurvey'.toJS, surveyId.toJS);
  }

  @override
  Future<void> displayConversation(String conversationId) async {
    globalContext.callMethod(
        'Intercom'.toJS, 'showConversation'.toJS, conversationId.toJS);
  }

  @override
  Future<void> displayTickets() async {
    globalContext.callMethod('Intercom'.toJS, 'showSpace'.toJS, 'tickets'.toJS);
    print("Launched Tickets space");
  }

  @override
  Future<void> displayHome() async {
    globalContext.callMethod('Intercom'.toJS, 'showSpace'.toJS, 'home'.toJS);
    print("Launched Home space");
  }

  @override
  Future<bool> isUserLoggedIn() async {
    // There is no direct JS API available
    // Here we check if intercomSettings has user_id or email then user is
    // logged in
    var settings = getIntercomSettings();
    var user_id = settings['user_id'] as String? ?? "";
    var email = settings['email'] as String? ?? "";

    return user_id.isNotEmpty || email.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> fetchLoggedInUserAttributes() async {
    // There is no direct JS API available
    // Just return the user_id or email from intercomSettings
    var settings = getIntercomSettings();
    var user_id = settings['user_id'] as String? ?? "";
    var email = settings['email'] as String? ?? "";

    if (user_id.isNotEmpty) {
      return {'user_id': user_id};
    } else if (email.isNotEmpty) {
      return {'email': email};
    }

    return {};
  }

  @override
  Future<void> setUserJwt(String jwt) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings('intercom_user_jwt', jwt).jsify(),
    );
    print("jwt added");
  }

  @override
  Future<void> setAuthTokens(Map<String, String> tokens) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings('auth_tokens', tokens).jsify(),
    );
    print("Auth tokens added");
  }

  @override
  Future<void> setThemeMode(IntercomTheme theme) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings(
        'theme_mode',
        theme == IntercomTheme.none ? null : theme.name,
      ).jsify(),
    );
    print("Theme overridden");
  }

  @override
  Future<void> setMessengerStyleId(String? styleId) async {
    globalContext.callMethod(
      'Intercom'.toJS,
      'update'.toJS,
      updateIntercomSettings(
        'messenger_style_id',
        styleId?.isEmpty ?? true ? null : styleId,
      ).jsify(),
    );
    print("Messenger style set");
  }

  /// get the [window.intercomSettings]
  Map<dynamic, dynamic> getIntercomSettings() {
    if (globalContext.hasProperty('intercomSettings'.toJS).toDart) {
      var settings =
          globalContext.getProperty('intercomSettings'.toJS).dartify();
      // settings are of type LinkedMap<Object?, Object?>
      return settings as Map;
    }

    return {};
  }

  /// add/update property to [window.intercomSettings]
  /// and returns the updated object
  Map<dynamic, dynamic> updateIntercomSettings(String key, dynamic value) {
    var intercomSettings = getIntercomSettings();
    intercomSettings[key] = value;

    // Update the [window.intercomSettings]
    globalContext.setProperty(
        "intercomSettings".toJS, intercomSettings.jsify());

    return intercomSettings;
  }

  /// Remove properties from [window.intercomSettings]
  Map<dynamic, dynamic> removeIntercomSettings(List<String> keys) {
    var intercomSettings = getIntercomSettings();

    // remove the keys
    for (var key in keys) {
      intercomSettings.remove(key);
    }

    // Update the [window.intercomSettings]
    globalContext.setProperty(
        "intercomSettings".toJS, intercomSettings.jsify());

    return intercomSettings;
  }
}
