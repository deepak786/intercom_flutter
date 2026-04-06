# Changelog

## 2.0.7

* Added method `getWindowDidHideStream`.
* Removed deprecated `handlePushMessage`.

## 2.0.6

* Added method `setThemeMode`.

## 2.0.5

* Deprecated `handlePushMessage`

## 2.0.4

* Added method `setAuthTokens`.

## 2.0.3

* Added method `setUserJwt`.

## 2.0.2

* Added method `isUserLoggedIn`.
* Added method `fetchLoggedInUserAttributes`.

## 2.0.1

* Added method `displayHome`.

## 2.0.0

* Removed deprecated methods `registerIdentifiedUser` and `registerUnidentifiedUser`.

## 1.3.2

* Added method `displayTickets`

## 1.3.1

* Added method `displayConversation`

## 1.3.0

* Update minimum Dart version to Dart 3.

## 1.2.3

* Added method `displayHelpCenterCollections`.

## 1.2.2

* Added method `displayMessages`.

## 1.2.1

* Updated dependencies

## 1.2.0

* Added method `displaySurvey`.

## 1.1.0

* Added method `loginIdentifiedUser` with `IntercomStatusCallback` support.
* Deprecated `registerIdentifiedUser` in favor of `loginIdentifiedUser`.
* Added method `loginUnidentifiedUser` with `IntercomStatusCallback` support.
* Deprecated `registerUnidentifiedUser` in favor of `loginUnidentifiedUser`.
* Added parameter `statusCallback` in `updateUser` to support `IntercomStatusCallback`.
* Renamed the following methods in the MethodChannel:
  * `registerIdentifiedUserWithUserId` to `loginIdentifiedUserWithUserId`.
  * `regsiterIdentifiedUserWithEmail` to `loginIdentifiedUserWithEmail`.
  * `registerUnidentifiedUser` to `loginUnidentifiedUser`.

## 1.0.1

* Added API documentation.

## 1.0.0

* displayCarousel
* displayArticle

## 0.0.1

* Initial open source release
