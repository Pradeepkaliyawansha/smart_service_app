import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the correct app class name
import 'package:smart_package_app/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (
    WidgetTester tester,
  ) async {
    // SmartPackageApp (not MyApp) is the correct class
    await tester.pumpWidget(
      const ProviderScope(child: SmartPackageApp()),
    );
    // Just verify it renders something
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
