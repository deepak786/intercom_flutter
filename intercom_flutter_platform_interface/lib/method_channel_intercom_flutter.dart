import 'package:flutter/services.dart';
import 'package:intercom_flutter_platform_interface/enumeral.dart';
import 'package:intercom_flutter_platform_interface/intercom_flutter_platform_interface.dart';
import 'package:intercom_flutter_platform_interface/intercom_status_callback.dart';

const MethodChannel _channel = MethodChannel('maido.io/intercom');
const EventChannel _unreadChannel = EventChannel('maido.io/intercom/unread');
const EventChannel _windowDidHideChannel =
    EventChannel('maido.io/intercom/windowDidHide');

/// An implementation of [IntercomFlutterPlatform] that uses method channels.
class MethodChannelIntercomFlutter extends IntercomFlutterPlatform {
  @override
  Future<void> initialize(
    String appId, {
    String? androidApiKey,
    String? iosApiKey,
  }) async {
    await _channel.invokeMethod('initialize', {
      'appId': appId,
      'androidApiKey': androidApiKey,
      'iosApiKey': iosApiKey,
    });
  }

  @override
  Stream<dynamic> getUnreadStream() {
    return _unreadChannel.receiveBroadcastStream();
  }

  @override
  Stream<dynamic> getWindowDidHideStream() {
    return _windowDidHideChannel.receiveBroadcastStream();
  }

