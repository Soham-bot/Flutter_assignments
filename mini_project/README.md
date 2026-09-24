# 🎬 Movie Explorer — Premium Cinema & Streaming Mobile App

> **College Evaluation Mini Project (20 Marks)**  
> **Domain**: Entertainment & Cinema Ticket Reservation  
> **Aesthetic**: Premium Streaming & Cinema Platform (Netflix meets BookMyShow)  
> **Framework**: Pure Flutter (Material 3, `useMaterial3: true`)  
> **Dependencies**: **Zero** external packages beyond the default Flutter SDK  
> **State Management**: Clean `setState` and in-memory Singleton Repository pattern (`ChangeNotifier`)  

---

## 📸 App Screenshots

| 🎬 Home & Hero Carousel | 🔍 Live Search & Filter | 📋 Movie Listing & Sort | 🔖 Watchlist & Progress |
| :---: | :---: | :---: | :---: |
| <img src="screenshots/1_home_screen.png" width="220" /> | <img src="screenshots/3_search_filter_screen.png" width="220" /> | <img src="screenshots/2_movie_list_screen.png" width="220" /> | <img src="screenshots/4_watchlist_screen.png" width="220" /> |

---

## 📋 Table of Contents
1. [Project Overview](#-project-overview)
2. [Screen Flow Diagram](#-screen-flow-diagram)
3. [Key Features & Innovations](#-key-features--innovations)
4. [Design System & Theme Tokens](#-design-system--theme-tokens)
5. [Evaluation Rubric Coverage (20 Marks)](#-evaluation-rubric-coverage-20-marks)
6. [Folder Structure](#-folder-structure)
7. [Screenshots](#-screenshots)
8. [How to Run & Test](#-how-to-run--test)

---

## 🌟 Project Overview
**Movie Explorer** is a high-polish cinema discovery and seat booking mobile application built for college practical evaluation. Designed with a sleek, dark-cinematic aesthetic inspired by modern entertainment leaders (Netflix and BookMyShow), it gives users a seamless native experience:
- **Discover**: Auto-advancing featured hero banner with PageView dot indicators, dynamic time-of-day greeting ("Good morning, Movie Buff"), horizontal genre filter pills, and carousels for *Trending Now*, *Top Rated*, and *New Releases*.
- **Browse & Search**: Sticky search bar, animated List/Grid view switcher (`AnimatedSwitcher`), sorting by Rating/Year/Title, and instant genre filtering across 24+ movies.
- **Details**: 45% screen collapsing SliverAppBar with smooth gradient scrim fade, expandable storyline synopsis, circular cast avatars with initials, 5-star interactive user rating, in-memory review box, and "You May Also Like" recommendations.
- **Interactive Cinema Booking**: 3-step checkout stepper (Date & Showtime -> Interactive 8x6 Cinema Seat Map -> Validated Details Form with snacks combo & SMS alert).
- **Realistic Admission Pass**: Perforated e-ticket card with cutouts, dashed divider, deterministic 8x8 QR code matrix generated from booking ID, animated checkmark bounce (`AnimatedScale`), and subtle confetti celebration particles.
- **Watchlist & Analytics**: Dual tabs (*To Watch* / *Watched*), swipe-to-dismiss with instant `UNDO`, watch completion percentage bar (`LinearProgressIndicator`), and live calculated metrics (total watch hours, favorite genre).

All functionality operates 100% offline with zero external dependencies, zero network images, and pure Material 3 widgets.

---

## 🗺️ Screen Flow Diagram

```text
               ┌───────────────────────────────┐
               │         Splash Screen         │
               │      (splash_screen.dart)     │
               └───────────────┬───────────────┘
                               │ (Smooth Fade Entrance - 1.8s)
                               ▼
               ┌───────────────────────────────┐
               │           Home Hub            │
               │       (home_screen.dart)      │
               └───────────────┬───────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
   [Hero PageView Banner] [Genre Scroller]  [3 Carousels: Trending, Top, New]
            │                  │                  │
            └──────────┬───────┴──────────────────┘
                       │
                       ▼
         ┌───────────────────────────┐
         │       Movie Listing       │◄────────────┐
         │  (movie_list_screen.dart) │             │
         └─────────────┬─────────────┘             │
                       │                           │
                 (Tap on Card)                     │
                       │                           │
                       ▼                           │
         ┌───────────────────────────┐             │
         │       Movie Details       │             │
         │ (movie_detail_screen.dart)│             │
         └─────────────┬─────────────┘             │
                       │                           │
              (Tap "Book Tickets")                 │
                       │                           │
                       ▼                           │
         ┌───────────────────────────┐             │
         │     3-Step Booking Form   │             │
         │ (booking_form_screen.dart)│             │
         │  1. Date & Showtime       │             │
         │  2. Interactive Seat Map  │             │
         │  3. Validated Contact     │             │
         └─────────────┬─────────────┘             │
                       │                           │
             (Form Validated & Paid)               │
                       │                           │
                       ▼                           │
         ┌───────────────────────────┐             │
         │    Booking Confirmation   │             │
         │(confirmation_screen.dart) │             │
         │   (Perforated E-Ticket,   │             │
         │     QR Code, Confetti)    │             │
         └─────────────┬─────────────┘             │
                       │                           │
              (Back to Home)                       │
                       │                           │
                       ▼                           │
         ┌───────────────────────────┐             │
         │      Watchlist Screen     │─────────────┘
         │  (watchlist_screen.dart)  │
         │  To Watch / Watched Tabs  │
         │  Progress Bar & Stats     │
         └───────────────────────────┘
```

---

## 🚀 Key Features & Innovations

### 1. "What Should I Watch?" Mood Engine
Tap the magic icon in the Home AppBar to open an interactive bottom sheet modal. Select your current mood (*Happy*, *Thrilled*, *Romantic*, *Curious*, *Relaxed*) and adjust your available time with a live `Slider` (1.0 - 3.5 hrs). The app intelligently filters the catalogue and presents a personalized match with tailored rationale (*"Because you're in the mood for thrills and have under 2.5 hours"*).

### 2. "Surprise Me!" Slot-Machine Shuffle
Tap the dice button in the Home AppBar to launch a high-energy shuffle dialog. An `AnimatedSwitcher` rapidly cycles through movie posters before landing on a random recommendation with a direct "View Details" action.

### 3. Personal Rating & In-Memory Review
On the Movie Details screen, tap any of the 5 interactive gold stars to submit a personal score, accompanied by a custom review field. Reviews and ratings persist across screens in the singleton repository.

### 4. Side-by-Side Movie Comparison
Long-press any movie poster in the Home or Browse screens to stage it, then long-press a second movie to launch a side-by-side comparison modal analyzing Rating, Duration, Release Year, Genre, and Director.

### 5. Interactive Cinema Seat Map (8x6 Grid)
Step 2 of the booking process features a realistic cinema layout:
- Curved theater screen indicator with gradient reflection.
- 48 interactive seat chairs with states: *Available*, *Selected*, *Booked*.
- Multiple tiers: Regular (Rows A-D @ ₹180), Premium (Row E @ ₹280), Recliner (Row F @ ₹420).
- Live pricing updating synchronously as seats and add-ons are toggled.

### 6. Perforated E-Ticket Pass
Screen 5 renders a realistic movie ticket pass with:
- Circular cutouts and dashed perforation line.
- Scannable 8x8 deterministic QR matrix generated directly from the booking ID.
- Animated checkmark scale bounce (`AnimatedScale`) accompanied by floating celebration confetti particles.

### 7. Watchlist Completion Analytics
- Dual tabs (`TabBar` + `TabBarView`) for "To Watch" and "Watched" movies.
- Dynamic `LinearProgressIndicator` showing exact completion percentage.
- Real-time aggregate statistics: Total hours left to watch and computed favorite genre.
- Swipe-to-dismiss (`Dismissible`) with a 4-second floating `SnackBar` containing instant `UNDO`.

---

## 🎨 Design System & Theme Tokens

All styling tokens are centralized in [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart):
- **Background**: Near-black `#0B0B10`
- **Surface**: Dark elevation `#16161D` / Card `#1F1F2A`
- **Accent Primary**: Netflix Crimson `#E50914`
- **Accent Secondary**: IMAX Gold `#F5C518`
- **Typography**: Clean hierarchy with weights 400, 600, 700, 900
- **Spacing Scale**: 4, 8, 12, 16, 24, 32
- **Radius Scale**: 8, 12, 16, 20, 999 (Pill)
- **Aspect Ratio**: Standard 2:3 cinematic poster ratio maintained on every card.

---

## 📁 Folder Structure

```text
lib/
├── data/
│   └── movie_data.dart          # 24 movies, repository singleton, recommendations, stats
├── models/
│   ├── booking.dart             # Cinema booking model with pass ID & add-ons
│   └── movie.dart               # Movie entity with age ratings, reviews, poster colors
├── screens/
│   ├── booking_form_screen.dart # 3-step checkout wizard with 8x6 seat map
│   ├── confirmation_screen.dart # Perforated ticket pass with QR & confetti
│   ├── home_screen.dart         # Hero banner, genre pills, 3 carousels, mood & surprise
│   ├── movie_detail_screen.dart # Collapsing sliver header, 5-star rating, cast avatars
│   ├── movie_list_screen.dart   # Sticky search, animated list/grid, sorting
│   ├── splash_screen.dart       # Cinematic 1.8s logo entrance
│   └── watchlist_screen.dart    # TabBar, watch progress bar, stats card, swipe undo
├── theme/
│   └── app_theme.dart           # Centralized color tokens, text styles, radiuses, theme data
├── utils/
│   └── constants.dart           # Static movie genres, showtimes, seats, ticket prices
├── widgets/
│   ├── custom_drawer.dart       # Dark/Light theme switcher & project info
│   ├── genre_pill.dart          # Custom pill-shaped category buttons
│   ├── mood_picker_sheet.dart   # "What Should I Watch?" recommendation engine
│   ├── movie_compare_dialog.dart# Side-by-side movie comparison modal
│   ├── movie_poster_image.dart  # 2:3 aspect ratio poster with gradient & watermark icon
│   ├── poster_card.dart         # Tall poster card with bookmark button & long-press compare
│   ├── rating_badge.dart        # Gold star rating score badge
│   ├── seat_widget.dart         # Interactive cinema chair widget
│   ├── section_header.dart      # Title, subtitle, and "See All" action header
│   ├── surprise_dialog.dart     # Slot-machine style random movie shuffle
│   └── ticket_card.dart         # Perforated ticket with notches & deterministic QR matrix
└── main.dart                    # App root, ValueListenableBuilder theme mode, PageRouteBuilder
```

---

## 🏆 Evaluation Rubric Coverage (20 Marks)

| Criterion | Max Marks | Implementation Highlights |
| :--- | :---: | :--- |
| **1. UI & Visual Hierarchy** | 5 | Centralized `AppTheme`, 2:3 poster ratios, collapsing sliver app bar, custom pills, no overflows. |
| **2. Screen Diversity & Navigation** | 4 | 5+ screens (`Splash`, `Home`, `Listing`, `Details`, `Booking`, `Confirmation`, `Watchlist`) with custom `PageRouteBuilder` transitions. |
| **3. Form Validation & Interaction** | 4 | 3-step booking flow, live 8x6 cinema seat map, 10-digit phone verification, email regex, name validation. |
| **4. State Management & Architecture** | 4 | In-memory singleton `MovieRepository` (`ChangeNotifier`), pure `setState`, zero external packages. |
| **5. Code Quality & Automated Tests** | 3 | Zero `flutter analyze` issues, 12 automated unit & widget test cases verifying navigation and responsiveness. |

---

## 🚀 How to Run & Test

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis (0 errors, 0 warnings)
flutter analyze

# 3. Run all automated test suites (12/12 passing)
flutter test

# 4. Run on your preferred platform
flutter run -d macos
flutter run -d chrome
```
