import 'package:flutter/foundation.dart';

/// Global state tracking whether an immersive full-screen mode (e.g. Quran auto-scroll) is active.
/// Used by [AppShell] to hide the bottom navigation bar during full-screen reading,
/// and restore it immediately when stopped or exited.
class AppFullscreenState {
  AppFullscreenState._();

  static final ValueNotifier<bool> isFullscreenNotifier = ValueNotifier<bool>(false);

  static bool get isFullscreen => isFullscreenNotifier.value;

  static void setFullscreen(bool value) {
    if (isFullscreenNotifier.value != value) {
      isFullscreenNotifier.value = value;
    }
  }
}
