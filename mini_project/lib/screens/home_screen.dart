import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/screens/movie_list_screen.dart';
import 'package:movie_explorer/screens/watchlist_screen.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/utils/constants.dart';
import 'package:movie_explorer/widgets/badge_icon.dart';
import 'package:movie_explorer/widgets/custom_drawer.dart';
import 'package:movie_explorer/widgets/genre_pill.dart';
import 'package:movie_explorer/widgets/mood_picker_sheet.dart';
import 'package:movie_explorer/widgets/movie_compare_dialog.dart';
import 'package:movie_explorer/widgets/poster_card.dart';
import 'package:movie_explorer/widgets/section_header.dart';
import 'package:movie_explorer/widgets/surprise_dialog.dart';

/// Screen 1: Home Screen
/// Features dynamic day-part greeting, auto-scrolling hero banner,
/// horizontal genre selector pills, 3 movie carousels (Trending, Top Rated, New Releases),
/// and quick-action toolbars for Mood Picker and Surprise Me shuffle.
class HomeScreen extends StatefulWidget {
  final bool enableHeroAutoAdvance;

  const HomeScreen({
    super.key,
    this.enableHeroAutoAdvance = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  String _selectedGenreFilter = 'All';

  // Hero Carousel PageView State
  late final PageController _heroPageController;
  int _activeHeroIndex = 0;
  Timer? _heroTimer;

  // Movie comparison selection
  Movie? _firstMovieToCompare;

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController(viewportFraction: 0.92);

    // Auto-advance featured banner every 4.5 seconds
    if (widget.enableHeroAutoAdvance) {
      _heroTimer = Timer.periodic(const Duration(milliseconds: 4500), (timer) {
        if (!mounted) return;
        final featuredCount = MovieRepository().featuredMovies.length;
        if (featuredCount > 1 && _heroPageController.hasClients) {
          final nextPage = (_activeHeroIndex + 1) % featuredCount;
          _heroPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, Movie Buff ☕';
    if (hour < 17) return 'Good afternoon, Cinephile 🎬';
    return 'Good evening, Movie Buff 🍿';
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _navigateToDetail(Movie movie, String heroPrefix) {
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
          content: Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, color: AppTheme.secondaryGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Selected "${movie.title}". Long press another movie to compare!'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (_firstMovieToCompare!.id != movie.id) {
      final a = _firstMovieToCompare!;
      _firstMovieToCompare = null;
      MovieCompareDialog.show(context, a, movie);
    } else {
      _firstMovieToCompare = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selection cleared.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        return Scaffold(
          drawer: CustomDrawer(
            currentTabIndex: _currentTabIndex,
            onSelectTab: _onTabSelected,
          ),
          appBar: _currentTabIndex == 0
              ? AppBar(
                  leading: Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.crimsonGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        ),
                        child: const Icon(Icons.movie_filter_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          AppConstants.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Surprise Me!',
                      icon: const Icon(Icons.casino_rounded, color: AppTheme.secondaryGold),
                      onPressed: () {
                        SurpriseMovieDialog.show(context, (chosen) {
                          _navigateToDetail(chosen, 'surprise');
                        });
                      },
                    ),
                    IconButton(
                      tooltip: 'What Should I Watch?',
                      icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryCrimson),
                      onPressed: () {
                        MoodPickerSheet.show(context, (chosen) {
                          _navigateToDetail(chosen, 'mood');
                        });
                      },
                    ),
                    WatchlistBadgeButton(
                      onTap: () => _onTabSelected(2),
                    ),
                  ],
                )
              : null,
          body: IndexedStack(
            index: _currentTabIndex,
            children: [
              // Tab 0: Home Hub
              _buildHomeBody(context, repo),

              // Tab 1: Browse All Movies
              const MovieListScreen(isEmbedded: true),

              // Tab 2: Watchlist
              WatchlistScreen(
                isEmbedded: true,
                onExploreTap: () => _onTabSelected(1),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: _onTabSelected,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.movie_creation_outlined),
                activeIcon: Icon(Icons.movie_creation_rounded),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.bookmark_border_rounded),
                    if (repo.watchlistCount > 0)
                      Positioned(
                        right: -6,
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryCrimson,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Center(
                            child: Text(
                              '${repo.watchlistCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.bookmark_rounded),
                label: 'Watchlist',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeBody(BuildContext context, MovieRepository repo) {
    final featured = repo.featuredMovies;
    final trending = repo.trendingMovies;
    final topRated = repo.topRatedMovies;
    final newReleases = repo.newReleases;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spaceLG, 8, AppTheme.spaceLG, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTimeGreeting(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Explore 24+ blockbusters across 8 cinema genres',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 1. Hero PageView Banner ──
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _heroPageController,
              itemCount: featured.length,
              onPageChanged: (i) => setState(() => _activeHeroIndex = i),
              itemBuilder: (context, index) {
                final movie = featured[index];
                return _buildHeroBannerCard(context, movie);
              },
            ),
          ),

          const SizedBox(height: 10),

          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              featured.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _activeHeroIndex == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _activeHeroIndex == index
                      ? AppTheme.primaryCrimson
                      : AppTheme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spaceLG),

          // ── 2. Horizontal Genre Scroller ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
            child: const Text(
              'Genres',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
              children: [
                GenrePill(
                  genre: 'All',
                  isSelected: _selectedGenreFilter == 'All',
                  showIcon: false,
                  onTap: () => setState(() => _selectedGenreFilter = 'All'),
                ),
                ...AppConstants.genres.map((g) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GenrePill(
                      genre: g,
                      isSelected: _selectedGenreFilter == g,
                      onTap: () {
                        Navigator.pushNamed(context, '/movies', arguments: g);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceXL),

          // ── 3. Trending Now Section ──
          SectionHeader(
            leadingIcon: Icons.local_fire_department_rounded,
            title: 'Trending Now',
            subtitle: 'Most watched movies this week',
            onActionTap: () => _onTabSelected(1),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
              itemCount: trending.length,
              itemBuilder: (context, index) {
                final movie = trending[index];
                return PosterCard(
                  movie: movie,
                  heroPrefix: 'home_trending',
                  onTap: () => _navigateToDetail(movie, 'home_trending'),
                  onLongPress: () => _handleMovieLongPress(movie),
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.spaceXL),

          // ── 4. Top Rated Section ──
          SectionHeader(
            leadingIcon: Icons.star_rounded,
            title: 'Top Rated',
            subtitle: 'Highest rated masterpieces (4.8+)',
            onActionTap: () => _onTabSelected(1),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
              itemCount: topRated.length,
              itemBuilder: (context, index) {
                final movie = topRated[index];
                return PosterCard(
                  movie: movie,
                  heroPrefix: 'home_top',
                  onTap: () => _navigateToDetail(movie, 'home_top'),
                  onLongPress: () => _handleMovieLongPress(movie),
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.spaceXL),

          // ── 5. New Releases Section ──
          SectionHeader(
            leadingIcon: Icons.new_releases_rounded,
            title: 'New Releases',
            subtitle: 'Fresh arrivals in theatres',
            onActionTap: () => _onTabSelected(1),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
              itemCount: newReleases.length,
              itemBuilder: (context, index) {
                final movie = newReleases[index];
                return PosterCard(
                  movie: movie,
                  heroPrefix: 'home_new',
                  onTap: () => _navigateToDetail(movie, 'home_new'),
                  onLongPress: () => _handleMovieLongPress(movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBannerCard(BuildContext context, Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        gradient: LinearGradient(
          colors: movie.posterColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Stack(
          children: [
            // Watermark icon
            Positioned(
              right: -15,
              top: -10,
              child: Icon(
                movie.posterIcon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),

            // Gradient Scrim
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Content Overlay
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCrimson,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${movie.year} • ${movie.duration} • ★ ${movie.rating}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (movie.tagline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '"${movie.tagline}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.secondaryGold,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('Watch Details', style: TextStyle(fontSize: 13)),
                      onPressed: () => _navigateToDetail(movie, 'home_hero'),
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
}
