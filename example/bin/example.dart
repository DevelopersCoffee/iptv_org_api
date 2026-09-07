import 'package:iptv_org_api/iptv_org_api.dart';

void main() async {
  print('Fetching global channels from iptv-org...');
  final client = IptvOrgApiClient();

  final channels = await client.fetchChannels();
  print('Successfully fetched ${channels.length} global channels!');

  final categories = await client.fetchCategories();
  print('Available categories: ${categories.map((IptvOrgCategory c) => c.name).take(5).join(', ')}');
}
