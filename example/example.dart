import 'dart:convert';
import 'dart:html';

import 'package:virtual_dom/components/component.dart';
import 'package:virtual_dom/errors/error_report.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_error_report.dart';
import 'package:virtual_dom/features/use_value_watcher.dart';
import 'package:virtual_dom/helpers/el.dart';
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

    return el('div', children: [
      _ErrorReporter(errorReport),
      el('div', children: [
        'Last rendered: ${DateTime.now()}',
        el('p',
            child: 'Parent counter (will throw an exception if count > 10)'),
        el('p', child: 'Counter: $count'),
        el('p', child: el('button', child: 'Click', onClick: click)),
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

    return el('div', children: [
      'Last rendered: ${DateTime.now()}',
      el('p', child: 'Child counter'),
      el('p', child: 'Counter: $count'),
      el('p', child: el('button', child: 'Click', onClick: click)),
      el('p', child: el('button', child: 'Throw error', onClick: throwError)),
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
      return el('div', attributes: {'display': 'none'});
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
      return el(
        'div',
        attributes: {'style': style},
        child: el('div',
            children: [for (final line in lines) el('div', child: line)]),
      );
    }
  }
}
