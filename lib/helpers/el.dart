import 'dart:html';

import '../virtual_dom/velement.dart';
import '../virtual_dom/vnode_entry.dart';
import '../virtual_dom/vnode_factory.dart';

VElement el(
  String tag, {
  Map<String, Object> attributes = const {},
  Map<String, void Function(Event event)> listeners = const {},
  Object? child,
  List<Object> children = const [],
  void Function(Event event)? onChange,
  void Function(Event event)? onClick,
  void Function(Event event)? onDblClick,
  void Function(Event event)? onKeyDown,
  void Function(Event event)? onKeyPress,
  void Function(Event event)? onKeyUp,
  void Function(Event event)? onMouseDown,
  void Function(Event event)? onMouseMove,
  void Function(Event event)? onMouseOut,
  void Function(Event event)? onMouseOver,
  void Function(Event event)? onMouseUp,
}) {
  if (children.isNotEmpty && child != null) {
    throw ArgumentError(
        "The arguments 'children' and 'child' cannot be used together");
  }

  final result = VElement(tag);
  if (attributes.isNotEmpty) {
    result.attributes.addAll(attributes);
  }

  if (children.isNotEmpty) {
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final vNode = VNodeFactory.createVNode(child);
      final vEntry = VNodeEntry(vNode);
      result.children.add(vEntry);
    }
  } else if (child != null) {
    final vNode = VNodeFactory.createVNode(child);
    final vEntry = VNodeEntry(vNode);
    result.children.add(vEntry);
  }

  if (listeners.isNotEmpty) {
    result.listeners.addAll(listeners);
  }

  final listenerMap = {
    'change': onChange,
    'click': onClick,
    'dblclick': onDblClick,
    'keydown': onKeyDown,
    'keypress': onKeyPress,
    'keyup': onKeyUp,
    'mousedown': onMouseDown,
    'mousemove': onMouseMove,
    'mouseout': onMouseOut,
    'mouseover': onMouseOver,
    'mouseup': onMouseUp,
  };

  for (final key in listenerMap.keys) {
    final value = listenerMap[key];
    if (value != null) {
      if (result.listeners.containsKey(key)) {
        throw ArgumentError(
            "The listener for the '$key' event was specified twice");
      }

      result.listeners[key] = value;
    }
  }

  return result;
}
