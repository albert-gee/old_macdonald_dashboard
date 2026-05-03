final class ThreadRole {
  final String value;

  const ThreadRole([this.value = '']);

  String get displayName {
    if (value.isEmpty || value.toLowerCase() == 'unknown') return 'Unknown';
    return value;
  }
}
