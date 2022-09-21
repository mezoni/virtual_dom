import 'dart:html';

import '../errors/error_report.dart';
import '../errors/wrapped_exception.dart';
import '../listenable/listenable.dart';
import 'vcomponent.dart';
import 'velement.dart';
import 'vhtml.dart';

/// Virtual node.
abstract class VNode {
  bool disposed = false;

  Object? error;

  bool hasError = false;

  Object? key;

  Node? node;

  VNode? parent;

  StackTrace? stackTrace;

  Expando<Function(Event event)>? _listenerWrappers;

  VNodeKind get kind;

  void dispose() {
    disposed = true;
  }

  ValueNotifier<ErrorReport?>? findErrorReport() {
    VNode? current = this;
    while (current != null) {
      if (current.kind == VNodeKind.component) {
        current = current as VComponent;
        if (current.errorReport != null) {
          return current.errorReport;
        }
      }

      current = current.parent;
    }

    return null;
  }

  void rebuild(VNode newVNode, bool canDispose);

  /// Renders an existing (this) virtual node or a newly created [newVNode]
  /// node.
  ///
  /// If the existing node and the newly created node are equivalent, then the
  /// existing node is rendered, otherwise a new node is rendered, replacing the
  /// existing node.
  ///
  /// Rendering an existing node does not necessarily mean an actual rendering.
  ///
  /// For example, if an existing [VComponent] node is rendered that does not
  /// need to be rendered, no action will be taken.
  VNode render(VNode newVNode, bool canDispose);

  /// Renders a newly created (this) virtual node and replaces the content of
  /// [node] with the new content.
  void renderAndReplace(VNode? parent, Node node) {
    renderNew(parent);
    node.replaceWith(this.node!);
  }

  /// Renders the newly created virtual node.
  void renderNew(VNode? parent);

  T renderSafely<T>(T Function() render) {
    if (hasError) {
      _reportError();
    }

    try {
      return render();
    } catch (e, s) {
      hasError = true;
      error = e;
      stackTrace = s;
      _reportError();
    }
  }

  void updateElement(
      Map<String, Object> oldAttributes,
      Map<String, Object> newAttributes,
      final Map<String, void Function(Event event)> oldListeners,
      final Map<String, void Function(Event event)> newListeners) {
    final node1 = node as Element;
    final keys = {...oldAttributes.keys, ...newAttributes.keys};
    for (final key in keys) {
      final oldValue = oldAttributes[key];
      final newValue = newAttributes[key];
      if (oldValue != newValue) {
        if (newValue == null || newValue == false) {
          node1.removeAttribute(key);
          oldAttributes.remove(key);
        } else {
          node1.setAttribute(key, newValue);
          oldAttributes[key] = newValue;
        }
      }
    }

    if (oldListeners.isNotEmpty) {
      for (final key in oldListeners.keys) {
        final listener = oldListeners[key];
        final wrapper = wrapListener(listener);
        node1.removeEventListener(key, wrapper);
      }

      oldListeners.clear();
    }

    if (newListeners.isNotEmpty) {
      for (final key in newListeners.keys) {
        final listener = newListeners[key];
        final wrapper = wrapListener(listener);
        node1.addEventListener(key, wrapper);
      }

      oldListeners.addAll(newListeners);
    }
  }

  Function(Event event)? wrapListener(Function(Event event)? listener) {
    if (listener == null) {
      return listener;
    }

    final errorReport = findErrorReport();
    if (errorReport != null) {
      _listenerWrappers ??= Expando();
      final listenerWrappers = _listenerWrappers!;
      var wrapper = listenerWrappers[listener];
      if (wrapper == null) {
        // ignore: prefer_function_declarations_over_variables
        final h = (Event event) {
          try {
            listener(event);
          } catch (e, s) {
            errorReport.value = ErrorReport(e, s);
            rethrow;
          }
        };
        wrapper = h;
        listenerWrappers[listener] = h;
      }

      return wrapper;
    }

    return listener;
  }

  Never _reportError() {
    try {
      throw WrappedException(
          'Rendering error: $this, ${DateTime.now()}', error!, stackTrace!);
    } catch (e, s) {
      final errorReport = findErrorReport();
      if (errorReport != null) {
        errorReport.value = ErrorReport(e, s);
      } else {
        ErrorReport.global.value = ErrorReport(e, s);
      }

      final this1 = this;
      if (this1 is VComponent) {
        this1.dirty = false;
      }

      rethrow;
    }
  }

  static bool isEqual(VNode vNode1, VNode vNode2) {
    switch (vNode1.kind) {
      case VNodeKind.component:
        if (vNode2.kind != VNodeKind.component) {
          return false;
        }

        vNode1 = vNode1 as VComponent;
        vNode2 = vNode2 as VComponent;
        final component1 = vNode1.component;
        final component2 = vNode2.component;
        return component1.runtimeType == component2.runtimeType &&
            component1.key == component2.key;
      case VNodeKind.element:
        if (vNode2.kind != VNodeKind.element) {
          return false;
        }

        vNode1 = vNode1 as VElement;
        vNode2 = vNode2 as VElement;
        return vNode1.tagName == vNode2.tagName &&
            vNode1.isShadowRootUsed == vNode2.isShadowRootUsed;
      case VNodeKind.html:
        if (vNode2.kind != VNodeKind.html) {
          return false;
        }

        vNode1 = vNode1 as VHtml;
        vNode2 = vNode2 as VHtml;
        return vNode1.tagName == vNode2.tagName;
      case VNodeKind.text:
        return vNode2.kind == VNodeKind.text;
    }
  }
}

/// Kinds of the virtual nodes.
enum VNodeKind { component, element, html, text }
