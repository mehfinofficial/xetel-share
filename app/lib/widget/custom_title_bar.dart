import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:window_manager/window_manager.dart';

/// Replaces the native Windows caption with an in-app title bar that matches
/// the app's own branding and theme, instead of the default OS chrome.
/// No-op on every other platform.
class CustomTitleBar extends StatefulWidget {
  final Widget child;

  const CustomTitleBar({required this.child});

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (checkPlatform([TargetPlatform.windows])) {
      windowManager.addListener(this);
      // ignore: discarded_futures
      windowManager.isMaximized().then((value) {
        if (mounted) {
          setState(() => _isMaximized = value);
        }
      });
    }
  }

  @override
  void dispose() {
    if (checkPlatform([TargetPlatform.windows])) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    if (mounted) {
      setState(() => _isMaximized = true);
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) {
      setState(() => _isMaximized = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!checkPlatform([TargetPlatform.windows])) {
      return widget.child;
    }

    return Column(
      children: [
        _buildBar(context),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/img/logo-32.png', width: 20, height: 20),
                    const SizedBox(width: 10),
                    Text(
                      t.appName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _TitleBarButton(
            icon: Icons.remove_rounded,
            onPressed: () => windowManager.minimize(),
          ),
          _TitleBarButton(
            icon: _isMaximized ? Icons.filter_none_rounded : Icons.crop_square_rounded,
            iconSize: _isMaximized ? 14 : 15,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _TitleBarButton(
            icon: Icons.close_rounded,
            hoverColor: Colors.red,
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color? hoverColor;
  final VoidCallback onPressed;

  const _TitleBarButton({
    required this.icon,
    required this.onPressed,
    this.iconSize = 16,
    this.hoverColor,
  });

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoverBackground = widget.hoverColor ?? theme.colorScheme.primary.withValues(alpha: 0.15);
    final iconColor = _hovering && widget.hoverColor != null ? Colors.white : theme.iconTheme.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 40,
          color: _hovering ? hoverBackground : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        ),
      ),
    );
  }
}