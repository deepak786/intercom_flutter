# intercom_flutter_web

The web implementation of [`intercom_flutter`][1].

## Usage

This package is already included as part of the `intercom_flutter` package dependency, and will be included when using `intercom_flutter` as normal.

But if you want to use this package as alone, add the dependency `intercom_flutter_web`.
You don't need to add Intercom script in the index.html file, it will be automatically injected.
But you can pre-define some Intercom settings, if you want (optional), such as `api_base`, `hide_default_launcher`, etc.
```html
<script>
    window.intercomSettings = {
        hide_default_launcher: true, // hide the launcher
    };
</script>
```
#### Following functions are not yet supported on Web:

- unreadConversationCount
- setInAppMessagesVisibility
- sendTokenToIntercom
- isIntercomPush
- handlePush
- displayCarousel
- displayHelpCenterCollections

[1]: ../intercom_flutter

