/// The [AsyncResult] is intended to simplify the implementation of handling
/// asynchronous operations in synchronous methods by tracking state changes.
///
/// The [AsyncResult] is a result with 3 states:
/// - Pending
/// - Complete
/// - Complete with error
///
/// In combination with the ability to use `null` as the initial value (result
/// processing has not been started), there are 4 states in total, which are
/// quite enough to implement rendering based on the use of asynchronous data.
abstract class AsyncResult<T> {
  factory AsyncResult.complete(T value) {
    return _OK(value);
  }

  factory AsyncResult.completeWithError(Object error, StackTrace stackTrace) {
    return _Fail(error, stackTrace);
  }

  factory AsyncResult.create() {
    return _Pending();
  }

  Object get error;

  bool get isComplete;

  bool get ok;

  StackTrace get stackTrace;

  T get value;
}

class _Fail<T> implements AsyncResult<T> {
  @override
  final Object error;

  @override
  final StackTrace stackTrace;

  _Fail(this.error, this.stackTrace);

  @override
  bool get isComplete => true;

  @override
  bool get ok => false;

  @override
  T get value => throw UnsupportedError('value');
}

class _OK<T> implements AsyncResult<T> {
  @override
  final T value;

  _OK(this.value);

  @override
  Object get error => throw UnsupportedError('error');

  @override
  bool get isComplete => true;

  @override
  bool get ok => true;

  @override
  StackTrace get stackTrace => throw UnsupportedError('stackTrace');
}

class _Pending<T> implements AsyncResult<T> {
  @override
  Object get error => throw UnsupportedError('error');

  @override
  bool get isComplete => false;

  @override
  bool get ok => false;

  @override
  StackTrace get stackTrace => throw UnsupportedError('stackTrace');

  @override
  T get value => throw UnsupportedError('value');
}
