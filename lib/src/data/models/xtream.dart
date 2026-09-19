import 'package:meta/meta.dart';

/// Account information returned by Xtream Codes `/player_api.php`.
@immutable
final class XtreamAccountInfo {
  const XtreamAccountInfo({
    required this.username,
    required this.status,
    required this.expDate,
    required this.isTrial,
    required this.activeConnections,
    required this.maxConnections,
    required this.allowedOutputFormats,
  });

  final String username;
  final String status;
  final DateTime? expDate;
  final bool isTrial;
  final int activeConnections;
  final int maxConnections;
  final List<String> allowedOutputFormats;

  factory XtreamAccountInfo.fromJson(Map<String, dynamic> json) {
    final userInfo = json['user_info'] as Map<String, dynamic>? ?? json;
    final expStr = userInfo['exp_date']?.toString();
    DateTime? exp;
    if (expStr != null && expStr != 'null' && expStr.isNotEmpty) {
      final timestamp = int.tryParse(expStr);
      if (timestamp != null) {
        exp = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    }

    return XtreamAccountInfo(
      username: userInfo['username']?.toString() ?? '',
      status: userInfo['status']?.toString() ?? 'Active',
      expDate: exp,
      isTrial: userInfo['is_trial']?.toString() == '1',
      activeConnections:
          int.tryParse(userInfo['active_cons']?.toString() ?? '0') ?? 0,
      maxConnections:
          int.tryParse(userInfo['max_connections']?.toString() ?? '1') ?? 1,
      allowedOutputFormats: List<String>.from(
        userInfo['allowed_output_formats'] as List? ?? ['m3u8', 'ts'],
      ),
    );
  }
}

/// Category item from Xtream Codes API.
@immutable
final class XtreamCategory {
  const XtreamCategory({
    required this.categoryId,
    required this.categoryName,
    this.parentId = 0,
  });

  final int categoryId;
  final String categoryName;
  final int parentId;

  factory XtreamCategory.fromJson(Map<String, dynamic> json) {
    return XtreamCategory(
      categoryId:
          int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? 'General',
      parentId: int.tryParse(json['parent_id']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Live Stream entry from Xtream Codes API.
@immutable
final class XtreamLiveStream {
  const XtreamLiveStream({
    required this.streamId,
    required this.name,
    required this.streamType,
    required this.streamIcon,
    required this.epgChannelId,
    required this.categoryId,
    required this.customSid,
    required this.directSource,
  });

  final int streamId;
  final String name;
  final String streamType;
  final String streamIcon;
  final String epgChannelId;
  final int categoryId;
  final String customSid;
  final String directSource;

  factory XtreamLiveStream.fromJson(Map<String, dynamic> json) {
    return XtreamLiveStream(
      streamId: int.tryParse(json['stream_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Unknown Stream',
      streamType: json['stream_type']?.toString() ?? 'live',
      streamIcon: json['stream_icon']?.toString() ?? '',
      epgChannelId: json['epg_channel_id']?.toString() ?? '',
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      customSid: json['custom_sid']?.toString() ?? '',
      directSource: json['direct_source']?.toString() ?? '',
    );
  }
}
