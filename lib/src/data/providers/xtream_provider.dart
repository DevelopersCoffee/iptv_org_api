import 'dart:convert';
import 'dart:io';
import '../models/channel.dart';
import '../models/xtream.dart';

/// Industrial Xtream Codes IPTV API client and provider.
final class XtreamProvider {
  XtreamProvider({
    required String baseUrl,
    required this.username,
    required this.password,
    HttpClient? httpClient,
  })  : baseUrl = _sanitizeBaseUrl(baseUrl),
        _client = httpClient ?? HttpClient();

  final String baseUrl;
  final String username;
  final String password;
  final HttpClient _client;

  static String _sanitizeBaseUrl(String url) {
    var s = url.trim();
    if (!s.endsWith('/')) s += '/';
    return s;
  }

  Uri _buildApiUri(Map<String, String> queryParams) {
    final params = {
      'username': username,
      'password': password,
      ...queryParams,
    };
    return Uri.parse('${baseUrl}player_api.php').replace(queryParameters: params);
  }

  Future<Map<String, dynamic>> _getJson(Map<String, String> params) async {
    final uri = _buildApiUri(params);
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getJsonList(Map<String, String> params) async {
    final uri = _buildApiUri(params);
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as List<dynamic>;
  }

  /// Authenticates with the Xtream server and returns user account status
  Future<XtreamAccountInfo> authenticate() async {
    final json = await _getJson({});
    return XtreamAccountInfo.fromJson(json);
  }

  /// Fetches live categories from Xtream server
  Future<List<XtreamCategory>> getCategories() async {
    final list = await _getJsonList({'action': 'get_live_categories'});
    return list
        .map((e) => XtreamCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches live streams from Xtream server
  Future<List<XtreamLiveStream>> getLiveStreams({int? categoryId}) async {
    final params = {'action': 'get_live_streams'};
    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }
    final list = await _getJsonList(params);
    return list
        .map((e) => XtreamLiveStream.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Constructs direct media stream URL for a given stream ID
  String buildStreamUrl(int streamId, {String containerExtension = 'm3u8'}) {
    return '$baseUrl$username/$password/$streamId.$containerExtension';
  }

  /// Fetches streams and normalizes them into standard [IptvChannel] models
  Future<List<IptvChannel>> getNormalizedChannels() async {
    final categories = await getCategories();
    final categoryMap = {
      for (final cat in categories) cat.categoryId: cat.categoryName,
    };

    final streams = await getLiveStreams();
    return List.unmodifiable([
      for (final s in streams)
        IptvChannel(
          id: 'xtream_${s.streamId}',
          name: s.name,
          streamUrl: buildStreamUrl(s.streamId),
          logo: s.streamIcon,
          group: categoryMap[s.categoryId] ?? 'General',
          tvgId: s.epgChannelId,
          tvgName: s.name,
          category: categoryMap[s.categoryId] ?? '',
          extraMetadata: {
            'xtream_stream_id': s.streamId.toString(),
            'xtream_stream_type': s.streamType,
          },
        ),
    ]);
  }
}
