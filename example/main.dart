import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_status/internet_connection_status.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: const [
            Center(child: Text("Internet Connection Status Example")),
            // Put your internet status banner on top
            InternetConnectionStatus(),
          ],
        ),
      ),
    );
  }
}
