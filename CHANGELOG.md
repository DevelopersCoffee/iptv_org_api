## 2.1.0

* **Stalker Portal Middleware Support**: Introduced `StalkerProvider` and `connectStalker()` for MAC-authenticated Stalker middleware servers (`/stalker_portal/server/load.php`).
* **Preloaded Dataset Asset Generator**: Added `tool/generate_preloaded_asset.dart` to bundle static datasets into indexed offline JSON assets for sub-millisecond cold boot speeds in mobile & smart TV apps.
* **Expanded Example Suite**: Enhanced `example/bin/example.dart` showcasing multi-source M3U ingestion, EPG schedule lookup, health checks, and player state streams.

## 2.0.0

* **Enterprise IPTV SDK Transition**: Expanded scope from a passive REST client into an Enterprise-Grade IPTV Core SDK across iOS, Android, macOS, Windows, Linux, and Web.
* **Unified SDK Facade (`IptvClient`)**: Centralized entrypoint coordinating ingestion, health checking, EPG synchronization, persistence, and video player controls.
* **Memory-Efficient Stream Ingestion**: Introduced `MemoryEfficientM3uParser` using asynchronous Dart streams to process 100,000+ streams under 15MB RAM footprint.
* **XMLTV EPG Support**: Introduced `XmltvParser` and `EpgProgram` models for parsing program timelines and calculating live broadcast progress.
* **Xtream Codes Compatibility**: Added `XtreamProvider` supporting authentication, live categories, streams, VOD, and direct URL generation (`/player_api.php`).
* **Real-Time Stream Health Engine**: Introduced `IptvHealthChecker` for concurrent HEAD/range network probing, latency timing, MIME verification, and status monitoring.
* **Local Persistence Layer**: Added `IptvLocalStorage` and `MemoryLocalStorage` with indexed search, category filtering, favorites, and live EPG program lookup.
* **Universal Player Abstraction**: Introduced `IptvPlayerController` and `IptvVideoSurface` for cross-platform video surface rendering.

## 1.0.0

* Initial release of `iptv_org_api`.
* Typed relational Dart models for all 13 iptv-org datasets (channels, feeds, logos, streams, guides, categories, languages, countries, subdivisions, cities, regions, timezones, blocklist).
* In-memory ETag caching transport layer.
* Isolate-backed JSON parsing using `run_off_main`.
