import 'dart:collection';

import 'patch.dart';

class Patcher {
  /// Applies patches to a list of items.
  void patch<T extends LinkedListEntry<T>>(
    List<Patch<T>> patches,
    LinkedList<T> list, {
    required void Function(Patch<T> patch) apply,
    required T Function(T newValue) createEntry,
  }) {
    var entry = list.isEmpty ? null : list.first;
    for (var i = 0; i < patches.length; i++) {
      var patch = patches[i];
      switch (patch.kind) {
        case PatchKind.insert:
          patch = patch as InsertPatch<T>;
          apply(patch);
          final newValue = patch.newValue;
          final newEntry = createEntry(newValue);
          if (entry != null) {
            entry.insertBefore(newEntry);
          } else {
            list.add(newEntry);
          }

          break;
        case PatchKind.move:
          patch = patch as MovePatch<T>;
          apply(patch);
          final oldValue2 = patch.oldValue2;
          if (oldValue2.list != null) {
            oldValue2.unlink();
          }

          entry!.insertBefore(oldValue2);
          break;
        case PatchKind.rebuild:
          patch = patch as RebuildPatch<T>;
          apply(patch);
          entry = entry!.next;
          break;
        case PatchKind.remove:
          patch = patch as RemovePatch<T>;
          apply(patch);
          final next = entry!.next;
          entry.unlink();
          entry = next;
          break;
        case PatchKind.replace:
          patch = patch as ReplacePatch<T>;
          apply(patch);
          final newValue = patch.newValue;
          final newEntry = createEntry(newValue);
          entry!.insertBefore(newEntry);
          final next = entry.next;
          entry.unlink();
          entry = next;
          break;
        case PatchKind.update:
          patch = patch as UpdatePatch<T>;
          apply(patch);
          entry = entry!.next;
          break;
      }
    }
  }
}
