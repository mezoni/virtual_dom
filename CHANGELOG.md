## 0.1.11

- Changes have been made to the procedure for setting `innerHtml` for `VHtml`. This is now done using `_TrustedHtmlTreeSanitizer`.

## 0.1.10

- The source code has been modified to reflect the changes made to "analysis_options.yaml".

## 0.1.9

- Added `AsyncResult` class to simplify the implementation of handling asynchronous operations in synchronous methods by tracking state changes.

## 0.1.8

- Minor improvements in rendering procedures.
- Added concept of component effect key. The field `Object? Component.effectKey` has been added for this purpose. This field is intended to specify a value, which will indicate that the component requires rerendering if the previous value of this key differs from the current one. Usually the values for the key are taken from the current arguments.

## 0.1.7

- Added helper function `el`.

## 0.1.6

- Added description to `README.md` file for using global error reporting for non-UI cases.

## 0.1.5

- Fixed bug in `VTree._getKey()`. At the very beginning of the implementation, virtual keys could only be specified for `VElement` nodes (via the `key` attribute), now virtual keys could be specified for any kind of nodes (in the `Object? VNode.key` field). This was not taken into account and was incorrect work. Now this shortcoming has been eliminated.


## 0.1.4

- Added `ValueNotifier<ErrorReport?> global` static field to `ErrorReport` class.
- The `VNode.renderSafely()` method has been changed to take into account the addition of the global `ErrorReport`.

## 0.1.3

- Fixed a critical error in the `VNode.updateElement()` method. The error is related to the incorrect update of listeners.

## 0.1.2

- Changes have been made to the file `README.md`.

## 0.1.1

- Changes have been made to the file `README.md`.

## 0.1.0

- Initial release