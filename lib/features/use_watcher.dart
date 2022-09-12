import '../listenable/listenable.dart';
import 'listener.dart';
import 'state.dart';

Listenable useWatcher<T>(Listenable listenable) {
  final changeState = State.change();
  Listener.use(listenable, changeState);
  return listenable;
}
