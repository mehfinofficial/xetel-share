import 'package:flutter/material.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/widget/liquid_glass.dart';
import 'package:localsend_app/widget/responsive_builder.dart';

class BigButton extends StatelessWidget {
  static const double desktopWidth = 104.0;
  static const double mobileWidth = 92.0;

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const BigButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sizingInformation = SizingInformation(MediaQuery.sizeOf(context).width);
    final buttonWidth = sizingInformation.isDesktop ? desktopWidth : mobileWidth;
    final borderRadius = BorderRadius.circular(18);

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12 + desktopPaddingFix),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: filled ? colorScheme.onPrimary : colorScheme.primary, size: 26),
          FittedBox(
            alignment: Alignment.bottomCenter,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: filled ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );

    if (!filled) {
      // Real liquid glass surface: blur + gradient depth + specular sheen,
      // matching the nav rail / settings sections.
      //
      // LiquidGlassContainer's Stack sizes itself to the *given* box (here,
      // the fixed SizedBox below), but its child is laid out with loose
      // constraints — so without forcing it to expand, the icon+label would
      // shrink to their own small size and sit pinned to the top-left corner,
      // and the InkWell's tap/hover area would shrink along with them.
      // SizedBox.expand forces content to claim the full box instead.
      return SizedBox(
        width: buttonWidth,
        height: 78.0,
        child: LiquidGlassContainer(
          borderRadius: borderRadius,
          blurSigma: 18,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              child: SizedBox.expand(child: content),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: buttonWidth,
      height: 78.0,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                Color.lerp(colorScheme.primary, Colors.black, isDark ? 0.15 : 0.08)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: isDark ? 0.28 : 0.22),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: content,
          ),
        ),
      ),
    );
  }
}