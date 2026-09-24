import 'package:flutter/material.dart';
import 'package:movie_explorer/theme/app_theme.dart';

enum SeatStatus { available, selected, booked }

/// Interactive Cinema Seat Widget for the 8x6 auditorium grid.
class SeatWidget extends StatelessWidget {
  final String seatId;
  final SeatStatus status;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seatId,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case SeatStatus.selected:
        backgroundColor = AppTheme.primaryCrimson;
        borderColor = AppTheme.primaryCrimson;
        textColor = Colors.white;
        icon = Icons.check_rounded;
        break;
      case SeatStatus.booked:
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
        borderColor = Colors.transparent;
        textColor = AppTheme.textMuted.withValues(alpha: 0.5);
        icon = Icons.close_rounded;
        break;
      case SeatStatus.available:
        backgroundColor = Theme.of(context).cardColor;
        borderColor = AppTheme.border;
        textColor = AppTheme.textSecondary;
        icon = null;
        break;
    }

    final isTappable = status != SeatStatus.booked;

    return GestureDetector(
      onTap: isTappable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            topRight: Radius.circular(7),
            bottomLeft: Radius.circular(3),
            bottomRight: Radius.circular(3),
          ),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: status == SeatStatus.selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCrimson.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 12, color: textColor)
              : Text(
                  seatId,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
