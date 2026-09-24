import 'package:flutter/material.dart';

/// Movie Model representing a cinema release in Movie Explorer.
class Movie {
  final String id;
  final String title;
  final String genre;
  final int year;
  final double rating;
  final String duration;
  final String director;
  final List<String> cast;
  final String synopsis;
  final List<Color> posterColors;
  final IconData posterIcon;
  final double ticketPrice;
  final String ageRating;
  final String tagline;
  bool isWatched;
  final bool isFeatured;
  double? userRating;
  String? userReview;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.duration,
    required this.director,
    required this.cast,
    required this.synopsis,
    required this.posterColors,
    required this.posterIcon,
    required this.ticketPrice,
    this.ageRating = 'U/A 13+',
    this.tagline = '',
    this.isWatched = false,
    this.isFeatured = false,
    this.userRating,
    this.userReview,
  });

  /// Parse duration (e.g. "2h 32m") to total integer minutes for watchlist metrics
  int get durationMinutes {
    int hours = 0;
    int minutes = 0;
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(duration);
    if (hMatch != null) hours = int.tryParse(hMatch.group(1) ?? '0') ?? 0;
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(duration);
    if (mMatch != null) minutes = int.tryParse(mMatch.group(1) ?? '0') ?? 0;
    final total = (hours * 60) + minutes;
    return total > 0 ? total : 120;
  }

  /// Create a copy with modified attributes
  Movie copyWith({
    String? id,
    String? title,
    String? genre,
    int? year,
    double? rating,
    String? duration,
    String? director,
    List<String>? cast,
    String? synopsis,
    List<Color>? posterColors,
    IconData? posterIcon,
    double? ticketPrice,
    String? ageRating,
    String? tagline,
    bool? isWatched,
    bool? isFeatured,
    double? userRating,
    String? userReview,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      synopsis: synopsis ?? this.synopsis,
      posterColors: posterColors ?? this.posterColors,
      posterIcon: posterIcon ?? this.posterIcon,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      ageRating: ageRating ?? this.ageRating,
      tagline: tagline ?? this.tagline,
      isWatched: isWatched ?? this.isWatched,
      isFeatured: isFeatured ?? this.isFeatured,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
    );
  }
}
