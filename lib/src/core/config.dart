import 'package:meta/meta.dart';

/// Global SDK Configuration settings for caching, concurrency, and validation limits.
@immutable
final class IptvSdkConfig {
  const IptvSdkConfig({
    this.cacheTtl = const Duration(hours: 24),
    this.streamProbeTimeout = const Duration(seconds: 4),
    this.healthCheckConcurrency = 5,
    this.enableAutoCaching = true,
  });

  /// Default cache expiration TTL
  final Duration cacheTtl;

  /// Timeout for dynamic stream health verification
  final Duration streamProbeTimeout;

  /// Maximum concurrent network probe workers during health checks
  final int healthCheckConcurrency;

  /// Automatically index ingested streams in local storage
  final bool enableAutoCaching;
}
