import 'local_storage.dart';
import '../data/models/channel.dart';
import '../data/models/epg.dart';

/// In-memory indexed implementation of [IptvLocalStorage] for fast local operations.
final class MemoryLocalStorage implements IptvLocalStorage {
  final Map<String, IptvChannel> _channels = {};
  final Map<String, List<IptvChannel>> _groupIndex = {};
  final Set<String> _favorites = {};
  final Map<String, List<EpgProgram>> _epgIndex = {};

  @override
  Future<void> saveChannels(List<IptvChannel> channels) async {
    for (final channel in channels) {
      _channels[channel.id] = channel;

      final groupKey = channel.group.toLowerCase();
      _groupIndex.putIfAbsent(groupKey, () => []).add(channel);
    }
  }

  @override
  Future<List<IptvChannel>> getChannels() async {
    return List.unmodifiable(_channels.values);
  }

  @override
  Future<List<IptvChannel>> searchChannels(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getChannels();

    final matches = _channels.values.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.group.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.tvgName.toLowerCase().contains(q);
    }).toList();

    return List.unmodifiable(matches);
  }

  @override
  Future<List<IptvChannel>> getChannelsByGroup(String group) async {
    final list = _groupIndex[group.trim().toLowerCase()] ?? [];
    return List.unmodifiable(list);
  }

  @override
  Future<void> setFavorite(String channelId, bool isFavorite) async {
    if (isFavorite) {
      _favorites.add(channelId);
    } else {
      _favorites.remove(channelId);
    }
  }

  @override
  Future<Set<String>> getFavorites() async {
    return Set.unmodifiable(_favorites);
  }

  @override
  Future<void> saveEpgPrograms(List<EpgProgram> programs) async {
    for (final program in programs) {
      _epgIndex.putIfAbsent(program.channelId, () => []).add(program);
    }

    // Sort timelines by start time
    for (final key in _epgIndex.keys) {
      _epgIndex[key]!.sort((a, b) => a.start.compareTo(b.start));
    }
  }

  @override
  Future<EpgProgram?> getLiveProgram(String channelId, [DateTime? at]) async {
    final schedule = _epgIndex[channelId];
    if (schedule == null || schedule.isEmpty) return null;

    final time = at ?? DateTime.now();
    for (final program in schedule) {
      if (program.isLive(time)) {
        return program;
      }
    }
    return null;
  }

  @override
  Future<List<EpgProgram>> getProgramSchedule(String channelId) async {
    final schedule = _epgIndex[channelId] ?? [];
    return List.unmodifiable(schedule);
  }

  @override
  Future<void> clearAll() async {
    _channels.clear();
    _groupIndex.clear();
    _favorites.clear();
    _epgIndex.clear();
  }
}
