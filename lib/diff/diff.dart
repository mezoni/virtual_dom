import 'dart:collection';

import 'patch.dart';

class Diff {
  /// Computes the differences between the elements of a list and returns a
  /// patch list.
  List<Patch<T>> diff<T extends LinkedListEntry<T>>(
    LinkedList<T> oldList,
    LinkedList<T> newList, {
    required Object? Function(T entry) getKey,
    required bool Function(T x, T y) isEqual,
  }) {
    final result = <Patch<T>>[];
    final oldKeys = <Object, T>{};
    final newKeys = <Object, T>{};
    for (final entry in oldList) {
      final key = getKey(entry);
      if (key != null) {
        if (oldKeys.containsKey(key)) {
          throw StateError('The old list contains a non-unique key: $key');
        }

        oldKeys[key] = entry;
      }
    }

    for (final entry in newList) {
      final key = getKey(entry);
      if (key != null) {
        if (newKeys.containsKey(key)) {
          throw StateError('The new list contains a non-unique key: $key');
        }

        newKeys[key] = entry;
      }
    }

    final insertedKeys =
        newKeys.keys.where((e) => !oldKeys.containsKey(e)).toSet();
    final removedKeys =
        oldKeys.keys.where((e) => !newKeys.containsKey(e)).toSet();
    final moved = <T>{};
    var oldEntry = oldList.isEmpty ? null : oldList.first;
    var newEntry = newList.isEmpty ? null : newList.first;
    while (oldEntry != null || newEntry != null) {
      if (oldEntry == null) {
        final patch = InsertPatch(newValue: newEntry!, oldValue: oldEntry);
        result.add(patch);
        newEntry = newEntry.next;
        continue;
      }

      if (moved.contains(oldEntry)) {
        oldEntry = oldEntry.next;
        continue;
      }

      if (newEntry == null) {
        final patch = RemovePatch(oldValue: oldEntry);
        result.add(patch);
        oldEntry = oldEntry.next;
        continue;
      }

      final newKey = getKey(newEntry);
      if (insertedKeys.contains(newKey)) {
        final patch = InsertPatch(newValue: newEntry, oldValue: oldEntry);
        result.add(patch);
        newEntry = newEntry.next;
        continue;
      }

      final oldKey = getKey(oldEntry);
      if (removedKeys.contains(oldKey)) {
        final patch = RemovePatch(oldValue: oldEntry);
        result.add(patch);
        oldEntry = oldEntry.next;
        continue;
      }

      if (oldKey != null && oldKey == newKey) {
        final patch = UpdatePatch(newValue: newEntry, oldValue: oldEntry);
        result.add(patch);
        oldEntry = oldEntry.next;
        newEntry = newEntry.next;
        continue;
      }

      if (isEqual(oldEntry, newEntry)) {
        if (oldKey != null && oldKeys.containsKey(oldKey)) {
          oldKeys.remove(oldKey);
        }

        final patch = RebuildPatch(newValue: newEntry, oldValue: oldEntry);
        result.add(patch);
        oldEntry = oldEntry.next;
        newEntry = newEntry.next;
        continue;
      }

      if (newKey != null) {
        if (oldKeys.containsKey(newKey)) {
          final oldValue2 = oldKeys[newKey]!;
          final patch = MovePatch(
              newValue: newEntry, oldValue: oldEntry, oldValue2: oldValue2);
          result.add(patch);
          moved.add(oldValue2);
          newEntry = newEntry.next;
          continue;
        }
      }

      final patch = ReplacePatch(newValue: newEntry, oldValue: oldEntry);
      result.add(patch);
      oldEntry = oldEntry.next;
      newEntry = newEntry.next;
    }

    return result;
  }
}
