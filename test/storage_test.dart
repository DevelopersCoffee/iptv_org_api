import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryLocalStorage', () {
    late MemoryLocalStorage storage;

    setUp(() {
      storage = MemoryLocalStorage();
    });

    test('saveChannels and searchChannels index channels correctly', () async {
      const c1 = IptvChannel(
        id: 'c1',
        name: 'CNN News',
        streamUrl: 'http://stream1.m3u8',
        group: 'News',
      );
      const c2 = IptvChannel(
        id: 'c2',
        name: 'BBC Sports',
        streamUrl: 'http://stream2.m3u8',
        group: 'Sports',
      );

      await storage.saveChannels([c1, c2]);

      final all = await storage.getChannels();
      expect(all.length, equals(2));

      final newsMatches = await storage.searchChannels('news');
      expect(newsMatches.length, equals(1));
      expect(newsMatches.first.id, equals('c1'));

      final sportsGroup = await storage.getChannelsByGroup('Sports');
      expect(sportsGroup.length, equals(1));
      expect(sportsGroup.first.id, equals('c2'));
    });

    test('favorite toggles persist correctly', () async {
      await storage.setFavorite('c1', true);
      var favs = await storage.getFavorites();
      expect(favs.contains('c1'), isTrue);

      await storage.setFavorite('c1', false);
      favs = await storage.getFavorites();
      expect(favs.contains('c1'), isFalse);
    });

    test('EPG timeline indexing and live program query work correctly', () async {
      final now = DateTime.now();
      final p1 = EpgProgram(
        id: 'p1',
        channelId: 'c1',
        title: 'Morning Show',
        start: now.subtract(const Duration(hours: 1)),
        stop: now.add(const Duration(hours: 1)),
      );

      await storage.saveEpgPrograms([p1]);

      final live = await storage.getLiveProgram('c1');
      expect(live, isNotNull);
      expect(live!.title, equals('Morning Show'));
    });
  });
}
