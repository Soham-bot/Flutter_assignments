import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/widgets/movie_poster_image.dart';

/// "What Should I Watch?" Interactive Mood & Time Recommendation Sheet.
class MoodPickerSheet extends StatefulWidget {
  final Function(Movie) onMovieSelected;

  const MoodPickerSheet({
    super.key,
    required this.onMovieSelected,
  });

  static void show(BuildContext context, Function(Movie) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MoodPickerSheet(onMovieSelected: onSelect),
    );
  }

  @override
  State<MoodPickerSheet> createState() => _MoodPickerSheetState();
}

class _MoodPickerSheetState extends State<MoodPickerSheet> {
  final List<Map<String, dynamic>> _moods = [
    {'name': 'Thrilled', 'icon': Icons.bolt_rounded, 'color': AppTheme.primaryCrimson},
    {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied_rounded, 'color': AppTheme.secondaryGold},
    {'name': 'Romantic', 'icon': Icons.favorite_rounded, 'color': Colors.pinkAccent},
    {'name': 'Curious', 'icon': Icons.psychology_rounded, 'color': Colors.cyanAccent},
    {'name': 'Relaxed', 'icon': Icons.spa_rounded, 'color': AppTheme.successGreen},
  ];

  String _selectedMood = 'Thrilled';
  double _timeAvailableHours = 2.5;
  Map<String, dynamic>? _recommendation;

  void _getRecommendation() {
    final result = MovieRepository().getMoodRecommendation(
      _selectedMood,
      _timeAvailableHours,
    );
    setState(() {
      _recommendation = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCrimson.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryCrimson, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What Should I Watch?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tell us your mood & time budget for an AI match',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Step 1: Pick Mood
            const Text(
              '1. How are you feeling today?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((m) {
                final isSelected = _selectedMood == m['name'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMood = m['name'];
                      _recommendation = null; // reset to prompt user
                    });
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (m['color'] as Color).withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      border: Border.all(
                        color: isSelected ? (m['color'] as Color) : AppTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(m['icon'], size: 16, color: m['color']),
                        const SizedBox(width: 6),
                        Text(
                          m['name'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Step 2: Time Available Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. Time Available:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${_timeAvailableHours.toStringAsFixed(1)} hours (${(_timeAvailableHours * 60).round()} mins)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryGold),
                ),
              ],
            ),
            Slider(
              value: _timeAvailableHours,
              min: 1.5,
              max: 3.5,
              divisions: 4,
              activeColor: AppTheme.primaryCrimson,
              onChanged: (val) {
                setState(() {
                  _timeAvailableHours = val;
                  _recommendation = null;
                });
              },
            ),

            const SizedBox(height: 12),

            // Generate Recommendation CTA
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Find My Perfect Movie'),
                onPressed: _getRecommendation,
              ),
            ),

            // Recommendation Result Area
            if (_recommendation != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryCrimson.withValues(alpha: 0.15),
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 65,
                          child: MoviePosterImage(
                            movie: _recommendation!['movie'] as Movie,
                            showTitle: false,
                            showRating: false,
                            borderRadius: AppTheme.radiusSM,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'TOP SUGGESTION',
                                  style: TextStyle(
                                    color: AppTheme.secondaryGold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (_recommendation!['movie'] as Movie).title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_recommendation!['movie'] as Movie).year} • ${(_recommendation!['movie'] as Movie).duration} • ★ ${(_recommendation!['movie'] as Movie).rating}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _recommendation!['reason'] as String,
                      style: const TextStyle(fontSize: 12, height: 1.4, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('View Movie Details'),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onMovieSelected(_recommendation!['movie'] as Movie);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
