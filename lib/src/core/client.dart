import 'dart:async';
import 'config.dart';
import '../client.dart';
import '../database/local_storage.dart';
import '../database/memory_storage.impl.dart';
import '../data/models/channel.dart';
import '../data/models/epg.dart';
import '../data/models/stream_status.dart';
import '../data/parsers/m3u_parser.dart';
import '../data/parsers/xmltv_parser.dart';
import '../data/providers/iptv_org_provider.dart';
import '../data/providers/xtream_provider.dart';
import '../player/controller.dart';
import '../utils/health_checker.dart';

/// Central Enterprise-Grade IPTV SDK Entrypoint and Facade.
/// Coordinates multi-source ingestion, health validation, local persistence, EPG sync, and player controls.
final class IptvClient {
  IptvClient({
    IptvSdkConfig? config,
    IptvLocalStorage? storage,
    IptvHealthChecker? healthChecker,
    IptvPlayerController? playerController,
    this.iptvOrgApiClient,
  })  : config = config ?? const IptvSdkConfig(),
        storage = storage ?? MemoryLocalStorage(),
        healthChecker = healthChecker ?? IptvHealthChecker(),
        playerController = playerController ?? DefaultIptvPlayerController(),
        m3uParser = const MemoryEfficientM3uParser(),
        xmltvParser = const XmltvParser();

  final IptvSdkConfig config;
  final IptvLocalStorage storage;
  final IptvHealthChecker healthChecker;
  final IptvPlayerController playerController;
  final IptvOrgApiClient? iptvOrgApiClient;
  final MemoryEfficientM3uParser m3uParser;
  final XmltvParser xmltvParser;

  /// Loads an M3U/M3U8 playlist string, parses channels, and optionally caches them locally.
  Future<List<IptvChannel>> loadM3uPlaylist(String m3uContent) async {
    final channels = m3uParser.parseString(m3uContent);
    if (config.enableAutoCaching) {
      await storage.saveChannels(channels);
    }
    return channels;
  }

  /// Memory-efficient streaming ingestion for M3U playlist byte streams.
  Stream<IptvChannel> streamM3uPlaylist(Stream<List<int>> byteStream) async* {
    final buffer = <IptvChannel>[];

    await for (final channel in m3uParser.parseByteStream(byteStream)) {
      yield channel;
      buffer.add(channel);

      if (config.enableAutoCaching && buffer.length >= 100) {
        await storage.saveChannels(List.from(buffer));
        buffer.clear();
      }
    }

    if (config.enableAutoCaching && buffer.isNotEmpty) {
      await storage.saveChannels(buffer);
    }
  }

  /// Parses XMLTV program schedules and Syncs them into local storage.
  Future<List<EpgProgram>> loadXmltvEpg(String xmltvContent) async {
    final programs = xmltvParser.parsePrograms(xmltvContent);
    await storage.saveEpgPrograms(programs);
    return programs;
  }

  /// Syncs iptv-org global API relational tables into normalized channels.
  Future<List<IptvChannel>> syncIptvOrgDataset() async {
    if (iptvOrgApiClient == null) {
      throw StateError('iptvOrgApiClient must be provided to sync iptv-org dataset');
    }
    final provider = IptvOrgProvider(iptvOrgApiClient!);
    final channels = await provider.getNormalizedChannels();
    if (config.enableAutoCaching) {
      await storage.saveChannels(channels);
    }
    return channels;
  }

  /// Connects to an industrial Xtream Codes backend server.
  Future<XtreamProvider> connectXtream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final provider = XtreamProvider(
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
    final channels = await provider.getNormalizedChannels();
    if (config.enableAutoCaching) {
      await storage.saveChannels(channels);
    }
    return provider;
  }

  /// Probes stream URL health and latency
  Future<StreamStatus> verifyStreamHealth(String streamUrl) {
    return healthChecker.verifyStream(streamUrl);
  }

  /// Concurrently probes health across channels
  Stream<MapEntry<IptvChannel, StreamStatus>> verifyAllChannelsHealth({
    List<IptvChannel>? channels,
  }) async* {
    final list = channels ?? await storage.getChannels();
    yield* healthChecker.verifyChannelsConcurrent(
      list,
      concurrency: config.healthCheckConcurrency,
    );
  }

  /// Plays a given channel's stream URL using the player controller
  Future<void> playChannel(IptvChannel channel) {
    return playerController.setSource(channel.streamUrl, autoPlay: true);
  }

  /// Searches cached channels by query string
  Future<List<IptvChannel>> searchChannels(String query) {
    return storage.searchChannels(query);
  }

  /// Releases resources
  Future<void> dispose() async {
    await playerController.dispose();
  }
}
