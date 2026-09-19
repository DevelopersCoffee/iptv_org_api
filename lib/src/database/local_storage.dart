import '../data/models/channel.dart';
import '../data/models/epg.dart';

/// Abstract contract for local persistence, caching, and offline-first storage.
abstract interface class IptvLocalStorage {
  /// Saves a list of channels to local storage
  Future<void> saveChannels(List<IptvChannel> channels);

  /// Retrieves stored channels
  Future<List<IptvChannel>> getChannels();

  /// Searches channels by name, group, or category
  Future<List<IptvChannel>> searchChannels(String query);

  /// Filters channels by group title or category
  Future<List<IptvChannel>> getChannelsByGroup(String group);

  /// Sets favorite flag for a channel ID
  Future<void> setFavorite(String channelId, bool isFavorite);

  /// Gets list of favorite channel IDs
  Future<Set<String>> getFavorites();

  /// Saves EPG programs for offline schedule display
  Future<void> saveEpgPrograms(List<EpgProgram> programs);

  /// Retrieves active EPG program for a channel ID at a given timestamp
  Future<EpgProgram?> getLiveProgram(String channelId, [DateTime? at]);

  /// Retrieves program timeline for a channel
  Future<List<EpgProgram>> getProgramSchedule(String channelId);

  /// Clears all cached channels and EPG entries
  Future<void> clearAll();
}
