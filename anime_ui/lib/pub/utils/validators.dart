String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return '必填';
  return null;
}
