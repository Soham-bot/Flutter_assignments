import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:movie_explorer/models/booking.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/ticket_card.dart';

/// Screen 5: Confirmation Summary Screen
/// Displays an animated checkmark with confetti particles, a realistic cinema
/// perforated e-ticket, and navigation back to Home.
class ConfirmationScreen extends StatefulWidget {
  final Booking booking;

  const ConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _confettiAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admission Pass'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close',
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingMD,
          ),
          child: Column(
            children: [
              // ── Animated Header: Checkmark with Confetti ──
              SizedBox(
                height: 120,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Confetti particle icons floating outward
                        ..._buildConfettiParticles(_confettiAnimation.value),

                        // Success checkmark badge with bounce
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppTheme.spacingSM),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Show your admission pass at the theater counter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),

              const SizedBox(height: AppTheme.spacingLG),

              // ── Realistic Perforated Ticket Card ──
              TicketCard(booking: widget.booking),

              const SizedBox(height: AppTheme.spacingXL),

              // ── Action Buttons ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.file_download_done_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Text('Ticket #${widget.booking.bookingId} saved to device!'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Save Ticket to Device'),
                ),
              ),

              const SizedBox(height: AppTheme.spacingMD),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                ),
              ),

              const SizedBox(height: AppTheme.spacingLG),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds subtle decorative animated confetti icons that radiate outward
  List<Widget> _buildConfettiParticles(double progress) {
    const particleData = [
      {'angle': 0.3, 'dist': 60.0, 'icon': Icons.star_rounded, 'color': AppTheme.secondaryGold, 'size': 20.0},
      {'angle': 1.1, 'dist': 55.0, 'icon': Icons.circle, 'color': AppTheme.primaryCrimson, 'size': 10.0},
      {'angle': 1.8, 'dist': 65.0, 'icon': Icons.celebration_rounded, 'color': AppTheme.secondaryGold, 'size': 22.0},
      {'angle': 2.7, 'dist': 58.0, 'icon': Icons.star_rounded, 'color': Color(0xFF60A5FA), 'size': 18.0},
      {'angle': 3.6, 'dist': 62.0, 'icon': Icons.auto_awesome_rounded, 'color': AppTheme.secondaryGold, 'size': 18.0},
      {'angle': 4.4, 'dist': 54.0, 'icon': Icons.circle, 'color': Color(0xFF34D399), 'size': 10.0},
      {'angle': 5.2, 'dist': 64.0, 'icon': Icons.star_rounded, 'color': AppTheme.primaryCrimson, 'size': 20.0},
    ];

    return particleData.map((data) {
      final angle = data['angle'] as double;
      final maxDist = data['dist'] as double;
      final icon = data['icon'] as IconData;
      final color = data['color'] as Color;
      final size = data['size'] as double;

      final currentDist = maxDist * progress;
      final dx = currentDist * math.cos(angle);
      final dy = currentDist * math.sin(angle);
      final opacity = (1.0 - progress * 0.4).clamp(0.0, 1.0);

      return Transform.translate(
        offset: Offset(dx, dy),
        child: Opacity(
          opacity: opacity,
          child: Icon(icon, color: color, size: size),
        ),
      );
    }).toList();
  }
}
