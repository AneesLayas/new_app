import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adsd_maintenance/main.dart';

void main() {
  testWidgets('App should start with login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login page is displayed
    expect(find.text('ADSD Maintenance App'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Username and password fields
    expect(find.text('Don\'t have an account? Register here'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find the login button and tap it without entering credentials
    final loginButton = find.byType(ElevatedButton);
    await tester.tap(loginButton);
    await tester.pump();

    // Should show error dialog for empty fields
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Please fill in both username and password'), findsOneWidget);
  });

  testWidgets('Navigation to registration page works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find and tap the register link
    final registerLink = find.text('Don\'t have an account? Register here');
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    // Should navigate to registration page
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4)); // Username, email, password, confirm password
  });
} 