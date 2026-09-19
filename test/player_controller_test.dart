import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultIptvPlayerController', () {
    late DefaultIptvPlayerController controller;

    setUp(() {
      controller = DefaultIptvPlayerController();
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('initial state is idle', () {
      expect(controller.value.status, equals(IptvPlaybackStatus.idle));
      expect(controller.value.currentSource, isEmpty);
    });

    test('setSource updates state to playing and emits values', () async {
      final states = <IptvPlayerValue>[];
      final sub = controller.valueStream.listen(states.add);

      await controller.setSource('http://stream.m3u8', autoPlay: true);

      expect(controller.value.currentSource, equals('http://stream.m3u8'));
      expect(controller.value.status, equals(IptvPlaybackStatus.playing));

      await sub.cancel();
    });

    test('pause, volume, and mute controls update value correctly', () async {
      await controller.setSource('http://stream.m3u8', autoPlay: true);
      await controller.pause();
      expect(controller.value.status, equals(IptvPlaybackStatus.paused));

      await controller.setVolume(0.8);
      expect(controller.value.volume, equals(0.8));

      await controller.setMuted(true);
      expect(controller.value.isMuted, isTrue);
    });
  });
}
