import 'package:flutter/material.dart';
import 'package:localsend_app/widget/liquid_glass.dart';

/// A frosted-glass pill segmented control matching [GlassNavRail] /
/// [GlassBottomNav]'s visual language. The selected segment is shown with
/// a sliding accent-colored capsule behind the label.
class GlassSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  const GlassSegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
    required this.labels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return LiquidGlassContainer(
      borderRadius: BorderRadius.circular(24),
      blurSigma: 20,
      child: Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / labels.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: segmentWidth * selectedIndex,
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.40),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(labels.length, (i) {
                      final selected = i == selectedIndex;
                      return SizedBox(
                        width: segmentWidth,
                        height: double.infinity,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected ? Colors.white : textColor?.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
      ),
    );
  }
}