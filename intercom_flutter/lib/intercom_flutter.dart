library intercom_flutter;

import 'dart:async';

import 'package:intercom_flutter_platform_interface/enumeral.dart';
import 'package:intercom_flutter_platform_interface/intercom_flutter_platform_interface.dart';
import 'package:intercom_flutter_platform_interface/intercom_status_callback.dart';

/// export the [IntercomVisibility] enum
export 'package:intercom_flutter_platform_interface/enumeral.dart'
    show IntercomVisibility, IntercomTheme;
export 'package:intercom_flutter_platform_interface/intercom_status_callback.dart'
    show IntercomStatusCallback, IntercomError;

class Intercom {
  /// private constructor to not allow the object creation from outside.
  Intercom._();

  static final Intercom _instance = Intercom._();

  /// get the instance of the [Intercom].
  static Intercom get instance => _instance;

  /// Function to initialize the Intercom SDK.
  ///
  /// First, you'll need to get your Intercom [appId].
  /// [androidApiKey] is required if you want to use Intercom in Android.
  /// [iosApiKey] is required if you want to use Intercom in iOS.
  ///
  /// You can get these from Intercom settings:
  /// * [Android](https://app.intercom.com/a/apps/_/settings/android)
  /// * [iOS](https://app.intercom.com/a/apps/_/settings/ios)
  ///
  /// Then, initialize Intercom in main method.
  Future<void> initialize(
    String appId, {
    String? androidApiKey,
    String? iosApiKey,
  }) {
    return IntercomFlutterPlatform.instance
        .initialize(appId, androidApiKey: androidApiKey, iosApiKey: iosApiKey);
  }

  /// You can check how many unread conversations a user has
  /// even if a user dismisses a notification.
  ///
  /// You can listen for unread conversation count with this method.
  Stream<dynamic> getUnreadStream() {
    return IntercomFlutterPlatform.instance.getUnreadStream();
  }

  /// You can listen for when the Intercom window is hidden.
  ///
  /// This stream emits when the Intercom window (messenger, help center, etc.) is closed.
  /// This allows developers to perform certain actions in their app when the Intercom window is closed.
  /// Only available on iOS.
  Stream<dynamic> getWindowDidHideStream() {
    return IntercomFlutterPlatform.instance.getWindowDidHideStream();
  }

  /// This method allows you to set a fixed bottom padding for in app messages and the launcher.
  ///
  /// It is useful if your app has a tab bar or similar UI at the bottom of your window.
  /// [padding] is the size of the bottom padding in points.
  Future<void> setBottomPadding(int padding) {
    return IntercomFlutterPlatform.instance.setBottomPadding(padding);
  }

  /// To make sure that conversations between you and your users are kept private
  /// and that one user can't impersonate another then you need you need to setup
  /// the identity verification.
  ///
  /// This function helps to set up the identity verification.
  /// Here you need to pass hash (HMAC) of the user.
  ///
  /// This must be called before registering the user in Intercom.
  ///
  /// To generate the user hash (HMAC) see
  /// <https://gist.github.com/thewheat/7342c76ade46e7322c3e>
  ///
  /// Note: identity verification does not apply to unidentified users.
  Future<void> setUserHash(String userHash) {
    return IntercomFlutterPlatform.instance.setUserHash(userHash);
  }

  /// Function to create a identified user in Intercom.
  /// You need to register your users before you can talk to them and
  /// track their activity in your app.
  ///
  /// You can register a identified user either with [userId] or with [email],
  /// but not with both.
  Future<void> loginIdentifiedUser(
      {String? userId, String? email, IntercomStatusCallback? statusCallback}) {
    return IntercomFlutterPlatform.instance.loginIdentifiedUser(
        userId: userId, email: email, statusCallback: statusCallback);
  }

  /// Function to create a unidentified user in Intercom.
  /// You need to register your users before you can talk to them and
  /// track their activity in your app.
  Future<void> loginUnidentifiedUser({IntercomStatusCallback? statusCallback}) {
    return IntercomFlutterPlatform.instance
        .loginUnidentifiedUser(statusCallback: statusCallback);
  }

