import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selectedColor ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : theme.colorScheme.onSurface,
        fontWeight:
            isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : theme.colorScheme.outlineVariant,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }
}

class ColorFilterChip extends StatelessWidget {
  final String colorName;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorFilterChip({
    super.key,
    required this.colorName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = _colorFromName(colorName);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (colorName != 'All')
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
          Text(colorName),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
