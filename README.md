# `iptv_org_api`

[![pub package](https://img.shields.io/pub/v/iptv_org_api.svg)](https://pub.dev/packages/iptv_org_api)
[![CI](https://github.com/DevelopersCoffee/iptv_org_api/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/iptv_org_api/actions)
[![GitHub Pages](https://img.shields.io/badge/Docs-GitHub%20Pages-38bdf8)](https://developerscoffee.github.io/iptv_org_api/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Enterprise-Grade IPTV Core SDK for Flutter & Dart. Handles multi-source stream ingestion (M3U/M3U8, XMLTV EPG, Xtream Codes, iptv-org), real-time stream health monitoring, local persistence, and cross-platform video player abstractions.

Part of the **[DevelopersCoffee](https://developerscoffee.com)** open-source ecosystem.

🌐 **Interactive Documentation & Live Preview**: [https://developerscoffee.github.io/iptv_org_api/](https://developerscoffee.github.io/iptv_org_api/)

---

## 🚀 Key Features

* ⚡ **Memory-Efficient Stream Ingestion**: Stream-reads massive M3U/M3U8 playlists (100k+ channels) under 15MB RAM.
* 📺 **Unified EPG Parser (XMLTV)**: Parses program schedules, timeline sync, and live progress indicators.
* 📡 **Xtream Codes Compatibility**: Connects directly to industrial Xtream Codes backends (`/player_api.php`) for live streams, VOD, and categories.
* 🩺 **Dynamic Stream Health Monitoring**: Concurrent HEAD/range HTTP probing for latency timing and status verification.
* 💾 **Local Persistence & Caching**: Indexed search, category filtering, favorites, and offline EPG program lookup.
* 🎬 **Universal Player Surface Abstraction**: Unified player controller (`IptvPlayerController`) across iOS, Android, macOS, Windows, Linux, and Web.

---

## 📦 Installation

```yaml
dependencies:
  iptv_org_api: ^2.0.0
```

---

## 💡 Quick Start Usage

### 1. Ingest M3U Playlist & Search Channels

```dart
import 'package:iptv_org_api/iptv_org_api.dart';

void main() async {
  final sdk = IptvClient();

  const m3uContent = '''
#EXTM3U
#EXTINF:-1 tvg-id="CNN.us" group-title="News",CNN HD
http://stream.example.com/cnn/live.m3u8
''';

  final channels = await sdk.loadM3uPlaylist(m3uContent);
  print('Loaded ${channels.length} channels');

  final newsChannels = await sdk.searchChannels('News');
  print('Found ${newsChannels.length} news channels');
}
```

### 2. Stream Health Probing

```dart
final healthChecker = IptvHealthChecker();
final status = await healthChecker.verifyStream('http://stream.example.com/live.m3u8');

if (status.isAlive) {
  print('Stream active! Latency: ${status.latencyMs}ms, MIME: ${status.mimeType}');
}
```

### 3. Connect to Xtream Codes Backend

```dart
final xtream = await sdk.connectXtream(
  baseUrl: 'http://xtream.server:8080',
  username: 'user123',
  password: 'pass456',
);

final streams = await xtream.getLiveStreams();
print('Active Xtream Streams: ${streams.length}');
```

---

## License

MIT License - see [LICENSE](LICENSE) for details. Maintained with ❤️ by **[DevelopersCoffee](https://developerscoffee.com)**.
