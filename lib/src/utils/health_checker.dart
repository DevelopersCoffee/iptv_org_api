import 'dart:async';
import 'dart:io';
import '../data/models/channel.dart';
import '../data/models/stream_status.dart';

/// Dynamic real-time stream validation and health monitoring engine.
final class IptvHealthChecker {
  IptvHealthChecker({
    Duration timeout = const Duration(seconds: 4),
    HttpClient? httpClient,
  })  : _timeout = timeout,
        _client = httpClient ?? (HttpClient()..connectionTimeout = timeout);

  final Duration _timeout;
  final HttpClient _client;

  /// Verifies a single stream URL's health, measuring latency and checking active codecs/MIME types.
  Future<StreamStatus> verifyStream(String url) async {
    final stopwatch = Stopwatch()..start();
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return StreamStatus(
        isAlive: false,
        errorReason: 'Invalid URI scheme',
        checkedAt: DateTime.now().toUtc(),
      );
    }

    try {
      // First attempt a low-cost HEAD request
      var request = await _client.headUrl(uri).timeout(_timeout);
      var response = await request.close().timeout(_timeout);

      // Fallback to GET range request if HEAD method is unsupported (405 / 501)
      if (response.statusCode == 405 || response.statusCode == 501) {
        request = await _client.getUrl(uri).timeout(_timeout);
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-1024');
        response = await request.close().timeout(_timeout);
      }

      stopwatch.stop();
      final latencyMs = stopwatch.elapsedMilliseconds;
      final statusCode = response.statusCode;
      final contentType = response.headers.value(HttpHeaders.contentTypeHeader) ?? '';

      final isAlive = statusCode >= 200 && statusCode < 400;

      return StreamStatus(
        isAlive: isAlive,
        statusCode: statusCode,
        mimeType: contentType,
        latencyMs: latencyMs,
        checkedAt: DateTime.now().toUtc(),
      );
    } catch (e) {
      stopwatch.stop();
      return StreamStatus(
        isAlive: false,
        errorReason: e.toString(),
        latencyMs: stopwatch.elapsedMilliseconds,
        checkedAt: DateTime.now().toUtc(),
      );
    }
  }

  /// Concurrently probes a collection of channels, yielding updated channel statuses.
  Stream<MapEntry<IptvChannel, StreamStatus>> verifyChannelsConcurrent(
    List<IptvChannel> channels, {
    int concurrency = 5,
  }) async* {
    final controller = StreamController<MapEntry<IptvChannel, StreamStatus>>();
    var index = 0;
    var activeWorkers = 0;

    void spawnNextWorker() {
      if (index >= channels.length) return;
      final currentChannel = channels[index++];
      activeWorkers++;

      verifyStream(currentChannel.streamUrl).then((status) {
        controller.add(MapEntry(currentChannel, status));
        activeWorkers--;
        if (index < channels.length) {
          spawnNextWorker();
        } else if (activeWorkers == 0) {
          controller.close();
        }
      }).catchError((Object err) {
        controller.add(
          MapEntry(
            currentChannel,
            StreamStatus(
              isAlive: false,
              errorReason: err.toString(),
              checkedAt: DateTime.now().toUtc(),
            ),
          ),
        );
        activeWorkers--;
        if (index < channels.length) {
          spawnNextWorker();
        } else if (activeWorkers == 0) {
          controller.close();
        }
      });
    }

    final initialWorkers = channels.length < concurrency ? channels.length : concurrency;
    if (initialWorkers == 0) {
      controller.close();
    } else {
      for (var i = 0; i < initialWorkers; i++) {
        spawnNextWorker();
      }
    }

    yield* controller.stream;
  }
}
