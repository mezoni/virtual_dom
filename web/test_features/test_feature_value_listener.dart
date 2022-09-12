import 'package:virtual_dom/features/listener.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/features/value_listener.dart';
import 'package:virtual_dom/listenable/listenable.dart';
import 'package:virtual_dom/virtual_dom.dart';
import 'package:virtual_dom/virtual_dom/vcomponent.dart';

final _done = ValueNotifier(false);

final _value = ValueNotifier(0);

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
    if (!_done.value) {
      return _Component1(onDone);
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
    final val = State.get('val', () => 0);
    final setVal = State.set<int>('val');
    ValueListener.use(_value, setVal);
    if (_value.value == 0) {
      _value.value = 1;
      return '';
    } else if (_value.value == 1) {
      if (_value.value != val) {
        onDone('The value listener did not call the handler');
      }

      VComponent.run((vComponent) {
        vComponent.addDisposeHandler(vComponent, () {
          if (_value.getListenerCount() != 0) {
            onDone(
                'The listener was not removed when the component was disposed');
          } else {
            onDone(null);
          }
        });
      });
      _done.value = true;
      return '';
    } else {
      onDone('Unexpected error');
      return '';
    }
  }
}
