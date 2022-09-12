import '../errors/wrapped_exception.dart';
import '../listenable/listenable.dart';
import '../src/package.dart';
import '../virtual_dom/vcomponent.dart';
import '../virtual_dom/vcontext.dart';
import '../virtual_dom/vnode.dart';
import '../virtual_dom/vrenderer.dart';

/// The [InheritedValue] feature provides functionality to make it possible
/// for child components to access a "value" declared in a parent component.
///
/// By "value" is meant a value (object) whose changes need to be tracked.
class InheritedValue {
  static final _key = '$packageName.$InheritedValue';

  /// Adds an inherited "value" and listens for its changes. Used in the parent
  /// component.
  ///
  /// Also removes the listener when the component is disposed.
  static ValueNotifier<T> add<T>(String key, T Function() init) {
    return VComponent.run((vComponent) {
      final context = VContext(context: vComponent.context, key: _key);
      final Map<String, ValueNotifier> notifiers =
          context.init('notifiers', () => {});
      if (!notifiers.containsKey(key)) {
        try {
          final value = init();
          final notifier = ValueNotifier(value);
          // ignore: prefer_function_declarations_over_variables
          final h = () {
            VRenderer.render(vComponent);
          };

          notifiers[key] = notifier;
          notifier.addListener(h);
          vComponent.addDisposeHandler(vComponent, () {
            notifier.removeListener(h);
          });
          return notifier;
        } catch (e, s) {
          throw WrappedException(
              "An error occurred while executing the method '$InheritedValue.add($key)' for component '$vComponent'",
              e,
              s);
        }
      } else {
        final notifier = notifiers[key];
        return notifier as ValueNotifier<T>;
      }
    });
  }

  /// Allows to get an inherited "value" and add listener for its changes. Used
  /// in child components.
  ///
  /// Also removes the listener when the component is disposed.
  static ValueNotifier<T>? get<T>(String key) {
    return VComponent.run((vComponent) {
      try {
        final context = VContext(context: vComponent.context, key: _key);
        final Map<String, ValueNotifier> notifiers =
            context.init('notifiers', () => {});
        if (!notifiers.containsKey(key)) {
          VNode? parent = vComponent;
          while (parent != null) {
            if (parent.kind == VNodeKind.component) {
              parent = parent as VComponent;
              final parentContext =
                  VContext(context: parent.context, key: _key);
              if (parentContext.hasKey('notifiers')) {
                final Map<String, ValueNotifier> parentNotifiers =
                    parentContext.get('notifiers');
                if (parentNotifiers.containsKey(key)) {
                  final notifier = parentNotifiers[key] as ValueNotifier<T>;
                  // ignore: prefer_function_declarations_over_variables
                  final h = () {
                    VRenderer.render(vComponent);
                  };

                  notifiers[key] = notifier;
                  notifier.addListener(h);
                  vComponent.addDisposeHandler(vComponent, () {
                    notifier.removeListener(h);
                  });

                  return notifier;
                }
              }
            }

            parent = parent.parent;
          }

          return null;
        } else {
          final notifier = notifiers[key];
          return notifier as ValueNotifier<T>;
        }
      } catch (e, s) {
        throw WrappedException(
            "An error occurred while executing the method '$InheritedValue.get($key)' for component '$vComponent'",
            e,
            s);
      }
    });
  }
}
