import '../errors/wrapped_exception.dart';
import '../src/package.dart';
import '../virtual_dom/vcomponent.dart';
import '../virtual_dom/vcontext.dart';
import '../virtual_dom/vnode.dart';

/// The [InheritedProperty] feature provides functionality to make it possible
/// for child components to access a "property" declared in a parent component.
///
/// By "property" is meant a value (object) whose changes do not need to be
/// tracked.
class InheritedProperty {
  static final _key = '$packageName.$InheritedProperty';

  /// Adds an inherited "property". Used in the parent component.
  static T add<T>(String key, T Function() init) {
    return VComponent.run((vComponent) {
      final context = VContext(context: vComponent.context, key: _key);
      if (!context.hasKey(key)) {
        try {
          final value = context.init(key, init);
          return value;
        } catch (e, s) {
          throw WrappedException(
              "An error occurred while executing the method '$InheritedProperty.add($key)' for component '$vComponent'",
              e,
              s);
        }
      } else {
        final value = context.get(key);
        return value as T;
      }
    });
  }

  /// Allows to find an inherited "property".
  ///
  /// This method does a lookup every time and is therefore not fast and should
  /// only be used in special cases.
  static T? find<T>(String key) {
    return VComponent.run((vComponent) {
      try {
        final context = VContext(context: vComponent.context, key: _key);
        if (context.hasKey(key)) {
          return context.get(key);
        }

        VNode? parent = vComponent;
        while (parent != null) {
          if (parent.kind == VNodeKind.component) {
            parent = parent as VComponent;
            final parentContext = VContext(context: parent.context, key: _key);
            if (parentContext.hasKey(key)) {
              return parentContext.get(key);
            }
          }

          parent = parent.parent;
        }

        return null;
      } catch (e, s) {
        throw WrappedException(
            "An error occurred while executing the method '$InheritedProperty.find($key)' for component '$vComponent'",
            e,
            s);
      }
    });
  }

  /// Allows to get an inherited "property". Used in child components.
  static T get<T>(String key) {
    return VComponent.run((vComponent) {
      try {
        final context = VContext(context: vComponent.context, key: _key);
        if (!context.hasKey(key)) {
          VNode? parent = vComponent;
          while (parent != null) {
            if (parent.kind == VNodeKind.component) {
              parent = parent as VComponent;
              final parentContext =
                  VContext(context: parent.context, key: _key);
              if (parentContext.hasKey(key)) {
                final T value = parentContext.get(key);
                return value;
              }
            }

            parent = parent.parent;
          }

          throw StateError("The property '$key' not found");
        } else {
          final value = context.get<T>(key);
          return value;
        }
      } catch (e, s) {
        throw WrappedException(
            "An error occurred while executing the method '$InheritedProperty.get($key)' for component '$vComponent'",
            e,
            s);
      }
    });
  }
}
