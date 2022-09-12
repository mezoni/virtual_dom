import 'dart:html';

import '../components/component.dart';
import '../errors/error_report.dart';
import '../errors/wrapped_exception.dart';
import '../listenable/listenable.dart';
import 'vnode.dart';
import 'vnode_factory.dart';

class VComponent extends VNode {
  static VComponent? current;

  VNode? child;

  final Component component;

  Map<String, Map<String, Object?>> context = {};

  bool dirty = true;

  ValueNotifier<ErrorReport?>? errorReport;

  List<void Function()>? onDispose;

  VComponent(this.component);

  @override
  VNodeKind get kind => VNodeKind.component;

  @override
  Node? get node => child!.node;

  @override
  set node(Node? node) => throw UnsupportedError('set node');

  void addDisposeHandler(VComponent vComponent, void Function() handler) {
    (vComponent.onDispose ??= []).add(handler);
  }

  @override
  void dispose() {
    super.dispose();
    child?.dispose();
    if (onDispose != null) {
      final handlers = onDispose!;
      for (var i = 0; i < handlers.length; i++) {
        final listener = handlers[i];
        try {
          listener();
        } catch (e, s) {
          throw WrappedException(
              "An error occurred while executing the handler 'dispose' for '$this'",
              e,
              s);
        }
      }
    }
  }

  @override
  void rebuild(VNode newVNode, bool canDispose) {
    renderSafely(() {
      _rebuild(newVNode, canDispose);
    });
  }

  @override
  VNode render(VNode newVNode, bool canDispose) {
    return renderSafely(() {
      if (VNode.isEqual(this, newVNode)) {
        _rebuild(newVNode, canDispose);
        return this;
      } else {
        newVNode.renderAndReplace(parent, node!);
        if (canDispose) {
          dispose();
        }

        return newVNode;
      }
    });
  }

  @override
  void renderNew(VNode? parent) {
    renderSafely(() {
      this.parent = parent;
      final child1 = _renderNew();
      child1.renderNew(this);
      child = child1;
    });
  }

  @override
  String toString() {
    return '${component.runtimeType}';
  }

  void _rebuild(VNode newVNode, bool canDispose) {
    key = newVNode.key;
    if (dirty) {
      dirty = false;
      final oldChild = child!;
      final newChild = _renderNew();
      child = oldChild.render(newChild, canDispose);
    }
  }

  VNode _renderNew() {
    return VComponent.runWith(this, (vComponent) {
      vComponent.dirty = false;
      final component = vComponent.component;
      final data = component.render();
      final vNode = VNodeFactory.createVNode(data);
      return vNode;
    });
  }

  static T run<T>(T Function(VComponent vComponent) action) {
    final current = VComponent.current;
    if (current == null) {
      throw StateError('The current component is undefined');
    }

    try {
      final result = action(current);
      return result;
    } catch (e, s) {
      throw WrappedException(
          "An error occurred while executing action '$current.run'", e, s);
    } finally {
      VComponent.current = current;
    }
  }

  static T runWith<T>(
      VComponent vComponent, T Function(VComponent vComponent) action) {
    final current = VComponent.current;
    VComponent.current = vComponent;
    try {
      final result = action(vComponent);
      return result;
    } catch (e, s) {
      throw WrappedException(
          "An error occurred while executing action '$vComponent.runWith'",
          e,
          s);
    } finally {
      VComponent.current = current;
    }
  }
}
