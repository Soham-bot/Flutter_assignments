import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment_4/main.dart';
import 'package:assignment_4/screens/form_screen.dart';
import 'package:assignment_4/screens/image_grid_screen.dart';
import 'package:assignment_4/screens/animation_screen.dart';

void main() {
  testWidgets('HomeScreen renders concept cards and navigates to all 3 screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AssignmentFourApp());
    await tester.pumpAndSettle();

    // Verify HomeScreen elements
    expect(find.text('Flutter Concepts Hub'), findsOneWidget);
    expect(find.text('User Input & Forms'), findsOneWidget);
    expect(find.text('Images, Assets & Fonts'), findsOneWidget);
    expect(find.text('Interactive Animations'), findsOneWidget);

    // 1. Navigate to FormScreen
    await tester.tap(find.byKey(const Key('card_forms')));
    await tester.pumpAndSettle();
    expect(find.byType(FormScreen), findsOneWidget);
    expect(find.text('User Registration Form'), findsOneWidget);

    // Navigate back to HomeScreen
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 2. Navigate to ImageGridScreen
    await tester.tap(find.byKey(const Key('card_gallery')));
    await tester.pumpAndSettle();
    expect(find.byType(ImageGridScreen), findsOneWidget);
    expect(find.text('Images, Assets & Fonts'), findsOneWidget);

    // Navigate back to HomeScreen
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 3. Navigate to AnimationScreen
    await tester.tap(find.byKey(const Key('card_animations')));
    await tester.pumpAndSettle();
    expect(find.byType(AnimationScreen), findsOneWidget);
    expect(find.text('Interactive Animations'), findsOneWidget);
  });

  testWidgets('FormScreen validates inputs, shows SnackBar, and resets form',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: FormScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Submit without filling in fields -> should show validation error SnackBar
    await tester.tap(find.byKey(const Key('btn_submit_form')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please enter an email address.'), findsOneWidget);
    expect(find.text('Please enter your phone number.'), findsOneWidget);
    expect(find.text('Please provide your feedback or remarks.'), findsOneWidget);

    // Fill valid data
    await tester.enterText(find.byKey(const Key('input_name')), 'John Doe');
    await tester.enterText(
        find.byKey(const Key('input_email')), 'john.doe@example.com');
    await tester.enterText(find.byKey(const Key('input_phone')), '9876543210');
    await tester.enterText(
        find.byKey(const Key('input_feedback')), 'This is a great Flutter app!');

    await tester.tap(find.byKey(const Key('btn_submit_form')));
    await tester.pumpAndSettle();

    // Verify success SnackBar and result card
    expect(find.text('Form submitted successfully! Welcome, John Doe!'),
        findsOneWidget);
    expect(find.byKey(const Key('submitted_data_card')), findsOneWidget);
    expect(find.text('john.doe@example.com'), findsNWidgets(2));

    // Test Reset button
    await tester.tap(find.byKey(const Key('btn_reset_form')));
    await tester.pumpAndSettle();

    // Form inputs and submitted card should be cleared
    expect(find.byKey(const Key('submitted_data_card')), findsNothing);
    expect(find.text('Form inputs have been cleared.'), findsOneWidget);
  });

  testWidgets('ImageGridScreen renders custom font banner and image cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ImageGridScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Images, Assets & Fonts'), findsOneWidget);
    expect(find.text('Custom Font: Poppins'), findsOneWidget);
    expect(find.text('ASSET IMAGES (GridView.count)'), findsOneWidget);
    expect(find.text('Pacific Shore'), findsOneWidget);
    expect(find.text('Catalina Sunset'), findsOneWidget);
    expect(find.text('Dome Architecture'), findsOneWidget);
  });

  testWidgets('AnimationScreen toggles AnimatedContainer properties and applies presets',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: AnimationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Interactive Animations'), findsOneWidget);
    expect(find.text('Compact Purple'), findsWidgets);

    // Find the AnimatedContainer
    final containerFinder = find.byKey(const Key('animated_container_target'));
    expect(containerFinder, findsOneWidget);

    AnimatedContainer container =
        tester.widget<AnimatedContainer>(containerFinder);
    var boxDec = container.decoration as BoxDecoration;
    expect(boxDec.color, const Color(0xFF673AB7));

    // Tap Toggle button to morph container
    await tester.tap(find.byKey(const Key('btn_toggle_animation')));
    await tester.pumpAndSettle();

    // Check transformed properties
    container = tester.widget<AnimatedContainer>(containerFinder);
    boxDec = container.decoration as BoxDecoration;
    expect(boxDec.color, const Color(0xFFE65100));
    expect(find.text('Glowing Orange Circle'), findsWidgets);

    // Tap preset: Emerald Card
    await tester.tap(find.text('Emerald Card'));
    await tester.pumpAndSettle();

    container = tester.widget<AnimatedContainer>(containerFinder);
    boxDec = container.decoration as BoxDecoration;
    expect(boxDec.color, const Color(0xFF2E7D32));
    expect(find.text('Emerald Card'), findsWidgets);
  });
}
