import 'dart:async';

import '../errors/wrapped_exception.dart';
import 'vcomponent.dart';

class VRenderer {
  static void render(VComponent vComponent) {
    if (!vComponent.dirty) {
      vComponent.dirty = true;
      Timer.run(() {
        try {
          if (!vComponent.disposed) {
            VComponent.runWith(vComponent, (vComponent) {
              vComponent.render(VComponent(vComponent.component), true);
            });
          }
        } catch (e, s) {
          throw WrappedException(
              "An error occurred while rendering the component '$vComponent'",
              e,
              s);
        }
      });
    }
  }
}
