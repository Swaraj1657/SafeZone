// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safezone/main.dart';
import 'package:safezone/screens/home_screen.dart';
import 'package:safezone/screens/location_screen.dart';
import 'package:safezone/screens/emergency_contacts_screen.dart';
import 'package:safezone/widgets/sos_button.dart';
import 'package:safezone/services/emergency_service.dart';

void main() {
  testWidgets('App renders basic structure', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SafeZoneApp());
    await tester.pump();

    // Verify that the app renders with basic structure
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Navigation bar has correct items', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SafeZoneApp());
    await tester.pump();

    // Verify navigation labels
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });

  testWidgets('SOS button UI elements', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SafeZoneApp());
    await tester.pump();

    // Verify initial state
    expect(find.byType(SOSButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.text('Hold the SOS button to alert'), findsOneWidget);
    expect(find.text('This will notify your emergency contacts and nearby authorities'), findsOneWidget);
  });

  testWidgets('SOS button updates UI on press', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SafeZoneApp());
    await tester.pump();

    // Verify initial state
    expect(find.byType(SOSButton), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    // Tap the button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