  @override
  Future<void> setUserHash(String userHash) async {
    await _channel.invokeMethod('setUserHash', {'userHash': userHash});
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
      try {
        await _channel.invokeMethod('loginIdentifiedUserWithUserId', {
          'userId': userId,
        });
        statusCallback?.onSuccess?.call();
      } on PlatformException catch (e) {
        statusCallback?.onFailure?.call(_convertExceptionToIntercomError(e));
      }
    } else if (email?.isNotEmpty ?? false) {
      try {
        await _channel.invokeMethod('loginIdentifiedUserWithEmail', {
          'email': email,
        });
        statusCallback?.onSuccess?.call();
      } on PlatformException catch (e) {
        statusCallback?.onFailure?.call(_convertExceptionToIntercomError(e));
      }
    } else {
      throw ArgumentError(
          'An identification method must be provided as a parameter, either `userId` or `email`.');
    }
  }

  @override
  Future<void> loginUnidentifiedUser(
      {IntercomStatusCallback? statusCallback}) async {
    try {
      await _channel.invokeMethod('loginUnidentifiedUser');
      statusCallback?.onSuccess?.call();
    } on PlatformException catch (e) {
      statusCallback?.onFailure?.call(_convertExceptionToIntercomError(e));
    }
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
    try {
      await _channel.invokeMethod('updateUser', <String, dynamic>{
        'email': email,
        'name': name,
        'phone': phone,
        'company': company,
        'companyId': companyId,
        'userId': userId,
        'signedUpAt': signedUpAt,
        'language': language,
        'customAttributes': customAttributes,
      });
      statusCallback?.onSuccess?.call();
    } on PlatformException catch (e) {
      statusCallback?.onFailure?.call(_convertExceptionToIntercomError(e));
    }
  }

  @override
  Future<void> logout() async {
    await _channel.invokeMethod('logout');
  }

  @override
  Future<void> setLauncherVisibility(IntercomVisibility visibility) async {
    String visibilityString =
        visibility == IntercomVisibility.visible ? 'VISIBLE' : 'GONE';
    await _channel.invokeMethod('setLauncherVisibility', {
      'visibility': visibilityString,
    });
  }

  @override
  Future<int> unreadConversationCount() async {
    final result = await _channel.invokeMethod<int>('unreadConversationCount');
    return result ?? 0;
  }

  @override
  Future<void> setInAppMessagesVisibility(IntercomVisibility visibility) async {
    String visibilityString =
        visibility == IntercomVisibility.visible ? 'VISIBLE' : 'GONE';
    await _channel.invokeMethod('setInAppMessagesVisibility', {
      'visibility': visibilityString,
    });
  }

  @override
  Future<void> displayMessenger() async {
    await _channel.invokeMethod('displayMessenger');
  }

  @override
  Future<void> hideMessenger() async {
    await _channel.invokeMethod('hideMessenger');
  }

  @override
  Future<void> displayHelpCenter() async {
    await _channel.invokeMethod('displayHelpCenter');
  }

  @override
  Future<void> displayHelpCenterCollections(List<String> collectionIds) {
    return _channel.invokeMethod(
        'displayHelpCenterCollections', {'collectionIds': collectionIds});
  }

  @override
  Future<void> displayMessages() async {
    await _channel.invokeMethod('displayMessages');
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? metaData]) async {
    await _channel
        .invokeMethod('logEvent', {'name': name, 'metaData': metaData});
  }

  @override
  Future<void> sendTokenToIntercom(String token) async {
    assert(token.isNotEmpty);
    print("Start sending token to Intercom");
    await _channel.invokeMethod('sendTokenToIntercom', {'token': token});
  }

  @Deprecated(
      "Calling this API is no longer required. Intercom will directly open the chat screen when a push notification is clicked.")
  @override
  Future<void> handlePushMessage() async {
    await _channel.invokeMethod('handlePushMessage');
  }

  @override
  Future<void> displayMessageComposer(String message) async {
    await _channel.invokeMethod('displayMessageComposer', {'message': message});
  }

  @override
  Future<bool> isIntercomPush(Map<String, dynamic> message) async {
    if (!message.values.every((item) => item is String)) {
      return false;
    }
    final result = await _channel
        .invokeMethod<bool>('isIntercomPush', {'message': message});
    return result ?? false;
  }

  @override
  Future<void> handlePush(Map<String, dynamic> message) async {
    if (!message.values.every((item) => item is String)) {
      throw new ArgumentError(
          'Intercom push messages can only have string values');
    }

    return await _channel
        .invokeMethod<void>('handlePush', {'message': message});
  }

  @override
  Future<void> setBottomPadding(int padding) async {
    await _channel.invokeMethod('setBottomPadding', {'bottomPadding': padding});
  }

  @override
  Future<void> displayArticle(String articleId) async {
    await _channel.invokeMethod('displayArticle', {'articleId': articleId});
  }

  @override
  Future<void> displayCarousel(String carouselId) async {
    await _channel.invokeMethod('displayCarousel', {'carouselId': carouselId});
  }

  @override
  Future<void> displaySurvey(String surveyId) async {
    await _channel.invokeMethod('displaySurvey', {'surveyId': surveyId});
  }

  @override
  Future<void> displayConversation(String conversationId) async {
    await _channel.invokeMethod(
        'displayConversation', {'conversationId': conversationId});
  }

  @override
  Future<void> displayTickets() async {
    await _channel.invokeMethod('displayTickets');
  }

  @override
  Future<void> displayHome() async {
    await _channel.invokeMethod('displayHome');
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return await _channel.invokeMethod<bool>('isUserLoggedIn') ?? false;
  }

  @override
  Future<Map<String, dynamic>> fetchLoggedInUserAttributes() async {
    var attributes = Map<String, dynamic>.from(
        await _channel.invokeMethod<Map>('fetchLoggedInUserAttributes') ?? {});
    return attributes;
  }

  @override
  Future<void> setUserJwt(String jwt) async {
    await _channel.invokeMethod('setUserJwt', {'jwt': jwt});
  }

  @override
  Future<void> setAuthTokens(Map<String, String> tokens) async {
    await _channel.invokeMethod('setAuthTokens', {'tokens': tokens});
  }

  @override
  Future<void> setThemeMode(IntercomTheme theme) async {
    await _channel.invokeMethod('setThemeMode', {'theme': theme.name});
  }

  /// Convert the [PlatformException] details to [IntercomError].
  /// From the Platform side if the intercom operation failed then error details
  /// will be sent as details in [PlatformException].
  IntercomError _convertExceptionToIntercomError(PlatformException e) {
    var details = e.details ?? {};

    return IntercomError(
        details['errorCode'] ?? -1, details['errorMessage'] ?? e.message ?? "");
  }
}
