import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/genre_pill.dart';
import 'package:movie_explorer/widgets/poster_card.dart';
import 'package:movie_explorer/widgets/section_header.dart';

/// Screen 3: Movie Details Screen
/// Features collapsing full-bleed 45% sliver poster header,
/// expandable synopsis, personal 5-star rating and review box,
/// "You May Also Like" carousel, and a sticky bottom booking bar.
class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _movie;
  bool _isSynopsisExpanded = false;

  // Personal Review & Rating State
  double _myRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isReviewSaved = false;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _myRating = _movie.userRating ?? 0;
    if (_movie.userReview != null) {
      _reviewController.text = _movie.userReview!;
      _isReviewSaved = true;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _toggleWatchlist() {
    final repo = MovieRepository();
    final wasSaved = repo.isInWatchlist(_movie.id);
    repo.toggleWatchlist(_movie.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved
              ? 'Removed "${_movie.title}" from Watchlist'
              : 'Added "${_movie.title}" to Watchlist',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppTheme.secondaryGold,
          onPressed: () {
            if (wasSaved) {
              repo.addToWatchlist(_movie.id);
            } else {
              repo.removeFromWatchlist(_movie.id);
            }
          },
        ),
      ),
    );
  }

  void _shareMovie() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Movie link for "${_movie.title}" copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
      ),
    );
  }

  void _openBookingForm() async {
    final result = await Navigator.pushNamed(
      context,
      '/booking',
      arguments: _movie,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 $result for "${_movie.title}"!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _savePersonalReview() {
    if (_myRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final repo = MovieRepository();
    repo.setMovieReview(_movie.id, _myRating, _reviewController.text.trim());
    setState(() {
      _isReviewSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your review & rating have been saved!'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.42;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final isSaved = repo.isInWatchlist(_movie.id);
        final similarMovies = repo.getSimilarMovies(_movie);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── 1. Full-Bleed 45% Collapsing Poster Header ──
              SliverAppBar(
                expandedHeight: headerHeight,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Share',
                      icon: const Icon(Icons.share_rounded, color: Colors.white),
                      onPressed: _shareMovie,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: isSaved ? 'Remove from Watchlist' : 'Add to Watchlist',
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? AppTheme.primaryCrimson : Colors.white,
                      ),
                      onPressed: _toggleWatchlist,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Poster
                      Hero(
                        tag: 'detail_poster_${_movie.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _movie.posterColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _movie.posterIcon,
                              size: 110,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ),

                      // Fade overlay from center to bottom background
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                              stops: const [0.3, 0.6, 0.88, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Movie Details Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Tagline
                      Text(
                        _movie.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (_movie.tagline.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '"${_movie.tagline}"',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.secondaryGold,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Metadata Badges Row (Rating, Year, Duration, Age Rating)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                              border: Border.all(color: AppTheme.secondaryGold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: AppTheme.secondaryGold),
                                const SizedBox(width: 4),
                                Text(
                                  '${_movie.rating} / 5.0',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildBadge('${_movie.year}'),
                          _buildBadge(_movie.duration),
                          _buildBadge(_movie.ageRating, isHighlight: true),
                          GenrePill(genre: _movie.genre, showIcon: false),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Director Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.movie_creation_rounded, size: 18, color: AppTheme.primaryCrimson),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Directed by',
                                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                              Text(
                                _movie.director,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Expandable Synopsis Section
                      const Text(
                        'Synopsis',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _movie.synopsis,
                        maxLines: _isSynopsisExpanded ? null : 3,
                        overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _isSynopsisExpanded = !_isSynopsisExpanded),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _isSynopsisExpanded ? 'Show less' : 'Read more',
                            style: const TextStyle(
                              color: AppTheme.primaryCrimson,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Top Cast (Circular Avatar Containers with Initials)
                      const Text(
                        'Top Cast',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _movie.cast.length,
                          itemBuilder: (context, index) {
                            final actor = _movie.cast[index];
                            final initials = actor.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join();

                            return Container(
                              margin: const EdgeInsets.only(right: 16),
                              width: 70,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppTheme.primaryCrimson.withValues(alpha: 0.2),
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: AppTheme.primaryCrimson,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    actor,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── 3. Innovative Feature: Personal 5-Star Rating & Review ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Rating & Quick Review',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if (_isReviewSaved)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('SAVED', style: TextStyle(color: AppTheme.successGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // 5 Interactive Tappable Stars
                            Row(
                              children: List.generate(5, (index) {
                                final starVal = index + 1.0;
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    _myRating >= starVal ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: AppTheme.secondaryGold,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _myRating = starVal;
                                      _isReviewSaved = false;
                                    });
                                  },
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _reviewController,
                              maxLines: 2,
                              onChanged: (_) => setState(() => _isReviewSaved = false),
                              decoration: const InputDecoration(
                                hintText: 'Write a few words about this movie...',
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text('Save Review'),
                                onPressed: _savePersonalReview,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── 4. "You May Also Like" Carousel ──
                      if (similarMovies.isNotEmpty) ...[
                        SectionHeader(
                          title: 'You May Also Like',
                          subtitle: 'More top ${_movie.genre} picks',
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 195,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: similarMovies.length,
                            itemBuilder: (context, index) {
                              final sim = similarMovies[index];
                              return PosterCard(
                                movie: sim,
                                heroPrefix: 'detail_similar',
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/movie_detail',
                                    arguments: sim,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 5. Sticky Bottom Bar with Price & Book Tickets CTA ──
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(top: BorderSide(color: AppTheme.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TICKETS FROM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Text(
                        '₹${_movie.ticketPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryCrimson,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.confirmation_number_rounded),
                        label: const Text('Book Tickets Now'),
                        onPressed: _openBookingForm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppTheme.primaryCrimson.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: isHighlight
              ? AppTheme.primaryCrimson.withValues(alpha: 0.4)
              : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isHighlight ? AppTheme.primaryCrimson : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
