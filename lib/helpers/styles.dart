String styles(Map<String, String> styles) {
  if (styles.isEmpty) {
    return '';
  }

  final list = <String>[];
  for (final name in styles.keys) {
    final value = styles[name]!;
    list.add(name);
    list.add(':');
    list.add(value);
    list.add(';');
  }

  return list.join();
}
