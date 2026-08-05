import 'package:flutter/material.dart';
import 'package:localsend_app/widget/liquid_glass.dart';

/// Shared destination model used by both [GlassNavRail] (desktop/tablet)
/// and [GlassBottomNav] (mobile).
class GlassNavDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const GlassNavDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Floating frosted-glass pill navigation bar for mobile.
/// Sits above the bottom edge with margin on all sides so it reads as a
/// floating capsule rather than a docked bar.
class GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<GlassNavDestination> destinations;

  const GlassBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: LiquidGlassContainer(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(destinations.length, (i) {
              final selected = i == selectedIndex;
              final dest = destinations[i];
              return _GlassNavItem(
                icon: selected ? (dest.selectedIcon ?? dest.icon) : dest.icon,
                selected: selected,
                accent: scheme.primary,
                onTap: () => onDestinationSelected(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: selected ? 52 : 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 22,
          color: selected ? Colors.white : iconColor?.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

/// Floating frosted-glass pill navigation rail for desktop/tablet.
/// Replaces the stock [NavigationRail]. Set [extended] to true to show
/// labels next to icons (desktop), false for icon-only (tablet).
class GlassNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<GlassNavDestination> destinations;
  final bool extended;
  final Widget? leading;

  const GlassNavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 20),
      child: LiquidGlassContainer(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: extended ? 200 : 80,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) leading!,
              ...List.generate(destinations.length, (i) {
                final selected = i == selectedIndex;
                final dest = destinations[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _GlassRailItem(
                    icon: selected ? (dest.selectedIcon ?? dest.icon) : dest.icon,
                    label: dest.label,
                    selected: selected,
                    extended: extended,
                    accent: scheme.primary,
                    onTap: () => onDestinationSelected(i),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassRailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final Color accent;
  final VoidCallback onTap;

  const _GlassRailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: extended ? 16 : 0),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: extended
            ? Row(
                children: [
                  Icon(icon, size: 20, color: selected ? Colors.white : textColor?.withValues(alpha: 0.65)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : textColor?.withValues(alpha: 0.75),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Icon(icon, size: 22, color: selected ? Colors.white : textColor?.withValues(alpha: 0.65)),
              ),
      ),
    );
  }
}