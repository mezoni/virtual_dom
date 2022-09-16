import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:virtual_dom/components/component.dart';
import 'package:virtual_dom/errors/error_report.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_value_watcher.dart';
import 'package:virtual_dom/helpers/h.dart';
import 'package:virtual_dom/helpers/mount.dart';
import 'package:virtual_dom/helpers/vkey.dart';
import 'package:virtual_dom/listenable/listenable.dart';

import 'error_reporter.dart';

void main(List<String> args) {
  final app = document.getElementById('app')!;
  mount(app, _App());
}

final errorReport = ValueNotifier<ErrorReport?>(null);

Future _delay() => Future.delayed(Duration(seconds: 1));

class _App extends Component {
  @override
  Object render() {
    final items = ValueNotifier<List<_Item>>([]);
    items.value = List.generate(10000, (i) => _Item());
    return h('div', [
      ErrorReporter(errorReport),
      _LongListWidget(items),
    ]);
  }
}

class _Info extends Component {
  final ValueNotifier<String> text;

  _Info(this.text) : super(key: text);

  @override
  Object render() {
    useValueWatcher(text);
    return text.value;
  }
}

class _Item {
  static int _id = 0;

  final int id = _id++;

  @override
  String toString() {
    return 'Item $id';
  }
}

class _LongListWidget extends Component {
  final ValueNotifier<List<_Item>> items;

  _LongListWidget(this.items) : super(key: items);

  @override
  Object render() {
    final changeState = State.change();
    final count = State.get('count', () => _Ref(1000));
    final nonUiInfo = State.get('nonUiInfo', () => ValueNotifier(''));
    final uiInfo = State.get('uiInfo', () => ValueNotifier(''));
    final items1 = items.value;
    final list = [];
    for (var i = 0; i < items1.length; i++) {
      final item = items1[i];
      final li = h('li', '$item');
      list.add(vKey(item.id, li));
    }

    void measure() {
      // This timer will be executed after the component is rendered.
      final start = DateTime.now();
      Timer.run(() {
        final now = DateTime.now();
        final elapsed =
            (now.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000;
        uiInfo.value = 'Render time: $elapsed sec';
      });
    }

    void insert(Event event) {
      if (count.value <= 0) {
        nonUiInfo.value = '';
        return;
      }

      event.preventDefault();
      Timer.run(() async {
        await ErrorReport.runAsync(() async {
          final count1 = count.value;
          nonUiInfo.value = 'Inserting $count1 random elements to List';
          await _delay();
          final sw = Stopwatch();
          sw.start();
          if (items1.isEmpty) {
            for (var i = 0; i < count1; i++) {
              items1.add(_Item());
            }
          } else {
            final random = Random();
            for (var i = 0; i < count1; i++) {
              final length = items1.length;
              if (length < 2) {
                items1.add(_Item());
              } else {
                final index = random.nextInt(length - 1);
                items1.insert(index, _Item());
              }
            }
          }

          sw.stop();
          items.notifyListeners();
          nonUiInfo.value =
              'Inserted $count1 random elements to List in ${sw.elapsedMilliseconds / 1000} sec';
          await _delay();
          changeState();
          measure();
        });
      });
    }

    void remove(Event event) {
      event.preventDefault();
      if (items1.isEmpty) {
        nonUiInfo.value = '';
        return;
      }

      Timer.run(() async {
        var count1 = count.value;
        if (count1 > items1.length) {
          count1 = items1.length;
          count.value = count1;
        }

        nonUiInfo.value = 'Removing $count1 random elements from List';
        await _delay();
        final sw = Stopwatch();
        sw.start();
        final random = Random();
        for (var i = 0; i < count1; i++) {
          final length = items1.length;
          final index = random.nextInt(length);
          items1.removeAt(index);
        }

        sw.stop();
        items.notifyListeners();
        nonUiInfo.value =
            'Removed $count1 random elements from List in ${sw.elapsedMilliseconds / 1000} sec';
        await _delay();
        changeState();
        measure();
      });
    }

    void onChangeCount(Event event) {
      final target = event.target as TextInputElement;
      final value = int.tryParse('${target.value}') ?? 0;
      count.value = value;
      event.preventDefault();
    }

    return h('div', [
      h('p', [
        'Non UI action:',
        _Info(nonUiInfo),
      ]),
      h('p', [
        'UI action:',
        _Info(uiInfo),
      ]),
      h('p', 'Items count: ${items1.length}'),
      h('p', [
        'Count',
        h('input', {
          'type': 'text',
          'value': '${count.value}',
        }, {
          'change': onChangeCount
        }),
      ]),
      h('p', [
        h('button', 'Insert', {'click': insert}),
        h('button', 'Remove', {'click': remove}),
      ]),
      h('ul', list),
    ]);
  }
}

class _Ref<T> {
  T value;

  _Ref(this.value);
}
