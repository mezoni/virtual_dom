import '../errors/wrapped_exception.dart';
import '../src/package.dart';
import '../virtual_dom/vcomponent.dart';
import '../virtual_dom/vcontext.dart';
import '../virtual_dom/vrenderer.dart';

/// The [State] feature provides functionality to make it possible to implement
/// state management for components.
class State {
  static final _key = '$packageName.$State';

  /// Returns a function that is intended to be used as a function to change the
  /// state of a component.
  static void Function() change() {
    return VComponent.run((vComponent) {
      return () {
        VRenderer.render(vComponent);
      };
    });
  }

  /// The [get] method takes the state variable name and its initial value and
  /// returns the current value of that variable.
  static T get<T>(String key, T Function() init) {
    return VComponent.run((vComponent) {
      try {
        final context = VContext(context: vComponent.context, key: _key);
        return context.init(key, init);
      } catch (e, s) {
        throw WrappedException(
            "An error occurred while executing the method '$State.get($key)' for component '$vComponent'",
            e,
            s);
      }
    });
  }

  /// The [set] method takes a state variable name and returns a function that
  /// is intended to be used as a function to set the value of a variable.
  static void Function(T value) set<T>(String key) {
    return VComponent.run((vComponent) {
      return (T value) {
        final context = VContext(context: vComponent.context, key: _key);
        final T oldValue = context.get(key);
        if (oldValue != value) {
          context.set(key, value);
          VRenderer.render(vComponent);
        }
      };
    });
  }

  /// Not implemented prior to the implementation of the 'records'
  static Never use<T>(String key, T Function() init) {
    throw UnimplementedError(
        "Not implemented prior to the implementation of the 'records'");
  }
}
