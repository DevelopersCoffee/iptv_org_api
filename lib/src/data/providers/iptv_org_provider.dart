import '../../client.dart';
import '../models/channel.dart';

/// Provider for fetching and converting iptv-org repository datasets into normalized channels.
final class IptvOrgProvider {
  const IptvOrgProvider(this.apiClient);

  final IptvOrgApiClient apiClient;

  /// Fetches iptv-org streams and channels, merging relational metadata into [IptvChannel] models.
  Future<List<IptvChannel>> getNormalizedChannels() async {
    final channels = await apiClient.fetchChannels();
    final streams = await apiClient.fetchStreams();
    final logos = await apiClient.fetchLogos();
    final categories = await apiClient.fetchCategories();

    final channelMap = {for (final c in channels) c.id: c};
    final logoMap = {for (final l in logos) l.channel: l.url};
    final catMap = {for (final c in categories) c.id: c.name};

    final result = <IptvChannel>[];

    for (var i = 0; i < streams.length; i++) {
      final s = streams[i];
      final channelId = s.channel ?? '';
      final matchingChannel = channelMap[channelId];

      final name = matchingChannel?.name ?? s.title;
      final logo = logoMap[channelId] ?? '';
      final category = matchingChannel?.categories.isNotEmpty == true
          ? (catMap[matchingChannel!.categories.first] ?? matchingChannel.categories.first)
          : 'General';
      final country = matchingChannel?.country ?? '';

      result.add(
        IptvChannel(
          id: 'iptvorg_${channelId}_$i',
          name: name,
          streamUrl: s.url,
          logo: logo,
          group: category,
          tvgId: channelId,
          country: country,
          category: category,
          extraMetadata: {
            if (s.referrer != null) 'referrer': s.referrer!,
            if (s.userAgent != null) 'user_agent': s.userAgent!,
            if (s.quality != null) 'quality': s.quality!,
          },
        ),
      );
    }

    return List.unmodifiable(result);
  }
}
