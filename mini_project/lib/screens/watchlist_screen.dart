import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/genre_pill.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';
import 'package:movie_explorer/widgets/rating_badge.dart';

/// Screen 6: Watchlist Screen
/// Features dual tabs ("To Watch" & "Watched"), watch progress bar,
/// calculated stats card (total hours, favorite genre), and swipe-to-delete with undo.
class WatchlistScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onExploreTap;

  const WatchlistScreen({
    super.key,
    this.isEmbedded = false,
    this.onExploreTap,
  });

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  void _navigateToDetail(Movie movie) {
    Navigator.pushNamed(
      context,
      '/movie_detail',
      arguments: movie,
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _removeWithUndo(BuildContext context, Movie movie) {
    final repo = MovieRepository();
    repo.removeFromWatchlist(movie.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bookmark_remove_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Removed "${movie.title}" from Watchlist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppTheme.secondaryGold,
          onPressed: () {
            repo.addToWatchlist(movie.id);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final toWatchList = repo.watchlistMovies.where((m) => !m.isWatched).toList();
        final watchedList = repo.watchlistMovies.where((m) => m.isWatched).toList();
        final totalCount = repo.watchlistCount;
        final watchedCount = repo.watchedCount;
        final progressRatio = totalCount > 0 ? (watchedCount / totalCount) : 0.0;
        final percentage = (progressRatio * 100).toInt();

        final content = DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // ── Top Summary & Progress Header ──
              _buildProgressCard(
                context,
                watchedCount: watchedCount,
                totalCount: totalCount,
                progressRatio: progressRatio,
                percentage: percentage,
                totalHours: repo.totalWatchlistHours.toDouble(),
                favoriteGenre: repo.favoriteGenre,
              ),

              // ── Tab Bar ──
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLG,
                  vertical: AppTheme.spaceSM,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: AppTheme.crimsonGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD - 2),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_outline_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('To Watch (${toWatchList.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('Watched (${watchedList.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Views ──
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMovieList(
                      context,
                      movies: toWatchList,
                      isWatchedTab: false,
                    ),
                    _buildMovieList(
                      context,
                      movies: watchedList,
                      isWatchedTab: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (widget.isEmbedded) {
          return content;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Watchlist'),
          ),
          body: content,
        );
      },
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required int watchedCount,
    required int totalCount,
    required double progressRatio,
    required int percentage,
    required double totalHours,
    required String favoriteGenre,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.spaceLG,
        AppTheme.spaceSM,
        AppTheme.spaceLG,
        AppTheme.spaceXS,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Watch Progress Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Watching Progress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
              ),
              Text(
                "You've watched $watchedCount of $totalCount ($percentage%)",
                style: const TextStyle(
                  color: AppTheme.secondaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceHighlight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCrimson),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // Stats Row
          Row(
            children: [
              _buildStatChip(
                context,
                icon: Icons.access_time_filled_rounded,
                label: 'Time to Watch',
                value: '${totalHours.toStringAsFixed(1)} hrs',
                color: const Color(0xFF60A5FA),
              ),
              const SizedBox(width: AppTheme.spaceSM),
              _buildStatChip(
                context,
                icon: Icons.movie_filter_rounded,
                label: 'Favorite Genre',
                value: favoriteGenre,
                color: AppTheme.secondaryGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMD,
          vertical: AppTheme.spaceSM,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieList(
    BuildContext context, {
    required List<Movie> movies,
    required bool isWatchedTab,
  }) {
    if (movies.isEmpty) {
      return _buildEmptyState(context, isWatchedTab: isWatchedTab);
    }

    final repo = MovieRepository();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLG,
        vertical: AppTheme.spaceSM,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Dismissible(
          key: Key('watchlist_item_${movie.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppTheme.spaceLG),
            margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
            decoration: BoxDecoration(
              color: Colors.red.shade800,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
          onDismissed: (_) => _removeWithUndo(context, movie),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              border: Border.all(color: AppTheme.border),
            ),
            child: InkWell(
              onTap: () => _navigateToDetail(movie),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2:3 Aspect ratio poster thumbnail
                    SizedBox(
                      width: 70,
                      child: MoviePosterImage(
                        movie: movie,
                        showTitle: false,
                        showRating: false,
                        borderRadius: AppTheme.radiusSM,
                        heroTag: 'watchlist_${isWatchedTab ? "w" : "u"}_${movie.id}',
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    // Movie details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${movie.year} • ${movie.duration} • ${movie.ageRating}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              GenrePill(
                                genre: movie.genre,
                                showIcon: false,
                                fontSize: 10,
                              ),
                              const SizedBox(width: 6),
                              RatingBadge(
                                rating: movie.rating,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            movie.synopsis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceXS),
                    // Watched status checkbox button
                    IconButton(
                      tooltip: movie.isWatched ? 'Mark as Unwatched' : 'Mark as Watched',
                      icon: Icon(
                        movie.isWatched
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        color: movie.isWatched
                            ? AppTheme.successGreen
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 26,
                      ),
                      onPressed: () {
                        repo.toggleWatched(movie.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isWatchedTab}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              decoration: BoxDecoration(
                color: AppTheme.primaryCrimson.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWatchedTab ? Icons.movie_outlined : Icons.bookmark_outline_rounded,
                size: 56,
                color: AppTheme.primaryCrimson,
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            Text(
              isWatchedTab ? 'No Watched Movies Yet' : 'Your Watchlist is Empty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              isWatchedTab
                ? 'Check off movies you have finished to track your cinema journey.'
                : 'Bookmark top rated and trending movies to build your cinema queue.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            ElevatedButton.icon(
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Discover Movies'),
              onPressed: () {
                if (widget.onExploreTap != null) {
                  widget.onExploreTap!();
                } else {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
