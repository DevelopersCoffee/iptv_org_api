import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('XtreamProvider', () {
    test('buildStreamUrl constructs valid video stream URL', () {
      final provider = XtreamProvider(
        baseUrl: 'http://xtream.server:8080',
        username: 'user123',
        password: 'pass456',
      );

      final url = provider.buildStreamUrl(9988, containerExtension: 'm3u8');
      expect(url, equals('http://xtream.server:8080/user123/pass456/9988.m3u8'));
    });

    test('XtreamCategory model decodes JSON correctly', () {
      final category = XtreamCategory.fromJson({
        'category_id': '45',
        'category_name': 'Sports USA',
        'parent_id': '0',
      });

      expect(category.categoryId, equals(45));
      expect(category.categoryName, equals('Sports USA'));
    });

    test('XtreamLiveStream model decodes JSON correctly', () {
      final stream = XtreamLiveStream.fromJson({
        'stream_id': '101',
        'name': 'ESPN HD',
        'stream_type': 'live',
        'stream_icon': 'http://logos.com/espn.png',
        'epg_channel_id': 'espn.us',
        'category_id': '45',
      });

      expect(stream.streamId, equals(101));
      expect(stream.name, equals('ESPN HD'));
      expect(stream.epgChannelId, equals('espn.us'));
      expect(stream.categoryId, equals(45));
    });
  });
}
