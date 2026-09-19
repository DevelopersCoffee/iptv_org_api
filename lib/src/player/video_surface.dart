import 'controller.dart';

/// Configuration descriptor for mounting universal video surfaces in Flutter applications.
final class IptvVideoSurfaceConfig {
  const IptvVideoSurfaceConfig({
    required this.controller,
    this.fit = 'contain',
    this.showControls = true,
    this.autoInitialize = true,
  });

  /// The unified player controller managing video stream state
  final IptvPlayerController controller;

  /// Layout fit mode (e.g. "contain", "cover", "fill")
  final String fit;

  /// Whether default overlay UI controls should be rendered
  final bool showControls;

  /// Auto-initialize stream when surface mounts
  final bool autoInitialize;
}
