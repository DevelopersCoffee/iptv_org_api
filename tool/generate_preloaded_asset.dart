import 'dart:convert';
import 'dart:io';

/// Edge compute pre-loaded dataset bundler.
/// Downloads static iptv-org JSON tables and generates a pre-indexed offline dataset asset
/// for instant sub-millisecond cold boot speeds inside Flutter mobile & TV apps.
void main() async {
  print('🚀 Starting IPTV offline asset generation...');

  final httpClient = HttpClient();
  final baseUri = Uri.parse('https://iptv-org.github.io/api/');

  Future<List<dynamic>> fetchEndpoint(String filename) async {
    final request = await httpClient.getUrl(baseUri.resolve(filename));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as List<dynamic>;
  }

  try {
    print('  - Fetching channels...');
    final channels = await fetchEndpoint('channels.json');
    print('  - Fetching streams...');
    final streams = await fetchEndpoint('streams.json');
    print('  - Fetching categories...');
    final categories = await fetchEndpoint('categories.json');

    final assetPayload = {
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'channelCount': channels.length,
      'streamCount': streams.length,
      'channels': channels,
      'streams': streams,
      'categories': categories,
    };

    final outputDir = Directory('assets');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final outputFile = File('assets/iptv_preloaded_dataset.json');
    outputFile.writeAsStringSync(jsonEncode(assetPayload));

    print('✅ Pre-loaded dataset asset successfully created at: ${outputFile.path}');
    print('   Size: ${(outputFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
  } catch (e) {
    print('❌ Failed to generate offline dataset asset: $e');
  } finally {
    httpClient.close();
  }
}
