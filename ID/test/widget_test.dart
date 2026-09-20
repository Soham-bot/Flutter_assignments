import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:id_card/main.dart';

void main() {
  testWidgets('ID Card smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Identity Card'), findsOneWidget);
    expect(find.text('Soham Ahirrao'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('20 Years'), findsOneWidget);
    expect(find.text('150096724095'), findsOneWidget);
    expect(find.text('AB+'), findsOneWidget);
    expect(find.text('2024.sohama@iau.ac.in'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byType(Icon), findsNWidgets(4));
  });
}
