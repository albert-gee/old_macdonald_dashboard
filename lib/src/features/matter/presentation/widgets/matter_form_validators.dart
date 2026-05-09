String? Function(String?) matterIntValidator(String label) {
  return (value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$label is required.';
    if (int.tryParse(trimmed) == null) return '$label must be an integer.';
    return null;
  };
}

String? Function(String?) matterUnsignedDecimalStringValidator(String label) {
  return (value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$label is required.';
    if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(trimmed)) {
      return '$label must be an unsigned decimal integer.';
    }
    return null;
  };
}

String? Function(String?) matterRequiredValidator(String label) {
  return (value) =>
      (value?.trim().isEmpty ?? true) ? '$label is required.' : null;
}
