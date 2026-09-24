import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_explorer/models/movie.dart';

/// In-memory Repository and Singleton for Movie Explorer.
/// Manages movie catalog, watchlist states, ratings/reviews, and discovery algorithms.
/// Extends ChangeNotifier to allow instant UI reactivity across all screens.
class MovieRepository extends ChangeNotifier {
  // Singleton instance
  static final MovieRepository _instance = MovieRepository._internal();
  factory MovieRepository() => _instance;
  MovieRepository._internal() {
    _initData();
  }

  // All movie records
  late final List<Movie> _movies;

  // Set of Movie IDs added to Watchlist
  final Set<String> _watchlistIds = {'dune-2', 'across-spiderverse', 'dark-knight', 'interstellar'};

  // Theme mode notifier
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  void toggleTheme() {
    if (themeModeNotifier.value == ThemeMode.dark) {
      themeModeNotifier.value = ThemeMode.light;
    } else {
      themeModeNotifier.value = ThemeMode.dark;
    }
    notifyListeners();
  }

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  // ── Getters ──
  List<Movie> get allMovies => List.unmodifiable(_movies);

  List<Movie> get featuredMovies =>
      _movies.where((movie) => movie.isFeatured).toList();

  List<Movie> get trendingMovies =>
      _movies.where((m) => m.rating >= 4.7).take(8).toList();

  List<Movie> get topRatedMovies =>
      (List<Movie>.from(_movies)..sort((a, b) => b.rating.compareTo(a.rating))).take(8).toList();

  List<Movie> get newReleases =>
      (List<Movie>.from(_movies)..sort((a, b) => b.year.compareTo(a.year))).take(8).toList();

  List<Movie> get watchlistMovies =>
      _movies.where((movie) => _watchlistIds.contains(movie.id)).toList();

  List<Movie> get watchedMovies =>
      _movies.where((m) => _watchlistIds.contains(m.id) && m.isWatched).toList();

  List<Movie> get toWatchMovies =>
      _movies.where((m) => _watchlistIds.contains(m.id) && !m.isWatched).toList();

  int get watchlistCount => _watchlistIds.length;

  int get watchedCount => watchedMovies.length;

  int get unwatchedCount => toWatchMovies.length;

  /// Total duration in hours for all movies in watchlist
  int get totalWatchlistHours {
    final totalMinutes = watchlistMovies.fold<int>(0, (sum, m) => sum + m.durationMinutes);
    return (totalMinutes / 60).ceil();
  }

  /// Compute user's favorite genre based on frequency in watchlist
  String get favoriteGenre {
    if (watchlistMovies.isEmpty) return 'Cinema Buff';
    final counts = <String, int>{};
    for (final m in watchlistMovies) {
      counts[m.genre] = (counts[m.genre] ?? 0) + 1;
    }
    String topGenre = watchlistMovies.first.genre;
    int maxCount = 0;
    counts.forEach((genre, count) {
      if (count > maxCount) {
        maxCount = count;
        topGenre = genre;
      }
    });
    return topGenre;
  }

  /// Find a movie by its unique identifier
  Movie? getMovieById(String movieId) {
    try {
      return _movies.firstWhere((m) => m.id == movieId);
    } catch (_) {
      return null;
    }
  }

  bool isInWatchlist(String movieId) => _watchlistIds.contains(movieId);

  /// Toggle movie in/out of watchlist
  bool toggleWatchlist(String movieId) {
    bool isAdded;
    if (_watchlistIds.contains(movieId)) {
      _watchlistIds.remove(movieId);
      isAdded = false;
    } else {
      _watchlistIds.add(movieId);
      isAdded = true;
    }
    notifyListeners();
    return isAdded;
  }

  /// Explicitly add to watchlist (e.g. for Undo action)
  void addToWatchlist(String movieId) {
    if (!_watchlistIds.contains(movieId)) {
      _watchlistIds.add(movieId);
      notifyListeners();
    }
  }

