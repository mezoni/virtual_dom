import 'dart:async';
import 'dart:html';

import 'package:virtual_dom/components/component.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_error_report.dart';
import 'package:virtual_dom/helpers/h.dart';
import 'package:virtual_dom/helpers/mount.dart';
import 'package:virtual_dom/helpers/vhtml.dart';

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
        Timer(Duration(seconds: 2), () {
          setStep(1);
        });
        return h('div', [
          _Component1('Red text 1', 'red'),
          _Component2('Text 1'),
        ]);
      case 1:
        Timer(Duration(seconds: 2), () {
          setStep(2);
        });
        return h('div', [
          _Component1('Red text 2', 'red'),
          _Component2('Text 2'),
        ]);
      default:
        return h('div', [
          _Component1('Brown text 3', 'brown'),
          _Component2('Text 3'),
        ]);
    }
  }
}

class _Component1 extends Component {
  final String color;

  final String text;

  _Component1(this.text, this.color) : super(key: '$text#$color');

  @override
  Object render() {
    final style = '''
.specialColor {
  color: $color
}''';

    return h('div', [
      vHtml('style', style),
      h('div', h('div', {'class': 'specialColor'}, text)),
    ])
      ..useShadowRoot();
  }
}

class _Component2 extends Component {
  final String text;

  _Component2(this.text) : super(key: text);

  @override
  Object render() {
    return h('div', [
      h('div', h('div', {'class': 'specialColor'}, text)),
    ]);
  }
}
