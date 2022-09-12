import 'dart:collection';

import '../errors/wrapped_exception.dart';

abstract class ChangeNotifier {
  /// Notifies listeners by executing their handlers.
  void notifyListeners();
}

abstract class Listenable {
  /// Adds a listener handler.
  void addListener(void Function() listener);

  /// Returns the number of listeners.
  ///
  /// If this method is called during the processing of the execution of the
  /// notify listeners operation and listeners were added or removed at that
  /// time, then the number of these listeners is not taken into account.
  ///
  /// The main purpose of this method is to obtain information about the state
  /// of this instance when testing the operation of other objects.
  int getListenerCount();

  /// Removes the listener handler.
  void removeListener(void Function() listener);
}

abstract class ValueListenable<T> implements Listenable {
  T get value;
}

class ValueListenableController<T> {
  final _ValueListenable<T> _listenable;

  ValueListenableController(T value) : _listenable = _ValueListenable(value);

  ValueListenable<T> get listenable => _listenable;

  T get value => _listenable.value;

  set value(T value) {
    _listenable.value = value;
  }
}

class ValueNotifier<T> extends _ChangeNotifier
    implements ChangeNotifier, ValueListenable<T> {
  T _value;

  ValueNotifier(T value) : _value = value;

  @override
  T get value => _value;

  set value(T value) {
    final changed = _value != value;
    _value = value;
    if (changed) {
      _notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    _notifyListeners();
  }
}

class _ChangeNotifier implements Listenable {
  static const _add = true;

  static const _remove = false;

  bool _isProcessed = false;

  final LinkedList<_ListenerEntry> _listeners = LinkedList();

  final Map<void Function(), _ListenerEntry> _map = {};

  final Map<void Function(), bool> _pending = {};

  @override
  void addListener(void Function() listener) {
    _pending[listener] = _add;
    if (!_isProcessed) {
      _applyChanges();
    }
  }

  @override
  int getListenerCount() {
    return _listeners.length;
  }

  @override
  void removeListener(void Function() listener) {
    _pending[listener] = _remove;
    if (!_isProcessed) {
      _applyChanges();
    }
  }

  void _applyChanges() {
    for (final listener in _pending.keys) {
      switch (_pending[listener]) {
        case _add:
          final entry = _ListenerEntry(listener);
          _listeners.add(entry);
          _map[listener] = entry;
          break;
        case _remove:
          final entry = _map[listener];
          if (entry != null) {
            _listeners.remove(entry);
          }

          _map.remove(listener);
          break;
      }
    }

    _pending.clear();
  }

  /// Notifies listeners by executing their handlers.
  void _notifyListeners() {
    if (_isProcessed) {
      throw StateError(
          "Recursive execution '$runtimeType'.notifyListeners()' is not allowed");
    }

    _isProcessed = true;
    for (final listener in _listeners) {
      try {
        listener.value();
      } catch (e, s) {
        throw WrappedException(
            "An error occurred while executing the listener for '$runtimeType'",
            e,
            s);
      }
    }

    _isProcessed = false;
    if (_pending.isNotEmpty) {
      _applyChanges();
    }
  }
}

class _ListenerEntry extends LinkedListEntry<_ListenerEntry> {
  final void Function() value;

  _ListenerEntry(this.value);
}

class _ValueListenable<T> extends _ChangeNotifier
    implements ValueListenable<T> {
  T _value;

  _ValueListenable(this._value);

  @override
  T get value => _value;

  set value(T value) {
    final changed = _value != value;
    _value = value;
    if (changed) {
      _notifyListeners();
    }
  }
}
