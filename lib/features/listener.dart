import '../errors/wrapped_exception.dart';
import '../listenable/listenable.dart';
import '../src/package.dart';
import '../virtual_dom/vcomponent.dart';
import '../virtual_dom/vcontext.dart';

/// The [Listener] feature provides functionality to make it possible for
/// components to add listener to the [Listenable].
class Listener {
  static final _key = '$packageName.$Listener';

  ///The [use] method takes as an argument a function to be used as a listener
  ///and adds it to the [Listenable] listeners.
  ///
  /// Also removes the listener when the component is disposed.
  static void use<T>(Listenable listener, void Function() action) {
    return VComponent.run((vComponent) {
      final context = VContext(context: vComponent.context, key: _key);
      final Set<Listenable> listeners = context.init('listeners', () => {});
      if (!listeners.contains(listener)) {
        // ignore: prefer_function_declarations_over_variables
        final h = () {
          try {
            action();
          } catch (e, s) {
            throw WrappedException(
                "An error occurred while executing the listener action on ${listener.runtimeType})' for component '$vComponent'",
                e,
                s);
          }
        };
        listeners.add(listener);
        listener.addListener(h);
        vComponent.addDisposeHandler(vComponent, () {
          listener.removeListener(h);
        });
      }
    });
  }
}
