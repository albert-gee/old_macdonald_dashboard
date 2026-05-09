import 'matter_attribute.dart';

final class MatterCluster {
  final String id;
  final String name;
  final List<MatterAttribute> attributes;

  const MatterCluster({
    required this.id,
    required this.name,
    required this.attributes,
  });

  int get numericId {
    final normalized = id.trim().toLowerCase();
    if (normalized.startsWith('0x')) {
      return int.tryParse(normalized.substring(2), radix: 16) ?? 0;
    }
    return int.tryParse(normalized) ?? 0;
  }
}
