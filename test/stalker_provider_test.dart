import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('StalkerProvider', () {
    test('StalkerCategory deserializes JSON correctly', () {
      final category = StalkerCategory.fromJson({
        'id': '10',
        'title': 'Cinema HD',
        'alias': 'cinema',
      });

      expect(category.id, equals('10'));
      expect(category.title, equals('Cinema HD'));
      expect(category.alias, equals('cinema'));
    });

    test('StalkerChannel deserializes JSON correctly', () {
      final channel = StalkerChannel.fromJson({
        'id': '205',
        'name': 'HBO East',
        'number': 101,
        'cmd': 'ffrt http://stalker.server/hbo',
        'category_id': '10',
        'logo': 'http://logos.com/hbo.png',
      });

      expect(channel.id, equals('205'));
      expect(channel.name, equals('HBO East'));
      expect(channel.number, equals(101));
      expect(channel.cmd, equals('ffrt http://stalker.server/hbo'));
      expect(channel.categoryId, equals('10'));
      expect(channel.logo, equals('http://logos.com/hbo.png'));
    });
  });
}
