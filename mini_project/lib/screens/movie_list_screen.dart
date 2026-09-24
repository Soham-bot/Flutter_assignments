import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/badge_icon.dart';
import 'package:movie_explorer/widgets/genre_pill.dart';
import 'package:movie_explorer/widgets/movie_compare_dialog.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';
import 'package:movie_explorer/widgets/poster_card.dart';

/// Screen 2: Movie Listing Screen
/// Features sticky search bar, animated list/grid view switch,
/// 2:3 aspect ratio posters with short synopsis, and sorting/filtering controls.
class MovieListScreen extends StatefulWidget {
  final String? initialGenre;
  final bool isEmbedded;

  const MovieListScreen({
    super.key,
    this.initialGenre,
    this.isEmbedded = false,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late String? _selectedGenre;
  String _selectedSort = 'Rating'; // 'Rating', 'Year', 'Title'
  bool _onlyUnwatched = false;
  bool _isGridView = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Movie? _firstMovieToCompare;

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.initialGenre;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(Movie movie) {
    Navigator.pushNamed(
      context,
      '/movie_detail',
      arguments: movie,
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _handleMovieLongPress(Movie movie) {
    if (_firstMovieToCompare == null) {
      _firstMovieToCompare = movie;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected "${movie.title}". Long press another movie to compare!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (_firstMovieToCompare!.id != movie.id) {
      final a = _firstMovieToCompare!;
      _firstMovieToCompare = null;
      MovieCompareDialog.show(context, a, movie);
    } else {
      _firstMovieToCompare = null;
    }
  }

  void _toggleWatchlist(BuildContext context, Movie movie) {
    final repo = MovieRepository();
    final wasIn = repo.isInWatchlist(movie.id);
    repo.toggleWatchlist(movie.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasIn
              ? 'Removed "${movie.title}" from Watchlist'
              : 'Added "${movie.title}" to Watchlist',
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
    final repo = MovieRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final movies = repo.getMovies(
          genre: _selectedGenre,
          searchQuery: _searchQuery,
          sortBy: _selectedSort,
          onlyUnwatched: _onlyUnwatched,
        );

        final titleText = _selectedGenre != null ? '$_selectedGenre Movies' : 'Browse Catalog';

        final content = Column(
          children: [
            // ── Sticky Search & Filter Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Search Bar with Clean Filled Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search 24+ movies by title, director...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Filter Row (Sort dropdown + unwatched switch + layout toggle)
                  Row(
                    children: [
                      // Sort Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedSort,
                              icon: const Icon(Icons.sort_rounded, size: 18),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Rating',
                                  child: Text('Sort: Rating (High)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Year',
                                  child: Text('Sort: Year (Newest)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Title',
                                  child: Text('Sort: Title (A-Z)'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSort = val);
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Unwatched Switch
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Unseen',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          Switch(
                            value: _onlyUnwatched,
                            activeThumbColor: AppTheme.primaryCrimson,
                            onChanged: (val) => setState(() => _onlyUnwatched = val),
                          ),
                        ],
                      ),

                      const SizedBox(width: 6),

                      // Animated Layout Toggle Switcher
                      IconButton.filledTonal(
                        tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
                        onPressed: () => setState(() => _isGridView = !_isGridView),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                            key: ValueKey<bool>(_isGridView),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Active Filter Tags (if any genre selected)
                  if (_selectedGenre != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GenrePill(
                          genre: _selectedGenre!,
                          isSelected: true,
                          onTap: () => setState(() => _selectedGenre = null),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${movies.length} movies found',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() => _selectedGenre = null),
                          child: const Text('Reset', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Movie Content Area (AnimatedSwitcher between List and Grid) ──
            Expanded(
              child: movies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No movies found matching criteria',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedGenre = null;
                                _onlyUnwatched = false;
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isGridView
                          ? GridView.builder(
                              key: const ValueKey('grid_view'),
                              padding: const EdgeInsets.all(AppTheme.spaceLG),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                return PosterCard(
                                  movie: movie,
                                  heroPrefix: 'list_grid',
                                  width: double.infinity,
                                  onTap: () => _navigateToDetail(movie),
                                  onLongPress: () => _handleMovieLongPress(movie),
                                );
                              },
                            )
                          : ListView.builder(
                              key: const ValueKey('list_view'),
                              padding: const EdgeInsets.all(AppTheme.spaceLG),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                return _buildListCardItem(context, movie, repo);
                              },
                            ),
                    ),
            ),
          ],
        );

        if (widget.isEmbedded) {
          return content;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(titleText),
            actions: [
              WatchlistBadgeButton(
                onTap: () => Navigator.pushNamed(context, '/watchlist'),
              ),
            ],
          ),
          body: content,
        );
      },
    );
  }

  Widget _buildListCardItem(BuildContext context, Movie movie, MovieRepository repo) {
    final isSaved = repo.isInWatchlist(movie.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(movie),
          onLongPress: () => _handleMovieLongPress(movie),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster on Left (2:3 Aspect Ratio)
                  SizedBox(
                    width: 85,
                    child: MoviePosterImage(
                      movie: movie,
                      heroTag: 'list_row_${movie.id}',
                      showTitle: false,
                      showRating: false,
                      borderRadius: AppTheme.radiusSM,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Movie Information in Center
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
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
                            const Icon(Icons.star_rounded, size: 16, color: AppTheme.secondaryGold),
                            const SizedBox(width: 3),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            GenrePill(
                              genre: movie.genre,
                              showIcon: false,
                              fontSize: 10,
                            ),
                            if (movie.isWatched) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Watched',
                                  style: TextStyle(color: AppTheme.successGreen, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 2-line Short Synopsis
                        Text(
                          movie.synopsis,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bookmark Button on Right
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isSaved ? AppTheme.primaryCrimson : AppTheme.textMuted,
                      size: 24,
                    ),
                    onPressed: () => _toggleWatchlist(context, movie),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
