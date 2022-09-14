import '../listenable/listenable.dart';

class ErrorReport {
  static ValueNotifier<ErrorReport?> global = ValueNotifier(null);

  final Object? error;

  final errorReport = ValueNotifier<ErrorReport?>(null);

  final StackTrace? stackTrace;

  ErrorReport(this.error, this.stackTrace);

  static T run<T>(T Function() f) {
    try {
      return f();
    } catch (e, s) {
      global.value = ErrorReport(e, s);
      rethrow;
    }
  }

  static Future<T> runAsync<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e, s) {
      global.value = ErrorReport(e, s);
      rethrow;
    }
  }
}
