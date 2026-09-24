import 'package:flutter/material.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/rating_badge.dart';

/// Cinematic 2:3 Movie Poster Widget.
/// Renders rich color gradients, watermark genre iconography,
/// dark bottom scrim, overlaid title, and rating badge.
class MoviePosterImage extends StatelessWidget {
  final Movie movie;
  final String? heroTag;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showTitle;
  final bool showRating;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;

  const MoviePosterImage({
    super.key,
    required this.movie,
    this.heroTag,
    this.width,
    this.height,
    this.borderRadius = AppTheme.radiusLG,
    this.showTitle = true,
    this.showRating = true,
    this.onBookmarkTap,
    this.isBookmarked = false,
  });

  Widget _buildPosterContent(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: movie.posterColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Watermark Genre Icon
          Positioned(
            right: -10,
            top: 20,
            child: Icon(
              movie.posterIcon,
              size: 110,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),

          // Center Cinema Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                movie.posterIcon,
                size: 36,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),

          // Dark Gradient Scrim for readable bottom text
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: AppTheme.posterOverlayGradient,
              ),
            ),
          ),

          // Top Rating Badge
          if (showRating)
            Positioned(
              top: 8,
              left: 8,
              child: RatingBadge(rating: movie.rating),
            ),

          // Top Bookmark Action Button
          if (onBookmarkTap != null)
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppTheme.primaryCrimson : Colors.white,
                  size: 22,
                ),
                onPressed: onBookmarkTap,
              ),
            ),

          // Bottom Title & Year Overlay
          if (showTitle)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${movie.year}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          movie.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.secondaryGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
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

  @override
  Widget build(BuildContext context) {
    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: _buildPosterContent(context),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: poster,
      );
    }
    return poster;
  }
}
