import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/virtual_dom.dart';

var _changeState = false;

var _count = 0;

Component test(void Function(String? message) onDone) {
  return _App(onDone);
}

class _App extends Component {
  final void Function(String? message) onDone;

  _App(this.onDone);

  @override
  Object render() {
    final step = State.get('step', () => 0);
    final setStep = State.set<int>('step');
    final changeState = State.change();
    if (step == 0) {
      _count++;
      setStep(1);
      return '';
    } else if (step == 1) {
      if (_count != 1) {
        onDone("Expected '_count' to be 1, but got $_count");
        return '';
      }

      _count++;
      setStep(2);
      return '';
    } else if (step == 2) {
      if (!_changeState) {
        if (_count != 2) {
          onDone("Expected '_count' to be 2, but got $_count");
          return '';
        }

        _count++;
        _changeState = true;
        changeState();
      } else {
        if (_count != 3) {
          onDone("Expected '_count' to be 3, but got $_count");
          return '';
        }

        onDone(null);
      }

      return '';
    } else {
      onDone('Unexpected error');
      return '';
    }
  }
}
