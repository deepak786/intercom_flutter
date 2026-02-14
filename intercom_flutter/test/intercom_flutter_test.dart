import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

import 'test_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Intercom', () {
    setUp(() {
      setUpTestMethodChannel('maido.io/intercom');
    });

    test('initialize', () {
      final appId = 'mock';
      final androidApiKey = 'android-key';
      final iosApiKey = 'ios-key';

      Intercom.instance.initialize(
        appId,
        androidApiKey: androidApiKey,
        iosApiKey: iosApiKey,
      );

      expectMethodCall('initialize', arguments: {
        'appId': appId,
        'androidApiKey': androidApiKey,
        'iosApiKey': iosApiKey,
      });
    });

    test('testSendingAPNTokenToIntercom', () {
      Intercom.instance.sendTokenToIntercom('mock_apn_token');
      expectMethodCall('sendTokenToIntercom', arguments: {
        'token': 'mock_apn_token',
      });
    });

    group('loginIdentifiedUser', () {
      test('with userId', () {
        Intercom.instance.loginIdentifiedUser(userId: 'test');
        expectMethodCall('loginIdentifiedUserWithUserId', arguments: {
          'userId': 'test',
        });
      });

      test('with email', () {
        Intercom.instance.loginIdentifiedUser(email: 'test');
        expectMethodCall('loginIdentifiedUserWithEmail', arguments: {
          'email': 'test',
        });
      });

      test('with userId and email should fail', () {
        expect(
          () => Intercom.instance.loginIdentifiedUser(
            userId: 'testId',
            email: 'testEmail',
          ),
          throwsArgumentError,
        );
      });

      test('without parameters', () {
        expect(
            () => Intercom.instance.loginIdentifiedUser(), throwsArgumentError);
      });
    });

    test('loginUnidentifiedUser', () {
      Intercom.instance.loginUnidentifiedUser();
      expectMethodCall('loginUnidentifiedUser');
    });

    test('setBottomPadding', () {
      final padding = 64;
      Intercom.instance.setBottomPadding(padding);
      expectMethodCall('setBottomPadding', arguments: {
        'bottomPadding': padding,
      });
    });

    test('setUserHash', () {
      Intercom.instance.setUserHash('test');
      expectMethodCall('setUserHash', arguments: {
        'userHash': 'test',
      });
    });

    test('logout', () {
      Intercom.instance.logout();
      expectMethodCall('logout');
    });

    group('toggleMessengerVisibility', () {
      test('displayMessenger', () {
        Intercom.instance.displayMessenger();
        expectMethodCall('displayMessenger');
      });

      test('hideMessenger', () {
        Intercom.instance.hideMessenger();
        expectMethodCall('hideMessenger');
      });
    });

    test('displayHelpCenter', () {
      Intercom.instance.displayHelpCenter();
      expectMethodCall('displayHelpCenter');
    });

    test('displayHelpCenterCollections', () {
      final collectionIds = ['collection1', 'collection2'];
      Intercom.instance.displayHelpCenterCollections(collectionIds);
      expectMethodCall('displayHelpCenterCollections',
          arguments: {'collectionIds': collectionIds});
    });

    test('displayMessages', () {
      Intercom.instance.displayMessages();
      expectMethodCall('displayMessages');
    });

    test('unreadConversationCount', () {
      Intercom.instance.unreadConversationCount();
      expectMethodCall('unreadConversationCount');
    });

    test('displayMessageComposer', () {
      Intercom.instance.displayMessageComposer("message");
      expectMethodCall(
        'displayMessageComposer',
        arguments: {"message": "message"},
      );
    });

    group('setInAppMessagesVisibility', () {
      test('visible', () {
        Intercom.instance
            .setInAppMessagesVisibility(IntercomVisibility.visible);
        expectMethodCall('setInAppMessagesVisibility', arguments: {
          'visibility': 'VISIBLE',
        });
      });

      test('gone', () {
        Intercom.instance.setInAppMessagesVisibility(IntercomVisibility.gone);
        expectMethodCall('setInAppMessagesVisibility', arguments: {
          'visibility': 'GONE',
        });
      });
    });

    group('setLauncherVisibility', () {
      test('visible', () {
        Intercom.instance.setLauncherVisibility(IntercomVisibility.visible);
        expectMethodCall('setLauncherVisibility', arguments: {
          'visibility': 'VISIBLE',
        });
      });

      test('gone', () {
        Intercom.instance.setLauncherVisibility(IntercomVisibility.gone);
        expectMethodCall('setLauncherVisibility', arguments: {
          'visibility': 'GONE',
        });
      });
    });

    test('updateUser', () {
      Intercom.instance.updateUser(
        email: 'test@example.com',
        name: 'John Doe',
        userId: '1',
        phone: '+37256123456',
        company: 'Some Company LLC',
        companyId: '2',
        signedUpAt: 1590949800,
        language: 'en',
      );
      expectMethodCall('updateUser', arguments: {
        'email': 'test@example.com',
        'name': 'John Doe',
        'userId': '1',
        'phone': '+37256123456',
        'company': 'Some Company LLC',
        'companyId': '2',
        'signedUpAt': 1590949800,
        'language': 'en',
        'customAttributes': null,
      });
    });
  });

  group('logEvent', () {
    test('withoutMetaData', () {
      Intercom.instance.logEvent("TEST");
      expectMethodCall('logEvent', arguments: {
        'name': 'TEST',
        'metaData': null,
      });
    });

    test('withMetaData', () {
      Intercom.instance.logEvent(
        "TEST",
        {'string': 'A string', 'number': 10, 'bool': true},
      );
      expectMethodCall('logEvent', arguments: {
        'name': 'TEST',
        'metaData': {'string': 'A string', 'number': 10, 'bool': true},
      });
    });
  });

  group('UnreadMessageCount', () {
    const String channelName = 'maido.io/intercom/unread';
    const MethodChannel channel = MethodChannel(channelName);
    final int value = 9;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channelName,
          const StandardMethodCodec().encodeSuccessEnvelope(value),
          (ByteData? data) {},
        );
        return;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('testStream', () async {
      expect(await Intercom.instance.getUnreadStream().first, value);
    });
  });

  group('WindowDidHide', () {
    const String channelName = 'maido.io/intercom/windowDidHide';
    const MethodChannel channel = MethodChannel(channelName);
    final bool value = true;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channelName,
          const StandardMethodCodec().encodeSuccessEnvelope(value),
          (ByteData? data) {},
        );
        return;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('testStream', () async {
      expect(await Intercom.instance.getWindowDidHideStream().first, value);
    });
  });

  test('displayArticle', () async {
    final String testArticleId = "123456";
    await Intercom.instance.displayArticle(testArticleId);
    expectMethodCall('displayArticle', arguments: {
      'articleId': testArticleId,
    });
  });

  test('displayCarousel', () async {
    final String testCarouselId = "123456";
    await Intercom.instance.displayCarousel(testCarouselId);
    expectMethodCall('displayCarousel', arguments: {
      'carouselId': testCarouselId,
    });
  });

  test('displaySurvey', () async {
    final String testSurveyId = "123456";
    await Intercom.instance.displaySurvey(testSurveyId);
    expectMethodCall('displaySurvey', arguments: {
      'surveyId': testSurveyId,
    });
  });

  test('displayConversation', () async {
    final String testConversationId = "123456";
    await Intercom.instance.displayConversation(testConversationId);
    expectMethodCall('displayConversation', arguments: {
      'conversationId': testConversationId,
    });
  });

  test('displayTickets', () async {
    await Intercom.instance.displayTickets();
    expectMethodCall('displayTickets');
  });

  test('displayHome', () async {
    await Intercom.instance.displayHome();
    expectMethodCall('displayHome');
  });

  test('setUserJwt', () {
    Intercom.instance.setUserJwt('test');
    expectMethodCall('setUserJwt', arguments: {
      'jwt': 'test',
    });
  });

  test('setAuthTokens', () {
    Intercom.instance.setAuthTokens({'security_token': 'test'});
    expectMethodCall('setAuthTokens', arguments: {
      'tokens': {'security_token': 'test'},
    });
  });

  group('setThemeMode', () {
    test('dark', () {
      Intercom.instance.setThemeMode(IntercomTheme.dark);
      expectMethodCall('setThemeMode', arguments: {
        'theme': 'dark',
      });
    });

    test('light', () {
      Intercom.instance.setThemeMode(IntercomTheme.light);
      expectMethodCall('setThemeMode', arguments: {
        'theme': 'light',
      });
    });

    test('system', () {
      Intercom.instance.setThemeMode(IntercomTheme.system);
      expectMethodCall('setThemeMode', arguments: {
        'theme': 'system',
      });
    });

    test('none', () {
      Intercom.instance.setThemeMode(IntercomTheme.none);
      expectMethodCall('setThemeMode', arguments: {
        'theme': 'none',
      });
    });
  });
}
