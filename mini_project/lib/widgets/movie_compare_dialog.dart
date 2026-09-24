import 'package:flutter/material.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';

/// Modal Dialog comparing two movies side-by-side.
class MovieCompareDialog extends StatelessWidget {
  final Movie movieA;
  final Movie movieB;

  const MovieCompareDialog({
    super.key,
    required this.movieA,
    required this.movieB,
  });

  static void show(BuildContext context, Movie a, Movie b) {
    showDialog(
      context: context,
      builder: (ctx) => MovieCompareDialog(movieA: a, movieB: b),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
      title: const Row(
        children: [
          Icon(Icons.compare_arrows_rounded, color: AppTheme.primaryCrimson, size: 26),
          SizedBox(width: 10),
          Text('Movie Comparison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Posters Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: MoviePosterImage(
                            movie: movieA,
                            showRating: false,
                            showTitle: false,
                            borderRadius: AppTheme.radiusSM,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          movieA.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 40),
                    child: Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.secondaryGold)),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: MoviePosterImage(
                            movie: movieB,
                            showRating: false,
                            showTitle: false,
                            borderRadius: AppTheme.radiusSM,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          movieB.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Metrics Comparison Table
              _buildCompareRow('IMDb Rating', '★ ${movieA.rating}', '★ ${movieB.rating}',
                  isWinnerA: movieA.rating > movieB.rating, isWinnerB: movieB.rating > movieA.rating),
              _buildCompareRow('Release Year', '${movieA.year}', '${movieB.year}'),
              _buildCompareRow('Runtime', movieA.duration, movieB.duration),
              _buildCompareRow('Genre', movieA.genre, movieB.genre),
              _buildCompareRow('Director', movieA.director, movieB.director),
              _buildCompareRow('Ticket Price', '₹${movieA.ticketPrice.toInt()}', '₹${movieB.ticketPrice.toInt()}'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildCompareRow(
    String label,
    String valA,
    String valB, {
    bool isWinnerA = false,
    bool isWinnerB = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  valA,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isWinnerA ? FontWeight.bold : FontWeight.w500,
                    color: isWinnerA ? AppTheme.secondaryGold : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  valB,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isWinnerB ? FontWeight.bold : FontWeight.w500,
                    color: isWinnerB ? AppTheme.secondaryGold : null,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 8, thickness: 0.5),
        ],
      ),
    );
  }
}
