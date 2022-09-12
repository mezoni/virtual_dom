import 'dart:html';

import '../components/component.dart';
import '../virtual_dom/vcomponent.dart';

void mount(Element parent, Component component) {
  final vComponent = VComponent(component);
  vComponent.renderNew(null);
  final node = vComponent.node!;
  parent.nodes.clear();
  parent.append(node);
}