  /// Updates the attributes of the current Intercom user.
  ///
  /// The [signedUpAt] param should be seconds since epoch.
  ///
  /// The [language] param should be an an ISO 639-1 two-letter code such as `en` for English or `fr` for French.
  /// You’ll need to use a four-letter code for Chinese like `zh-CN`.
  /// check this link https://www.intercom.com/help/en/articles/180-localize-intercom-to-work-with-multiple-languages.
  ///
  /// See also:
  ///  * [Localize Intercom to work with multiple languages](https://www.intercom.com/help/en/articles/180-localize-intercom-to-work-with-multiple-languages)
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
  }) {
    return IntercomFlutterPlatform.instance.updateUser(
      email: email,
      name: name,
      phone: phone,
      company: company,
      companyId: companyId,
      userId: userId,
      signedUpAt: signedUpAt,
      language: language,
      customAttributes: customAttributes,
      statusCallback: statusCallback,
    );
  }

  /// To logout a user from Intercom.
  /// This clears the Intercom SDK's cache of your user's identity.
  Future<void> logout() {
    return IntercomFlutterPlatform.instance.logout();
  }

  /// To hide or show the standard launcher on the bottom right-hand side of the screen.
  Future<void> setLauncherVisibility(IntercomVisibility visibility) {
    return IntercomFlutterPlatform.instance.setLauncherVisibility(visibility);
  }

  /// You can check how many unread conversations a user has
  /// even if a user dismisses a notification.
  ///
  /// You can get the current unread conversation count with this method.
  Future<int> unreadConversationCount() {
    return IntercomFlutterPlatform.instance.unreadConversationCount();
  }

  /// To allow or prevent in app messages from popping up in certain parts of your app.
  Future<void> setInAppMessagesVisibility(IntercomVisibility visibility) {
    return IntercomFlutterPlatform.instance
        .setInAppMessagesVisibility(visibility);
  }

  /// To open the Intercom messenger.
  ///
  /// This is used when you manually want to launch Intercom messenger.
  /// for e.g: from your custom launcher (Help & Support) or (Talk to us).
  Future<void> displayMessenger() {
    return IntercomFlutterPlatform.instance.displayMessenger();
  }

  /// To close the Intercom messenger.
  ///
  /// This is used when you manually want to close Intercom messenger.
  Future<void> hideMessenger() {
    return IntercomFlutterPlatform.instance.hideMessenger();
  }

  /// To display an Activity with your Help Center content.
  ///
  /// Make sure Help Center is turned on.
  /// If you don't have Help Center enabled in your Intercom settings the method
  /// displayHelpCenter will fail to load.
  Future<void> displayHelpCenter() {
    return IntercomFlutterPlatform.instance.displayHelpCenter();
  }

  /// To display an Activity with your Help Center content for specific collections.
  ///
  /// Make sure Help Center is turned on.
  /// If you don't have Help Center enabled in your Intercom settings the method
  /// displayHelpCenterCollections will fail to load.
  /// The [collectionIds] you want to display.
  Future<void> displayHelpCenterCollections(List<String> collectionIds) {
    return IntercomFlutterPlatform.instance
        .displayHelpCenterCollections(collectionIds);
  }

  /// To display an Activity with your Messages content.
  Future<void> displayMessages() {
    return IntercomFlutterPlatform.instance.displayMessages();
  }

  /// To log events in Intercom that record what users do in your app and when they do it.
  /// For example, you can record when user opened a specific screen in your app.
  /// You can also pass [metaData] about the event.
  Future<void> logEvent(String name, [Map<String, dynamic>? metaData]) {
    return IntercomFlutterPlatform.instance.logEvent(name, metaData);
  }

  /// The [token] to send to the Intercom to receive the notifications.
  ///
  /// For the Android, this [token] must be a FCM (Firebase cloud messaging) token.
  /// For the iOS, this [token] must be a APNS token.
  Future<void> sendTokenToIntercom(String token) {
    return IntercomFlutterPlatform.instance.sendTokenToIntercom(token);
  }

  /// When a user taps on a push notification Intercom hold onto data
  /// such as the URI in your message or the conversation to open.
  ///
  /// When you want Intercom to act on that data, use this method.
  @Deprecated(
      "Calling this API is no longer required. Intercom will directly open the chat screen when a push notification is clicked.")
  Future<void> handlePushMessage() {
    return IntercomFlutterPlatform.instance.handlePushMessage();
  }

  /// To open the Intercom messenger to the composer screen with [message]
  /// field pre-populated.
  Future<void> displayMessageComposer(String message) {
    return IntercomFlutterPlatform.instance.displayMessageComposer(message);
  }

  /// To check if the push [message] is for Intercom or not.
  /// This is useful when your app is also configured to receive push messages
  /// from third parties.
  Future<bool> isIntercomPush(Map<String, dynamic> message) async {
    return IntercomFlutterPlatform.instance.isIntercomPush(message);
  }

  /// If the push [message] is for Intercom then use this method to let
  /// Intercom handle that push.
  Future<void> handlePush(Map<String, dynamic> message) async {
    return IntercomFlutterPlatform.instance.handlePush(message);
  }

  /// To display an Article, pass in an [articleId] from your Intercom workspace.
  ///
  /// An article must be ‘live’ to be used in this feature.
  /// If it is in a draft or paused state,
  /// end-users will see an error if the app tries to open the content.
  Future<void> displayArticle(String articleId) async {
    return IntercomFlutterPlatform.instance.displayArticle(articleId);
  }

  /// To display a Carousel, pass in a [carouselId] from your Intercom workspace.
  ///
  /// A carousel must be ‘live’ to be used in this feature.
  /// If it is in a draft or paused state,
  /// end-users will see an error if the app tries to open the content.
  Future<void> displayCarousel(String carouselId) async {
    return IntercomFlutterPlatform.instance.displayCarousel(carouselId);
  }

  /// To display a Survey, pass in a [surveyId] from your Intercom workspace.
  ///
  /// A survey must be ‘live’ to be used in this feature.
  /// If it is in a draft or paused state,
  /// end-users will see an error if the app tries to open the content.
  Future<void> displaySurvey(String surveyId) {
    return IntercomFlutterPlatform.instance.displaySurvey(surveyId);
  }

  /// To display a Conversation, pass in a [conversationId] from your Intercom workspace.
  Future<void> displayConversation(String conversationId) {
    return IntercomFlutterPlatform.instance.displayConversation(conversationId);
  }

  /// To display an activity with all your tickets.
  Future<void> displayTickets() {
    return IntercomFlutterPlatform.instance.displayTickets();
  }

  /// To display an Intercom Home space.
  Future<void> displayHome() {
    return IntercomFlutterPlatform.instance.displayHome();
  }

  /// Determine if a user is currently logged in to Intercom.
  Future<bool> isUserLoggedIn() {
    return IntercomFlutterPlatform.instance.isUserLoggedIn();
  }

  /// Retrieve the details of the currently logged in user.
  Future<Map<String, dynamic>> fetchLoggedInUserAttributes() {
    return IntercomFlutterPlatform.instance.fetchLoggedInUserAttributes();
  }

  /// JWT (JSON Web Token) is the recommended method to secure your Messenger.
  /// With JWT, you can ensure that bad actors can't impersonate your users,
  /// see their conversation history, or make unauthorized updates to data.
  Future<void> setUserJwt(String jwt) {
    return IntercomFlutterPlatform.instance.setUserJwt(jwt);
  }

  /// Set up the authentication (user-defined token) to secure your Data
  /// connectors. These tokens can be used for functionality such as Fin Actions.
  ///  You can provide multiple tokens at once. Please ensure you have created
  ///  the correct keys [here](https://www.intercom.com/a/apps/_/settings/app-settings/authentication)
  Future<void> setAuthTokens(Map<String, String> tokens) {
    return IntercomFlutterPlatform.instance.setAuthTokens(tokens);
  }

  /// The theme mode controls whether the SDK displays in light mode, dark mode,
  /// or follows the system theme.
  /// The theme selection will be reset when the app restarts i.e. You can
  /// override the server-provided theme setting for the current session only.
  Future<void> setThemeMode(IntercomTheme theme) {
    return IntercomFlutterPlatform.instance.setThemeMode(theme);
  }
}
