import 'dart:convert';
import 'dart:typed_data';

import 'package:run_off_main/run_off_main.dart';

import 'cache.dart';
import 'models.dart';
import 'transport.dart';

const _offMainDecodeThresholdBytes = 50 * 1024;
final _defaultBaseUri = Uri.parse('https://iptv-org.github.io/api/');

/// Strongly typed client for fetching and caching the `iptv-org` global dataset.
final class IptvOrgApiClient {
  /// Creates a new [IptvOrgApiClient].
  IptvOrgApiClient({
    IptvOrgTransport? transport,
    IptvOrgCache? cache,
    Uri? baseUri,
    this.cacheTtl = const Duration(hours: 24),
    DateTime Function()? now,
  }) : transport = transport ?? IoIptvOrgTransport(),
       cache = cache ?? MemoryIptvOrgCache(),
       baseUri = baseUri ?? _defaultBaseUri,
       _now = now ?? DateTime.now {
    if (!this.baseUri.hasScheme || !this.baseUri.path.endsWith('/')) {
      throw ArgumentError.value(
        this.baseUri,
        'baseUri',
        'must be absolute and end with /',
      );
    }
  }

  /// Factory constructor for IO environment with custom timeout.
  factory IptvOrgApiClient.io({
    Duration timeout = const Duration(seconds: 30),
    IptvOrgCache? cache,
    Uri? baseUri,
    Duration cacheTtl = const Duration(hours: 24),
  }) {
    return IptvOrgApiClient(
      transport: IoIptvOrgTransport(timeout: timeout),
      cache: cache,
      baseUri: baseUri,
      cacheTtl: cacheTtl,
    );
  }

  /// Network transport instance.
  final IptvOrgTransport transport;

  /// Cache storage instance.
  final IptvOrgCache cache;

  /// Base API endpoint URI.
  final Uri baseUri;

  /// Time-to-live duration for cached entries.
  final Duration cacheTtl;

  final DateTime Function() _now;

  /// Closes underlying transport resources.
  void close() => transport.close();

  /// Fetches global channels.
  Future<List<IptvOrgChannel>> fetchChannels() =>
      _fetch(IptvOrgEndpoint.channels);

  /// Fetches channel feeds.
  Future<List<IptvOrgFeed>> fetchFeeds() => _fetch(IptvOrgEndpoint.feeds);

  /// Fetches channel logos.
  Future<List<IptvOrgLogo>> fetchLogos() => _fetch(IptvOrgEndpoint.logos);

  /// Fetches live stream endpoints.
  Future<List<IptvOrgStream>> fetchStreams() => _fetch(IptvOrgEndpoint.streams);

  /// Fetches EPG guide references.
  Future<List<IptvOrgGuide>> fetchGuides() => _fetch(IptvOrgEndpoint.guides);

  /// Fetches channel categories.
  Future<List<IptvOrgCategory>> fetchCategories() =>
      _fetch(IptvOrgEndpoint.categories);

  /// Fetches catalog languages.
  Future<List<IptvOrgLanguage>> fetchLanguages() =>
      _fetch(IptvOrgEndpoint.languages);

  /// Fetches catalog countries.
  Future<List<IptvOrgCountry>> fetchCountries() =>
      _fetch(IptvOrgEndpoint.countries);

  /// Fetches country subdivisions.
  Future<List<IptvOrgSubdivision>> fetchSubdivisions() =>
      _fetch(IptvOrgEndpoint.subdivisions);

  /// Fetches catalog cities.
  Future<List<IptvOrgCity>> fetchCities() => _fetch(IptvOrgEndpoint.cities);

  /// Fetches geographical regions.
  Future<List<IptvOrgRegion>> fetchRegions() => _fetch(IptvOrgEndpoint.regions);

  /// Fetches timezones.
  Future<List<IptvOrgTimezone>> fetchTimezones() =>
      _fetch(IptvOrgEndpoint.timezones);

  /// Fetches blocklist entries.
  Future<List<IptvOrgBlocklistEntry>> fetchBlocklist() =>
      _fetch(IptvOrgEndpoint.blocklist);

  /// Fetches a complete relational snapshot of all datasets concurrently.
  Future<IptvOrgSnapshot> fetchSnapshot() async {
    final channels = fetchChannels();
    final feeds = fetchFeeds();
    final logos = fetchLogos();
    final streams = fetchStreams();
    final guides = fetchGuides();
    final categories = fetchCategories();
    final languages = fetchLanguages();
    final countries = fetchCountries();
    final subdivisions = fetchSubdivisions();
    final cities = fetchCities();
    final regions = fetchRegions();
    final timezones = fetchTimezones();
    final blocklist = fetchBlocklist();

    return IptvOrgSnapshot(
      channels: await channels,
      feeds: await feeds,
      logos: await logos,
      streams: await streams,
      guides: await guides,
      categories: await categories,
      languages: await languages,
      countries: await countries,
      subdivisions: await subdivisions,
      cities: await cities,
      regions: await regions,
      timezones: await timezones,
      blocklist: await blocklist,
    );
  }

  Future<List<T>> _fetch<T>(IptvOrgEndpoint endpoint) async {
    final now = _now().toUtc();
    final cached = await cache.read(endpoint.name);
    if (cached != null && now.difference(cached.fetchedAt) <= cacheTtl) {
      return (await _decode(endpoint, cached.body)).cast<T>();
    }

    final headers = <String, String>{'accept-encoding': 'gzip'};
    if (cached?.etag case final etag?) headers['if-none-match'] = etag;
    if (cached?.lastModified case final modified?) {
      headers['if-modified-since'] = modified;
    }

    try {
      final response = await transport.get(
        IptvOrgRequest(
          uri: baseUri.resolve(endpoint.fileName),
          headers: Map.unmodifiable(headers),
        ),
      );
      if (response.statusCode == 304 && cached != null) {
        final refreshed = cached.refreshedAt(now);
        await cache.write(endpoint.name, refreshed);
        return (await _decode(endpoint, refreshed.body)).cast<T>();
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw IptvOrgHttpException(response.statusCode, endpoint.name);
      }

      try {
        final decoded = await _decode(endpoint, response.body);
        await cache.write(
          endpoint.name,
          IptvOrgCacheEntry(
            body: response.body,
            fetchedAt: now,
            etag: response.header('etag'),
            lastModified: response.header('last-modified'),
          ),
        );
        return decoded.cast<T>();
      } on FormatException {
        if (cached != null) {
          return (await _decode(endpoint, cached.body)).cast<T>();
        }
        rethrow;
      }
    } on Object {
      if (cached != null) {
        return (await _decode(endpoint, cached.body)).cast<T>();
      }
      rethrow;
    }
  }

  Future<List<Object?>> _decode(
    IptvOrgEndpoint endpoint,
    Uint8List body,
  ) async {
    final input = (endpoint.index, body);
    final decoded = body.length > _offMainDecodeThresholdBytes
        ? await runOffMain(() => _decodeEndpointBytes(input))
        : _decodeEndpointBytes(input);
    return (decoded as List).cast<Object?>();
  }
}

Object _decodeEndpointBytes((int, Uint8List) input) {
  final endpoint = IptvOrgEndpoint.values[input.$1];
  return decodeIptvOrgEndpoint(endpoint, jsonDecode(utf8.decode(input.$2)));
}
