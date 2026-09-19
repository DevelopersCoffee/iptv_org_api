import 'package:meta/meta.dart';

/// Verification status for an IPTV stream URL.
@immutable
final class StreamStatus {
  const StreamStatus({
    required this.isAlive,
    this.statusCode = 0,
    this.mimeType = '',
    this.latencyMs = 0,
    this.resolution = '',
    this.audioTracks = const [],
    this.errorReason = '',
    this.checkedAt,
  });

  /// Whether the stream URL returned an active 2xx status code and valid media stream
  final bool isAlive;

  /// HTTP response status code (e.g. 200, 404, 503)
  final int statusCode;

  /// Detected Content-Type / MIME type (e.g., "application/x-mpegURL", "video/mp2t")
  final String mimeType;

  /// Network round-trip latency in milliseconds
  final int latencyMs;

  /// Resolution detected from stream probe if available (e.g. "1920x1080")
  final String resolution;

  /// Audio tracks/languages detected
  final List<String> audioTracks;

  /// Error details if stream validation failed
  final String errorReason;

  /// Timestamp when verification occurred
  final DateTime? checkedAt;

  Map<String, dynamic> toJson() => {
    'isAlive': isAlive,
    'statusCode': statusCode,
    'mimeType': mimeType,
    'latencyMs': latencyMs,
    'resolution': resolution,
    'audioTracks': audioTracks,
    'errorReason': errorReason,
    'checkedAt': checkedAt?.toIso8601String(),
  };

  factory StreamStatus.fromJson(Map<String, dynamic> json) {
    return StreamStatus(
      isAlive: json['isAlive'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? '',
      latencyMs: json['latencyMs'] as int? ?? 0,
      resolution: json['resolution'] as String? ?? '',
      audioTracks: List<String>.from(json['audioTracks'] as List? ?? []),
      errorReason: json['errorReason'] as String? ?? '',
      checkedAt: json['checkedAt'] != null
          ? DateTime.parse(json['checkedAt'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'StreamStatus(isAlive: $isAlive, statusCode: $statusCode, latency: ${latencyMs}ms, mime: $mimeType)';
}
