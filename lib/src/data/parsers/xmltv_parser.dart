import '../models/epg.dart';

/// Lightweight XMLTV EPG parser for program schedules and channel guide tags.
final class XmltvParser {
  const XmltvParser();

  /// Parses an XMLTV string and extracts a list of [EpgProgram] items.
  List<EpgProgram> parsePrograms(String xmlContent) {
    final programs = <EpgProgram>[];
    final programmeRegExp = RegExp(
      r'<programme\s+([^>]+)>(.*?)</programme>',
      dotAll: true,
    );

    final matches = programmeRegExp.allMatches(xmlContent);
    for (final match in matches) {
      final attrStr = match.group(1) ?? '';
      final bodyStr = match.group(2) ?? '';

      final startStr = _extractAttr(attrStr, 'start');
      final stopStr = _extractAttr(attrStr, 'stop');
      final channelId = _extractAttr(attrStr, 'channel');

      if (startStr.isEmpty || stopStr.isEmpty || channelId.isEmpty) continue;

      final start = parseXmltvDate(startStr);
      final stop = parseXmltvDate(stopStr);

      if (start == null || stop == null) continue;

      final title = _extractTag(bodyStr, 'title');
      final description = _extractTag(bodyStr, 'desc');
      final category = _extractTag(bodyStr, 'category');
      final icon = _extractAttrFromTag(bodyStr, 'icon', 'src');
      final rating = _extractTag(bodyStr, 'rating');

      final id = 'prog_${channelId}_${start.millisecondsSinceEpoch}';

      programs.add(
        EpgProgram(
          id: id,
          channelId: channelId,
          title: title.isNotEmpty ? title : 'Untitled Program',
          start: start,
          stop: stop,
          description: description,
          category: category,
          icon: icon,
          rating: rating,
        ),
      );
    }

    return List.unmodifiable(programs);
  }

  /// Parses channel entries `<channel id="...">` in XMLTV data.
  List<EpgChannel> parseChannels(String xmlContent) {
    final channels = <EpgChannel>[];
    final channelRegExp = RegExp(
      r'<channel\s+([^>]+)>(.*?)</channel>',
      dotAll: true,
    );

    final matches = channelRegExp.allMatches(xmlContent);
    for (final match in matches) {
      final attrStr = match.group(1) ?? '';
      final bodyStr = match.group(2) ?? '';

      final id = _extractAttr(attrStr, 'id');
      if (id.isEmpty) continue;

      final displayName = _extractTag(bodyStr, 'display-name');
      final icon = _extractAttrFromTag(bodyStr, 'icon', 'src');
      final url = _extractTag(bodyStr, 'url');

      channels.add(
        EpgChannel(
          id: id,
          displayName: displayName.isNotEmpty ? displayName : id,
          icon: icon,
          url: url,
        ),
      );
    }

    return List.unmodifiable(channels);
  }

  /// Parses XMLTV format dates e.g. "20260919120000 +0000" or "20260919120000"
  DateTime? parseXmltvDate(String dateStr) {
    final trimmed = dateStr.trim();
    if (trimmed.length < 14) return null;

    try {
      final year = int.parse(trimmed.substring(0, 4));
      final month = int.parse(trimmed.substring(4, 6));
      final day = int.parse(trimmed.substring(6, 8));
      final hour = int.parse(trimmed.substring(8, 10));
      final minute = int.parse(trimmed.substring(10, 12));
      final second = int.parse(trimmed.substring(12, 14));

      return DateTime.utc(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  String _extractAttr(String text, String attrName) {
    final match = RegExp('$attrName="([^"]*)"').firstMatch(text);
    return match?.group(1) ?? '';
  }

  String _extractTag(String xmlText, String tagName) {
    final match = RegExp('<$tagName[^>]*>(.*?)</$tagName>', dotAll: true)
        .firstMatch(xmlText);
    return match?.group(1)?.trim() ?? '';
  }

  String _extractAttrFromTag(String xmlText, String tagName, String attrName) {
    final match = RegExp('<$tagName[^>]*$attrName="([^"]*)"[^>]*>').firstMatch(xmlText) ??
        RegExp('<$tagName[^>]*$attrName="([^"]*)"\\s*/>').firstMatch(xmlText);
    return match?.group(1)?.trim() ?? '';
  }
}
