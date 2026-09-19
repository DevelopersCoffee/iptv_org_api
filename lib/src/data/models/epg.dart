import 'package:meta/meta.dart';

/// Represents a program broadcast item in an Electronic Program Guide (XMLTV / Xtream).
@immutable
final class EpgProgram {
  const EpgProgram({
    required this.id,
    required this.channelId,
    required this.title,
    required this.start,
    required this.stop,
    this.description = '',
    this.category = '',
    this.icon = '',
    this.rating = '',
    this.episode = '',
  });

  /// Unique program ID
  final String id;

  /// Associated channel TVG ID
  final String channelId;

  /// Program title (e.g., "Evening News", "Matchday Live")
  final String title;

  /// Start timestamp
  final DateTime start;

  /// End / stop timestamp
  final DateTime stop;

  /// Detailed synopsis or episode description
  final String description;

  /// Genre or category
  final String category;

  /// Program poster or image URL
  final String icon;

  /// Content rating (e.g. "PG-13", "TV-MA")
  final String rating;

  /// Episode or season information if available
  final String episode;

  /// Checks if the program is currently broadcasting
  bool isLive([DateTime? at]) {
    final time = at ?? DateTime.now();
    return time.isAfter(start) && time.isBefore(stop);
  }

  /// Calculates remaining duration from current time
  Duration duration() => stop.difference(start);

  /// Progress fraction between 0.0 and 1.0 for live programs
  double progress([DateTime? at]) {
    final time = at ?? DateTime.now();
    if (time.isBefore(start)) return 0.0;
    if (time.isAfter(stop)) return 1.0;
    final total = stop.difference(start).inMilliseconds;
    if (total <= 0) return 0.0;
    final elapsed = time.difference(start).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'channelId': channelId,
    'title': title,
    'start': start.toIso8601String(),
    'stop': stop.toIso8601String(),
    'description': description,
    'category': category,
    'icon': icon,
    'rating': rating,
    'episode': episode,
  };

  factory EpgProgram.fromJson(Map<String, dynamic> json) {
    return EpgProgram(
      id: json['id'] as String? ?? '',
      channelId: json['channelId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Program',
      start: DateTime.parse(json['start'] as String),
      stop: DateTime.parse(json['stop'] as String),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      rating: json['rating'] as String? ?? '',
      episode: json['episode'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpgProgram &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          channelId == other.channelId &&
          start == other.start;

  @override
  int get hashCode => id.hashCode ^ channelId.hashCode ^ start.hashCode;

  @override
  String toString() =>
      'EpgProgram(title: $title, channelId: $channelId, start: $start, stop: $stop)';
}

/// Represents an EPG Channel header entry in XMLTV.
@immutable
final class EpgChannel {
  const EpgChannel({
    required this.id,
    required this.displayName,
    this.icon = '',
    this.url = '',
  });

  final String id;
  final String displayName;
  final String icon;
  final String url;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'icon': icon,
    'url': url,
  };

  factory EpgChannel.fromJson(Map<String, dynamic> json) {
    return EpgChannel(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
