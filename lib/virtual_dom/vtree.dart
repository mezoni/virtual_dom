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

    var oldListWithKeys = false;
    var oldEntry = oldList.isEmpty ? null : oldList.first;
    while (oldEntry != null) {
      final vNode = oldEntry.vNode;
      if (vNode.key != null) {
        oldListWithKeys = true;
        break;
      }

      oldEntry = oldEntry.next;
    }

    if (oldListWithKeys) {
      var newWithKeys = false;
      var newEntry = newList.isEmpty ? null : newList.first;
      while (newEntry != null) {
        final vNode = newEntry.vNode;
        if (vNode.key != null) {
          newWithKeys = true;
          break;
        }

        newEntry = newEntry.next;
      }

      if (newWithKeys) {
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

        return;
      }
    }

    _updateWithoutKeys(oldList, newList);
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

  void _updateWithoutKeys(
      LinkedList<VNodeEntry> oldList, LinkedList<VNodeEntry> newList) {
    var oldEntry = oldList.isEmpty ? null : oldList.first;
    var newEntry = newList.isEmpty ? null : newList.first;
    while (oldEntry != null && newEntry != null) {
      final oldVNode = oldEntry.vNode;
      final newVNode = newEntry.vNode;
      final vNode = oldVNode.render(newVNode, true);
      if (oldVNode != vNode) {
        final newEntry = VNodeEntry(vNode);
        oldEntry.insertBefore(newEntry);
        final next = oldEntry.next;
        oldEntry.unlink();
        oldEntry = next;
      } else {
        oldEntry = oldEntry.next;
      }

      newEntry = newEntry.next;
    }

    if (oldEntry != null) {
      while (oldEntry != null) {
        final vNode = oldEntry.vNode;
        final node = vNode.node!;
        vNode.dispose();
        node.remove();
        final next = oldEntry.next;
        oldEntry.unlink();
        oldEntry = next;
      }
    } else if (newEntry != null) {
      while (newEntry != null) {
        final vNode = newEntry.vNode;
        vNode.renderNew(parent);
        final node = vNode.node!;
        parentNode.append(node);
        final next = newEntry.next;
        newEntry.unlink();
        oldList.add(newEntry);
        newEntry = next;
      }
    }
  }

  static VNodeEntry _createEntry(VNodeEntry entry) {
    final vNode = entry.vNode;
    final result = VNodeEntry(vNode);
    return result;
  }

  static Object? _getKey(VNodeEntry entry) {
    final vNode = entry.vNode;
    return vNode.key;
  }
}
