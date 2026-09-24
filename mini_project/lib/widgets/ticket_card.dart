import 'package:flutter/material.dart';
import 'package:movie_explorer/models/booking.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';

/// Realistic Cinema E-Ticket with circular cutouts, perforated divider, and QR Matrix.
class TicketCard extends StatelessWidget {
  final Booking booking;

  const TicketCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Ticket Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: AppTheme.crimsonGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_activity_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'CINEMA ADMISSION PASS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(
                      color: AppTheme.secondaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Movie Summary Row
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: MoviePosterImage(
                        movie: booking.movie,
                        showTitle: false,
                        showRating: false,
                        borderRadius: AppTheme.radiusSM,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.movie.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.movie.genre} • ${booking.movie.duration} • ${booking.movie.ageRating}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCrimson.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            ),
                            child: Text(
                              booking.bookingId,
                              style: const TextStyle(
                                color: AppTheme.primaryCrimson,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Perforated Divider with Circular Notches ──
          Row(
            children: [
              // Left Circular Notch Cutout
              Container(
                width: 16,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: const Border(
                    top: BorderSide(color: AppTheme.border),
                    right: BorderSide(color: AppTheme.border),
                    bottom: BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
              // Dashed Line
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: List.generate(
                      28,
                      (index) => Expanded(
                        child: Container(
                          height: 1.5,
                          color: index % 2 == 0 ? AppTheme.border : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Right Circular Notch Cutout
              Container(
                width: 16,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  border: const Border(
                    top: BorderSide(color: AppTheme.border),
                    left: BorderSide(color: AppTheme.border),
                    bottom: BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ],
          ),

          // ── Ticket Details & QR Code Matrix ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  label1: 'SHOWTIME',
                  val1: booking.showtime,
                  label2: 'SEATS',
                  val2: '${booking.seatType} (${booking.ticketsCount})',
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  context,
                  label1: 'CUSTOMER',
                  val1: booking.customerName,
                  label2: 'PHONE',
                  val2: booking.phone,
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  context,
                  label1: 'SNACKS COMBO',
                  val1: booking.hasPopcorn ? 'Included (+₹250)' : 'None',
                  label2: 'TOTAL PAID',
                  val2: '₹${booking.totalAmount.toInt()}',
                  isVal2Highlight: true,
                ),

                const Divider(height: 32),

                // QR Code Generator (8x8 Grid of deterministic bits from booking ID)
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildQrCodeMatrix(booking.bookingId),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scan at Cinema Entry Gate',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Show this digital pass to the usher. No printout required.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a deterministic 8x8 QR code matrix
  Widget _buildQrCodeMatrix(String seed) {
    final hash = seed.hashCode;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 49,
      itemBuilder: (context, index) {
        // Standard QR anchor corners (top-left, top-right, bottom-left)
        final row = index ~/ 7;
        final col = index % 7;
        final isCorner = (row < 2 && col < 2) || (row < 2 && col > 4) || (row > 4 && col < 2);
        final isBlack = isCorner || ((hash ^ (index * 31)) % 3 != 0);

        return Container(
          decoration: BoxDecoration(
            color: isBlack ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label1,
    required String val1,
    required String label2,
    required String val2,
    bool isVal2Highlight = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                val1,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                val2,
                style: TextStyle(
                  fontSize: isVal2Highlight ? 16 : 13,
                  fontWeight: FontWeight.bold,
                  color: isVal2Highlight ? AppTheme.primaryCrimson : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
