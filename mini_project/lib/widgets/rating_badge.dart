import 'package:flutter/material.dart';
import 'package:movie_explorer/theme/app_theme.dart';

/// Polished Rating Badge showing a gold star and rating score.
class RatingBadge extends StatelessWidget {
  final double rating;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const RatingBadge({
    super.key,
    required this.rating,
    this.fontSize = 11.0,
    this.iconSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: AppTheme.secondaryGold.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: iconSize,
            color: AppTheme.secondaryGold,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
