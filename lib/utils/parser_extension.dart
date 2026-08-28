extension ParserExtension on String {
  // ignore: strict_top_level_inference
  toType(Type type) {
    switch (type) {
      // ignore: type_literal_in_constant_pattern
      case String:
        return toString();
      // ignore: type_literal_in_constant_pattern
      case int:
        return int.parse(toString());
      default:
        return toString();
    }
  }
}
