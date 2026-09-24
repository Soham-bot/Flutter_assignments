import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';

/// Reusable 2:3 Poster Card for horizontal sections and grid displays.
/// Supports tap to navigate, long-press to compare movies, and instant bookmark toggle.
class PosterCard extends StatelessWidget {
  final Movie movie;
  final String heroPrefix;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double width;

  const PosterCard({
    super.key,
    required this.movie,
    required this.heroPrefix,
    required this.onTap,
    this.onLongPress,
    this.width = 135.0,
  });

  void _toggleWatchlist(BuildContext context) {
    final repo = MovieRepository();
    final wasIn = repo.isInWatchlist(movie.id);
    repo.toggleWatchlist(movie.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              wasIn ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                wasIn
                    ? 'Removed "${movie.title}"'
                    : 'Added "${movie.title}" to Watchlist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppTheme.secondaryGold,
          onPressed: () {
            if (wasIn) {
              repo.addToWatchlist(movie.id);
            } else {
              repo.removeFromWatchlist(movie.id);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MovieRepository(),
      builder: (context, _) {
        final isSaved = MovieRepository().isInWatchlist(movie.id);

        return Container(
          width: width,
          margin: const EdgeInsets.only(right: AppTheme.spaceMD),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              child: MoviePosterImage(
                movie: movie,
                heroTag: '${heroPrefix}_${movie.id}',
                isBookmarked: isSaved,
                onBookmarkTap: () => _toggleWatchlist(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
