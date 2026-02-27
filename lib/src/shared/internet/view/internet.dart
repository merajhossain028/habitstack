import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

class InternetWidget extends ConsumerWidget {
  final Widget child;

  const InternetWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (results) {
        final isConnected = results.isNotEmpty &&
            !results.contains(ConnectivityResult.none);

        return Stack(
          children: [
            child,
            if (!isConnected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.red,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'No internet connection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
