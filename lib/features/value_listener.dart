import '../errors/wrapped_exception.dart';
import '../listenable/listenable.dart';
import '../src/package.dart';
import '../virtual_dom/vcomponent.dart';
import '../virtual_dom/vcontext.dart';

/// The [ValueNotifier] feature provides functionality to make it possible for
/// components to add listener to the [ValueNotifier].
class ValueListener {
  static final _key = '$packageName.$ValueListener';

  ///The [use] method takes as an argument a function to be used as a listener
  ///and adds it to the [ValueNotifier] listeners.
  ///
  /// Also removes the listener when the component is disposed.
  static void use<T>(ValueNotifier<T> notifier, void Function(T value) action) {
    return VComponent.run((vComponent) {
      final context = VContext(context: vComponent.context, key: _key);
      final Set<ValueNotifier> notifiers = context.init('notifiers', () => {});
      if (!notifiers.contains(notifier)) {
        // ignore: prefer_function_declarations_over_variables
        final h = () {
          try {
            action(notifier.value);
          } catch (e, s) {
            throw WrappedException(
                "An error occurred while executing the value listener action on ${notifier.runtimeType})' for component '$vComponent'",
                e,
                s);
          }
        };
        notifiers.add(notifier);
        notifier.addListener(h);
        vComponent.addDisposeHandler(vComponent, () {
          notifier.removeListener(h);
        });
      }
    });
  }
}
