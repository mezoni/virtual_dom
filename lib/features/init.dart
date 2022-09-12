import '../errors/wrapped_exception.dart';
import '../src/package.dart';
import '../virtual_dom/vcomponent.dart';
import '../virtual_dom/vcontext.dart';

/// The [Init] function provides the functionality to implement "init" and
/// "dispose" methods for the component.
///
/// The implementation of the "dispose" method is optional.
class Init {
  static final _key = '$packageName.$Init';

  /// The [use] method takes the "init" function as an argument. The "init"
  /// function can return a function that will be used as "dispose".
  static void use(void Function()? Function() handler) {
    VComponent.run((VComponent vComponent) {
      return useWithKey(_key, handler);
    });
  }

  /// The [use] method takes a key [key] and the "init" function as an argument.
  /// The "init" function can return a function that will be used as "dispose".
  ///
  /// This method is intended primarily for use by other features to simplify
  /// the process of their implementation.
  static void useWithKey(String key, void Function()? Function() handler) {
    VComponent.run((VComponent vComponent) {
      final context = VContext(context: vComponent.context, key: _key);
      final initialized = context.init(key, () => false);
      if (!initialized) {
        context.set(key, true);
        try {
          final dispose = handler();
          if (dispose != null) {
            vComponent.addDisposeHandler(vComponent, dispose);
          }
        } catch (e, s) {
          throw WrappedException(
              "An error occurred while executing the method '$Init.use()' for component '$vComponent'",
              e,
              s);
        }
      }
    });
  }
}
