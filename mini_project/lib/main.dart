import 'package:flutter/material.dart';
import 'package:movie_explorer/data/movie_data.dart';
import 'package:movie_explorer/models/booking.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/screens/booking_form_screen.dart';
import 'package:movie_explorer/screens/confirmation_screen.dart';
import 'package:movie_explorer/screens/home_screen.dart';
import 'package:movie_explorer/screens/movie_detail_screen.dart';
import 'package:movie_explorer/screens/movie_list_screen.dart';
import 'package:movie_explorer/screens/splash_screen.dart';
import 'package:movie_explorer/screens/watchlist_screen.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/utils/constants.dart';

/// Entry Point for Movie Explorer Application
/// Domain: Entertainment
/// College Evaluation: 20-Mark Project Demonstration
/// Uses 100% Core Flutter + Material 3 widgets with zero external package dependencies.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieExplorerApp());
}

class MovieExplorerApp extends StatelessWidget {
  final String initialRoute;
  final bool enableHeroAutoAdvance;

  const MovieExplorerApp({
    super.key,
    this.initialRoute = '/',
    this.enableHeroAutoAdvance = true,
  });

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: repo.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: initialRoute,
          routes: {
            '/': (context) => initialRoute == '/'
                ? const SplashScreen()
                : HomeScreen(enableHeroAutoAdvance: enableHeroAutoAdvance),
            '/home': (context) => HomeScreen(enableHeroAutoAdvance: enableHeroAutoAdvance),
            '/watchlist': (context) => const WatchlistScreen(),
          },
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/movies':
                final genre = settings.arguments as String?;
                page = MovieListScreen(initialGenre: genre);
                break;

              case '/movie_detail':
                final movie = settings.arguments as Movie;
                page = MovieDetailScreen(movie: movie);
                break;

              case '/booking':
                final movie = settings.arguments as Movie;
                page = BookingFormScreen(movie: movie);
                break;

              case '/confirmation':
                final booking = settings.arguments as Booking;
                page = ConfirmationScreen(booking: booking);
                break;

              default:
                page = HomeScreen(enableHeroAutoAdvance: enableHeroAutoAdvance);
                break;
            }

            // Custom Smooth Fade & Slide Page Transition
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.04, 0.0);
                const end = Offset.zero;
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return SlideTransition(
                  position: Tween<Offset>(begin: begin, end: end).animate(curved),
                  child: FadeTransition(
                    opacity: curved,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 280),
            );
          },
        );
      },
    );
  }
}
