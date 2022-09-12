// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:convert';

import 'package:virtual_dom/errors/error_report.dart';
import 'package:virtual_dom/features/use_value_watcher.dart';
import 'package:virtual_dom/helpers/h.dart';
import 'package:virtual_dom/helpers/styles.dart';
import 'package:virtual_dom/listenable/listenable.dart';
import 'package:virtual_dom/virtual_dom.dart';

class ErrorReporter extends Component {
  final ValueNotifier<ErrorReport?> errorReport;

  ErrorReporter(this.errorReport) : super(key: errorReport);

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
