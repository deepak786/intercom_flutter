import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intercom_flutter_platform_interface/enumeral.dart';
import 'package:intercom_flutter_platform_interface/intercom_flutter_platform_interface.dart';
import 'package:intercom_flutter_platform_interface/method_channel_intercom_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$IntercomFlutterPlatform', () {
    test('$MethodChannelIntercomFlutter() is the default instance', () {
      expect(IntercomFlutterPlatform.instance,
          isInstanceOf<MethodChannelIntercomFlutter>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        IntercomFlutterPlatform.instance = ImplementsIntercomFlutterPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final IntercomFlutterPlatformMock mock = IntercomFlutterPlatformMock();
      IntercomFlutterPlatform.instance = mock;
    });

    test('Can be extended', () {
      IntercomFlutterPlatform.instance = ExtendsIntercomFlutterPlatform();
    });
  });

  group('$MethodChannelIntercomFlutter', () {
    const MethodChannel channel = MethodChannel('maido.io/intercom');
    final List<MethodCall> log = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);

      // Return null explicitly instead of relying on the implicit null
      // returned by the method channel if no return statement is specified.
      return null;
    });

    final MethodChannelIntercomFlutter intercom =
        MethodChannelIntercomFlutter();

    tearDown(() {
      log.clear();
    });

    test('initialize', () async {
      final appId = 'mock';
      final androidApiKey = 'android-key';
      final iosApiKey = 'ios-key';

      await intercom.initialize(
        appId,
        androidApiKey: androidApiKey,
        iosApiKey: iosApiKey,
      );

      expect(
        log,
        <Matcher>[
          isMethodCall('initialize', arguments: {
            'appId': appId,
            'androidApiKey': androidApiKey,
            'iosApiKey': iosApiKey,
          })
        ],
      );
    });

    test('testSendingAPNTokenToIntercom', () async {
      await intercom.sendTokenToIntercom('mock_apn_token');
      expect(
        log,
        <Matcher>[
          isMethodCall('sendTokenToIntercom', arguments: {
            'token': 'mock_apn_token',
          })
        ],
      );
    });

    group('loginIdentifiedUser', () {
      test('with userId', () async {
        await intercom.loginIdentifiedUser(userId: 'test');
        expect(
          log,
          <Matcher>[
            isMethodCall('loginIdentifiedUserWithUserId', arguments: {
              'userId': 'test',
            })
          ],
        );
      });

      test('with email', () async {
        await intercom.loginIdentifiedUser(email: 'test');
        expect(
          log,
          <Matcher>[
            isMethodCall('loginIdentifiedUserWithEmail', arguments: {
              'email': 'test',
            })
          ],
        );
      });

      test('with userId and email should fail', () {
        expect(
          () => intercom.loginIdentifiedUser(
            userId: 'testId',
            email: 'testEmail',
          ),
          throwsArgumentError,
        );
      });

      test('without parameters', () {
        expect(() => intercom.loginIdentifiedUser(), throwsArgumentError);
      });
    });

    test('loginUnidentifiedUser', () async {
      await intercom.loginUnidentifiedUser();
      expect(
        log,
        <Matcher>[isMethodCall('loginUnidentifiedUser', arguments: null)],
      );
    });

    test('setBottomPadding', () async {
      final padding = 64;
      await intercom.setBottomPadding(padding);
      expect(
        log,
        <Matcher>[
          isMethodCall('setBottomPadding', arguments: {
            'bottomPadding': padding,
          })
        ],
      );
    });

    test('setUserHash', () async {
      await intercom.setUserHash('test');
      expect(
        log,
        <Matcher>[
          isMethodCall('setUserHash', arguments: {
            'userHash': 'test',
          })
        ],
      );
    });

    test('logout', () async {
      await intercom.logout();
      expect(
        log,
        <Matcher>[isMethodCall('logout', arguments: null)],
      );
    });

    group('toggleMessengerVisibility', () {
      test('displayMessenger', () async {
        await intercom.displayMessenger();
        expect(
          log,
          <Matcher>[isMethodCall('displayMessenger', arguments: null)],
        );
      });

      test('hideMessenger', () async {
        await intercom.hideMessenger();
        expect(
          log,
          <Matcher>[isMethodCall('hideMessenger', arguments: null)],
        );
      });
    });

    test('displayHelpCenter', () async {
      await intercom.displayHelpCenter();
      expect(
        log,
        <Matcher>[isMethodCall('displayHelpCenter', arguments: null)],
      );
    });

    test('displayHelpCenter', () async {
      final collectionIds = ['collectionId1', 'collectionId2'];
      await intercom.displayHelpCenterCollections(collectionIds);
      expect(
        log,
        <Matcher>[
          isMethodCall('displayHelpCenterCollections',
              arguments: {'collectionIds': collectionIds})
        ],
      );
    });

    test('displayMessages', () async {
      await intercom.displayMessages();
      expect(
        log,
        <Matcher>[isMethodCall('displayMessages', arguments: null)],
      );
    });

    test('unreadConversationCount', () async {
      await intercom.unreadConversationCount();
      expect(
        log,
        <Matcher>[isMethodCall('unreadConversationCount', arguments: null)],
      );
    });

    test('displayMessageComposer', () async {
      await intercom.displayMessageComposer("message");
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'displayMessageComposer',
            arguments: {"message": "message"},
          )
        ],
      );
    });

    group('setInAppMessagesVisibility', () {
      test('visible', () async {
        await intercom.setInAppMessagesVisibility(IntercomVisibility.visible);
        expect(
          log,
          <Matcher>[
            isMethodCall('setInAppMessagesVisibility', arguments: {
              'visibility': 'VISIBLE',
            })
          ],
        );
      });

      test('gone', () async {
        await intercom.setInAppMessagesVisibility(IntercomVisibility.gone);
        expect(
          log,
          <Matcher>[
            isMethodCall('setInAppMessagesVisibility', arguments: {
              'visibility': 'GONE',
            })
          ],
        );
      });
    });

    group('setLauncherVisibility', () {
      test('visible', () async {
        await intercom.setLauncherVisibility(IntercomVisibility.visible);
        expect(
          log,
          <Matcher>[
            isMethodCall('setLauncherVisibility', arguments: {
              'visibility': 'VISIBLE',
            })
          ],
        );
      });

      test('gone', () async {
        await intercom.setLauncherVisibility(IntercomVisibility.gone);
        expect(
          log,
          <Matcher>[
            isMethodCall('setLauncherVisibility', arguments: {
              'visibility': 'GONE',
            })
          ],
        );
      });
    });

    test('updateUser', () async {
      await intercom.updateUser(
        email: 'test@example.com',
        name: 'John Doe',
        userId: '1',
        phone: '+37256123456',
        company: 'Some Company LLC',
        companyId: '2',
        signedUpAt: 1590949800,
        language: 'en',
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('updateUser', arguments: {
            'email': 'test@example.com',
            'name': 'John Doe',
            'userId': '1',
            'phone': '+37256123456',
            'company': 'Some Company LLC',
            'companyId': '2',
            'signedUpAt': 1590949800,
            'language': 'en',
            'customAttributes': null,
          })
        ],
      );
    });

    group('logEvent', () {
      test('withoutMetaData', () async {
        await intercom.logEvent("TEST");
        expect(
          log,
          <Matcher>[
            isMethodCall('logEvent', arguments: {
              'name': 'TEST',
              'metaData': null,
            })
          ],
        );
      });

      test('withMetaData', () async {
        await intercom.logEvent(
          "TEST",
          {'string': 'A string', 'number': 10, 'bool': true},
        );
        expect(
          log,
          <Matcher>[
            isMethodCall('logEvent', arguments: {
              'name': 'TEST',
              'metaData': {'string': 'A string', 'number': 10, 'bool': true},
            })
          ],
        );
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
        expect(await intercom.getUnreadStream().first, value);
      });
    });

    String testArticleId = "123456";
    test('displayArticle', () async {
      await intercom.displayArticle(testArticleId);
      expect(
        log,
        <Matcher>[
          isMethodCall('displayArticle', arguments: {
            'articleId': testArticleId,
          })
        ],
      );
    });

    String testCarouselId = "123456";
    test('displayCarousel', () async {
      await intercom.displayCarousel(testCarouselId);
      expect(
        log,
        <Matcher>[
          isMethodCall('displayCarousel', arguments: {
            'carouselId': testCarouselId,
          })
        ],
      );
    });

    String testSurveyId = "123456";
    test('displaySurvey', () async {
      await intercom.displaySurvey(testSurveyId);
      expect(
        log,
        <Matcher>[
          isMethodCall('displaySurvey', arguments: {
            'surveyId': testSurveyId,
          })
        ],
      );
    });

    String testConversationId = "123456";
    test('displayConversation', () async {
      await intercom.displayConversation(testConversationId);
      expect(
        log,
        <Matcher>[
          isMethodCall('displayConversation', arguments: {
            'conversationId': testConversationId,
          })
        ],
      );
    });

    test('displayTickets', () async {
      await intercom.displayTickets();
      expect(
        log,
        <Matcher>[isMethodCall('displayTickets', arguments: null)],
      );
    });

    test('displayHome', () async {
      await intercom.displayHome();
      expect(
        log,
        <Matcher>[isMethodCall('displayHome', arguments: null)],
      );
    });

    test('isUserLoggedIn', () async {
      await intercom.isUserLoggedIn();
      expect(
        log,
        <Matcher>[isMethodCall('isUserLoggedIn', arguments: null)],
      );
    });

    test('fetchLoggedInUserAttributes', () async {
      await intercom.fetchLoggedInUserAttributes();
      expect(
        log,
        <Matcher>[isMethodCall('fetchLoggedInUserAttributes', arguments: null)],
      );
    });

    test('setUserJwt', () async {
      await intercom.setUserJwt('test');
      expect(
        log,
        <Matcher>[
          isMethodCall('setUserJwt', arguments: {
            'jwt': 'test',
          })
        ],
      );
    });

    test('setAuthTokens', () async {
      await intercom.setAuthTokens({'security_token': 'test'});
      expect(
        log,
        <Matcher>[
          isMethodCall('setAuthTokens', arguments: {
            'tokens': {'security_token': 'test'},
          })
        ],
      );
    });

    group('setThemeMode', () {
      test('dark', () async {
        await intercom.setThemeMode(IntercomTheme.dark);
        expect(
          log,
          <Matcher>[
            isMethodCall('setThemeMode', arguments: {
              'theme': 'dark',
            })
          ],
        );
      });

      test('light', () async {
        await intercom.setThemeMode(IntercomTheme.light);
        expect(
          log,
          <Matcher>[
            isMethodCall('setThemeMode', arguments: {
              'theme': 'light',
            })
          ],
        );
      });

      test('system', () async {
        await intercom.setThemeMode(IntercomTheme.system);
        expect(
          log,
          <Matcher>[
            isMethodCall('setThemeMode', arguments: {
              'theme': 'system',
            })
          ],
        );
      });

      test('none', () async {
        await intercom.setThemeMode(IntercomTheme.none);
        expect(
          log,
          <Matcher>[
            isMethodCall('setThemeMode', arguments: {
              'theme': 'none',
            })
          ],
        );
      });
    });

    group('suppressProactiveContent', () {
      test('suppress carousel and survey', () async {
        await intercom.suppressProactiveContent([
          IntercomProactiveContentType.carousel,
          IntercomProactiveContentType.survey,
        ]);
        expect(
          log,
          <Matcher>[
            isMethodCall('suppressProactiveContent', arguments: {
              'types': ['carousel', 'survey'],
            })
          ],
        );
      });

      test('unsuppress all', () async {
        await intercom.suppressProactiveContent([]);
        expect(
          log,
          <Matcher>[
            isMethodCall('suppressProactiveContent', arguments: {
              'types': [],
            })
          ],
        );
      });
    });
  });
}

class IntercomFlutterPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements IntercomFlutterPlatform {}

class ImplementsIntercomFlutterPlatform extends Mock
    implements IntercomFlutterPlatform {}

class ExtendsIntercomFlutterPlatform extends IntercomFlutterPlatform {}
