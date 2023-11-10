import 'dart:ui';

/// The `iMouse` values to pass to the shader `iMouse` uniform
class IMouse {
  /// The pointer position
  /// Shows how to use the mouse input (only left button supported):
  ///
  ///      mouse.xy  = mouse position during last button down
  /// abs(mouse.zw)  = mouse position during last button click
  /// sign(mouse.z)  = button is down
  /// sign(mouse.w)  = button is clicked
  /// https://www.shadertoy.com/view/llySRh
  /// https://www.shadertoy.com/view/Mss3zH
  IMouse(this.x, this.y, this.z, this.w);

  double x = 0;
  double y = 0;
  double z = 0;
  double w = 0;

  static IMouse zero = IMouse(0, 0, 0, 0);

  @override
  String toString() {
    return 'x: $x  y: $y  z: $z  w: $w';
  }
}

/// The current pointer state
///
enum PointerState {
  ///
  onPointerDown,
  ///
  onPointerMove,
  ///
  onPointerUp,
  ///
  none,
}

/// Class to control user tap and pan to manage the `vec4 iMouse` uniform
/// 
class IMouseController {
  /// Controllore to manage the `vec4 iMouse` uniform
  IMouseController({
    required this.width,
    required this.height,
  })  : iMouse = IMouse.zero,
        startingPos = Offset.zero;

  /// The current [iMouse]
  IMouse iMouse;

  /// Get the current [iMouse] normalized to 0-1
  IMouse get iMouseNormalized => getIMouseNormalized();

  /// The width of the widget
  final double width;

  /// The heigth of the widget
  final double height;

  /// The position when the user tap on the shader widget
  Offset startingPos;

  /// The current state of mouse interaction
  PointerState currState = PointerState.none;

  /// Update [iMouse] when the user starts to pan
  void start(Offset position) {
    startingPos = position;
    iMouse = getIMouseValue(startingPos, PointerState.onPointerDown);
    updatePointer(PointerState.onPointerDown);
  }

  /// Update [iMouse] when the user pan
  void update(Offset position) {
    iMouse = getIMouseValue(position, PointerState.onPointerMove);
    updatePointer(PointerState.onPointerMove);
  }

  /// Update [iMouse] when the user ends to pan
  void end() {
    iMouse =
        getIMouseValue(Offset(iMouse.x, iMouse.y), PointerState.onPointerUp);
    updatePointer(PointerState.onPointerUp);
  }

  /// Get the iMouse vec4
  IMouse getIMouseValue(
    Offset pos,
    PointerState eventType,
  ) {
    return IMouse(
      pos.dx,
      pos.dy,
      eventType == PointerState.onPointerDown ||
              eventType == PointerState.onPointerMove
          ? startingPos.dx
          : -startingPos.dx,
      -startingPos.dy,
    );
  }

  /// get the mouse coordinates in the 0~1 range
  IMouse getIMouseNormalized() {
    return IMouse(
      iMouse.x / width,
      iMouse.y / height,
      (iMouse.w / width).abs(),
      (iMouse.z / height).abs(),
    );
  }

  /// update iMouse when user interact
  void updatePointer(PointerState state) {
    currState = state;
    if (state == PointerState.onPointerUp) {
      currState = PointerState.none;
    }
  }

  @override
  String toString() => 'IMouseController(iMouse: $iMouse)';
}
