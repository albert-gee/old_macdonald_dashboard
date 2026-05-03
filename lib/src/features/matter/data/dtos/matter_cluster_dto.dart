final class MatterClusterDto {
  final String id;
  final String name;
  final List<MatterAttributeDto> attributes;

  const MatterClusterDto({
    required this.id,
    required this.name,
    required this.attributes,
  });
}

final class MatterAttributeDto {
  final String id;
  final String name;

  const MatterAttributeDto({
    required this.id,
    required this.name,
  });
}
