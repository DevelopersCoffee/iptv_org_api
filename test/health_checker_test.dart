import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('IptvHealthChecker', () {
    final healthChecker = IptvHealthChecker();

    test('verifyStream handles invalid scheme gracefully', () async {
      final status = await healthChecker.verifyStream('invalid-url-string');
      expect(status.isAlive, isFalse);
      expect(status.errorReason, contains('Invalid URI scheme'));
    });

    test('verifyChannelsConcurrent streams results for channel list', () async {
      const channels = [
        IptvChannel(id: 'c1', name: 'Chan 1', streamUrl: 'invalid://url1'),
        IptvChannel(id: 'c2', name: 'Chan 2', streamUrl: 'invalid://url2'),
      ];

      final results = await healthChecker
          .verifyChannelsConcurrent(channels, concurrency: 2)
          .toList();

      expect(results.length, equals(2));
      expect(results[0].value.isAlive, isFalse);
      expect(results[1].value.isAlive, isFalse);
    });
  });
}
