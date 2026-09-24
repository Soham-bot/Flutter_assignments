import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/utils/constants.dart';

/// Reusable Badge Icon for Watchlist on AppBars.
/// Shows dynamic count of items currently in the watchlist.
class WatchlistBadgeButton extends StatelessWidget {
  final VoidCallback onTap;

  const WatchlistBadgeButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MovieRepository(),
      builder: (context, _) {
        final count = MovieRepository().watchlistCount;
        return IconButton(
          tooltip: 'Watchlist ($count)',
          onPressed: onTap,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.bookmark_rounded,
                size: 26,
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppConstants.primaryCrimson,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
