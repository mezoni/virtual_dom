/// The application component is the building block for creating user interface
/// controls.
abstract class Component {
  /// This field is intended to specify a value, which will indicate that the
  /// component requires rerendering if the previous value of this key differs
  /// from the current one.
  ///
  /// Usually the values for the key are taken from the current arguments.
  ///
  /// Example:
  ///
  /// ```dart
  /// ItemRow({
  ///   required this.dataItem,
  ///   required this.selected,
  ///})  : super(effectKey: Key([dataItem.label, selected]), key: dataItem.id);
  /// ```
  final Object? effectKey;

  /// The [key] is used to identify components of the same type.
  ///
  /// Instances of components of the same type are considered identical. This is
  /// fair and works correctly as long as the components have no input
  /// parameters. When using components with parameters, this makes the
  /// components dependent on the arguments passed as parameters.
  ///
  /// To be able to distinguish components of the same type from each other,
  /// this [key] is used to distinguish instances of the component.
  ///
  /// It is recommended to use, as a value, an appropriate key instance with all
  /// the important arguments.
  ///
  /// Example:
  ///
  /// ```dart
  /// Widget1(this.arg1, this.arg2) : super(key: Key([arg1, arg2]));
  /// ```
  final Object? key;

  const Component({
    this.effectKey,
    this.key,
  });

  /// The "render" method is the only method that does all the work.
  ///
  /// This method is responsible for the following operations:
  /// - Content generation
  /// - Initialization
  /// - Destruction
  /// - State management
  /// - Listening
  /// - Other similar work
  ///
  /// All these actions are performed mainly through the use of "helpers" and
  /// "features".
  Object render();
}
