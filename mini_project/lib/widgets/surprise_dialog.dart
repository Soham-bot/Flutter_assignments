import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';

/// Slot-machine style random movie picker dialog.
class SurpriseMovieDialog extends StatefulWidget {
  final Function(Movie) onMovieChosen;

  const SurpriseMovieDialog({
    super.key,
    required this.onMovieChosen,
  });

  static void show(BuildContext context, Function(Movie) onChosen) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SurpriseMovieDialog(onMovieChosen: onChosen),
    );
  }

  @override
  State<SurpriseMovieDialog> createState() => _SurpriseMovieDialogState();
}

class _SurpriseMovieDialogState extends State<SurpriseMovieDialog> {
  late Movie _currentMovie;
  bool _isShuffling = true;
  Timer? _timer;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    final repo = MovieRepository();
    _currentMovie = repo.allMovies.first;

    // Simulate slot-machine shuffle
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      _ticks++;
      if (mounted) {
        setState(() {
          _currentMovie = repo.getRandomMovie(_currentMovie.id);
        });
      }
      if (_ticks > 10) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isShuffling = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
      title: Row(
        children: [
          Icon(
            Icons.casino_rounded,
            color: _isShuffling ? AppTheme.secondaryGold : AppTheme.primaryCrimson,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(
            _isShuffling ? 'Shuffling Movies...' : 'Tonight\'s Surprise Pick!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: SizedBox(
              key: ValueKey<String>(_currentMovie.id),
              height: 220,
              child: MoviePosterImage(
                movie: _currentMovie,
                showTitle: true,
                showRating: true,
                borderRadius: AppTheme.radiusMD,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_isShuffling) ...[
            Text(
              _currentMovie.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${_currentMovie.genre} • ${_currentMovie.duration} • ★ ${_currentMovie.rating}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            if (_currentMovie.tagline.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '"${_currentMovie.tagline}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.secondaryGold),
              ),
            ],
          ] else ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCrimson),
                ),
                SizedBox(width: 10),
                Text('Rolling the reels...', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!_isShuffling)
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Explore This Movie'),
            onPressed: () {
              Navigator.pop(context);
              widget.onMovieChosen(_currentMovie);
            },
          ),
      ],
    );
  }
}
