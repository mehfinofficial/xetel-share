import 'package:flutter/material.dart';
import 'package:localsend_app/config/theme.dart';

/// A [DropdownButton] with a custom theme.
/// Currently, there is no easy way to apply color and border radius to all [DropdownButton].
class CustomDropdownButton<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool expanded;

  const CustomDropdownButton({
    required this.value,
    required this.items,
    this.onChanged,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      shape: RoundedRectangleBorder(borderRadius: Theme.of(context).inputDecorationTheme.borderRadius),
      child: DefaultTextStyle.merge(
        // Without this, the selected value falls back to a lower-contrast
        // default text color that reads as "dull"/washed out against the
        // light theme's mint fill (it looks fine on the dark fill, which is
        // why this was only noticeable in light mode).
        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
        child: DropdownButton<T>(
          value: value,
          isExpanded: expanded,
          underline: Container(),
          borderRadius: Theme.of(context).inputDecorationTheme.borderRadius,
          items: items,
          onChanged: onChanged == null
              ? null
              : (value) {
                  if (value != null) {
                    onChanged!(value);
                  }
                },
        ),
      ),
    );
  }
}