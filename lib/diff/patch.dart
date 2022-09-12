class InsertPatch<T> extends Patch<T> {
  final T newValue;

  final T? oldValue;

  InsertPatch({
    required this.newValue,
    required this.oldValue,
  });

  @override
  PatchKind get kind => PatchKind.insert;
}

class MovePatch<T> extends Patch<T> {
  final T newValue;

  final T oldValue;

  final T oldValue2;

  MovePatch({
    required this.newValue,
    required this.oldValue,
    required this.oldValue2,
  });

  @override
  PatchKind get kind => PatchKind.move;
}

abstract class Patch<T> {
  PatchKind get kind;
}

enum PatchKind { insert, move, rebuild, remove, replace, update }

class RebuildPatch<T> extends Patch<T> {
  final T newValue;

  final T oldValue;

  RebuildPatch({
    required this.newValue,
    required this.oldValue,
  });

  @override
  PatchKind get kind => PatchKind.rebuild;
}

class RemovePatch<T> extends Patch<T> {
  final T oldValue;

  RemovePatch({
    required this.oldValue,
  });

  @override
  PatchKind get kind => PatchKind.remove;
}

class ReplacePatch<T> extends Patch<T> {
  final T newValue;

  final T oldValue;

  ReplacePatch({
    required this.newValue,
    required this.oldValue,
  });

  @override
  PatchKind get kind => PatchKind.replace;
}

class UpdatePatch<T> extends Patch<T> {
  final T newValue;

  final T oldValue;

  UpdatePatch({
    required this.newValue,
    required this.oldValue,
  });

  @override
  PatchKind get kind => PatchKind.update;
}
