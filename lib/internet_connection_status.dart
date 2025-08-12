// lib/internet_connection_status.dart

library internet_connection_status;

import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Connection status enum
enum ConnectionStatus { connected, disconnected }

/// Provides the current internet connection status as a stream.
/// Uses Connectivity plus InternetConnectionChecker for accurate status.
final internetStatusStreamProvider = StreamProvider<ConnectionStatus>((ref) {
  final controller = StreamController<ConnectionStatus>();
  final checker = InternetConnectionChecker.instance;

  Future<void> updateStatus() async {
    final hasInternet = await checker.hasConnection;
    controller.add(
      hasInternet ? ConnectionStatus.connected : ConnectionStatus.disconnected,
    );
  }

  // Initial check
  updateStatus();

  // Listen to connectivity changes and update status accordingly
  final sub = Connectivity().onConnectivityChanged.listen((_) {
    updateStatus();
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Simple provider to get the current connection as a boolean
final isInternetConnectedProvider = Provider<bool?>((ref) {
  final asyncStatus = ref.watch(internetStatusStreamProvider);

  return asyncStatus.when(
    data: (status) => status == ConnectionStatus.connected,
    loading: () => null,
    error: (_, __) => false,
  );
});

/// Widget that listens to internet connection status and shows
/// appropriate online/offline banners.
///
/// Customize the banners with [online], [offline] widgets or
/// via titles and subtitles.
///
/// Requires hooks_riverpod and flutter_hooks.
class InternetConnectionStatus extends HookConsumerWidget {
  final Widget? online;
  final Widget? offline;
  final String? onlineTitle;
  final String? onlineSubtitle;
  final String? offlineTitle;
  final String? offlineSubtitle;

  const InternetConnectionStatus({
    super.key,
    this.online,
    this.offline,
    this.onlineTitle,
    this.onlineSubtitle,
    this.offlineTitle,
    this.offlineSubtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(internetStatusStreamProvider);
    final previousStatus = useRef<ConnectionStatus?>(null);
    final showBackOnlineBanner = useState(false);

    useEffect(() {
      final listener = ref.listenManual<AsyncValue<ConnectionStatus>>(
        internetStatusStreamProvider,
            (prev, next) {
          if (next is AsyncData<ConnectionStatus>) {
            final current = next.value;
            final prevVal = previousStatus.value;

            if (prevVal == null) {
              // First time initialization, just set previousStatus and don't show banner
              previousStatus.value = current;
              return;
            }

            // If coming back online from offline
            if (prevVal == ConnectionStatus.disconnected &&
                current == ConnectionStatus.connected) {
              showBackOnlineBanner.value = true;

              Future.delayed(const Duration(seconds: 3), () {
                showBackOnlineBanner.value = false;
              });
            }

            previousStatus.value = current;
          }
        },
      );

      return listener.close;
    }, []);

    if (connectionAsync.isLoading) {
      // First time loading - show nothing to avoid wrong banner
      return const SizedBox.shrink();
    }

    if (connectionAsync.hasError) {
      // Show disconnected on error
      return offline ??
          NetworkConnectionStatusCard(
            isOnline: false,
            onlineTitle: onlineTitle,
            onlineSubtitle: onlineSubtitle,
            offlineTitle: offlineTitle,
            offlineSubtitle: offlineSubtitle,
          );
    }

    final status = connectionAsync.value;
    if (status == ConnectionStatus.disconnected) {
      // Show offline banner
      return offline ??
          NetworkConnectionStatusCard(
            isOnline: false,
            onlineTitle: onlineTitle,
            onlineSubtitle: onlineSubtitle,
            offlineTitle: offlineTitle,
            offlineSubtitle: offlineSubtitle,
          );
    }

    if (showBackOnlineBanner.value) {
      // Show back online banner
      return online ??
          NetworkConnectionStatusCard(
            isOnline: true,
            onlineTitle: onlineTitle,
            onlineSubtitle: onlineSubtitle,
            offlineTitle: offlineTitle,
            offlineSubtitle: offlineSubtitle,
          );
    }

    // No banner
    return const SizedBox.shrink();
  }
}

/// The default banner card widget shown for online/offline status.
/// You can customize this or supply your own [online] and [offline] widgets
/// in [InternetConnectionStatus].
class NetworkConnectionStatusCard extends HookConsumerWidget {
  final bool isOnline;
  final String? onlineTitle;
  final String? onlineSubtitle;
  final String? offlineTitle;
  final String? offlineSubtitle;

  const NetworkConnectionStatusCard({
    super.key,
    required this.isOnline,
    this.onlineTitle,
    this.onlineSubtitle,
    this.offlineTitle,
    this.offlineSubtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = useState(true);

    return AnimatedPositioned(
      top: isOnline ? 36 : isVisible.value ? 36 : -100,
      left: 0,
      right: 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
                border: isOnline
                    ? const Border(
                  left: BorderSide(color: Colors.green, width: 4),
                )
                    : const Border(
                  left: BorderSide(color: Colors.grey, width: 4),
                ),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isOnline ? Icons.wifi : Icons.wifi_off,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  isOnline
                      ? onlineTitle ?? "You’re back to internet"
                      : offlineTitle ?? "You're offline now",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black54),
                ),
                subtitle: Text(
                  isOnline
                      ? onlineSubtitle ?? "Hurray! Internet is connected."
                      : offlineSubtitle ?? "Oops! Internet is disconnected.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: InkWell(
                      onTap: () => isVisible.value = false,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
