# `iptv_org_api`

[![pub package](https://img.shields.io/pub/v/iptv_org_api.svg)](https://pub.dev/packages/iptv_org_api)
[![CI](https://github.com/DevelopersCoffee/iptv_org_api/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/iptv_org_api/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A fully typed, cached, isolate-parsed relational Dart client for the public [iptv-org](https://github.com/iptv-org/iptv) global dataset (channels, feeds, logos, streams, guides, categories, languages, countries, timezones, and blocklists).

---

## Features

* **13 Relational Datasets**: Strongly typed models for `channels`, `streams`, `feeds`, `logos`, `guides`, `categories`, `languages`, `countries`, `subdivisions`, `cities`, `regions`, `timezones`, and `blocklist`.
* **Isolate Offloading**: Uses `run_off_main` to decode large dataset JSON responses away from the UI thread.
* **ETag Caching**: HTTP ETag caching transport to minimize redundant network requests.
* **Relational Indexing**: Build fast in-memory indexes connecting channels to their respective streams, logos, and EPG guides.

---

## Installation

```yaml
dependencies:
  iptv_org_api: ^1.0.0
```

---

## Usage

```dart
import 'package:iptv_org_api/iptv_org_api.dart';

void main() async {
  final client = IptvOrgApiClient();

  // Fetch typed channel catalog
  final channels = await client.fetchChannels();
  print('Loaded ${channels.length} global channels!');

  // Fetch streams
  final streams = await client.fetchStreams();
  print('Loaded ${streams.length} live stream endpoints!');
}
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.
