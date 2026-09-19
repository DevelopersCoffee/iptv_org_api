import 'dart:convert';
import 'dart:io';
import '../models/channel.dart';
import '../models/stalker.dart';

/// Stalker Portal IPTV Middleware provider for MAC-authenticated servers.
final class StalkerProvider {
  StalkerProvider({
    required String portalUrl,
    required this.macAddress,
    HttpClient? httpClient,
  })  : portalUrl = _sanitizePortalUrl(portalUrl),
        _client = httpClient ?? HttpClient();

  final String portalUrl;
  final String macAddress;
  final HttpClient _client;
  String _token = '';

  static String _sanitizePortalUrl(String url) {
    var s = url.trim();
    if (!s.endsWith('/')) s += '/';
    if (!s.contains('server/load.php')) {
      s += 'server/load.php';
    }
    return s;
  }

  Future<Map<String, dynamic>> _getJson(Map<String, String> queryParams) async {
    final uri = Uri.parse(portalUrl).replace(queryParameters: queryParams);
    final request = await _client.getUrl(uri);

    // Set Stalker MAC cookies and headers
    request.headers.set('Cookie', 'mac=$macAddress; stb_lang=en; timezone=UTC');
    request.headers.set('User-Agent', 'Mozilla/5.0 (QtEmbedded; U; Linux; C)');
    if (_token.isNotEmpty) {
      request.headers.set('Authorization', 'Bearer $_token');
    }

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body);
    if (json is Map<String, dynamic> && json.containsKey('js')) {
      return json['js'] as Map<String, dynamic>;
    }
    if (json is Map<String, dynamic>) {
      return json;
    }
    return {'data': json};
  }

  /// Performs initial Stalker handshake and token exchange
  Future<StalkerProfile> handshake() async {
    final json = await _getJson({
      'type': 'stb',
      'action': 'handshake',
      'token': '',
      'mac': macAddress,
    });
    final profile = StalkerProfile.fromJson(json, macAddress);
    _token = profile.token;
    return profile;
  }

  /// Fetches Stalker IPTV categories
  Future<List<StalkerCategory>> getCategories() async {
    final json = await _getJson({
      'type': 'itv',
      'action': 'get_categories',
    });
    final dataList = json['data'] as List? ?? [];
    return List.unmodifiable(
      dataList.map((e) => StalkerCategory.fromJson(e as Map<String, dynamic>)),
    );
  }

  /// Fetches all IPTV live channels from Stalker middleware
  Future<List<StalkerChannel>> getChannels() async {
    final json = await _getJson({
      'type': 'itv',
      'action': 'get_all_channels',
    });
    final dataList = json['data'] as List? ?? json['channels'] as List? ?? [];
    return List.unmodifiable(
      dataList.map((e) => StalkerChannel.fromJson(e as Map<String, dynamic>)),
    );
  }

  /// Generates direct media stream playback link from Stalker cmd
  Future<String> createLink(String cmd) async {
    final json = await _getJson({
      'type': 'itv',
      'action': 'create_link',
      'cmd': cmd,
    });
    return json['cmd']?.toString() ?? json['url']?.toString() ?? cmd;
  }

  /// Normalizes Stalker channels into standard [IptvChannel] models
  Future<List<IptvChannel>> getNormalizedChannels() async {
    final categories = await getCategories();
    final categoryMap = {for (final c in categories) c.id: c.title};

    final channels = await getChannels();
    return List.unmodifiable([
      for (final c in channels)
        IptvChannel(
          id: 'stalker_${c.id}',
          name: c.name,
          streamUrl: c.cmd,
          logo: c.logo,
          group: categoryMap[c.categoryId] ?? 'General',
          category: categoryMap[c.categoryId] ?? '',
          extraMetadata: {
            'stalker_cmd': c.cmd,
            'stalker_number': c.number.toString(),
          },
        ),
    ]);
  }
}
