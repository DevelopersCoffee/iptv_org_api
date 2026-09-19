import 'dart:async';
import 'package:meta/meta.dart';

/// Playback state status enum for [IptvPlayerController].
enum IptvPlaybackStatus {
  idle,
  buffering,
  playing,
  paused,
  completed,
  error,
}

/// Holds player status details (status, position, duration, volume, error).
@immutable
final class IptvPlayerValue {
  const IptvPlayerValue({
    this.status = IptvPlaybackStatus.idle,
    this.currentSource = '',
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isMuted = false,
    this.errorMessage = '',
    this.aspectRatio = 16 / 9,
  });

  final IptvPlaybackStatus status;
  final String currentSource;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isMuted;
  final String errorMessage;
  final double aspectRatio;

  IptvPlayerValue copyWith({
    IptvPlaybackStatus? status,
    String? currentSource,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isMuted,
    String? errorMessage,
    double? aspectRatio,
  }) {
    return IptvPlayerValue(
      status: status ?? this.status,
      currentSource: currentSource ?? this.currentSource,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      errorMessage: errorMessage ?? this.errorMessage,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}

/// Platform-agnostic unified video player controller interface.
abstract class IptvPlayerController {
  /// Current playback status value
  IptvPlayerValue get value;

  /// Stream of playback state updates
  Stream<IptvPlayerValue> get valueStream;

  /// Loads and starts playing a stream URL
  Future<void> setSource(String url, {bool autoPlay = true});

  /// Plays active media source
  Future<void> play();

  /// Pauses playback
  Future<void> pause();

  /// Seeks to target duration offset
  Future<void> seekTo(Duration position);

  /// Sets audio volume level (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Toggles audio mute state
  Future<void> setMuted(bool muted);

  /// Releases player resources
  Future<void> dispose();
}

/// Default lightweight mock / fallback implementation of [IptvPlayerController].
final class DefaultIptvPlayerController implements IptvPlayerController {
  DefaultIptvPlayerController();

  final _controller = StreamController<IptvPlayerValue>.broadcast();
  IptvPlayerValue _value = const IptvPlayerValue();

  @override
  IptvPlayerValue get value => _value;

  @override
  Stream<IptvPlayerValue> get valueStream => _controller.stream;

  void _update(IptvPlayerValue newValue) {
    _value = newValue;
    if (!_controller.isClosed) {
      _controller.add(_value);
    }
  }

  @override
  Future<void> setSource(String url, {bool autoPlay = true}) async {
    _update(
      _value.copyWith(
        currentSource: url,
        status: IptvPlaybackStatus.buffering,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _update(
      _value.copyWith(
        status: autoPlay ? IptvPlaybackStatus.playing : IptvPlaybackStatus.paused,
      ),
    );
  }

  @override
  Future<void> play() async {
    _update(_value.copyWith(status: IptvPlaybackStatus.playing));
  }

  @override
  Future<void> pause() async {
    _update(_value.copyWith(status: IptvPlaybackStatus.paused));
  }

  @override
  Future<void> seekTo(Duration position) async {
    _update(_value.copyWith(position: position));
  }

  @override
  Future<void> setVolume(double volume) async {
    _update(_value.copyWith(volume: volume.clamp(0.0, 1.0)));
  }

  @override
  Future<void> setMuted(bool muted) async {
    _update(_value.copyWith(isMuted: muted));
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
