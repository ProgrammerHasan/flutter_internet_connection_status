import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_status/internet_connection_status.dart';

void main() {
  testWidgets('InternetConnectionStatus shows nothing initially', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
            home: Stack(
              children: [
                Scaffold(
                  body: Center(child: Text("Internet Connection Status Example")),
                ),
                InternetConnectionStatus(),
              ],
            )
        ),
      ),
    );

    // Initially, banner should not be visible
    expect(find.byType(NetworkConnectionStatusCard), findsNothing);
  });

  // Additional tests can be added here to simulate connectivity changes
}