  /// Explicitly remove from watchlist
  void removeFromWatchlist(String movieId) {
    if (_watchlistIds.contains(movieId)) {
      _watchlistIds.remove(movieId);
      notifyListeners();
    }
  }

  /// Toggle Watched status for a movie
  void toggleWatched(String movieId) {
    final index = _movies.indexWhere((m) => m.id == movieId);
    if (index != -1) {
      _movies[index].isWatched = !_movies[index].isWatched;
      notifyListeners();
    }
  }

  /// Set user rating and review in memory
  void setMovieReview(String movieId, double rating, String review) {
    final index = _movies.indexWhere((m) => m.id == movieId);
    if (index != -1) {
      _movies[index].userRating = rating;
      _movies[index].userReview = review;
      notifyListeners();
    }
  }

  /// Get movies in the same genre for "You May Also Like"
  List<Movie> getSimilarMovies(Movie movie) {
    return _movies
        .where((m) => m.genre.toLowerCase() == movie.genre.toLowerCase() && m.id != movie.id)
        .toList();
  }

  /// Mood recommendation engine
  Map<String, dynamic> getMoodRecommendation(String mood, double maxHours) {
    List<String> targetGenres;
    switch (mood.toLowerCase()) {
      case 'happy':
        targetGenres = ['Comedy', 'Animation'];
        break;
      case 'thrilled':
        targetGenres = ['Action', 'Thriller', 'Horror'];
        break;
      case 'romantic':
        targetGenres = ['Romance', 'Drama'];
        break;
      case 'curious':
        targetGenres = ['Sci-Fi', 'Thriller'];
        break;
      case 'relaxed':
      default:
        targetGenres = ['Animation', 'Comedy', 'Drama'];
        break;
    }

    final maxMinutes = (maxHours * 60).round();
    final candidates = _movies.where((m) => targetGenres.contains(m.genre)).toList();

    // Prefer movies within the time budget
    final withinBudget = candidates.where((m) => m.durationMinutes <= maxMinutes).toList();
    final chosen = withinBudget.isNotEmpty
        ? withinBudget[Random().nextInt(withinBudget.length)]
        : candidates[Random().nextInt(candidates.length)];

    final reason = "Because you're in the mood to feel $mood and have ${maxHours.toStringAsFixed(1)} hours, '${chosen.title}' is your premier match.";

    return {
      'movie': chosen,
      'reason': reason,
    };
  }

  /// Surprise Me: returns a random movie
  Movie getRandomMovie([String? excludeId]) {
    final pool = _movies.where((m) => m.id != excludeId).toList();
    return pool[Random().nextInt(pool.length)];
  }

