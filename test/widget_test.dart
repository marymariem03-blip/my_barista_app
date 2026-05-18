import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_barista_app/screens/page1_splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
    // Build the SplashScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verify the headline texts are displayed
    expect(find.text('Click,'), findsOneWidget);
    expect(find.text('Pick ,'), findsOneWidget);
    expect(find.text('Sip.'),   findsOneWidget);

    // Verify the beans reward text
    expect(find.text('Collect 2000 Beans'), findsOneWidget);
    expect(find.text('GET A FREE DRINK!'),  findsOneWidget);

    // Verify the two buttons exist
    expect(find.text('Log In'),  findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Log In button navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Tap the Log In button
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Verify we landed on the Login screen
    expect(find.text('Hello!'),   findsOneWidget);
    expect(find.text('Welcome'),  findsOneWidget);
  });

  testWidgets('Sign Up button navigates to SignUpScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Tap the Sign Up button
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify we landed on the Sign Up screen
    expect(find.text('New Account'), findsOneWidget);
  });
}