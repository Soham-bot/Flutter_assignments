import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/utils/constants.dart';

/// Custom Navigation Drawer for Movie Explorer.
/// Features App Header, Light/Dark Theme Switcher, Navigation Links, and College Project Info.
class CustomDrawer extends StatelessWidget {
  final int currentTabIndex;
  final Function(int)? onSelectTab;

  const CustomDrawer({
    super.key,
    this.currentTabIndex = 0,
    this.onSelectTab,
  });

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.movie_filter_rounded, color: AppConstants.primaryCrimson, size: 28),
            SizedBox(width: 10),
            Text('Movie Explorer'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entertainment Domain Mini Project',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Designed for 20-Mark College Practical Evaluation.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Divider(height: 24),
              _buildAboutRow('Architecture', 'Material 3 (Pure Flutter)'),
              _buildAboutRow('State Pattern', 'setState & Singleton Repository'),
              _buildAboutRow('Dependencies', '0 External Packages'),
              _buildAboutRow('Screens', '5 Core + Watchlist Flow'),
              _buildAboutRow('Features', 'Filtering, Live Booking, Search, Themes'),
              const Divider(height: 24),
              const Text(
                'Includes validation, ticket generation, hero transitions, animated confirmations, and responsive layout across all device sizes.',
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();

    return Drawer(
      child: Column(
        children: [
          // Cinematic Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryCrimson,
                  Color(0xFF8B0000),
                  AppConstants.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_movies_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Theme Switcher Tile
          ListenableBuilder(
            listenable: repo,
            builder: (context, _) {
              final isDark = repo.isDarkMode;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? AppConstants.goldRating : AppConstants.primaryCrimson,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        isDark ? 'Dark Cinematic' : 'Light Mode',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: isDark,
                      activeThumbColor: AppConstants.primaryCrimson,
                      onChanged: (val) {
                        repo.toggleTheme();
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // Navigation Links
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            selected: currentTabIndex == 0,
            onTap: () {
              Navigator.pop(context);
              if (onSelectTab != null) {
                onSelectTab!(0);
              } else {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie_filter_rounded),
            title: const Text('Browse All Movies'),
            selected: currentTabIndex == 1,
            onTap: () {
              Navigator.pop(context);
              if (onSelectTab != null) {
                onSelectTab!(1);
              } else {
                Navigator.pushNamed(context, '/movies');
              }
            },
          ),
          ListenableBuilder(
            listenable: repo,
            builder: (context, _) {
              return ListTile(
                leading: const Icon(Icons.bookmark_rounded),
                title: const Text('My Watchlist'),
                trailing: repo.watchlistCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryCrimson,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${repo.watchlistCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                selected: currentTabIndex == 2,
                onTap: () {
                  Navigator.pop(context);
                  if (onSelectTab != null) {
                    onSelectTab!(2);
                  } else {
                    Navigator.pushNamed(context, '/watchlist');
                  }
                },
              );
            },
          ),

          const Spacer(),
          const Divider(),

          // Project Info & Evaluation Details
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About Evaluation Project'),
            subtitle: const Text('20-Mark College Project Specs'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'v1.0.0 • Pure Material 3 Flutter',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
