final class MatterAttribute {
  final String id;
  final String name;

  const MatterAttribute({
    required this.id,
    required this.name,
  });

  int get numericId {
    final normalized = id.trim().toLowerCase();
    if (normalized.startsWith('0x')) {
      return int.tryParse(normalized.substring(2), radix: 16) ?? 0;
    }
    return int.tryParse(normalized) ?? 0;
  }
}
