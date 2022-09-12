import '../components/component.dart';
import 'vcomponent.dart';
import 'vnode.dart';
import 'vtext.dart';

class VNodeFactory {
  static VNode createVNode(Object? data) {
    if (data is VNode) {
      return data;
    } else if (data is String) {
      return VText(data);
    } else if (data is Component) {
      return VComponent(data);
    }

    throw StateError("Unable to create VNode from '${data.runtimeType}' $data");
  }
}
