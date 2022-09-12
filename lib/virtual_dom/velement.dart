import 'dart:collection';
import 'dart:html';

import 'vnode.dart';
import 'vnode_entry.dart';
import 'vtree.dart';

class VElement extends VNode {
  final Map<String, Object> attributes = {};

  final LinkedList<VNodeEntry> children = LinkedList();

  final Map<String, void Function(Event event)> listeners = {};

  final String tagName;

  bool _isShadowRootUsed = false;

  ShadowRoot? _shadowRoot;

  VElement(this.tagName);

  bool get isShadowRootUsed => _isShadowRootUsed;

  @override
  VNodeKind get kind => VNodeKind.element;

  ShadowRoot? get shadowRoot => _shadowRoot;

  @override
  void dispose() {
    super.dispose();
    for (final entry in children) {
      final child = entry.vNode;
      child.dispose();
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
      final node1 = document.createElement(tagName);
      if (isShadowRootUsed) {
        _shadowRoot = node1.attachShadow(const {'mode': 'open'});
      }

      for (final key in attributes.keys) {
        final value = attributes[key]!;
        if (value != false) {
          node1.setAttribute(key, value);
        }
      }

      for (final key in listeners.keys) {
        final listener = listeners[key];
        final wrapper = wrapListener(listener);
        node1.addEventListener(key, wrapper);
      }

      for (final entry in children) {
        final child = entry.vNode;
        child.renderNew(parent);
        final node = child.node!;
        if (isShadowRootUsed) {
          shadowRoot!.append(node);
        } else {
          node1.append(node);
        }
      }

      node = node1;
    });
  }

  @override
  String toString() {
    return tagName;
  }

  /// Configures the virtual node to use shadow root.
  void useShadowRoot() {
    _isShadowRootUsed = true;
  }

  void _rebuild(VNode newVNode, bool canDispose) {
    key = newVNode.key;
    newVNode = newVNode as VElement;
    final newAttributes = newVNode.attributes;
    final newListeners = newVNode.listeners;
    updateElement(attributes, newAttributes, listeners, newListeners);
    final oldChildren = children;
    final newChildren = newVNode.children;
    if (oldChildren.isNotEmpty || newChildren.isNotEmpty) {
      final parentNode = isShadowRootUsed ? shadowRoot! : node!;
      final vTree = VTree(this, parentNode);
      vTree.update(oldChildren, newChildren);
    }
  }
}
