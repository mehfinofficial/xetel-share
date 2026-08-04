import 'package:flutter/material.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/native/windows_channel.dart';

/// Keeps the native Windows title bar (dark/light) in sync with the
/// resolved Flutter theme brightness.
///
/// [Theme.of(context).brightness] is already the fully resolved value (it
/// accounts for ThemeMode.system by reading the OS brightness itself), so
/// this widget doesn't need to re-derive it - it just forwards changes to
/// the native side whenever they happen, including live OS theme switches
/// while ThemeMode.system is active.
///
/// No-op on non-Windows platforms.
class WindowsTitleBarWatcher extends StatefulWidget {
  final Widget child;

  const WindowsTitleBarWatcher({required this.child, super.key});

  @override
  State<WindowsTitleBarWatcher> createState() => _WindowsTitleBarWatcherState();
}

class _WindowsTitleBarWatcherState extends State<WindowsTitleBarWatcher> {
  Brightness? _lastSyncedBrightness;

  @override
  Widget build(BuildContext context) {
    if (checkPlatform([TargetPlatform.windows])) {
      final brightness = Theme.of(context).brightness;
      if (brightness != _lastSyncedBrightness) {
        _lastSyncedBrightness = brightness;
        // Fire and forget; failures are swallowed inside the channel helper.
        setWindowsTitleBarDarkMode(brightness == Brightness.dark);
      }
    }
    return widget.child;
  }
}