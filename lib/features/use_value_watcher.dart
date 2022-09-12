import '../listenable/listenable.dart';
import 'listener.dart';
import 'state.dart';

ValueNotifier<T> useValueWatcher<T>(ValueNotifier<T> notifier) {
  final changeState = State.change();
  Listener.use(notifier, changeState);
  return notifier;
}
