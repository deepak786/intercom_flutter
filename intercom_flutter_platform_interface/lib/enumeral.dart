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
