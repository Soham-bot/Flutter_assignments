import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/main.dart';

void main() {
  testWidgets('Movie Explorer app smoke test and initial render', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MovieExplorerApp(enableHeroAutoAdvance: false));
    await tester.pumpAndSettle();

    // Verify that the title and key elements exist
    expect(find.text('Movie Explorer'), findsWidgets);
    expect(find.text('Trending Now'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
  });
}
