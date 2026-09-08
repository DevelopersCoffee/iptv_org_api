import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// A HTTP request envelope for `iptv-org` API calls.
final class IptvOrgRequest {
  /// Creates a new [IptvOrgRequest].
  const IptvOrgRequest({required this.uri, this.headers = const {}});

  /// Target request URI.
  final Uri uri;

  /// HTTP headers map.
  final Map<String, String> headers;
}

/// A HTTP response envelope for `iptv-org` API calls.
final class IptvOrgResponse {
  /// Creates a new [IptvOrgResponse].
  const IptvOrgResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  /// Response HTTP status code.
  final int statusCode;

  /// Raw response body bytes.
  final Uint8List body;

  /// Response headers map.
  final Map<String, String> headers;

  /// Returns the header value for [name] (case-insensitive).
  String? header(String name) => headers[name.toLowerCase()];
}

/// Abstract network transport interface for `iptv-org` API requests.
abstract interface class IptvOrgTransport {
  /// Executes a GET request and returns an [IptvOrgResponse].
  Future<IptvOrgResponse> get(IptvOrgRequest request);

  /// Closes any underlying network client resources.
  void close() {}
}

/// `dart:io` transport implementation for VM, CLI, and mobile/desktop platforms.
final class IoIptvOrgTransport implements IptvOrgTransport {
  /// Creates a new [IoIptvOrgTransport].
  IoIptvOrgTransport({
    HttpClient? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? HttpClient(),
       _ownsClient = client == null;

  final HttpClient _client;
  final bool _ownsClient;

  /// Timeout duration for requests.
  final Duration timeout;

  @override
  Future<IptvOrgResponse> get(IptvOrgRequest request) async {
    final ioRequest = await _client.getUrl(request.uri).timeout(timeout);
    request.headers.forEach(ioRequest.headers.set);
    final ioResponse = await ioRequest.close().timeout(timeout);
    final builder = BytesBuilder(copy: false);
    await for (final bytes in ioResponse.timeout(timeout)) {
      builder.add(bytes);
    }
    final headers = <String, String>{};
    ioResponse.headers.forEach((name, values) {
      headers[name.toLowerCase()] = values.join(',');
    });
    return IptvOrgResponse(
      statusCode: ioResponse.statusCode,
      body: builder.takeBytes(),
      headers: Map.unmodifiable(headers),
    );
  }

  @override
  void close() {
    if (_ownsClient) {
      _client.close(force: true);
    }
  }
}

/// Exception thrown when an HTTP request fails with a non-2xx status code.
final class IptvOrgHttpException implements IOException {
  /// Creates a new [IptvOrgHttpException].
  const IptvOrgHttpException(this.statusCode, this.endpoint);

  /// The HTTP status code.
  final int statusCode;

  /// The target endpoint name.
  final String endpoint;

  @override
  String toString() =>
      'IptvOrgHttpException: HTTP $statusCode while fetching $endpoint';
}
