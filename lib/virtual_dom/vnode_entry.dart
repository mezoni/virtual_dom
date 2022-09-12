import 'dart:collection';

import 'vnode.dart';

/// Represents a linked list entry of virtual nodes.
class VNodeEntry extends LinkedListEntry<VNodeEntry> {
  VNode vNode;

  VNodeEntry(this.vNode);

  @override
  String toString() {
    return '($vNode)';
  }
}
