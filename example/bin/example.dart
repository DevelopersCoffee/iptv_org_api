import 'package:iptv_org_api/iptv_org_api.dart';

void main() async {
  print('====================================================');
  print('🚀 Enterprise IPTV Core SDK Demo (iptv_org_api 2.1.0)');
  print('====================================================\n');

  final sdk = IptvClient();

  // 1. Ingest sample M3U Playlist
  print('1️⃣  Ingesting sample M3U Playlist...');
  const sampleM3u = '''
#EXTM3U
#EXTINF:-1 tvg-id="CNN.us" group-title="News" tvg-logo="http://logos.com/cnn.png",CNN International
http://stream.example.com/cnn/live.m3u8
#EXTINF:-1 tvg-id="BBC.uk" group-title="General" tvg-logo="http://logos.com/bbc.png",BBC News HD
http://stream.example.com/bbc/live.m3u8
''';

  final channels = await sdk.loadM3uPlaylist(sampleM3u);
  print('   Loaded ${channels.length} channels from M3U playlist.');
  for (final c in channels) {
    print('   - [${c.group}] ${c.name} (${c.streamUrl})');
  }

  // 2. Ingest EPG Program Schedules
  print('\n2️⃣  Syncing XMLTV EPG Schedules...');
  const sampleXmltv = '''
<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <programme start="20260919120000 +0000" stop="20260919180000 +0000" channel="CNN.us">
    <title>Global World News Live</title>
    <desc>Round-the-clock live international reporting.</desc>
    <category>News</category>
  </programme>
</tv>
''';

  final programs = await sdk.loadXmltvEpg(sampleXmltv);
  print('   Parsed ${programs.length} EPG program entries.');
  final liveProgram = await sdk.storage.getLiveProgram('CNN.us');
  if (liveProgram != null) {
    print('   Currently Broadcasting: ${liveProgram.title} (${liveProgram.category})');
  }

  // 3. Search & Filter local storage
  print('\n3️⃣  Searching cached channels...');
  final searchResults = await sdk.searchChannels('News');
  print('   Found ${searchResults.length} channels matching query "News".');

  // 4. Stream Health Probing
  print('\n4️⃣  Verifying stream health...');
  final healthStatus = await sdk.verifyStreamHealth(channels.first.streamUrl);
  print('   Stream Health Check: isAlive=${healthStatus.isAlive}, status=${healthStatus.statusCode}');

  // 5. Play Channel via Universal Player Controller
  print('\n5️⃣  Initializing Player Surface & Playing Stream...');
  sdk.playerController.valueStream.listen((state) {
    print('   [Player Event] Status: ${state.status.name} | Source: ${state.currentSource}');
  });

  await sdk.playChannel(channels.first);
  await Future<void>.delayed(const Duration(milliseconds: 200));

  await sdk.dispose();
  print('\n✅ Enterprise IPTV SDK Demo complete!');
}
