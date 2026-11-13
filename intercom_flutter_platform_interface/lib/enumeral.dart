enum IntercomVisibility {
  gone,
  visible,
}

/// Proactive content types whose visibility can be controlled via
/// `suppressProactiveContent`.
enum IntercomProactiveContentType {
  carousel,
  survey,
}

/// The location permission status reported by an
/// `IntercomLocationPermissionProvider`.
///
/// Matches the iOS `CLAuthorizationStatus` values.
enum IntercomLocationAuthorizationStatus {
  notDetermined,
  restricted,
  denied,
  authorizedAlways,
  authorizedWhenInUse,
}

enum IntercomTheme {
  // // Enable dark mode
  dark,

  // Enable light mode
  light,

  // Use system preference
  system,

  // Clear override and use server-provided theme
  none,
}
