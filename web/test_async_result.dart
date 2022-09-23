// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:html';

import 'package:virtual_dom/async/async_result.dart';
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
    final AsyncResult<String>? result = State.get('result', () => null);
    final setResult = State.set<AsyncResult<String>?>('result');
    if (result == null) {
      setResult(AsyncResult.create());
      Timer.run(() async {
        try {
          final data = await Future.delayed(Duration(seconds: 1), () => 'Ok');
          setResult(AsyncResult.complete(data));
        } catch (e, s) {
          setResult(AsyncResult.completeWithError(e, s));
        }
      });
      return 'Waiting';
    } else if (!result.isComplete) {
      return 'Waiting';
    } else if (result.ok) {
      return result.value;
    } else {
      return '${result.error}';
    }
  }
}
