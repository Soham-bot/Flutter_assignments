import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/main.dart';
import 'package:movie_explorer/models/booking.dart';
import 'package:movie_explorer/screens/booking_form_screen.dart';
import 'package:movie_explorer/screens/confirmation_screen.dart';
import 'package:movie_explorer/screens/movie_detail_screen.dart';

void main() {
  group('MovieRepository Tests', () {
    test('Initializes with 24 realistic movies across 8 genres', () {
      final repo = MovieRepository();
      expect(repo.allMovies.length, greaterThanOrEqualTo(16));
      expect(repo.featuredMovies.isNotEmpty, isTrue);
      expect(repo.watchlistCount, greaterThan(0));
    });

    test('Filter movies by genre', () {
      final repo = MovieRepository();
      final sciFiMovies = repo.getMovies(genre: 'Sci-Fi');
      expect(sciFiMovies.every((m) => m.genre == 'Sci-Fi'), isTrue);
      expect(sciFiMovies.length, greaterThanOrEqualTo(2));
    });

    test('Search movies by title', () {
      final repo = MovieRepository();
      final results = repo.getMovies(searchQuery: 'dark knight');
      expect(results.any((m) => m.title.contains('Dark Knight')), isTrue);
    });

    test('Watchlist toggle and undo functionality', () {
      final repo = MovieRepository();
      const testId = 'mad-max-fury';

      // Ensure test starts fresh
      repo.removeFromWatchlist(testId);
      final initialCount = repo.watchlistCount;

      repo.addToWatchlist(testId);
      expect(repo.watchlistCount, equals(initialCount + 1));
      expect(repo.isInWatchlist(testId), isTrue);

      repo.removeFromWatchlist(testId);
      expect(repo.watchlistCount, equals(initialCount));
      expect(repo.isInWatchlist(testId), isFalse);
    });

    test('Watched status toggle', () {
      final repo = MovieRepository();
      final movie = repo.allMovies.first;
      final originalStatus = movie.isWatched;

      repo.toggleWatched(movie.id);
      expect(repo.getMovieById(movie.id)?.isWatched, equals(!originalStatus));

      // Revert back
      repo.toggleWatched(movie.id);
      expect(repo.getMovieById(movie.id)?.isWatched, equals(originalStatus));
    });
  });

  group('UI & Screen Navigation Tests', () {
    testWidgets('Full App launches and displays HomeScreen with 3 tabs', (tester) async {
      await tester.pumpWidget(const MovieExplorerApp(enableHeroAutoAdvance: false));
      await tester.pumpAndSettle();

      expect(find.text('Movie Explorer'), findsWidgets);
      expect(find.text('Trending Now'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);

      // Verify bottom navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);

      // Tap Browse tab
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('Sort: Rating (High)'), findsOneWidget);

      // Tap Watchlist tab
      await tester.tap(find.text('Watchlist'));
      await tester.pumpAndSettle();
      expect(find.text('Watching Progress'), findsOneWidget);
      expect(find.textContaining('To Watch'), findsOneWidget);
      expect(find.textContaining('Watched'), findsWidgets);
    });

    testWidgets('MovieDetailScreen renders movie details and actions', (tester) async {
      final movie = MovieRepository().allMovies.first;

      await tester.pumpWidget(
        MaterialApp(
          home: MovieDetailScreen(movie: movie),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(movie.title), findsOneWidget);
      expect(find.text(movie.genre), findsWidgets);
      expect(find.text('Book Tickets Now'), findsOneWidget);
      expect(find.text('Top Cast'), findsOneWidget);
      expect(find.text('Synopsis'), findsOneWidget);
    });

    testWidgets('BookingFormScreen validates required fields and computes total', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final movie = MovieRepository().allMovies.first;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingFormScreen(movie: movie, initialStep: 2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book Movie Tickets'), findsOneWidget);

      final confirmButtonFinder = find.text('Confirm & Pay Booking');
      await tester.ensureVisible(confirmButtonFinder);

      // Tap confirm without typing name/email/phone
      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      // Expect validation error
      expect(find.text('Please enter your full name (minimum 3 characters)'), findsOneWidget);

      // Enter valid name
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      // Enter short phone
      await tester.enterText(find.byType(TextFormField).at(2), '1234');

      await tester.ensureVisible(confirmButtonFinder);
      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Phone number must be exactly 10 digits'), findsOneWidget);
    });

    testWidgets('ConfirmationScreen displays e-ticket and details', (tester) async {
      final movie = MovieRepository().allMovies.first;
      final booking = Booking(
        bookingId: 'ME-2026-X8B9',
        movie: movie,
        customerName: 'Alice Smith',
        email: 'alice@example.com',
        phone: '9876543210',
        showtime: '05:00 PM (Evening Show)',
        seatType: 'Premium',
        seatPrice: 280.0,
        ticketsCount: 2,
        hasPopcorn: true,
        sendSms: true,
        totalAmount: 810.0,
        bookingDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConfirmationScreen(booking: booking),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('ME-2026-X8B9'), findsWidgets);
      expect(find.text(movie.title), findsOneWidget);
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('App renders on small device (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MovieExplorerApp(initialRoute: '/home', enableHeroAutoAdvance: false));
      await tester.pumpAndSettle();

      expect(find.text('Movie Explorer'), findsWidgets);
    });

    testWidgets('App renders on large device (412x915) without overflow', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MovieExplorerApp(initialRoute: '/home', enableHeroAutoAdvance: false));
      await tester.pumpAndSettle();

      expect(find.text('Movie Explorer'), findsWidgets);
    });
  });
}
