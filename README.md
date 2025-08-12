<h1 align="center">Internet Connection Status.</h1>
<h4 align="center">A Flutter package to detect internet connection and show banners in your app.</h4>

<p align="center">
  <a href="https://pub.dartlang.org/packages/internet_connection_status"><img src="https://img.shields.io/pub/v/internet_connection_status.svg"></a>
</p>

<p align="center">
  <img src="https://github.com/programmerhasan/flutter_internet_connection_status/raw/master/screenshots/01.png" alt="Internet connection status for Flutter" width="120" style="border-radius: 50%;" />
  <img src="https://github.com/programmerhasan/flutter_internet_connection_status/raw/master/screenshots/02.png" alt="Internet connection status for Flutter" width="120" style="border-radius: 50%;" />
</p>


---

## Features

- Automatic internet connection detection using connectivity_plus and internet_connection_checker
- Shows online/offline status banners automatically
- Stylish blur glass-effect banners for online/offline status notifications
- Customizable banners via widget or text parameters
- Built with hooks_riverpod and flutter_hooks for reactive and declarative usage

---

## Quickstart

### Add dependency to your pubspec file

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  internet_connection_status: ^1.0.0
```

### Add Internet Connection Status to Your App!

```dart
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
```

# Public API

- `internetStatusStreamProvider`  
  StreamProvider<ConnectionStatus> — stream of internet connection status

- `isInternetConnectedProvider`  
  Provider<bool?> — boolean internet connection status (null while loading)

- `InternetConnectionStatus` (Widget)  
  Shows online/offline banners automatically, customizable

- `NetworkConnectionStatusCard` (Widget)  
  Default styled banner card with blur glass effect

- `ConnectionStatus` enum  
  Enum for `connected` and `disconnected`

