import 'package:virtual_dom/features/inherited_value.dart';
import 'package:virtual_dom/features/listener.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/helpers/el.dart';
import 'package:virtual_dom/listenable/listenable.dart';
import 'package:virtual_dom/virtual_dom.dart';
import 'package:virtual_dom/virtual_dom/vcomponent.dart';

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
    final value = InheritedValue.add('value', () => 0);
    _parentValue = value.value;
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
    final value = InheritedValue.get<int>('value');
    if (value == null) {
      onDone('Inherited value not found');
      return '';
    }

    if (value.value == 0) {
      value.value = value.value + 1;
    } else if (value.value == 1) {
      if (_parentValue != value.value) {
        onDone('The parent component did not update the value');
      }

      VComponent.run((vComponent) {
        vComponent.addDisposeHandler(vComponent, () {
          if (value.getListenerCount() != 1) {
            onDone(
                'The listener was not removed when the component was disposed');
          } else {
            onDone(null);
          }
        });
      });
      _done.value = true;
      return '';
    }

    return '';
  }
}
