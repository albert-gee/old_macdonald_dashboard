String? Function(String?) matterIntValidator(String label) {
  return (value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$label is required.';
    if (int.tryParse(trimmed) == null) return '$label must be an integer.';
    return null;
  };
}

String? Function(String?) matterRequiredValidator(String label) {
  return (value) =>
      (value?.trim().isEmpty ?? true) ? '$label is required.' : null;
}
