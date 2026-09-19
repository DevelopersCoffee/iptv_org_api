import 'package:meta/meta.dart';

/// Represents a normalized IPTV channel across M3U, Xtream Codes, and iptv-org sources.
@immutable
final class IptvChannel {
  const IptvChannel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logo = '',
    this.group = 'General',
    this.tvgId = '',
    this.tvgName = '',
    this.language = '',
    this.country = '',
    this.category = '',
    this.isResolutionVerified = false,
    this.resolution = '',
    this.extraMetadata = const {},
  });

  /// Unique identifier for the channel
  final String id;

  /// Human-readable channel display name
  final String name;

  /// Direct HTTP/HTTPS or HLS stream URL
  final String streamUrl;

  /// URL pointing to the channel logo/icon
  final String logo;

  /// Category or channel group title
  final String group;

  /// EPG TV Guide ID for XMLTV matching
  final String tvgId;

  /// EPG TV Guide Name reference
  final String tvgName;

  /// Primary broadcast language code (e.g. "en", "es")
  final String language;

  /// ISO 3166-1 country code (e.g. "US", "UK")
  final String country;

  /// Category description or genre
  final String category;

  /// Whether the stream resolution has been dynamically verified
  final bool isResolutionVerified;

  /// Video resolution label if known (e.g. "1080p", "4K", "720p")
  final String resolution;

  /// Additional key-value tags parsed from M3U or Xtream payload
  final Map<String, String> extraMetadata;

  IptvChannel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logo,
    String? group,
    String? tvgId,
    String? tvgName,
    String? language,
    String? country,
    String? category,
    bool? isResolutionVerified,
    String? resolution,
    Map<String, String>? extraMetadata,
  }) {
    return IptvChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logo: logo ?? this.logo,
      group: group ?? this.group,
      tvgId: tvgId ?? this.tvgId,
      tvgName: tvgName ?? this.tvgName,
      language: language ?? this.language,
      country: country ?? this.country,
      category: category ?? this.category,
      isResolutionVerified: isResolutionVerified ?? this.isResolutionVerified,
      resolution: resolution ?? this.resolution,
      extraMetadata: extraMetadata ?? this.extraMetadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'streamUrl': streamUrl,
    'logo': logo,
    'group': group,
    'tvgId': tvgId,
    'tvgName': tvgName,
    'language': language,
    'country': country,
    'category': category,
    'isResolutionVerified': isResolutionVerified,
    'resolution': resolution,
    'extraMetadata': extraMetadata,
  };

  factory IptvChannel.fromJson(Map<String, dynamic> json) {
    return IptvChannel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Channel',
      streamUrl: json['streamUrl'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      group: json['group'] as String? ?? 'General',
      tvgId: json['tvgId'] as String? ?? '',
      tvgName: json['tvgName'] as String? ?? '',
      language: json['language'] as String? ?? '',
      country: json['country'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isResolutionVerified: json['isResolutionVerified'] as bool? ?? false,
      resolution: json['resolution'] as String? ?? '',
      extraMetadata: Map<String, String>.from(
        json['extraMetadata'] as Map? ?? {},
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IptvChannel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          streamUrl == other.streamUrl;

  @override
  int get hashCode => id.hashCode ^ streamUrl.hashCode;

  @override
  String toString() => 'IptvChannel(id: $id, name: $name, group: $group)';
}
