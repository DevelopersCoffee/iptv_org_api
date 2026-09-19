import 'package:iptv_org_api/iptv_org_api.dart';
import 'package:test/test.dart';

void main() {
  group('XmltvParser', () {
    const sampleXmltv = '''
<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="cnn.us">
    <display-name>CNN USA</display-name>
    <icon src="http://logos.com/cnn.png"/>
  </channel>
  <programme start="20260919120000 +0000" stop="20260919130000 +0000" channel="cnn.us">
    <title>State of the Union</title>
    <desc>Weekly political discussion news program.</desc>
    <category>News</category>
    <rating>TV-G</rating>
  </programme>
</tv>
''';

    test('parseChannels extracts XMLTV channels correctly', () {
      const parser = XmltvParser();
      final channels = parser.parseChannels(sampleXmltv);

      expect(channels.length, equals(1));
      expect(channels[0].id, equals('cnn.us'));
      expect(channels[0].displayName, equals('CNN USA'));
      expect(channels[0].icon, equals('http://logos.com/cnn.png'));
    });

    test('parsePrograms extracts EPG program schedule correctly', () {
      const parser = XmltvParser();
      final programs = parser.parsePrograms(sampleXmltv);

      expect(programs.length, equals(1));
      final prog = programs[0];
      expect(prog.channelId, equals('cnn.us'));
      expect(prog.title, equals('State of the Union'));
      expect(prog.description, equals('Weekly political discussion news program.'));
      expect(prog.category, equals('News'));
      expect(prog.rating, equals('TV-G'));
      expect(prog.start, equals(DateTime.utc(2026, 9, 19, 12, 0, 0)));
      expect(prog.stop, equals(DateTime.utc(2026, 9, 19, 13, 0, 0)));
    });

    test('isLive and progress calculations work correctly', () {
      final start = DateTime.now().subtract(const Duration(minutes: 30));
      final stop = DateTime.now().add(const Duration(minutes: 30));

      final program = EpgProgram(
        id: 'test_1',
        channelId: 'chan_1',
        title: 'Live News',
        start: start,
        stop: stop,
      );

      expect(program.isLive(), isTrue);
      expect(program.progress(), closeTo(0.5, 0.05));
    });
  });
}
