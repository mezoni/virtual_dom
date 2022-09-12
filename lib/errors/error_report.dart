import '../listenable/listenable.dart';

class ErrorReport {
  final Object? error;

  final errorReport = ValueNotifier<ErrorReport?>(null);

  final StackTrace? stackTrace;

  ErrorReport(this.error, this.stackTrace);
}
