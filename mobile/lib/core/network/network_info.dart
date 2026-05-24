import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_info.g.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

/// Abstraction over connectivity detection.
abstract class NetworkInfo {
  /// Returns `true` if the device currently has network access.
  Future<bool> get isConnected;

  /// A broadcast stream that emits connectivity changes.
  Stream<bool> get onConnectivityChanged;
}

// ---------------------------------------------------------------------------
// ConnectivityPlus implementation
// ---------------------------------------------------------------------------

/// Concrete [NetworkInfo] backed by the [connectivity_plus] plugin.
class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Provides the raw [Connectivity] singleton.
@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) => Connectivity();

/// Provides the [NetworkInfo] implementation.
@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) =>
    ConnectivityNetworkInfo(ref.watch(connectivityProvider));
