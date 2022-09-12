class VContext {
  final String _key;

  final Map<String, Map<String, Object?>> _context;

  VContext({
    required Map<String, Map<String, Object?>> context,
    required String key,
  })  : _context = context,
        _key = key;

  V get<V>(String key) {
    if (_context.containsKey(_key)) {
      final context = _context[_key]!;
      final value = context[key];
      return value as V;
    }

    throw StateError("Context '$_key' not found");
  }

  bool hasKey<K>(K key) {
    if (_context.containsKey(_key)) {
      final context = _context[_key]!;
      return context.containsKey(key);
    }

    return false;
  }

  V init<V>(String key, V Function() init) {
    final context = _context[_key] ??= {};
    if (!context.containsKey(key)) {
      context[key] = init();
    }

    final result = context[key];
    return result as V;
  }

  void set<V>(String key, V value) {
    if (_context.containsKey(_key)) {
      final context = _context[_key]!;
      context[key] = value;
      return;
    }

    throw StateError("Context '$_key' not found");
  }
}
