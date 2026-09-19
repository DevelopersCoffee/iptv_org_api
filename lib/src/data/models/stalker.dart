import 'package:meta/meta.dart';

/// User profile details returned by Stalker Portal middleware handshake.
@immutable
final class StalkerProfile {
  const StalkerProfile({
    required this.mac,
    required this.phone,
    required this.status,
    required this.token,
  });

  final String mac;
  final String phone;
  final int status;
  final String token;

  factory StalkerProfile.fromJson(Map<String, dynamic> json, String mac) {
    return StalkerProfile(
      mac: mac,
      phone: json['phone']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '1') ?? 1,
      token: json['token']?.toString() ?? '',
    );
  }
}

/// Category item from Stalker Portal API.
@immutable
final class StalkerCategory {
  const StalkerCategory({
    required this.id,
    required this.title,
    required this.alias,
  });

  final String id;
  final String title;
  final String alias;

  factory StalkerCategory.fromJson(Map<String, dynamic> json) {
    return StalkerCategory(
      id: json['id']?.toString() ?? '0',
      title: json['title']?.toString() ?? 'General',
      alias: json['alias']?.toString() ?? '',
    );
  }
}

/// Channel item from Stalker Portal API.
@immutable
final class StalkerChannel {
  const StalkerChannel({
    required this.id,
    required this.name,
    required this.number,
    required this.cmd,
    required this.categoryId,
    required this.logo,
  });

  final String id;
  final String name;
  final int number;
  final String cmd;
  final String categoryId;
  final String logo;

  factory StalkerChannel.fromJson(Map<String, dynamic> json) {
    return StalkerChannel(
      id: json['id']?.toString() ?? '0',
      name: json['name']?.toString() ?? 'Unknown Channel',
      number: int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      cmd: json['cmd']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '0',
      logo: json['logo']?.toString() ?? '',
    );
  }
}
