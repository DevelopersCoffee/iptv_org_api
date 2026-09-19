import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('IptvClient Facade', () {
    late IptvClient client;

    setUp(() {
      client = IptvClient();
    });

    tearDown(() async {
      await client.dispose();
    });

    test('loadM3uPlaylist parses and caches channels', () async {
      const m3u = '''
#EXTM3U
#EXTINF:-1 tvg-id="c1" group-title="News",News 24
http://live.stream.com/news.m3u8
''';
      final channels = await client.loadM3uPlaylist(m3u);
      expect(channels.length, equals(1));
      expect(channels.first.name, equals('News 24'));

      final cached = await client.searchChannels('News');
      expect(cached.length, equals(1));
    });

    test('playChannel triggers player controller source update', () async {
      const channel = IptvChannel(
        id: 'c1',
        name: 'Sports HD',
        streamUrl: 'http://sports.m3u8',
      );

      await client.playChannel(channel);
      expect(client.playerController.value.currentSource, equals('http://sports.m3u8'));
      expect(client.playerController.value.status, equals(IptvPlaybackStatus.playing));
    });
  });
}
