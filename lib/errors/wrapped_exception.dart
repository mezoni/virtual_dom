class WrappedException {
  final Object exception;

  final String message;

  final StackTrace stackTrace;

  WrappedException(this.message, this.exception, this.stackTrace);

  @override
  String toString() {
    final buffer = <String>[];
    buffer.add('$exception');
    buffer.add('$stackTrace');
    buffer.add('-' * 80);
    buffer.add(message);
    buffer.add('-' * 80);
    return buffer.join('\n');
  }
}