  /// Filter, search, and sort movies
  List<Movie> getMovies({
    String? genre,
    String? searchQuery,
    String sortBy = 'Rating',
    bool onlyUnwatched = false,
  }) {
    List<Movie> filtered = List.from(_movies);

    if (genre != null && genre.isNotEmpty && genre.toLowerCase() != 'all') {
      filtered = filtered
          .where((m) => m.genre.toLowerCase() == genre.toLowerCase())
          .toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filtered = filtered
          .where((m) =>
              m.title.toLowerCase().contains(query) ||
              m.director.toLowerCase().contains(query) ||
              m.genre.toLowerCase().contains(query))
          .toList();
    }

    if (onlyUnwatched) {
      filtered = filtered.where((m) => !m.isWatched).toList();
    }

    switch (sortBy) {
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Year':
        filtered.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'Title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  void _initData() {
    _movies = [
      // ════════════ ACTION ════════════
      Movie(
        id: 'dark-knight',
        title: 'The Dark Knight',
        tagline: 'Why So Serious?',
        ageRating: 'U/A 16+',
        genre: 'Action',
        year: 2008,
        rating: 4.9,
        duration: '2h 32m',
        director: 'Christopher Nolan',
        cast: ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart', 'Michael Caine', 'Gary Oldman'],
        synopsis: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        posterColors: [const Color(0xFF1E293B), const Color(0xFF0F172A), const Color(0xFF334155)],
        posterIcon: Icons.masks_rounded,
        ticketPrice: 250.0,
        isWatched: true,
        isFeatured: true,
      ),
      Movie(
        id: 'mad-max-fury',
        title: 'Mad Max: Fury Road',
        tagline: 'What a Lovely Day.',
        ageRating: 'A',
        genre: 'Action',
        year: 2015,
        rating: 4.7,
        duration: '2h 0m',
        director: 'George Miller',
        cast: ['Tom Hardy', 'Charlize Theron', 'Nicholas Hoult', 'Hugh Keays-Byrne'],
        synopsis: 'In a post-apocalyptic wasteland, a woman rebels against a tyrannical ruler in search for her homeland with the aid of a group of female prisoners, a psychotic worshiper, and a drifter named Max.',
        posterColors: [const Color(0xFFC2410C), const Color(0xFF7C2D12), const Color(0xFFEA580C)],
        posterIcon: Icons.local_fire_department_rounded,
        ticketPrice: 220.0,
        isWatched: false,
        isFeatured: false,
      ),
      Movie(
        id: 'john-wick-4',
        title: 'John Wick: Chapter 4',
        tagline: 'No Way Back. One Way Out.',
        ageRating: 'A',
        genre: 'Action',
        year: 2023,
        rating: 4.8,
        duration: '2h 49m',
        director: 'Chad Stahelski',
        cast: ['Keanu Reeves', 'Donnie Yen', 'Bill Skarsgård', 'Laurence Fishburne'],
        synopsis: 'John Wick uncovers a path to defeating The High Table. But before he can earn his freedom, Wick must face off against a new enemy with powerful alliances across the globe.',
        posterColors: [const Color(0xFF7F1D1D), const Color(0xFF450A0A), const Color(0xFF991B1B)],
        posterIcon: Icons.shield_rounded,
        ticketPrice: 260.0,
        isWatched: false,
        isFeatured: true,
      ),

      // ════════════ COMEDY ════════════
      Movie(
        id: 'grand-budapest',
        title: 'The Grand Budapest Hotel',
        tagline: 'A Filmed Romance & Mystery.',
        ageRating: 'U/A 13+',
        genre: 'Comedy',
        year: 2014,
        rating: 4.6,
        duration: '1h 39m',
        director: 'Wes Anderson',
        cast: ['Ralph Fiennes', 'Tony Revolori', 'Saoirse Ronan', 'Willem Dafoe', 'Adrien Brody'],
        synopsis: 'A writer encounters the owner of an aging high-class hotel, who tells him of his early years serving as a lobby boy in the hotel\'s glorious years under an exceptional concierge.',
        posterColors: [const Color(0xFFDB2777), const Color(0xFF9D174D), const Color(0xFFF472B6)],
        posterIcon: Icons.hotel_rounded,
        ticketPrice: 200.0,
        isWatched: false,
        isFeatured: false,
      ),
      Movie(
        id: 'knives-out',
        title: 'Knives Out',
        tagline: 'Nothing Concupiscent About It.',
        ageRating: 'U/A 13+',
        genre: 'Comedy',
        year: 2019,
        rating: 4.7,
        duration: '2h 10m',
        director: 'Rian Johnson',
        cast: ['Daniel Craig', 'Ana de Armas', 'Chris Evans', 'Jamie Lee Curtis', 'Michael Shannon'],
        synopsis: 'A detective investigates the death of a patriarch of an eccentric, combative family. A masterclass in witty humor, gripping twists, and vibrant aesthetics.',
        posterColors: [const Color(0xFFD97706), const Color(0xFFB45309), const Color(0xFFF59E0B)],
        posterIcon: Icons.search_rounded,
        ticketPrice: 220.0,
        isWatched: true,
        isFeatured: true,
      ),
      Movie(
        id: 'superbad',
        title: 'Superbad',
        tagline: 'Ready to Break the Rules.',
        ageRating: 'A',
        genre: 'Comedy',
        year: 2007,
        rating: 4.3,
        duration: '1h 53m',
        director: 'Greg Mottola',
        cast: ['Jonah Hill', 'Michael Cera', 'Christopher Mintz-Plasse', 'Bill Hader', 'Seth Rogen'],
        synopsis: 'Two co-dependent high school seniors are forced to deal with separation anxiety after their plan to stage a booze-soaked party goes awry.',
        posterColors: [const Color(0xFFFBBF24), const Color(0xFFD97706), const Color(0xFF92400E)],
        posterIcon: Icons.celebration_rounded,
        ticketPrice: 180.0,
        isWatched: false,
        isFeatured: false,
      ),

      // ════════════ DRAMA ════════════
      Movie(
        id: 'oppenheimer',
        title: 'Oppenheimer',
        tagline: 'The World Forever Changes.',
        ageRating: 'A',
        genre: 'Drama',
        year: 2023,
        rating: 4.9,
        duration: '3h 0m',
        director: 'Christopher Nolan',
        cast: ['Cillian Murphy', 'Emily Blunt', 'Matt Damon', 'Robert Downey Jr.', 'Florence Pugh'],
        synopsis: 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb, charting the moral and geopolitical aftermath.',
        posterColors: [const Color(0xFFEA580C), const Color(0xFF9A3412), const Color(0xFF431407)],
        posterIcon: Icons.flare_rounded,
        ticketPrice: 280.0,
        isWatched: false,
        isFeatured: true,
      ),
      Movie(
        id: 'shawshank',
        title: 'The Shawshank Redemption',
        tagline: 'Fear Can Hold You Prisoner. Hope Can Set You Free.',
        ageRating: 'U/A 16+',
        genre: 'Drama',
        year: 1994,
        rating: 5.0,
        duration: '2h 22m',
        director: 'Frank Darabont',
        cast: ['Tim Robbins', 'Morgan Freeman', 'Bob Gunton', 'William Sadler', 'Clancy Brown'],
        synopsis: 'Over the course of several years, two convicts form a friendship, seeking consolation and, eventually, redemption through basic compassion.',
        posterColors: [const Color(0xFF374151), const Color(0xFF1F2937), const Color(0xFF111827)],
        posterIcon: Icons.wb_sunny_rounded,
        ticketPrice: 200.0,
        isWatched: true,
        isFeatured: false,
      ),
      Movie(
        id: 'whiplash',
        title: 'Whiplash',
        tagline: 'The Line Between Greatness and Madness.',
        ageRating: 'A',
        genre: 'Drama',
        year: 2014,
        rating: 4.8,
        duration: '1h 47m',
        director: 'Damien Chazelle',
        cast: ['Miles Teller', 'J.K. Simmons', 'Paul Reiser', 'Melissa Benoist'],
        synopsis: 'A promising young drummer enrolls at a cut-throat music conservatory where his dreams of greatness are mentored by an instructor who will stop at nothing to realize a student\'s potential.',
        posterColors: [const Color(0xFF78350F), const Color(0xFF451A03), const Color(0xFFB45309)],
        posterIcon: Icons.music_note_rounded,
        ticketPrice: 210.0,
        isWatched: false,
        isFeatured: false,
      ),

      // ════════════ SCI-FI ════════════
      Movie(
        id: 'interstellar',
        title: 'Interstellar',
        tagline: 'Mankind was Born on Earth. It was Never Meant to Die Here.',
        ageRating: 'U/A 13+',
        genre: 'Sci-Fi',
        year: 2014,
        rating: 4.9,
        duration: '2h 49m',
        director: 'Christopher Nolan',
        cast: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain', 'Michael Caine'],
        synopsis: 'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.',
        posterColors: [const Color(0xFF0284C7), const Color(0xFF0C4A6E), const Color(0xFF0369A1)],
        posterIcon: Icons.public_rounded,
        ticketPrice: 260.0,
        isWatched: true,
        isFeatured: true,
      ),
      Movie(
        id: 'dune-2',
        title: 'Dune: Part Two',
        tagline: 'Long Live the Fighters.',
        ageRating: 'U/A 13+',
        genre: 'Sci-Fi',
        year: 2024,
        rating: 4.9,
        duration: '2h 46m',
        director: 'Denis Villeneuve',
        cast: ['Timothée Chalamet', 'Zendaya', 'Rebecca Ferguson', 'Javier Bardem', 'Austin Butler'],
        synopsis: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family, facing a choice between love and the fate of the universe.',
        posterColors: [const Color(0xFFD97706), const Color(0xFF92400E), const Color(0xFF451A03)],
        posterIcon: Icons.wb_twilight_rounded,
        ticketPrice: 290.0,
        isWatched: false,
        isFeatured: true,
      ),
      Movie(
        id: 'blade-runner-2049',
        title: 'Blade Runner 2049',
        tagline: 'The Key to the Future is Finally Unearthed.',
        ageRating: 'A',
        genre: 'Sci-Fi',
        year: 2017,
        rating: 4.7,
        duration: '2h 44m',
        director: 'Denis Villeneuve',
        cast: ['Ryan Gosling', 'Harrison Ford', 'Ana de Armas', 'Sylvia Hoeks', 'Robin Wright'],
        synopsis: 'Young Blade Runner K\'s discovery of a long-buried secret leads him to track down former Blade Runner Rick Deckard, who\'s been missing for thirty years.',
        posterColors: [const Color(0xFF06B6D4), const Color(0xFF0891B2), const Color(0xFF164E63)],
        posterIcon: Icons.blur_on_rounded,
        ticketPrice: 240.0,
        isWatched: false,
        isFeatured: false,
      ),

      // ════════════ HORROR ════════════
      Movie(
        id: 'quiet-place-day-1',
        title: 'A Quiet Place: Day One',
        tagline: 'Hear How it All Began.',
        ageRating: 'U/A 16+',
        genre: 'Horror',
        year: 2024,
        rating: 4.4,
        duration: '1h 39m',
        director: 'Michael Sarnoski',
        cast: ['Lupita Nyong\'o', 'Joseph Quinn', 'Alex Wolff', 'Djimon Hounsou'],
        synopsis: 'Experience the day the world went quiet in this terrifying expansion of the survival horror franchise set in the bustling streets of New York City.',
        posterColors: [const Color(0xFF450A0A), const Color(0xFF1C1917), const Color(0xFF7F1D1D)],
        posterIcon: Icons.volume_off_rounded,
        ticketPrice: 230.0,
        isWatched: false,
        isFeatured: false,
      ),
      Movie(
        id: 'the-conjuring',
        title: 'The Conjuring',
        tagline: 'Based on the True Case Files of the Warrens.',
        ageRating: 'A',
        genre: 'Horror',
        year: 2013,
        rating: 4.5,
        duration: '1h 52m',
        director: 'James Wan',
        cast: ['Patrick Wilson', 'Vera Farmiga', 'Ron Livingston', 'Lili Taylor'],
        synopsis: 'Paranormal investigators Ed and Lorraine Warren work to help a family terrorized by a dark presence in their farmhouse.',
        posterColors: [const Color(0xFF2E1065), const Color(0xFF1E1B4B), const Color(0xFF3B0764)],
        posterIcon: Icons.door_back_door_rounded,
        ticketPrice: 200.0,
        isWatched: true,
        isFeatured: false,
      ),
      Movie(
        id: 'hereditary',
        title: 'Hereditary',
        tagline: 'Every Family Tree Hides a Secret.',
        ageRating: 'A',
        genre: 'Horror',
        year: 2018,
        rating: 4.6,
        duration: '2h 7m',
        director: 'Ari Aster',
        cast: ['Toni Collette', 'Alex Wolff', 'Milly Shapiro', 'Gabriel Byrne'],
        synopsis: 'A grieving family is haunted by tragic and disturbing occurrences after the death of their secretive grandmother.',
        posterColors: [const Color(0xFF18181B), const Color(0xFF3F3F46), const Color(0xFF09090B)],
        posterIcon: Icons.psychology_alt_rounded,
        ticketPrice: 220.0,
        isWatched: false,
        isFeatured: false,
      ),

      // ════════════ ROMANCE ════════════
      Movie(
        id: 'la-la-land',
        title: 'La La Land',
        tagline: 'Here\'s to the Fools Who Dream.',
        ageRating: 'U/A 13+',
        genre: 'Romance',
        year: 2016,
        rating: 4.8,
        duration: '2h 8m',
        director: 'Damien Chazelle',
        cast: ['Ryan Gosling', 'Emma Stone', 'John Legend', 'Rosemarie DeWitt', 'J.K. Simmons'],
        synopsis: 'While navigating their careers in Los Angeles, a pianist and an actress fall in love while attempting to reconcile their aspirations for the future.',
        posterColors: [const Color(0xFFBE185D), const Color(0xFF831843), const Color(0xFF9D174D)],
        posterIcon: Icons.nightlife_rounded,
        ticketPrice: 220.0,
        isWatched: true,
        isFeatured: true,
      ),
      Movie(
        id: 'before-sunrise',
        title: 'Before Sunrise',
        tagline: 'One Night. Two Strangers. Endless Possibility.',
        ageRating: 'U/A 16+',
        genre: 'Romance',
        year: 1995,
        rating: 4.6,
        duration: '1h 41m',
        director: 'Richard Linklater',
        cast: ['Ethan Hawke', 'Julie Delpy', 'Andrea Eckert', 'Hanno Pöschl'],
        synopsis: 'A young man and woman meet on a train in Europe, and wind up spending one evening together in Vienna. Unfortunately, both know that this will probably be their only night together.',
        posterColors: [const Color(0xFFDB2777), const Color(0xFFBE185D), const Color(0xFF6B21A8)],
        posterIcon: Icons.train_rounded,
        ticketPrice: 190.0,
        isWatched: false,
        isFeatured: false,
      ),
      Movie(
        id: 'past-lives',
        title: 'Past Lives',
        tagline: 'In-Yun Connects Two Souls Across Decades.',
        ageRating: 'U/A 13+',
        genre: 'Romance',
        year: 2023,
        rating: 4.7,
        duration: '1h 45m',
        director: 'Celine Song',
        cast: ['Greta Lee', 'Teo Yoo', 'John Magaro', 'Moon Seung-ah'],
        synopsis: 'Nora and Hae Sung, two deeply connected childhood friends, are wrested apart after Nora\'s family emigrates from South Korea. Two decades later, they are reunited in New York for one fateful week.',
        posterColors: [const Color(0xFF4C1D95), const Color(0xFF581C87), const Color(0xFF701A75)],
        posterIcon: Icons.favorite_rounded,
        ticketPrice: 240.0,
        isWatched: false,
        isFeatured: false,
      ),

      // ════════════ THRILLER ════════════
      Movie(
        id: 'inception',
        title: 'Inception',
        tagline: 'Your Mind is the Scene of the Crime.',
        ageRating: 'U/A 13+',
        genre: 'Thriller',
        year: 2010,
        rating: 4.8,
        duration: '2h 28m',
        director: 'Christopher Nolan',
        cast: ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Elliot Page', 'Tom Hardy', 'Ken Watanabe'],
        synopsis: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O., but his tragic past may doom the project.',
        posterColors: [const Color(0xFF0F766E), const Color(0xFF115E59), const Color(0xFF042F2E)],
        posterIcon: Icons.filter_tilt_shift_rounded,
        ticketPrice: 250.0,
        isWatched: true,
        isFeatured: true,
      ),
      Movie(
        id: 'shutter-island',
        title: 'Shutter Island',
        tagline: 'Someone is Missing.',
        ageRating: 'A',
        genre: 'Thriller',
        year: 2010,
        rating: 4.6,
        duration: '2h 18m',
        director: 'Martin Scorsese',
        cast: ['Leonardo DiCaprio', 'Mark Ruffalo', 'Ben Kingsley', 'Max von Sydow', 'Michelle Williams'],
        synopsis: 'In 1954, a U.S. Marshal investigates the disappearance of a murderess who escaped from a hospital for the criminally insane on a desolate Boston Harbor island.',
        posterColors: [const Color(0xFF047857), const Color(0xFF065F46), const Color(0xFF064E3B)],
        posterIcon: Icons.explore_rounded,
        ticketPrice: 210.0,
        isWatched: false,
        isFeatured: false,
      ),
      Movie(
        id: 'parasite',
        title: 'Parasite',
        tagline: 'Act as if You Own the Place.',
        ageRating: 'A',
        genre: 'Thriller',
        year: 2019,
        rating: 4.9,
        duration: '2h 12m',
        director: 'Bong Joon-ho',
        cast: ['Song Kang-ho', 'Lee Sun-kyun', 'Cho Yeo-jeong', 'Choi Woo-shik', 'Park So-dam'],
        synopsis: 'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.',
        posterColors: [const Color(0xFF15803D), const Color(0xFF166534), const Color(0xFF14532D)],
        posterIcon: Icons.cottage_rounded,
        ticketPrice: 260.0,
        isWatched: true,
        isFeatured: true,
      ),

      // ════════════ ANIMATION ════════════
      Movie(
        id: 'across-spiderverse',
        title: 'Spider-Man: Across the Spider-Verse',
        tagline: 'It\'s How You Wear the Mask That Matters.',
        ageRating: 'U',
        genre: 'Animation',
        year: 2023,
        rating: 4.9,
        duration: '2h 20m',
        director: 'Joaquim Dos Santos, Kemp Powers',
        cast: ['Shameik Moore', 'Hailee Steinfeld', 'Oscar Isaac', 'Jake Johnson', 'Daniel Kaluuya'],
        synopsis: 'Miles Morales catapults across the Multiverse, where he encounters a team of Spider-People charged with protecting its very existence. When the heroes clash, Miles must redefine what it means to be a hero.',
        posterColors: [const Color(0xFF7C3AED), const Color(0xFFC026D3), const Color(0xFF4338CA)],
        posterIcon: Icons.auto_awesome_rounded,
        ticketPrice: 260.0,
        isWatched: false,
        isFeatured: true,
      ),
      Movie(
        id: 'spirited-away',
        title: 'Spirited Away',
        tagline: 'Tunnel into an Uncharted Realm.',
        ageRating: 'U',
        genre: 'Animation',
        year: 2001,
        rating: 4.9,
        duration: '2h 5m',
        director: 'Hayao Miyazaki',
        cast: ['Rumi Hiiragi', 'Miyu Irino', 'Mari Natsuki', 'Takashi Naito'],
        synopsis: 'During her family\'s move to the suburbs, a sullen 10-year-old girl wanders into a world ruled by gods, witches, and spirits, and where humans are changed into beasts.',
        posterColors: [const Color(0xFF0D9488), const Color(0xFF0F766E), const Color(0xFF134E4A)],
        posterIcon: Icons.spa_rounded,
        ticketPrice: 230.0,
        isWatched: true,
        isFeatured: false,
      ),
      Movie(
        id: 'wall-e',
        title: 'WALL-E',
        tagline: 'After 700 Years of Doing What He Was Built For...',
        ageRating: 'U',
        genre: 'Animation',
        year: 2008,
        rating: 4.8,
        duration: '1h 38m',
        director: 'Andrew Stanton',
        cast: ['Ben Burtt', 'Elissa Knight', 'Jeff Garlin', 'Fred Willard', 'John Ratzenberger'],
        synopsis: 'In the distant future, a small waste-collecting robot inadvertently embarks on a space journey that will ultimately decide the fate of mankind.',
        posterColors: [const Color(0xFFD97706), const Color(0xFFB45309), const Color(0xFF78350F)],
        posterIcon: Icons.precision_manufacturing_rounded,
        ticketPrice: 210.0,
        isWatched: false,
        isFeatured: false,
      ),
    ];
  }
}
