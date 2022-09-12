// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_error_report.dart';
import 'package:virtual_dom/helpers/h.dart';
import 'package:virtual_dom/helpers/mount.dart';
import 'package:virtual_dom/helpers/vkey.dart';
import 'package:virtual_dom/virtual_dom.dart';
import 'package:virtual_dom/virtual_dom/vcomponent.dart';

import 'error_reporter.dart';

void main(List<String> args) {
  Timer(Duration(seconds: 2), () {
    final test = document.getElementById('app')!;
    mount(test, _App());
  });
}

final _random = Random();

List<Object> _getChildren(List<String> html) {
  const maxCount = 25;
  final count = _random.nextInt(maxCount);
  final keys = <String>{};
  final list = <Object>[];
  for (var i = 0; i < count; i++) {
    switch (_random.nextInt(9)) {
      case 0:
        const text = 'Text1';
        if (_random.nextBool()) {
          var key = '';
          while (true) {
            final n = _random.nextInt(maxCount);
            key = 'k$n';
            if (keys.add(key)) {
              break;
            }
          }

          list.add(vKey(key, text));
        } else {
          list.add(text);
        }

        html.add(text);
        break;
      case 1:
        const text = 'Text2';
        if (_random.nextBool()) {
          var key = '';
          while (true) {
            final n = _random.nextInt(maxCount);
            key = 'k$n';
            if (keys.add(key)) {
              break;
            }
          }

          list.add(vKey(key, text));
        } else {
          list.add(text);
        }

        html.add(text);
        break;
      case 2:
        list.add(h('div', 'Text1'));
        html.add('<div>Text1</div>');
        break;
      case 3:
        list.add(h('div', 'Text2'));
        html.add('<div>Text2</div>');
        break;
      case 4:
        list.add(h('h1', 'Text1'));
        html.add('<h1>Text1</h1>');
        break;
      case 5:
        list.add(h('h1', 'Text2'));
        html.add('<h1>Text2</h1>');
        break;
      case 6:
        var key = '';
        while (true) {
          final n = _random.nextInt(maxCount);
          key = 'k$n';
          if (keys.add(key)) {
            break;
          }
        }

        list.add(vKey(key, h('div', {'key': key}, 'Text1')));
        html.add('<div key="$key">Text1</div>');
        break;
      case 7:
        var key = '';
        while (true) {
          final n = _random.nextInt(maxCount);
          key = 'k$n';
          if (keys.add(key)) {
            break;
          }
        }

        list.add(vKey(key, h('h1', {'key': key}, 'Text2')));
        html.add('<h1 key="$key">Text2</h1>');
        break;
      case 8:
        final component = _getComponent();
        if (_random.nextBool()) {
          var key = '';
          while (true) {
            final n = _random.nextInt(maxCount);
            key = 'k$n';
            if (keys.add(key)) {
              break;
            }
          }

          list.add(vKey(key, component));
        } else {
          list.add(component);
        }

        html.add('$component');

        break;
    }
  }

  return list;
}

Component _getComponent() {
  switch (_random.nextInt(5)) {
    case 0:
      return _Component1();
    case 1:
      return _Component2();
    case 2:
      return _Component3();
    case 3:
      return _Component4();
    case 4:
      return _Component5();
    default:
      throw StateError('Internal error');
  }
}

String _getInnerHtml() {
  return VComponent.run((vComponent) {
    final node = vComponent.node;
    if (node is Element) {
      return node.innerHtml!;
    } else if (node is Text) {
      return node.text!;
    } else {
      return '$node';
    }
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

class _Component1 extends Component {
  @override
  Object render() {
    return '$this';
  }
}

class _Component2 extends Component {
  @override
  Object render() {
    return '$this';
  }
}

class _Component3 extends Component {
  @override
  Object render() {
    return '$this';
  }
}

class _Component4 extends Component {
  @override
  Object render() {
    return '$this';
  }
}

class _Component5 extends Component {
  @override
  Object render() {
    return '$this';
  }
}

class _Test extends Component {
  @override
  Object render() {
    final count = State.get('count', () => 0);
    final setCount = State.set<int>('count');
    final html = State.get('html', () => []);
    final setHtml = State.set<List>('html');
    final pc = State.get<List<Object>>('pc', () => []);
    final setPc = State.set<List<Object>>('pc');
    final date = State.get('date', DateTime.now);
    final setDate = State.set<DateTime>('date');
    if (count > 1000000) {
      return 'All done $count';
    }

    if (count % 1000 == 0) {
      final newDate = DateTime.now();
      setDate(newDate);
      print(
          '$count: ${(newDate.millisecondsSinceEpoch - date.millisecondsSinceEpoch) / 1000} sec');
    }

    if (count > 0) {
      final innerHtml = _getInnerHtml();
      var expected = html.join('');
      if (pc.length > 1) {
        expected = '<div>$expected</div>';
      }

      if (expected != innerHtml) {
        print('BAD ' * 20);
        print(innerHtml);
        print(expected);
      } else {
        //print('OK');
        //print('$innerHtml');
        //print('-' * 10);
      }
    }

    final html2 = <String>[];
    final children = _getChildren(html2);
    setPc(children);
    setHtml(html2);
    setCount(count + 1);
    return h('div', [
      if (children.isEmpty)
        ''
      else if (children.length == 1)
        children.first
      else
        h('div', children)
    ]);
  }
}
