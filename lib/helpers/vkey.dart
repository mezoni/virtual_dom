import '../virtual_dom/vnode.dart';
import '../virtual_dom/vnode_factory.dart';

/// Creates a virtual node from [data] using the [VNodeFactory] and assigns a
/// [key] to this node.
VNode vKey(Object key, Object data) {
  final vNode = VNodeFactory.createVNode(data);
  vNode.key = key;
  return vNode;
}
