import 'dart:html';

import '../components/component.dart';
import '../errors/wrapped_exception.dart';
import '../virtual_dom/velement.dart';
import '../virtual_dom/vnode.dart';
import '../virtual_dom/vnode_entry.dart';
import '../virtual_dom/vnode_factory.dart';

/// Creates a virtual node [VElement] with the specified [tag] and arguments.
///
/// The arguments mean the following element properties:
/// - Attributes
/// - Children
/// - Event listeners
///
/// Arguments may be specified in any order, must not be duplicated, or may not
/// be specified at all.
///
/// Example:
///
/// ```dart
/// return h(
///   'div',
///   {'class': 'w3-border-bottom', 'style': 'border-color:#BCAE5F!important;'},
///    SectionListWidget(),
/// );
/// ```
VElement h(
  String tag, [
  Object? arg1,
  Object? arg2,
  Object? arg3,
]) {
  Map<String, Object>? attributes;
  List<VNode>? children;
  Map<String, void Function(Event event)>? listeners;
  var isAttributesAllowed = true;
  var isChildrenAllowed = true;
  var isListenersAllowed = true;
  var isFinished = false;
  final arguments = [arg1, arg2, arg3];
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    if (argument == null) {
      isFinished = true;
    } else if (isFinished) {
      _error(
          "No processing is provided for an argument specified after a 'null' argument",
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
    } else if (argument is Iterable<Object?>) {
      _checkArgument(
          isChildrenAllowed,
          'children',
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
      isChildrenAllowed = false;
      final list = <VNode>[];
      for (final data in argument) {
        final vNode = _createNode(data);
        list.add(vNode);
      }

      children = list;
    } else if (argument is String) {
      _checkArgument(
          isChildrenAllowed,
          'children',
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
      isChildrenAllowed = false;
      final vNode = VNodeFactory.createVNode(argument);
      children = [vNode];
    } else if (argument is VNode) {
      _checkArgument(
          isChildrenAllowed,
          'children',
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
      isChildrenAllowed = false;
      children = [argument];
    } else if (argument is Component) {
      _checkArgument(
          isChildrenAllowed,
          'children',
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
      isChildrenAllowed = false;
      final vNode = VNodeFactory.createVNode(argument);
      children = [vNode];
    } else if (argument is Map<String, void Function(Event event)>) {
      _checkArgument(
          isListenersAllowed,
          'listeners',
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
      isListenersAllowed = false;
      listeners = argument;
    } else if (argument is Map<String, dynamic>) {
      _checkArgument(
          isAttributesAllowed,
          'attributes',
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
      isAttributesAllowed = false;
      attributes = {};
      for (final key in argument.keys) {
        final value = argument[key];
        if (value == null) {
          _error(
              "The value of an element attribute '$key' must not be 'null'",
              [arg1, arg2, arg3],
              i,
              {
                'attributes': attributes,
                'children': children,
                'listeners': listeners,
              });
        }

        attributes[key] = value as Object;
      }
    } else if (argument is Map && argument.isEmpty) {
      isAttributesAllowed = false;
      attributes = {};
    } else {
      _error(
          "Unable to process argument of type '${argument.runtimeType}'",
          [arg1, arg2, arg3],
          i,
          {
            'attributes': attributes,
            'children': children,
            'listeners': listeners,
          });
    }
  }

  final result = VElement(tag);
  if (attributes != null) {
    result.attributes.addAll(attributes);
  }

  if (listeners != null) {
    result.listeners.addAll(listeners);
  }

  if (children != null) {
    result.children.addAll(children.map(VNodeEntry.new));
  }

  return result;
}

void _checkArgument(bool condition, String parameter, List<Object?> arguments,
    int index, Object? defined) {
  if (!condition) {
    final value = arguments[index];
    var valueAsString = value.toString();
    if (valueAsString.length > 80) {
      valueAsString = '${valueAsString.substring(0, 80)}...';
    }

    var definedAsString = defined.toString();
    if (definedAsString.length > 80) {
      definedAsString = '${definedAsString.substring(0, 80)}...';
    }

    final messages = <String>[];
    messages.add(
        "The argument 'arg$index' was determined as '$parameter' parameter");
    messages.add(
        "The '$parameter' parameter is already set to '${defined.runtimeType} $definedAsString'");
  }
}

VNode _createNode(Object? data) {
  try {
    final result = VNodeFactory.createVNode(data);
    return result;
  } catch (e, s) {
    throw WrappedException(
        "An error occurred while creating a child element from the value '${data.runtimeType}'",
        e,
        s);
  }
}

Never _error(String message, List<Object?> arguments, int index,
    Map<String, Object?> parameters) {
  String toText(Object? object) {
    var text = object.toString();
    if (text.length > 80) {
      text = '${text.substring(0, 80)}...';
    }

    return text;
  }

  final name = 'arg$index';
  final messages = <String>[];
  messages.add(
      "An error occurred while processing argument '$name' to function 'h'");
  messages.add(message);
  messages.add("Arguments:");
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    final text = toText(argument);
    messages.add("arg$i: (${argument.runtimeType}) $text");
  }

  messages.add("Processed parameters:");
  for (final key in parameters.keys) {
    final value = parameters[key];
    final text = toText(value);
    messages.add("$key: (${value.runtimeType}) $text");
  }

  throw StateError(messages.join('\n'));
}
