# Changelog

## 1.1.12

* Updated `intercom_flutter_platform_interface` to `^2.0.7`.
* Removed deprecated `handlePushMessage`.

## 1.1.11

* JSON-encode `intercomSettings` before injecting the Intercom script to avoid invalid JavaScript
  syntax. Fixes [#582](https://github.com/v3rm0n/intercom_flutter/issues/582)

## 1.1.10

* Implemented method `setThemeMode`.

## 1.1.9

* Removed `auth_tokens` and `intercom_user_jwt` from intercomSettings on logout.

## 1.1.8

* Deprecated `handlePushMessage`.

## 1.1.7

* Implemented method `setAuthTokens`.

## 1.1.6

* Implemented method `setUserJwt`.

## 1.1.5

* Set user_hash, user_id, email in intercomSettings.
* Implemented methods `isUserLoggedIn` and `fetchLoggedInUserAttributes`.

## 1.1.4

* Updated dependency `intercom_flutter_platform_interface: ^2.0.2`.

## 1.1.3

* Implemented method `displayHome`.

## 1.1.2

* Bump `web` to `^1.0.0`

## 1.1.1

* Updated window.intercomSettings as Map instead of JSObject.

## 1.1.0

* Migrated to js_interop to be compatible with WASM.

## 1.0.2

* Automatically Injected Intercom script, if it is not added.

## 1.0.1

* Updated dependency `uuid: ^4.2.1`.

## 1.0.0

* Removed deprecated methods `registerIdentifiedUser` and `registerUnidentifiedUser`.

## 0.3.3

* Implemented method `displayTickets`.

## 0.3.2

* Implemented method `displayConversation`.

## 0.3.1

* Implemented method `displayHelpCenter`.

## 0.3.0

* Update minimum Dart version to Dart 3.

## 0.2.3

* Updated dependency `intercom_flutter_platform_interface: ^1.2.3`.

## 0.2.2

* Added method `displayMessages`.

## 0.2.1

* Updated dependencies

## 0.2.0

* Updated dependency `intercom_flutter_platform_interface: ^1.2.0`.
* Implemented `displaySurvey` [(startSurvey)](https://developers.intercom.com/installing-intercom/docs/intercom-javascript#intercomstartsurvey-surveyid)

## 0.1.0

* Added method `loginIdentifiedUser` with `IntercomStatusCallback` support.
* Deprecated `registerIdentifiedUser` in favor of `loginIdentifiedUser`.
* Added method `loginUnidentifiedUser` with `IntercomStatusCallback` support.
* Deprecated `registerUnidentifiedUser` in favor of `loginUnidentifiedUser`.
* Added parameter `statusCallback` in updateUser to support `IntercomStatusCallback`.
* Updated `intercom_flutter_platform_interface` version to `1.1.0`.

## 0.0.5

* Implemented `displayArticle` [(showArticle)](https://developers.intercom.com/installing-intercom/docs/intercom-javascript#intercomshowarticle-articleid)

## 0.0.4

* Updated dependency `intercom_flutter_platform_interface: ^1.0.1`

## 0.0.3

* Resolved issue [#173](https://github.com/v3rm0n/intercom_flutter/issues/173)

## 0.0.2

* Updated dependency intercom_flutter_platform_interface: ^1.0.0

## 0.0.1

* Initial open source release
