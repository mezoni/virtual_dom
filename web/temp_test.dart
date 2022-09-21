// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:html';

import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_error_report.dart';
import 'package:virtual_dom/helpers/h.dart';
import 'package:virtual_dom/helpers/mount.dart';
import 'package:virtual_dom/virtual_dom.dart';

import 'error_reporter.dart';

void main(List<String> args) {
  Timer(Duration(seconds: 2), () {
    final app = document.getElementById('app')!;
    mount(app, _App());
  });
}

class _App extends Component {
  @override
  Object render() {
    final errorReport = useErrorReport();
    return h('div', [
      ErrorReporter(errorReport),
      _Test(),
    ]);
  }
}

class _Test extends Component {
  @override
  Object render() {
    final step = State.get('step', () => 0);
    final setStep = State.set<int>('step');
    switch (step) {
      case 0:
        setStep(5);
        return h('div', [
          'Text2',
          h('h1', 'Text2'),
        ]);
      case 5:
        setStep(10);
        return h(
          'div',
          [h('h1', 'Text2'), 'Text2'],
        );
      case 10:
        setStep(20);
        return h('div', 'Text1');
      case 20:
        setStep(30);
        return h('div', '');
      default:
        return '';
    }
  }
}
