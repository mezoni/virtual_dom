import 'dart:convert';
import 'dart:html';

import 'package:virtual_dom/components/component.dart';
import 'package:virtual_dom/errors/error_report.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_error_report.dart';
import 'package:virtual_dom/features/use_value_watcher.dart';
import 'package:virtual_dom/helpers/h.dart';
import 'package:virtual_dom/helpers/mount.dart';
import 'package:virtual_dom/helpers/styles.dart';
import 'package:virtual_dom/listenable/listenable.dart';

void main(List<String> args) {
  final app = document.getElementById('app')!;
  mount(app, _App());
}

class _App extends Component {
  @override
  Object render() {
    final errorReport = useErrorReport();
    final count = State.get('count', () => 0);
    final setCount = State.set<int>('count');
    void click(Event event) {
      setCount(count + 1);
    }

    if (count > 10) {
      throw StateError('Oh, counter greater than 10');
    }

    return h('div', [
      _ErrorReporter(errorReport),
      h('div', [
        'Last rendered: ${DateTime.now()}',
        h('p', 'Parent counter (will throw an exception if count > 10)'),
        h('p', 'Counter: $count'),
        h('p', h('button', 'Click', {'click': click})),
        _CounterWidget(),
      ])
    ]);
  }
}

class _CounterWidget extends Component {
  @override
  Object render() {
    final count = State.get('count', () => 0);
    final setCount = State.set<int>('count');
    void click(Event event) {
      setCount(count + 1);
    }

    void throwError(Event event) {
      throw StateError('Some error ${DateTime.now()}');
    }

    return h('div', [
      'Last rendered: ${DateTime.now()}',
      h('p', 'Child counter'),
      h('p', 'Counter: $count'),
      h('p', h('button', 'Click', {'click': click})),
      h('p', h('button', 'Throw error', {'click': throwError})),
    ]);
  }
}

class _ErrorReporter extends Component {
  final ValueNotifier<ErrorReport?> errorReport;

  _ErrorReporter(this.errorReport) : super(key: errorReport);

  @override
  Object render() {
    useValueWatcher(errorReport);
    final errorReport1 = errorReport.value;
    if (errorReport1 == null) {
      return h('div', {'display': 'none'});
    } else {
      final lines = const LineSplitter().convert('${errorReport1.error}');
      lines.addAll(const LineSplitter().convert('${errorReport1.stackTrace}'));
      final style = styles({
        'background-color': 'black',
        'color': 'red',
        'display': 'block',
        'margin': '8px',
        'padding': '8px',
      });
      return h(
        'div',
        {'style': style},
        h('div', [for (final line in lines) h('div', line)]),
      );
    }
  }
}
