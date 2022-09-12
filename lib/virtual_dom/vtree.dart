import 'dart:collection';
import 'dart:html';

import '../diff/diff.dart';
import '../diff/patch.dart';
import '../diff/patcher.dart';
import 'velement.dart';
import 'vnode.dart';
import 'vnode_entry.dart';

class VTree {
  final Node parentNode;

  final VElement parent;

  Set<VNode> _removed = const {};

  VTree(this.parent, this.parentNode);

  void update(LinkedList<VNodeEntry> oldList, LinkedList<VNodeEntry> newList) {
    if (oldList.isEmpty && newList.isEmpty) {
      return;
    }

    final diff = Diff();
    final patches =
        diff.diff(oldList, newList, getKey: _getKey, isEqual: _isEqual);
    _removed = {};
    _patch(patches, oldList);
    if (_removed.isNotEmpty) {
      for (final element in _removed) {
        element.dispose();
      }

      _removed = const {};
    }
  }

  void _apply(Patch<VNodeEntry> patch) {
    switch (patch.kind) {
      case PatchKind.insert:
        patch = patch as InsertPatch<VNodeEntry>;
        _applyInsert(patch.oldValue, patch.newValue);
        break;
      case PatchKind.move:
        patch = patch as MovePatch<VNodeEntry>;
        _applyMove(patch.oldValue, patch.oldValue2, patch.newValue);
        break;
      case PatchKind.rebuild:
        patch = patch as RebuildPatch<VNodeEntry>;
        _applyRebuild(patch.oldValue, patch.newValue);
        break;
      case PatchKind.remove:
        patch = patch as RemovePatch<VNodeEntry>;
        _applyRemove(patch.oldValue);
        break;
      case PatchKind.replace:
        patch = patch as ReplacePatch<VNodeEntry>;
        _applyReplace(patch.oldValue, patch.newValue);
        break;
      case PatchKind.update:
        patch = patch as UpdatePatch<VNodeEntry>;
        _applyUpdate(patch.oldValue, patch.newValue);
        break;
    }
  }

  void _applyInsert(VNodeEntry? oldEntry, VNodeEntry newEntry) {
    final newVNode = newEntry.vNode;
    newVNode.renderNew(parent);
    final node = newVNode.node!;
    newEntry.vNode = newVNode;
    if (oldEntry != null) {
      final oldVNode = oldEntry.vNode;
      final oldNode = oldVNode.node!;
      parentNode.insertBefore(node, oldNode);
    } else {
      parentNode.append(node);
    }
  }

  void _applyMove(
      VNodeEntry oldEntry, VNodeEntry oldEntry2, VNodeEntry newEntry) {
    final oldVNode = oldEntry.vNode;
    final oldNode = oldVNode.node!;
    final oldVNode2 = oldEntry2.vNode;
    final oldNode2 = oldVNode2.node!;
    final newVNode = newEntry.vNode;
    final vNode = oldVNode2.render(newVNode, false);
    if (oldVNode2 == vNode) {
      _removed.remove(oldVNode2);
    } else {
      _removed.add(oldVNode2);
    }

    final node = vNode.node!;
    oldEntry2.vNode = vNode;
    parentNode.insertBefore(node, oldNode);
    if (oldNode2 != node) {
      oldNode2.remove();
    }
  }

  void _applyRebuild(VNodeEntry oldEntry, VNodeEntry newEntry) {
    final oldVNode = oldEntry.vNode;
    final newVNode = newEntry.vNode;
    oldVNode.rebuild(newVNode, false);
    _removed.remove(oldVNode);
  }

  void _applyRemove(VNodeEntry oldEntry) {
    final oldVNode = oldEntry.vNode;
    final oldNode = oldVNode.node!;
    oldNode.remove();
    _removed.add(oldVNode);
  }

  void _applyReplace(VNodeEntry oldEntry, VNodeEntry newEntry) {
    final oldVNode = oldEntry.vNode;
    final oldNode = oldVNode.node!;
    final newVNode = newEntry.vNode;
    newVNode.renderNew(parent);
    final node = newVNode.node!;
    oldNode.replaceWith(node);
    _removed.add(oldVNode);
  }

  void _applyUpdate(VNodeEntry oldEntry, VNodeEntry newEntry) {
    final oldVNode = oldEntry.vNode;
    final newVNode = newEntry.vNode;
    final oldNode = oldVNode.node!;
    final vNode = oldVNode.render(newVNode, false);
    if (oldVNode != vNode) {
      final newNode = vNode.node!;
      if (oldVNode.kind != VNodeKind.component) {
        oldVNode.node = newNode;
      }

      oldEntry.vNode = vNode;
      oldNode.replaceWith(newNode);
      _removed.add(oldVNode);
    } else {
      _removed.remove(oldVNode);
    }
  }

  bool _isEqual(VNodeEntry entry1, VNodeEntry entry2) {
    return VNode.isEqual(entry1.vNode, entry2.vNode);
  }

  void _patch(List<Patch<VNodeEntry>> patches, LinkedList<VNodeEntry> list) {
    final patcher = Patcher();
    patcher.patch<VNodeEntry>(
      patches,
      list,
      apply: _apply,
      createEntry: _createEntry,
    );
  }

  static VNodeEntry _createEntry(VNodeEntry entry) {
    final vNode = entry.vNode;
    final result = VNodeEntry(vNode);
    return result;
  }

  static Object? _getKey(VNodeEntry entry) {
    var vNode = entry.vNode;
    if (vNode.kind != VNodeKind.element) {
      return null;
    }

    vNode = vNode as VElement;
    return vNode.key;
  }
}
