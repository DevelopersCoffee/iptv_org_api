import 'dart:async';
import 'dart:convert';
import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryEfficientM3uParser', () {
    const sampleM3u = '''
#EXTM3U
#EXTINF:-1 tvg-id="CNN.us" tvg-name="CNN US" tvg-logo="http://logos.com/cnn.png" group-title="News" tvg-language="English",CNN HD
http://stream.example.com/cnn/live.m3u8
#EXTINF:-1 tvg-id="BBC.uk" tvg-logo="http://logos.com/bbc.png" group-title="General",BBC One
http://stream.example.com/bbc/live.m3u8
''';

    test('parseString extracts all channels and metadata correctly', () {
      const parser = MemoryEfficientM3uParser();
      final channels = parser.parseString(sampleM3u);

      expect(channels.length, equals(2));

      final cnn = channels[0];
      expect(cnn.name, equals('CNN HD'));
      expect(cnn.tvgId, equals('CNN.us'));
      expect(cnn.logo, equals('http://logos.com/cnn.png'));
      expect(cnn.group, equals('News'));
      expect(cnn.streamUrl, equals('http://stream.example.com/cnn/live.m3u8'));
      expect(cnn.language, equals('English'));

      final bbc = channels[1];
      expect(bbc.name, equals('BBC One'));
      expect(bbc.tvgId, equals('BBC.uk'));
      expect(bbc.logo, equals('http://logos.com/bbc.png'));
      expect(bbc.group, equals('General'));
      expect(bbc.streamUrl, equals('http://stream.example.com/bbc/live.m3u8'));
    });

    test('parseByteStream parses chunked byte stream under minimal memory', () async {
      const parser = MemoryEfficientM3uParser();
      final controller = StreamController<List<int>>();

      final streamFuture = parser.parseByteStream(controller.stream).toList();

      final bytes = utf8.encode(sampleM3u);
      // Push in small chunks
      controller.add(bytes.sublist(0, 50));
      controller.add(bytes.sublist(50, 150));
      controller.add(bytes.sublist(150));
      await controller.close();

      final channels = await streamFuture;
      expect(channels.length, equals(2));
      expect(channels[0].name, equals('CNN HD'));
      expect(channels[1].name, equals('BBC One'));
    });
  });
}
