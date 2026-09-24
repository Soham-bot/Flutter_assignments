import 'package:flutter/material.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/utils/constants.dart';

/// Pill-shaped genre chip widget (custom Container without Material Chip clutter).
class GenrePill extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showIcon;
  final double fontSize;

  const GenrePill({
    super.key,
    required this.genre,
    this.isSelected = false,
    this.onTap,
    this.showIcon = true,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final icon = AppConstants.getGenreIcon(genre);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryCrimson
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryCrimson
                    : AppTheme.border.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryCrimson.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.white : AppTheme.primaryCrimson,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
