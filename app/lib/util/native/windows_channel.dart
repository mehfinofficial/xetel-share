import 'package:flutter/services.dart';

const _methodChannel = MethodChannel('com.xetel.share/window');

/// Forces the native Win32 title bar into dark or light mode.
///
/// By default, Windows only paints the title bar based on the OS-wide theme
/// setting (Settings > Personalization > Colors), which means it doesn't
/// react to the in-app theme (Settings > Appearance) at all. Calling this
/// whenever the resolved app theme changes keeps the title bar and the app
/// content in sync, including when the app theme is set to "System" and the
/// OS theme changes at runtime.
///
/// No-op on non-Windows platforms (the underlying channel is only
/// registered by windows/runner/flutter_window.cpp).
Future<void> setWindowsTitleBarDarkMode(bool darkMode) async {
  try {
    await _methodChannel.invokeMethod('setTitleBarDarkMode', darkMode);
  } catch (_) {
    // Best-effort only. Swallow failures, e.g. running on a Windows version
    // that doesn't support DWMWA_USE_IMMERSIVE_DARK_MODE.
  }
}