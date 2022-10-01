import 'package:virtual_dom/features/init.dart';
import 'package:virtual_dom/features/state.dart';
import 'package:virtual_dom/helpers/el.dart';
import 'package:virtual_dom/virtual_dom.dart';

int _count = 0;

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
    if (step == 0) {
      setStep(1);
      return el('div', children: [
        _Component10(),
        _Component20(),
        _Component30(),
      ]);
    } else if (step == 1) {
      if (_count != 4) {
        onDone("Expected '_count' to be 4, but got $_count");
        return '';
      }

      setStep(2);
      return '';
    } else if (step == 2) {
      if (_count != 0) {
        onDone("Expected '_count' to be 0, but got $_count");
        return '';
      }

      onDone(null);
      return '';
    } else {
      onDone('Unexpected error');
      return '';
    }
  }
}

class _Component10 extends Component {
  @override
  Object render() {
    Init.use(() {
      _count++;
      return () {
        _count--;
      };
    });
    return '$_Component10';
  }
}

class _Component20 extends Component {
  @override
  Object render() {
    Init.use(() {
      _count++;
      return () {
        _count--;
      };
    });
    return '$_Component20';
  }
}

class _Component30 extends Component {
  @override
  Object render() {
    Init.use(() {
      _count++;
      return () {
        _count--;
      };
    });
    return el(
      'ul',
      child: el('li', child: _Component31()),
    );
  }
}

class _Component31 extends Component {
  @override
  Object render() {
    Init.use(() {
      _count++;
      return () {
        _count--;
      };
    });
    return '$_Component31';
  }
}
