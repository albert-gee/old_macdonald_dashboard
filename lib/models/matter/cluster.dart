class Cluster {
  final String id;
  final String name;
  final List<Attribute> attributes;

  Cluster({required this.id, required this.name, required this.attributes});
}

class Attribute {
  final String id;
  final String name;

  Attribute({required this.id, required this.name});
}
