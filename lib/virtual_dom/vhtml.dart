import 'dart:html';

import 'vnode.dart';

class VHtml extends VNode {
  final Map<String, Object> attributes = {};

  final String html;

  final Map<String, void Function(Event event)> listeners = {};

  final String tagName;

  VHtml(this.tagName, this.html);

  @override
  VNodeKind get kind => VNodeKind.html;

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
      for (final key in attributes.keys) {
        final value = attributes[key]!;
        if (value != false) {
          node1.setAttribute(key, value);
        }
      }

      for (final key in listeners.keys) {
        final listener = listeners[key];
        node1.addEventListener(key, listener);
      }

      _setInnerHtml(node1, html);
      node = node1;
    });
  }

  @override
  String toString() {
    return tagName;
  }

  void _rebuild(VNode newVNode, bool canDispose) {
    key = newVNode.key;
    newVNode = newVNode as VHtml;
    final newAttributes = newVNode.attributes;
    final newListeners = newVNode.listeners;
    updateElement(attributes, newAttributes, listeners, newListeners);
    final newHtml = newVNode.html;
    if (html != newHtml) {
      _setInnerHtml(node as Element, newHtml);
    }
  }

  void _setInnerHtml(Element node, String html) {
    node.setInnerHtml(html, treeSanitizer: NodeTreeSanitizer.trusted);
  }
}
