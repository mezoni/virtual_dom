import 'dart:collection';
import 'dart:math';

import 'package:test/test.dart';
import 'package:virtual_dom/diff/diff.dart';
import 'package:virtual_dom/diff/patch.dart';
import 'package:virtual_dom/diff/patcher.dart';

void main() {
  _test();
}

const _report1 = false;

const _report2 = false;

List<String> _generateKeys(int count) {
  final random = Random();
  final keys = <String>{};
  while (true) {
    if (keys.length == count) {
      break;
    }

    if (random.nextBool()) {
      final value = random.nextInt(count);
      final key = 'k$value';
      keys.add(key);
    } else {
      final value = random.nextInt(count);
      final key = '$value';
      keys.add(key);
    }
  }

  return keys.toList();
}

Object? _getKey(_StringEntry entry) {
  final value = entry.value;
  if (!value.startsWith('k')) {
    return null;
  }

  return value;
}

bool _isEqual(_StringEntry x, _StringEntry y) {
  return x.value == y.value;
}

void _patch(List<Patch<_StringEntry>> patches, LinkedList<_StringEntry> list) {
  final patcher = Patcher();
  patcher.patch<_StringEntry>(
    patches,
    list,
    apply: (patch) {},
    createEntry: (newValue) => _StringEntry(newValue.value),
  );
}

void _test() {
  test('Diff/Patch', () {
    final data = <List<List<String>>>[
      [[], []],
      [
        ['k1'],
        []
      ],
      [
        [],
        ['k1']
      ],
      [
        ['k1', 'k2', 'k3'],
        ['k1', 'k2', 'k3'],
      ],
      [
        ['k3'],
        ['k1', 'k2', 'k3'],
      ],
      [
        ['k3', 'k4'],
        ['k1', 'k2', 'k3'],
      ],
      [
        ['k3', 'k4', 'k5'],
        ['k1', 'k2', 'k3'],
      ],
      [
        ['k1', 'k2', 'k3'],
        ['k1', 'k3', 'k2'],
      ],
      [
        ['k1', 'k2', 'k3'],
        ['k1', 'k3', 'k2', 'K4'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k1', 'k4', 'k3', 'k2', 'k5'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k5', 'k4', 'k3', 'k2', 'k1'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k2', 'k1', 'k4', 'k3', 'k5'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k5', 'k1', 'k2', 'k3', 'k4'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k2', 'k3', 'k4', 'k5', 'k1'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k2', 'k4', 'k5'],
      ],
      [
        ['k1', 'k2', 'k3', 'k4', 'k5'],
        ['k1', 'k2', 'k3', 'k6', 'k7', 'k4', 'k5'],
      ],
      [
        ['k1', 'a', 'k2', 'b', 'k3', 'c', 'k4', 'd', 'k5'],
        ['k1', 'a', 'k2', 'b', 'k3', 'c', 'k4', 'd', 'k5'],
      ],
      [
        ['k1', 'a', 'k2', 'b', 'k3', 'c', 'k4', 'd', 'k5'],
        ['k1', 'd', 'k2', 'c', 'k3', 'b', 'k4', 'a', 'k5'],
      ],
      [
        ['a', 'k1', 'b', 'k2', 'c', 'k3', 'd', 'k4', 'e', 'k5'],
        ['b', 'k1', 'c', 'k2', 'd', 'k3', 'e', 'k4', 'a', 'k5'],
      ],
      [
        ['a', 'k1', 'b'],
        ['b', 'c'],
      ],
    ];
    for (var i = 0; i < data.length; i++) {
      final element = data[i];
      final list1 = element[0];
      final list2 = element[1];
      final oldList = LinkedList<_StringEntry>();
      final newList = LinkedList<_StringEntry>();
      for (var i = 0; i < list1.length; i++) {
        final element = list1[i];
        final entry = _StringEntry(element);
        oldList.add(entry);
      }

      for (var i = 0; i < list2.length; i++) {
        final element = list2[i];
        final entry = _StringEntry(element);
        newList.add(entry);
      }

      final diff = Diff();
      final patches =
          diff.diff(oldList, newList, getKey: _getKey, isEqual: _isEqual);
      _patch(patches, oldList);
      final result = oldList.map((e) => e.value);
      expect(result, list2);
      if (_report1) {
        print(list1);
        print(oldList);
        print(patches);
        print('-' * 16);
      }
    }

    final random = Random();
    final sw = Stopwatch();
    final sw2 = Stopwatch();
    sw.start();
    var totalCycles = 0;
    var totalCount = 0;
    while (true) {
      if (sw.elapsed.inSeconds > 30) {
        break;
      }

      totalCycles++;
      final count1 = random.nextInt(25);
      final count2 = random.nextInt(25);
      final list1 = _generateKeys(count1);
      final list2 = _generateKeys(count2);
      final oldList = LinkedList<_StringEntry>();
      final newList = LinkedList<_StringEntry>();
      for (var i = 0; i < list1.length; i++) {
        final element = list1[i];
        final entry = _StringEntry(element);
        oldList.add(entry);
      }

      for (var i = 0; i < list2.length; i++) {
        final element = list2[i];
        final entry = _StringEntry(element);
        newList.add(entry);
      }

      totalCount += max(count1, count2);
      sw2.start();
      final diff = Diff();
      final patches =
          diff.diff(oldList, newList, getKey: _getKey, isEqual: _isEqual);
      _patch(patches, oldList);
      sw2.stop();
      final result = oldList.map((e) => e.value);
      expect(result, list2);
    }

    if (_report2) {
      print('Total cycles: $totalCycles');
      print('Total count: $totalCount');
      print(
          'Count per second: ${totalCount / (sw2.elapsedMilliseconds / 1000)}');
    }
  });
}

class _StringEntry extends LinkedListEntry<_StringEntry> {
  String value;

  _StringEntry(this.value);

  @override
  String toString() {
    return value;
  }
}
