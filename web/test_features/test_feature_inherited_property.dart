import 'package:virtual_dom/features/inherited_property.dart';
import 'package:virtual_dom/features/listener.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/helpers/el.dart';
import 'package:virtual_dom/listenable/listenable.dart';
import 'package:virtual_dom/virtual_dom.dart';

final _done = ValueNotifier(false);

var _parentValue = 0;

Component test(void Function(String? message) onDone) {
  return _App(onDone);
}

class _App extends Component {
  final void Function(String? message) onDone;

  _App(this.onDone);

  @override
  Object render() {
    final changeState = State.change();
    Listener.use(_done, changeState);
    final value = InheritedProperty.add('value', () => 41);
    _parentValue = value;
    if (!_done.value) {
      return el('div', children: [
        el('div', child: _Component1(onDone)),
      ]);
    } else {
      return '';
    }
  }
}

class _Component1 extends Component {
  final void Function(String? message) onDone;

  _Component1(this.onDone);

  @override
  Object render() {
    return el('div', children: [
      el('div', child: _Component11(onDone)),
    ]);
  }
}

class _Component11 extends Component {
  final void Function(String? message) onDone;

  _Component11(this.onDone);

  @override
  Object render() {
    final value = InheritedProperty.get<int>('value');
    if (value != _parentValue) {
      onDone('Inherited value in child element is not equal to parent value');
      _done.value = true;
      return '';
    }

    onDone(null);
    _done.value = true;
    return '';
  }
}
