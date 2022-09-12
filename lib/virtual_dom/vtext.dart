import 'dart:html';

import 'vnode.dart';

class VText extends VNode {
  final String text;

  VText(this.text);

  @override
  VNodeKind get kind => VNodeKind.text;

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
        rebuild(newVNode, canDispose);
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
      node = Text(text);
    });
  }

  @override
  String toString() {
    return text;
  }

  void _rebuild(VNode newVNode, bool canDispose) {
    key = newVNode.key;
    return;
  }
}
