import '../errors/error_report.dart';
import '../listenable/listenable.dart';
import '../virtual_dom/vcomponent.dart';

ValueNotifier<ErrorReport?> useErrorReport() {
  return VComponent.run((vComponent) {
    vComponent.errorReport ??= ValueNotifier(null);
    return vComponent.errorReport!;
  });
}
