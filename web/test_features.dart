// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:html';

import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/use_error_report.dart';
import 'package:virtual_dom/helpers/el.dart';
import 'package:virtual_dom/helpers/mount.dart';
import 'package:virtual_dom/virtual_dom.dart';

import 'error_reporter.dart';
import 'test_features/test_feature_inherited_property.dart'
    as test_feature_inherited_property;
import 'test_features/test_feature_inherited_value.dart'
    as test_feature_inherited_value;
import 'test_features/test_feature_init.dart' as test_feature_init;
import 'test_features/test_feature_listener.dart' as test_feature_listener;
import 'test_features/test_feature_state.dart' as test_feature_state;
import 'test_features/test_feature_value_listener.dart'
    as test_feature_value_listener;

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
    return el('div', children: [
      ErrorReporter(errorReport),
      _Test(),
    ]);
  }
}

class _Test extends Component {
  @override
  Object render() {
    final results = State.get<Map<String, String?>>('results', () => {});
    final index = State.get<int>('index', () => 0);
    final setIndex = State.set<int>('index');
    final testMap = {
      'InheritProperty': test_feature_inherited_property.test,
      'InheritedValue': test_feature_inherited_value.test,
      'Init': test_feature_init.test,
      'Listener': test_feature_listener.test,
      'State': test_feature_state.test,
      'ValueListener': test_feature_value_listener.test,
    };

    String displayResult(MapEntry<String, String?> entry) {
      final key = entry.key;
      final value = entry.value == null ? 'OK' : entry.value!;
      return '$key: $value';
    }

    final names = testMap.keys.toList();
    final tests = testMap.values.toList();
    Object runTest() {
      if (index < testMap.length) {
        final name = names[index];
        final test = tests[index];
        return test((message) {
          results[name] = message;
          setIndex(index + 1);
        });
      } else {
        return '';
      }
    }

    return el('div', children: [
      el('ul', children: [
        for (final entry in results.entries)
          el(
            'li',
            child: displayResult(entry),
          ),
      ]),
      runTest(),
    ]);
  }
}
