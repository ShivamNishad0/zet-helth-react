import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class _CustomLayoutStateBase<T extends _SubSwiper> extends State<T>
    with SingleTickerProviderStateMixin {
  double _swiperWidth = Get.width / 1.1;
  double _swiperHeight = (Get.width / 1.1) / 2;
  late Animation<double> _animation;
  late AnimationController _animationController;
  SwiperController get _controller => widget.controller;
  late int _startIndex;
  int? _animationCount;
  int _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = widget.index ?? 0;

    _createAnimationController();
    _controller.addListener(_onController);
    super.initState();
  }

  void _createAnimationController() {
    _animationController = AnimationController(vsync: this, value: 0.5);
    Tween<double> tween = Tween(begin: 0.0, end: 1.0);
    _animation = tween.animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_getSize);
    super.didChangeDependencies();
  }

  void _getSize(Duration _) {
    if (!mounted) return;
    afterRender();
  }

  @mustCallSuper
  void afterRender() {
    RenderObject renderObject = context.findRenderObject()!;
    Size size = renderObject.paintBounds.size;
    _swiperWidth = size.width;
    _swiperHeight = size.height;
    setState(() {});
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }

    if (widget.loop != oldWidget.loop) {
      if (!widget.loop) {
        _currentIndex = _ensureIndex(_currentIndex);
      }
    }

    if (widget.axisDirection != oldWidget.axisDirection) {
      afterRender();
    }

    super.didUpdateWidget(oldWidget);
  }

  int _ensureIndex(int index) {
    var res = index;
    res = index % widget.itemCount;
    if (res < 0) {
      res += widget.itemCount;
    }
    return res;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildItem(int i, int realIndex, double animationValue);

  Widget _buildContainer(List<Widget> list) {
    return Stack(
      children: list,
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? w) {
    List<Widget> list = [];

    double animationValue = _animation.value;

    for (int i = 0; i < _animationCount! && widget.itemCount > 0; ++i) {
      int realIndex = _currentIndex + i + _startIndex;
      realIndex = realIndex % widget.itemCount;
      if (realIndex < 0) {
        realIndex += widget.itemCount;
      }

      if (widget.axisDirection == AxisDirection.right) {
        list.insert(0, _buildItem(i, realIndex, animationValue));
      } else {
        list.add(_buildItem(i, realIndex, animationValue));
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanUpdate: _onPanUpdate,
      child: ClipRect(
        child: Center(
          child: _buildContainer(list),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCount == null) {
      return Container();
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: _buildAnimation,
    );
  }

  late double _currentValue;
  late double _currentPos;

  bool _lockScroll = false;

  Future<void> _move(double position, {int? nextIndex}) async {
    if (_lockScroll) return;
    try {
      _lockScroll = true;
      await _animationController.animateTo(
        position,
        duration: Duration(milliseconds: widget.duration!),
        curve: widget.curve,
      );
      if (nextIndex != null) {
        widget.onIndexChanged!(widget.getCorrectIndex(nextIndex));
      }
    } catch (e) {
      debugPrint('error animating _animationController ${e.toString()}');
    } finally {
      if (nextIndex != null) {
        try {
          _animationController.value = 0.5;
        } catch (e) {
          debugPrint(
              'error setting _animationController.value ${e.toString()}');
        }

        _currentIndex = nextIndex;
      }
      _lockScroll = false;
    }
  }

  int _getProperNewIndex(int newIndex) {
    var res = newIndex;
    if (!widget.loop && newIndex >= widget.itemCount - 1) {
      res = widget.itemCount - 1;
    } else if (!widget.loop && newIndex < 0) {
      res = 0;
    }
    return res;
  }

  void _onController() {
    SwiperController controller = widget.controller;
    final event = controller.event;
    if (event is StepBasedIndexControllerEvent) {
      final newIndex = event.calcNextIndex(
        currentIndex: _currentIndex,
        itemCount: widget.itemCount,
        loop: widget.loop,
        reverse: false,
      );
      _move(event.targetPosition, nextIndex: newIndex);
    } else if (event is MoveIndexControllerEvent) {
      _move(
        event.targetPosition,
        nextIndex: _getProperNewIndex(event.newIndex),
      );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_lockScroll) return;

    double velocity = widget.scrollDirection == Axis.horizontal
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;

    if (_animationController.value >= 0.75 || velocity > 500.0) {
      if (_currentIndex <= 0 && !widget.loop) {
        return;
      }
      _move(1.0, nextIndex: _currentIndex - 1);
    } else if (_animationController.value < 0.25 || velocity < -500.0) {
      if (_currentIndex >= widget.itemCount - 1 && !widget.loop) {
        return;
      }
      _move(0.0, nextIndex: _currentIndex + 1);
    } else {
      _move(0.5);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_lockScroll) return;
    _currentValue = _animationController.value;
    _currentPos = widget.scrollDirection == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lockScroll) return;
    double value = _currentValue +
        ((widget.scrollDirection == Axis.horizontal
                    ? details.globalPosition.dx
                    : details.globalPosition.dy) -
                _currentPos) /
            _swiperWidth /
            2;
    // no loop ?
    if (!widget.loop) {
      if (_currentIndex >= widget.itemCount - 1) {
        if (value < 0.5) {
          value = 0.5;
        }
      } else if (_currentIndex <= 0) {
        if (value > 0.5) {
          value = 0.5;
        }
      }
    }

    _animationController.value = value;
  }
}

double _getValue(List<double> values, double animationValue, int index) {
  double s = values[index];
  if (animationValue >= 0.5) {
    if (index < values.length - 1) {
      s = s + (values[index + 1] - s) * (animationValue - 0.5) * 2.0;
    }
  } else {
    if (index != 0) {
      s = s - (s - values[index - 1]) * (0.5 - animationValue) * 2.0;
    }
  }
  return s;
}

Offset _getOffsetValue(List<Offset> values, double animationValue, int index) {
  Offset s = values[index];
  double dx = s.dx;
  double dy = s.dy;
  if (animationValue >= 0.5) {
    if (index < values.length - 1) {
      dx = dx + (values[index + 1].dx - dx) * (animationValue - 0.5) * 2.0;
      dy = dy + (values[index + 1].dy - dy) * (animationValue - 0.5) * 2.0;
    }
  } else {
    if (index != 0) {
      dx = dx - (dx - values[index - 1].dx) * (0.5 - animationValue) * 2.0;
      dy = dy - (dy - values[index - 1].dy) * (0.5 - animationValue) * 2.0;
    }
  }
  return Offset(dx, dy);
}

abstract class TransformBuilder<T> {
  final List<T> values;

  TransformBuilder({required this.values});

  Widget build(int i, double animationValue, Widget widget);
}

class ScaleTransformBuilder extends TransformBuilder<double> {
  final Alignment alignment;

  ScaleTransformBuilder({
    required super.values,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(int i, double animationValue, Widget widget) {
    double s = _getValue(values, animationValue, i);
    return Transform.scale(scale: s, child: widget);
  }
}

class OpacityTransformBuilder extends TransformBuilder<double> {
  OpacityTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    double v = _getValue(values, animationValue, i);
    return Opacity(
      opacity: v,
      child: widget,
    );
  }
}

class RotateTransformBuilder extends TransformBuilder<double> {
  RotateTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    double v = _getValue(values, animationValue, i);
    return Transform.rotate(
      angle: v,
      child: widget,
    );
  }
}

class TranslateTransformBuilder extends TransformBuilder<Offset> {
  TranslateTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    Offset s = _getOffsetValue(values, animationValue, i);
    return Transform.translate(
      offset: s,
      child: widget,
    );
  }
}

class CustomLayoutOption {
  final List<TransformBuilder> builders = [];
  final int startIndex;
  final int? stateCount;

  CustomLayoutOption({this.stateCount, required this.startIndex});

  void addOpacity(List<double> values) {
    builders.add(OpacityTransformBuilder(values: values));
  }

  void addTranslate(List<Offset> values) {
    builders.add(TranslateTransformBuilder(values: values));
  }

  void addScale(List<double> values, Alignment alignment) {
    builders.add(ScaleTransformBuilder(values: values, alignment: alignment));
  }

  void addRotate(List<double> values) {
    builders.add(RotateTransformBuilder(values: values));
  }
}

class _CustomLayoutSwiper extends _SubSwiper {
  final CustomLayoutOption option;

  const _CustomLayoutSwiper({
    required this.option,
    super.itemWidth,
    required super.loop,
    super.itemHeight,
    super.onIndexChanged,
    super.itemBuilder,
    required super.curve,
    super.duration,
    super.index,
    required super.itemCount,
    super.scrollDirection = null,
    required super.controller,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomLayoutState();
  }
}

class _CustomLayoutState extends _CustomLayoutStateBase<_CustomLayoutSwiper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
  }

  @override
  void didUpdateWidget(_CustomLayoutSwiper oldWidget) {
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget _buildItem(int index, int realIndex, double animationValue) {
    List<TransformBuilder> builders = widget.option.builders;

    Widget child = SizedBox(
        width: widget.itemWidth ?? double.infinity,
        height: widget.itemHeight ?? double.infinity,
        child: widget.itemBuilder!(context, realIndex));

    for (int i = builders.length - 1; i >= 0; --i) {
      TransformBuilder builder = builders[i];
      child = builder.build(index, animationValue, child);
    }

    return child;
  }
}

class WarmPainter extends BasePainter {
  WarmPainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double distance = size + space;
    double start = index * (size + space);

    if (progress > 0.5) {
      double right = start + size + distance;
      //progress=>0.5-1.0
      //left:0.0=>distance

      double left = index * distance + distance * (progress - 0.5) * 2;
      canvas.drawRRect(
          RRect.fromLTRBR(left, 0.0, right, size, Radius.circular(radius)),
          _paint);
    } else {
      double right = start + size + distance * progress * 2;

      canvas.drawRRect(
          RRect.fromLTRBR(start, 0.0, right, size, Radius.circular(radius)),
          _paint);
    }
  }
}

class DropPainter extends BasePainter {
  DropPainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double dropHeight = widget.dropHeight;
    double rate = (0.5 - progress).abs() * 2;
    double scale = widget.scale;

    //lerp(begin, end, progress)

    canvas.drawCircle(
        Offset(radius + ((page) * (size + space)),
            radius - dropHeight * (1 - rate)),
        radius * (scale + rate * (1.0 - scale)),
        _paint);
  }
}

class NonePainter extends BasePainter {
  NonePainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    if (progress > 0.5) {
      canvas.drawCircle(Offset(secondOffset, radius), radius, _paint);
    } else {
      canvas.drawCircle(
          Offset(radius + (index * (size + space)), radius), radius, _paint);
    }
  }
}

class SlidePainter extends BasePainter {
  SlidePainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    canvas.drawCircle(
        Offset(radius + (page * (size + space)), radius), radius, _paint);
  }
}

class ScalePainter extends BasePainter {
  ScalePainter(super.widget, super.page, super.index, super.paint);

  // 连续的两个点，含有最后一个和第一个
  @override
  bool _shouldSkip(int i) {
    if (index == widget.count - 1) {
      return i == 0 || i == index;
    }
    return (i == index || i == index + 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    int c = widget.count;
    for (int i = 0; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(Offset(i * (size + space) + radius, radius),
          radius * widget.scale, _paint);
    }

    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    double progress = page - index;
    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //last
    canvas.drawCircle(Offset(radius + (index * (size + space)), radius),
        lerp(radius, radius * widget.scale, progress), _paint);
    //first
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(Offset(secondOffset, radius),
        lerp(radius * widget.scale, radius, progress), _paint);
  }
}

class ColorPainter extends BasePainter {
  ColorPainter(super.widget, super.page, super.index, super.paint);

  // 连续的两个点，含有最后一个和第一个
  @override
  bool _shouldSkip(int i) {
    if (index == widget.count - 1) {
      return i == 0 || i == index;
    }
    return (i == index || i == index + 1);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //left
    canvas.drawCircle(
        Offset(radius + (index * (size + space)), radius), radius, _paint);
    //right
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(Offset(secondOffset, radius), radius, _paint);
  }
}

abstract class BasePainter extends CustomPainter {
  final PageIndicator widget;
  final double page;
  final int index;
  final Paint _paint;

  double lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  BasePainter(this.widget, this.page, this.index, this._paint);

  void draw(Canvas canvas, double space, double size, double radius);

  bool _shouldSkip(int i) {
    return false;
  }
  //double secondOffset = index == widget.count-1 ? radius : radius + ((index + 1) * (size + space));

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    int c = widget.count;
    for (int i = 0; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(
          Offset(i * (size + space) + radius, radius), radius, _paint);
    }

    double page = this.page;
    if (page < index) {
      page = 0.0;
    }
    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    return oldDelegate.page != page;
  }
}

class _PageIndicatorState extends State<PageIndicator> {
  int index = 0;
  double page = 0;
  final Paint _paint = Paint();

  BasePainter _createPainter() {
    switch (widget.layout) {
      case PageIndicatorLayout.NONE:
        return NonePainter(widget, page, index, _paint);
      case PageIndicatorLayout.SLIDE:
        return SlidePainter(widget, page, index, _paint);
      case PageIndicatorLayout.WARM:
        return WarmPainter(widget, page, index, _paint);
      case PageIndicatorLayout.COLOR:
        return ColorPainter(widget, page, index, _paint);
      case PageIndicatorLayout.SCALE:
        return ScalePainter(widget, page, index, _paint);
      case PageIndicatorLayout.DROP:
        return DropPainter(widget, page, index, _paint);
      default:
        throw Exception("Not a valid layout");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: widget.count * widget.size + (widget.count - 1) * widget.space,
      height: widget.size,
      child: CustomPaint(
        painter: _createPainter(),
      ),
    );

    if (widget.layout == PageIndicatorLayout.SCALE ||
        widget.layout == PageIndicatorLayout.COLOR) {
      child = ClipRect(
        child: child,
      );
    }

    return IgnorePointer(
      child: child,
    );
  }

  void _setInitialPage() {
    // use the initial page index but cut off
    // the offset specified when looping (kMiddleValue)
    index = widget.controller.initialPage % kMiddleValue;
    page = index.toDouble();
  }

  void _onController() {
    if (!widget.controller.hasClients) return;
    page = widget.controller.page ?? 0.0;
    index = page.floor();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _setInitialPage();
  }

  @override
  void didUpdateWidget(PageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }
}

enum PageIndicatorLayout {
  NONE,
  SLIDE,
  WARM,
  COLOR,
  SCALE,
  DROP,
}

class PageIndicator extends StatefulWidget {
  /// size of the dots
  final double size;

  /// space between dots.
  final double space;

  /// count of dots
  final int count;

  /// active color
  final Color activeColor;

  /// normal color
  final Color color;

  /// layout of the dots,default is [PageIndicatorLayout.SLIDE]
  final PageIndicatorLayout? layout;

  // Only valid when layout==PageIndicatorLayout.scale
  final double scale;

  // Only valid when layout==PageIndicatorLayout.drop
  final double dropHeight;

  final PageController controller;

  final double activeSize;

  const PageIndicator({
    super.key,
    this.size = 20.0,
    this.space = 5.0,
    required this.count,
    this.activeSize = 20.0,
    required this.controller,
    this.color = Colors.white30,
    this.layout = PageIndicatorLayout.SLIDE,
    this.activeColor = Colors.white,
    this.scale = 0.6,
    this.dropHeight = 20.0,
  });

  @override
  State<StatefulWidget> createState() {
    return _PageIndicatorState();
  }
}

abstract class IndexControllerEventBase {
  final bool animation;

  final completer = Completer<void>();
  Future<void> get future => completer.future;
  void complete() {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  IndexControllerEventBase({
    required this.animation,
  });
}

mixin TargetedPositionControllerEvent on IndexControllerEventBase {
  double get targetPosition;
}
mixin StepBasedIndexControllerEvent on TargetedPositionControllerEvent {
  int get step;
  int calcNextIndex({
    required int currentIndex,
    required int itemCount,
    required bool loop,
    required bool reverse,
  }) {
    var cIndex = currentIndex;
    if (reverse) {
      cIndex -= step;
    } else {
      cIndex += step;
    }

    if (!loop) {
      if (cIndex >= itemCount) {
        cIndex = 0;
      } else if (cIndex < 0) {
        cIndex = itemCount - 1;
      }
    }
    return cIndex;
  }
}

class NextIndexControllerEvent extends IndexControllerEventBase
    with TargetedPositionControllerEvent, StepBasedIndexControllerEvent {
  NextIndexControllerEvent({
    required super.animation,
  });

  @override
  int get step => 1;

  @override
  double get targetPosition => 1;
}

class PrevIndexControllerEvent extends IndexControllerEventBase
    with TargetedPositionControllerEvent, StepBasedIndexControllerEvent {
  PrevIndexControllerEvent({
    required super.animation,
  });
  @override
  int get step => -1;

  @override
  double get targetPosition => 0;
}

class MoveIndexControllerEvent extends IndexControllerEventBase
    with TargetedPositionControllerEvent {
  final int newIndex;
  final int oldIndex;
  MoveIndexControllerEvent({
    required this.newIndex,
    required this.oldIndex,
    required super.animation,
  });
  @override
  double get targetPosition => newIndex > oldIndex ? 1 : 0;
}

class IndexController extends ChangeNotifier {
  IndexControllerEventBase? event;
  int index = 0;
  Future move(int index, {bool animation = true}) {
    final e = event = MoveIndexControllerEvent(
      animation: animation,
      newIndex: index,
      oldIndex: this.index,
    );
    notifyListeners();
    return e.future;
  }

  Future next({bool animation = true}) {
    final e = event = NextIndexControllerEvent(animation: animation);
    notifyListeners();
    return e.future;
  }

  Future previous({bool animation = true}) {
    final e = event = PrevIndexControllerEvent(animation: animation);
    notifyListeners();
    return e.future;
  }
}

typedef PaintCallback = void Function(Canvas canvas, Size size);

// class ParallaxColor extends StatefulWidget {
//   final Widget child;
//
//   final List<Color> colors;
//
//   final TransformInfo info;
//
//   const ParallaxColor({
//     Key? key,
//     required this.colors,
//     required this.info,
//     required this.child,
//   }) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return _ParallaxColorState();
//   }
// }

class ParallaxContainer extends StatelessWidget {
  final Widget child;
  final double position;
  final double translationFactor;
  final double opacityFactor;

  const ParallaxContainer({
    super.key,
    required this.child,
    required this.position,
    this.translationFactor = 100.0,
    this.opacityFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (1 - position.abs()).clamp(0.0, 1.0) * opacityFactor,
      child: Transform.translate(
        offset: Offset(position * translationFactor, 0.0),
        child: child,
      ),
    );
  }
}

class ParallaxImage extends StatelessWidget {
  final Image image;
  final double imageFactor;

  ParallaxImage.asset(
    String name, {
    super.key,
    required double position,
    this.imageFactor = 0.3,
  }) : image = Image.asset(
          name,
          fit: BoxFit.cover,
          alignment: FractionalOffset(
            0.5 + position * imageFactor,
            0.5,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return image;
  }
}

typedef SwiperOnTap = void Function(int index);

typedef SwiperDataBuilder<T> = Widget Function(
    BuildContext context, T data, int index);

/// default auto play delay
const int kDefaultAutoplayDelayMs = 3000;

///  Default auto play transition duration (in millisecond)
const int kDefaultAutoplayTransactionDuration = 300;

const int kMaxValue = 2000000000;
const int kMiddleValue = 1000000000;

enum SwiperLayout {
  DEFAULT,
  STACK,
  TINDER,
  CUSTOM,
}

class Swiper extends StatefulWidget {
  /// If set true , the pagination will display 'outer' of the 'content' container.
  final bool outer;

  /// Inner item height, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double? itemHeight;

  /// Inner item width, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double? itemWidth;

  // height of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double? containerHeight;
  // width of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double? containerWidth;

  /// Build item on index
  final IndexedWidgetBuilder? itemBuilder;

  /// Support transform like Android PageView did
  /// `itemBuilder` and `transformItemBuilder` must have one not null
  final PageTransformer? transformer;

  /// count of the display items
  final int itemCount;

  final ValueChanged<int>? onIndexChanged;

  ///auto play config
  final bool autoplay;

  ///Duration of the animation between transactions (in millisecond).
  final int autoplayDelay;

  ///disable auto play when interaction
  final bool autoplayDisableOnInteraction;

  ///auto play transition duration (in millisecond)
  final int duration;

  ///horizontal/vertical
  final Axis scrollDirection;

  ///left/right for Stack Layout
  final AxisDirection axisDirection;

  ///transition curve
  final Curve curve;

  /// Set to false to disable continuous loop mode.
  final bool loop;

  ///Index number of initial slide.
  ///If not set , the `Swiper` is 'uncontrolled', which means manage index by itself
  ///If set , the `Swiper` is 'controlled', which means the index is fully managed by parent widget.
  final int? index;

  ///Called when tap
  final SwiperOnTap? onTap;

  ///The swiper pagination plugin
  final SwiperPlugin? pagination;

  ///the swiper control button plugin
  final SwiperPlugin? control;

  ///other plugins, you can custom your own plugin
  final List<SwiperPlugin>? plugins;

  ///
  final SwiperController? controller;

  final ScrollPhysics? physics;

  ///
  final double viewportFraction;

  /// Build in layouts
  final SwiperLayout layout;

  /// this value is valid when layout == SwiperLayout.CUSTOM
  final CustomLayoutOption? customLayoutOption;

  // This value is valid when viewportFraction is set and < 1.0
  final double? scale;

  // This value is valid when viewportFraction is set and < 1.0
  final double? fade;

  final PageIndicatorLayout indicatorLayout;

  final bool allowImplicitScrolling;

  const Swiper({
    this.itemBuilder,
    this.indicatorLayout = PageIndicatorLayout.NONE,

    ///
    this.transformer,
    required this.itemCount,
    bool autoplay = false,
    this.layout = SwiperLayout.DEFAULT,
    this.autoplayDelay = kDefaultAutoplayDelayMs,
    this.autoplayDisableOnInteraction = true,
    this.duration = kDefaultAutoplayTransactionDuration,
    this.onIndexChanged,
    this.index,
    this.onTap,
    this.control,
    bool loop = true,
    this.curve = Curves.ease,
    this.scrollDirection = Axis.horizontal,
    this.axisDirection = AxisDirection.left,
    this.pagination,
    this.plugins,
    this.physics,
    super.key,
    this.controller,
    this.customLayoutOption,

    /// since v1.0.0
    this.containerHeight,
    this.containerWidth,
    this.viewportFraction = 1.0,
    this.itemHeight,
    this.itemWidth,
    this.outer = false,
    this.scale,
    this.fade,
    this.allowImplicitScrolling = false,
  })  : assert(
          itemBuilder != null || transformer != null,
          'itemBuilder and transformItemBuilder must not be both null',
        ),
        assert(
            !loop ||
                ((loop &&
                        layout == SwiperLayout.DEFAULT &&
                        (indicatorLayout == PageIndicatorLayout.SCALE ||
                            indicatorLayout == PageIndicatorLayout.COLOR ||
                            indicatorLayout == PageIndicatorLayout.NONE)) ||
                    (loop && layout != SwiperLayout.DEFAULT)),
            "Only support `PageIndicatorLayout.SCALE` and `PageIndicatorLayout.COLOR`when layout==SwiperLayout.DEFAULT in loop mode"),
        autoplay = (autoplay && itemCount > 1),
        loop = (loop && itemCount > 1);

  factory Swiper.children({
    required List<Widget> children,
    bool autoplay = false,
    PageTransformer? transformer,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    AxisDirection axisDirection = AxisDirection.left,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    CustomLayoutOption? customLayoutOption,
    ScrollPhysics? physics,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double scale = 1.0,
    double? fade,
    PageIndicatorLayout indicatorLayout = PageIndicatorLayout.NONE,
    SwiperLayout layout = SwiperLayout.DEFAULT,
  }) =>
      Swiper(
        fade: fade,
        indicatorLayout: indicatorLayout,
        layout: layout,
        transformer: transformer,
        customLayoutOption: customLayoutOption,
        containerHeight: containerHeight,
        containerWidth: containerWidth,
        viewportFraction: viewportFraction,
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        outer: outer,
        scale: scale,
        autoplay: autoplay,
        autoplayDelay: autoplayDelay,
        autoplayDisableOnInteraction: autoplayDisableOnInteraction,
        duration: duration,
        onIndexChanged: onIndexChanged,
        index: index,
        onTap: onTap,
        curve: curve,
        scrollDirection: scrollDirection,
        axisDirection: axisDirection,
        pagination: pagination,
        control: control,
        controller: controller,
        loop: loop,
        plugins: plugins,
        physics: physics,
        key: key,
        itemBuilder: (context, index) {
          return children[index];
        },
        itemCount: children.length,
      );

  static Swiper list<T>({
    PageTransformer? transformer,
    required List<T> list,
    CustomLayoutOption? customLayoutOption,
    required SwiperDataBuilder<T> builder,
    bool autoplay = false,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool reverse = false,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    AxisDirection axisDirection = AxisDirection.left,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    ScrollPhysics? physics,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double scale = 1.0,
    double? fade,
    PageIndicatorLayout indicatorLayout = PageIndicatorLayout.NONE,
    SwiperLayout layout = SwiperLayout.DEFAULT,
  }) =>
      Swiper(
        fade: fade,
        indicatorLayout: indicatorLayout,
        layout: layout,
        transformer: transformer,
        customLayoutOption: customLayoutOption,
        containerHeight: containerHeight,
        containerWidth: containerWidth,
        viewportFraction: viewportFraction,
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        outer: outer,
        scale: scale,
        autoplay: autoplay,
        autoplayDelay: autoplayDelay,
        autoplayDisableOnInteraction: autoplayDisableOnInteraction,
        duration: duration,
        onIndexChanged: onIndexChanged,
        index: index,
        onTap: onTap,
        curve: curve,
        key: key,
        scrollDirection: scrollDirection,
        axisDirection: axisDirection,
        pagination: pagination,
        control: control,
        controller: controller,
        loop: loop,
        plugins: plugins,
        physics: physics,
        itemBuilder: (context, index) {
          return builder(context, list[index], index);
        },
        itemCount: list.length,
      );

  @override
  State<StatefulWidget> createState() => _SwiperState();
}

abstract class _SwiperTimerMixin extends State<Swiper> {
  Timer? _timer;

  late SwiperController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SwiperController();
    _controller.addListener(_onController);
    if (widget.autoplay) {
      _controller.startAutoplay();
    } else {
      _controller.stopAutoplay();
    }
  }

  void _onController() {
    final event = _controller.event;
    if (event is AutoPlaySwiperControllerEvent) {
      if (event.autoplay) {
        if (_timer == null) {
          _startAutoplay();
        }
      } else {
        _stopAutoplay();
      }
    }
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != oldWidget.controller) {
      final oldController = oldWidget.controller;
      if (oldController != null) {
        oldController.removeListener(_onController);
        _controller = oldController;
        _controller.addListener(_onController);
      }
    }
    if (widget.autoplay != oldWidget.autoplay) {
      if (widget.autoplay) {
        _controller.startAutoplay();
      } else {
        _controller.stopAutoplay();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onController);
    _stopAutoplay();
    super.dispose();
  }

  void _startAutoplay() {
    _stopAutoplay();
    _timer = Timer.periodic(
      Duration(
        milliseconds: widget.autoplayDelay,
      ),
      _onTimer,
    );
  }

  void _onTimer(Timer timer) {
    _controller.next(animation: true);
  }

  void _stopAutoplay() {
    _timer?.cancel();
    _timer = null;
  }
}

class _SwiperState extends _SwiperTimerMixin {
  late int _activeIndex;

  TransformerPageController? _pageController;

  Widget _wrapTap(BuildContext context, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTap!(index),
      child: widget.itemBuilder!(context, index),
    );
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.index ?? widget.controller?.index ?? 0;
    if (_isPageViewLayout()) {
      _pageController = TransformerPageController(
        initialPage: widget.index ?? widget.controller?.index ?? 0,
        loop: widget.loop,
        itemCount: widget.itemCount,
        reverse: widget.transformer?.reverse ?? false,
        viewportFraction: widget.viewportFraction,
      );
    }
  }

  bool _isPageViewLayout() {
    return widget.layout == SwiperLayout.DEFAULT;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool _getReverse(Swiper widget) => widget.transformer?.reverse ?? false;

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPageViewLayout()) {
      if (_pageController == null ||
          (widget.index != oldWidget.index ||
              widget.loop != oldWidget.loop ||
              widget.itemCount != oldWidget.itemCount ||
              widget.viewportFraction != oldWidget.viewportFraction ||
              _getReverse(widget) != _getReverse(oldWidget))) {
        _pageController = TransformerPageController(
          initialPage: widget.index ?? widget.controller?.index ?? 0,
          loop: widget.loop,
          itemCount: widget.itemCount,
          reverse: _getReverse(widget),
          viewportFraction: widget.viewportFraction,
        );
      }
    } else {
      scheduleMicrotask(() {
        // So that we have a chance to do `removeListener` in child widgets.
        if (_pageController != null) {
          _pageController!.dispose();
          _pageController = null;
        }
      });
    }
    if (widget.index != null && widget.index != _activeIndex) {
      _activeIndex = widget.index!;
    }
  }

  void _onIndexChanged(int index) {
    setState(() {
      _activeIndex = index;
    });
    widget.onIndexChanged?.call(index);
  }

  Widget _buildSwiper() {
    IndexedWidgetBuilder? itemBuilder;
    if (widget.onTap != null) {
      itemBuilder = _wrapTap;
    } else {
      itemBuilder = widget.itemBuilder;
    }

    if (widget.layout == SwiperLayout.STACK) {
      return _StackSwiper(
        loop: widget.loop,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        axisDirection: widget.axisDirection,
      );
    } else if (_isPageViewLayout()) {
      PageTransformer? transformer = widget.transformer;
      if (widget.scale != null || widget.fade != null) {
        transformer =
            ScaleAndFadeTransformer(scale: widget.scale, fade: widget.fade);
      }

      Widget child = TransformerPageView(
        pageController: _pageController,
        loop: widget.loop,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        transformer: transformer,
        viewportFraction: widget.viewportFraction,
        index: _activeIndex,
        duration: Duration(milliseconds: widget.duration),
        scrollDirection: widget.scrollDirection,
        onPageChanged: _onIndexChanged,
        curve: widget.curve,
        physics: widget.physics,
        controller: _controller,
        allowImplicitScrolling: widget.allowImplicitScrolling,
      );
      if (widget.autoplayDisableOnInteraction && widget.autoplay) {
        return NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              if (notification.dragDetails != null) {
                //by human
                if (_timer != null) _stopAutoplay();
              }
            } else if (notification is ScrollEndNotification) {
              if (_timer == null) _startAutoplay();
            }

            return false;
          },
          child: child,
        );
      }

      return child;
    } else if (widget.layout == SwiperLayout.TINDER) {
      return _TinderSwiper(
        loop: widget.loop,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller,
        scrollDirection: widget.scrollDirection,
      );
    } else if (widget.layout == SwiperLayout.CUSTOM) {
      return _CustomLayoutSwiper(
        loop: widget.loop,
        option: widget.customLayoutOption!,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller,
        scrollDirection: widget.scrollDirection,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  SwiperPluginConfig _ensureConfig(SwiperPluginConfig? config) {
    final con = config ??
        SwiperPluginConfig(
          outer: widget.outer,
          itemCount: widget.itemCount,
          layout: widget.layout,
          indicatorLayout: widget.indicatorLayout,
          pageController: _pageController,
          activeIndex: _activeIndex,
          scrollDirection: widget.scrollDirection,
          axisDirection: widget.axisDirection,
          controller: _controller,
          loop: widget.loop,
        );
    return con;
  }

  List<Widget>? _ensureListForStack({
    required Widget swiper,
    required List<Widget>? listForStack,
    required Widget widget,
  }) {
    final resList = <Widget>[];
    if (listForStack == null) {
      resList.addAll([swiper, widget]);
    } else {
      resList.addAll([...listForStack, widget]);
    }
    return resList;
  }

  @override
  Widget build(BuildContext context) {
    Widget swiper = _buildSwiper();
    List<Widget>? listForStack;
    SwiperPluginConfig? config;
    if (widget.control != null) {
      //Stack
      config = _ensureConfig(config);
      listForStack = _ensureListForStack(
        swiper: swiper,
        listForStack: listForStack,
        widget: widget.control!.build(context, config),
      );
    }

    if (widget.plugins != null) {
      config = _ensureConfig(config);
      for (SwiperPlugin plugin in widget.plugins!) {
        listForStack = _ensureListForStack(
          swiper: swiper,
          listForStack: listForStack,
          widget: plugin.build(context, config),
        );
      }
    }
    if (widget.pagination != null) {
      config = _ensureConfig(config);
      if (widget.outer) {
        return _buildOuterPagination(
            widget.pagination! as SwiperPagination,
            listForStack == null ? swiper : Stack(children: listForStack),
            config);
      } else {
        listForStack = _ensureListForStack(
          swiper: swiper,
          listForStack: listForStack,
          widget: widget.pagination!.build(context, config),
        );
      }
    }

    if (listForStack != null) {
      return Stack(
        children: listForStack,
      );
    }

    return swiper;
  }

  Widget _buildOuterPagination(
    SwiperPagination pagination,
    Widget swiper,
    SwiperPluginConfig config,
  ) {
    final list = <Widget>[];
    //Only support bottom yet!
    if (widget.containerHeight != null || widget.containerWidth != null) {
      list.add(swiper);
    } else {
      list.add(Expanded(child: swiper));
    }

    list.add(Align(
      alignment: Alignment.center,
      child: pagination.build(context, config),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }
}

abstract class _SubSwiper extends StatefulWidget {
  final IndexedWidgetBuilder? itemBuilder;
  final int itemCount;
  final int? index;
  final ValueChanged<int>? onIndexChanged;
  final SwiperController controller;
  final int? duration;
  final Curve curve;
  final double? itemWidth;
  final double? itemHeight;
  final bool loop;
  final Axis? scrollDirection;
  final AxisDirection? axisDirection;

  const _SubSwiper({
    required this.loop,
    this.itemHeight,
    this.itemWidth,
    this.duration,
    required this.curve,
    this.itemBuilder,
    required this.controller,
    this.index,
    required this.itemCount,
    this.scrollDirection = Axis.horizontal,
    this.axisDirection = AxisDirection.left,
    this.onIndexChanged,
  });

  @override
  State<StatefulWidget> createState();

  int getCorrectIndex(int indexNeedsFix) {
    if (itemCount == 0) return 0;
    var value = indexNeedsFix % itemCount;
    if (value < 0) {
      value += itemCount;
    }
    return value;
  }
}

class _TinderSwiper extends _SubSwiper {
  const _TinderSwiper({
    required super.curve,
    super.duration,
    required super.controller,
    super.onIndexChanged,
    super.itemHeight,
    super.itemWidth,
    super.itemBuilder,
    super.index,
    required super.loop,
    required super.itemCount,
    super.scrollDirection = null,
  }) : assert(itemWidth != null && itemHeight != null);

  @override
  State<StatefulWidget> createState() {
    return _TinderState();
  }
}

class _StackSwiper extends _SubSwiper {
  const _StackSwiper({
    required super.curve,
    super.duration,
    required super.controller,
    super.onIndexChanged,
    super.itemHeight,
    super.itemWidth,
    super.itemBuilder,
    super.index,
    required super.loop,
    required super.itemCount,
    super.scrollDirection = null,
    super.axisDirection = null,
  });

  @override
  State<StatefulWidget> createState() => _StackViewState();
}

class _TinderState extends _CustomLayoutStateBase<_TinderSwiper> {
  late List<double> scales;
  late List<double> offsetsX;
  late List<double> offsetsY;
  late List<double> opacity;
  late List<double> rotates;

  double getOffsetY(double scale) {
    return widget.itemHeight! - widget.itemHeight! * scale;
  }

  @override
  void didUpdateWidget(_TinderSwiper oldWidget) {
    _updateValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterRender() {
    super.afterRender();

    _startIndex = -3;
    _animationCount = 5;
    opacity = [0.0, 0.9, 0.9, 1.0, 0.0, 0.0];
    scales = [0.80, 0.80, 0.85, 0.90, 1.0, 1.0, 1.0];
    rotates = [0.0, 0.0, 0.0, 0.0, 20.0, 25.0];
    _updateValues();
  }

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      offsetsX = [0.0, 0.0, 0.0, 0.0, _swiperWidth, _swiperWidth];
      offsetsY = [
        0.0,
        0.0,
        -5.0,
        -10.0,
        -15.0,
        -20.0,
      ];
    } else {
      offsetsX = [
        0.0,
        0.0,
        5.0,
        10.0,
        15.0,
        20.0,
      ];

      offsetsY = [0.0, 0.0, 0.0, 0.0, _swiperHeight, _swiperHeight];
    }
  }

  @override
  Widget _buildItem(int i, int realIndex, double animationValue) {
    double s = _getValue(scales, animationValue, i);
    double f = _getValue(offsetsX, animationValue, i);
    double fy = _getValue(offsetsY, animationValue, i);
    double o = _getValue(opacity, animationValue, i);
    double a = _getValue(rotates, animationValue, i);

    Alignment alignment = widget.scrollDirection == Axis.horizontal
        ? Alignment.bottomCenter
        : Alignment.centerLeft;

    return Opacity(
      opacity: o,
      child: Transform.rotate(
        angle: a / 180.0,
        child: Transform.translate(
          key: ValueKey<int>(_currentIndex + i),
          offset: Offset(f, fy),
          child: Transform.scale(
            scale: s,
            alignment: alignment,
            child: SizedBox(
              width: widget.itemWidth ?? double.infinity,
              height: widget.itemHeight ?? double.infinity,
              child: widget.itemBuilder!(context, realIndex),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackViewState extends _CustomLayoutStateBase<_StackSwiper> {
  late List<double> scales;
  late List<double> offsets;
  late List<double> opacity;

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      double space = (_swiperWidth - widget.itemWidth!) / 2;
      offsets = widget.axisDirection == AxisDirection.left
          ? [-space, -space / 3 * 2, -space / 3, 0.0, _swiperWidth]
          : [_swiperWidth, 0.0, -space / 3, -space / 3 * 2, -space];
    } else {
      double space = (_swiperHeight - widget.itemHeight!) / 2;
      offsets = [-space, -space / 3 * 2, -space / 3, 0.0, _swiperHeight];
    }
  }

  @override
  void didUpdateWidget(_StackSwiper oldWidget) {
    _updateValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterRender() {
    super.afterRender();
    final isRightSide = widget.axisDirection == AxisDirection.right;

    //length of the values array below
    _animationCount = 5;

    //Array below this line, '0' index is 1.0, which is the first item show in swiper.
    _startIndex = isRightSide ? -1 : -3;
    scales =
        isRightSide ? [1.0, 1.0, 0.9, 0.8, 0.7] : [0.7, 0.8, 0.9, 1.0, 1.0];
    opacity =
        isRightSide ? [1.0, 1.0, 1.0, 0.5, 0.0] : [0.0, 0.5, 1.0, 1.0, 1.0];

    _updateValues();
  }

  @override
  Widget _buildItem(int i, int realIndex, double animationValue) {
    double s = _getValue(scales, animationValue, i);
    double f = _getValue(offsets, animationValue, i);
    double o = _getValue(opacity, animationValue, i);

    Offset offset = widget.scrollDirection == Axis.horizontal
        ? widget.axisDirection == AxisDirection.left
            ? Offset(f, 0.0)
            : Offset(-f, 0.0)
        : Offset(0.0, f);

    Alignment alignment = widget.scrollDirection == Axis.horizontal
        ? widget.axisDirection == AxisDirection.left
            ? Alignment.centerLeft
            : Alignment.centerRight
        : Alignment.topCenter;

    return Opacity(
      opacity: o,
      child: Transform.translate(
        key: ValueKey<int>(_currentIndex + i),
        offset: offset,
        child: Transform.scale(
          scale: s,
          alignment: alignment,
          child: SizedBox(
            width: widget.itemWidth ?? double.infinity,
            height: widget.itemHeight ?? double.infinity,
            child: widget.itemBuilder!(context, realIndex),
          ),
        ),
      ),
    );
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double? _scale;
  final double? _fade;

  ScaleAndFadeTransformer({double? fade = 0.3, double? scale = 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double? position = info.position;
    Widget newChild = child;
    if (_scale != null) {
      double scaleFactor = (1 - position!.abs()) * (1 - _scale);
      double scale = _scale + scaleFactor;

      newChild = Transform.scale(
        scale: scale,
        child: child,
      );
    }

    if (_fade != null) {
      double fadeFactor = (1 - position!.abs()) * (1 - _fade);
      double opacity = _fade + fadeFactor;
      newChild = Opacity(
        opacity: opacity,
        child: newChild,
      );
    }

    return newChild;
  }
}

class SwiperControl extends SwiperPlugin {
  ///IconData for previous
  final IconData iconPrevious;

  ///iconData fopr next
  final IconData iconNext;

  ///icon size
  final double size;

  ///Icon normal color, The theme's [ThemeData.primaryColor] by default.
  final Color? color;

  ///if set loop=false on Swiper, this color will be used when swiper goto the last slide.
  ///The theme's [ThemeData.disabledColor] by default.
  final Color? disableColor;

  final EdgeInsetsGeometry padding;

  final Key? key;

  const SwiperControl({
    this.iconPrevious = Icons.arrow_back_ios,
    this.iconNext = Icons.arrow_forward_ios,
    this.color,
    this.disableColor,
    this.key,
    this.size = 30.0,
    this.padding = const EdgeInsets.all(5.0),
  });

  Widget buildButton({
    required SwiperPluginConfig? config,
    required Color color,
    required IconData iconDaga,
    required int quarterTurns,
    required bool previous,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (previous) {
          config!.controller.previous(animation: true);
        } else {
          config!.controller.next(animation: true);
        }
      },
      child: Padding(
          padding: padding,
          child: RotatedBox(
              quarterTurns: quarterTurns,
              child: Icon(
                iconDaga,
                semanticLabel: previous ? "Previous" : "Next",
                size: size,
                color: color,
              ))),
    );
  }

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    ThemeData themeData = Theme.of(context);

    Color color = this.color ?? themeData.primaryColor;
    Color disableColor = this.disableColor ?? themeData.disabledColor;
    Color prevColor;
    Color nextColor;

    if (config.loop) {
      prevColor = nextColor = color;
    } else {
      bool next = config.activeIndex < config.itemCount - 1;
      bool prev = config.activeIndex > 0;
      prevColor = prev ? color : disableColor;
      nextColor = next ? color : disableColor;
    }

    Widget child;
    if (config.scrollDirection == Axis.horizontal) {
      child = Row(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(
            config: config,
            color: prevColor,
            iconDaga: iconPrevious,
            quarterTurns: 0,
            previous: true,
          ),
          buildButton(
            config: config,
            color: nextColor,
            iconDaga: iconNext,
            quarterTurns: 0,
            previous: false,
          )
        ],
      );
    } else {
      child = Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(
            config: config,
            color: prevColor,
            iconDaga: iconPrevious,
            quarterTurns: -3,
            previous: true,
          ),
          buildButton(
            config: config,
            color: nextColor,
            iconDaga: iconNext,
            quarterTurns: -3,
            previous: false,
          )
        ],
      );
    }

    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: child,
    );
  }
}

class SwipeIndexControllerEvent extends IndexControllerEventBase {
  SwipeIndexControllerEvent({
    required this.pos,
    required super.animation,
  });
  final double pos;
}

class BuildIndexControllerEvent extends IndexControllerEventBase {
  BuildIndexControllerEvent({
    required super.animation,
    required this.config,
  });
  final SwiperPluginConfig config;
}

class AutoPlaySwiperControllerEvent extends IndexControllerEventBase {
  AutoPlaySwiperControllerEvent({
    required super.animation,
    required this.autoplay,
  });

  AutoPlaySwiperControllerEvent.start({
    required bool animation,
  }) : this(animation: animation, autoplay: true);
  AutoPlaySwiperControllerEvent.stop({
    required bool animation,
  }) : this(animation: animation, autoplay: false);
  final bool autoplay;
}

class SwiperController extends IndexController {
  void startAutoplay({bool animation = true}) {
    event = AutoPlaySwiperControllerEvent.start(animation: animation);
    notifyListeners();
  }

  void stopAutoplay({bool animation = true}) {
    event = AutoPlaySwiperControllerEvent.stop(animation: animation);
    notifyListeners();
  }
}

class FractionPaginationBuilder extends SwiperPlugin {
  ///color ,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///color when active,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ////font size
  final double fontSize;

  ///font size when active
  final double activeFontSize;

  final Key? key;

  const FractionPaginationBuilder({
    this.color,
    this.fontSize = 20.0,
    this.key,
    this.activeColor,
    this.activeFontSize = 35.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    int itemCount = config.itemCount;
    if (itemCount <= 1) {
      return Container();
    }

    ThemeData themeData = Theme.of(context);
    Color activeColor = this.activeColor ?? themeData.primaryColor;
    Color color = this.color ?? themeData.scaffoldBackgroundColor;

    if (Axis.vertical == config.scrollDirection) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "${config.activeIndex + 1}",
            style: TextStyle(color: activeColor, fontSize: activeFontSize),
          ),
          Text(
            "/",
            style: TextStyle(color: color, fontSize: fontSize),
          ),
          Text(
            "$itemCount",
            style: TextStyle(color: color, fontSize: fontSize),
          )
        ],
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "${config.activeIndex + 1}",
            style: TextStyle(color: activeColor, fontSize: activeFontSize),
          ),
          Text(
            " / $itemCount",
            style: TextStyle(color: color, fontSize: fontSize),
          )
        ],
      );
    }
  }
}

class RectSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the rect when activate
  final Size activeSize;

  ///Size of the rect
  final Size size;

  /// Space between rects
  final double space;

  final Key? key;

  const RectSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = const Size(10.0, 3.0),
    this.activeSize = const Size(10.0, 3.0),
    this.space = 2.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    int itemCount = config.itemCount;
    if (itemCount <= 1) {
      return Container();
    }

    ThemeData themeData = Theme.of(context);
    Color activeColor = this.activeColor ?? themeData.primaryColor;
    Color color = this.color ?? themeData.scaffoldBackgroundColor;

    List<Widget> list = [];

    int activeIndex = config.activeIndex;
    if (itemCount > 20) {
      debugPrint(
          "The itemCount is too big, we suggest use FractionPaginationBuilder instead of DotSwiperPaginationBuilder in this situation");
    }

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      Size size = active ? activeSize : this.size;
      list.add(Container(
        width: size.width,
        height: size.height,
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.5),
          color: active ? activeColor : color,
        ),
      ));
    }

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}

class DotSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the dot when activate
  final double activeSize;

  ///Size of the dot
  final double size;

  /// Space between dots
  final double space;

  final Key? key;

  const DotSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = 10.0,
    this.activeSize = 10.0,
    this.space = 3.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    int itemCount = config.itemCount;
    if (itemCount <= 1) {
      return Container();
    }

    if (config.itemCount > 20) {
      debugPrint(
          "The itemCount is too big, we suggest use FractionPaginationBuilder instead of DotSwiperPaginationBuilder in this sitituation");
    }
    Color? activeColor = this.activeColor;
    Color? color = this.color;

    if (activeColor == null || color == null) {
      ThemeData themeData = Theme.of(context);
      activeColor = this.activeColor ?? themeData.primaryColor;
      color = this.color ?? themeData.scaffoldBackgroundColor;
    }

    if (config.indicatorLayout != PageIndicatorLayout.NONE &&
        config.layout == SwiperLayout.DEFAULT) {
      return PageIndicator(
        count: config.itemCount,
        controller: config.pageController!,
        layout: config.indicatorLayout,
        size: size,
        activeColor: activeColor,
        color: color,
        space: space,
      );
    }

    List<Widget> list = [];

    int? activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      list.add(Container(
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
        child: ClipOval(
          child: Container(
            color: active ? activeColor : color,
            width: active ? activeSize : size,
            height: active ? activeSize : size,
          ),
        ),
      ));
    }

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}

typedef SwiperPaginationBuilder = Widget Function(
    BuildContext context, SwiperPluginConfig config);

class SwiperCustomPagination extends SwiperPlugin {
  final SwiperPaginationBuilder builder;

  const SwiperCustomPagination({required this.builder});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return builder(context, config);
  }
}

class SwiperPagination extends SwiperPlugin {
  /// dot style pagination
  static const SwiperPlugin dots = DotSwiperPaginationBuilder();

  /// fraction style pagination
  static const SwiperPlugin fraction = FractionPaginationBuilder();

  /// round rect style pagination
  static const SwiperPlugin rect = RectSwiperPaginationBuilder();

  /// Alignment.bottomCenter by default when scrollDirection== Axis.horizontal
  /// Alignment.centerRight by default when scrollDirection== Axis.vertical
  final Alignment? alignment;

  /// Distance between pagination and the container
  final EdgeInsetsGeometry margin;

  /// Build the widget
  final SwiperPlugin builder;

  final Key? key;

  const SwiperPagination({
    this.alignment,
    this.key,
    this.margin = const EdgeInsets.all(10.0),
    this.builder = SwiperPagination.dots,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    Alignment defaultAlignment = config.scrollDirection == Axis.horizontal
        ? Alignment.bottomCenter
        : Alignment.centerRight;
    Widget child = Container(
      margin: margin,
      child: builder.build(context, config),
    );
    if (!config.outer!) {
      child = Align(
        key: key,
        alignment: alignment ?? defaultAlignment,
        child: child,
      );
    }
    return child;
  }
}

abstract class SwiperPlugin {
  const SwiperPlugin();

  Widget build(BuildContext context, SwiperPluginConfig config);
}

class SwiperPluginConfig {
  final Axis scrollDirection;
  final AxisDirection? axisDirection;
  final SwiperController controller;
  final int activeIndex;
  final int itemCount;
  final PageIndicatorLayout? indicatorLayout;
  final bool loop;
  final bool? outer;
  final PageController? pageController;
  final SwiperLayout? layout;

  const SwiperPluginConfig({
    required this.scrollDirection,
    required this.controller,
    required this.activeIndex,
    required this.itemCount,
    this.axisDirection,
    this.indicatorLayout,
    this.outer,
    this.pageController,
    this.layout,
    this.loop = false,
  });
}

class SwiperPluginView extends StatelessWidget {
  final SwiperPlugin plugin;
  final SwiperPluginConfig config;

  const SwiperPluginView({
    super.key,
    required this.plugin,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return plugin.build(context, config);
  }
}

///  Default auto play transition duration (in millisecond)
const int kDefaultTransactionDuration = 300;

class TransformInfo {
  /// The `width` of the `TransformerPageView`
  final double? width;

  /// The `height` of the `TransformerPageView`
  final double? height;

  /// The `position` of the widget pass to [PageTransformer.transform]
  ///  A `position` describes how visible the widget is.
  ///  The widget in the center of the screen' which is  full visible, position is 0.0.
  ///  The widge in the left ,may be hidden, of the screen's position is less than 0.0, -1.0 when out of the screen.
  ///  The widge in the right ,may be hidden, of the screen's position is greater than 0.0,  1.0 when out of the screen
  ///
  ///
  final double? position;

  /// The `index` of the widget pass to [PageTransformer.transform]
  final int? index;

  /// The `activeIndex` of the PageView
  final int? activeIndex;

  /// The `activeIndex` of the PageView, from user start to swipe
  /// It will change when user end drag
  final int fromIndex;

  /// Next `index` is greater than this `index`
  final bool? forward;

  /// User drag is done.
  final bool? done;

  /// Same as [TransformerPageView.viewportFraction]
  final double? viewportFraction;

  /// Copy from [TransformerPageView.scrollDirection]
  final Axis? scrollDirection;

  TransformInfo({
    this.index,
    this.position,
    this.width,
    this.height,
    this.activeIndex,
    required this.fromIndex,
    this.forward,
    this.done,
    this.viewportFraction,
    this.scrollDirection,
  });
}

abstract class PageTransformer {
  ///
  final bool reverse;

  PageTransformer({this.reverse = false});

  /// Return a transformed widget, based on child and TransformInfo
  Widget transform(Widget child, TransformInfo info);
}

typedef PageTransformerBuilderCallback = Widget Function(
    Widget child, TransformInfo info);

class PageTransformerBuilder extends PageTransformer {
  final PageTransformerBuilderCallback builder;

  PageTransformerBuilder({super.reverse, required this.builder});

  @override
  Widget transform(Widget child, TransformInfo info) {
    return builder(child, info);
  }
}

class TransformerPageController extends PageController {
  final bool loop;
  final int itemCount;
  final bool reverse;

  TransformerPageController({
    int initialPage = 0,
    super.keepPage,
    super.viewportFraction,
    this.loop = false,
    this.itemCount = 0,
    this.reverse = false,
  }) : super(
          initialPage: TransformerPageController._getRealIndexFromRenderIndex(
              initialPage, loop, itemCount, reverse),
        );

  int getRenderIndexFromRealIndex(num index) {
    return _getRenderIndexFromRealIndex(index, loop, itemCount, reverse);
  }

  int? getRealItemCount() {
    if (itemCount == 0) return 0;
    return loop ? itemCount + kMaxValue : itemCount;
  }

  static int _getRenderIndexFromRealIndex(
    num index,
    bool loop,
    int itemCount,
    bool reverse,
  ) {
    if (itemCount == 0) return 0;
    int renderIndex;
    if (loop) {
      renderIndex = (index - kMiddleValue).toInt();
      renderIndex = renderIndex % itemCount;
      if (renderIndex < 0) {
        renderIndex += itemCount;
      }
    } else {
      renderIndex = index.toInt();
    }
    if (reverse) {
      renderIndex = itemCount - renderIndex - 1;
    }

    return renderIndex;
  }

  double get realPage => super.page ?? 0.0;

  static double? _getRenderPageFromRealPage(
    double page,
    bool loop,
    int itemCount,
    bool reverse,
  ) {
    double? renderPage;
    if (loop) {
      renderPage = page - kMiddleValue;
      renderPage = renderPage % itemCount;
      if (renderPage < 0) {
        renderPage += itemCount;
      }
    } else {
      renderPage = page;
    }
    if (reverse) {
      renderPage = itemCount - renderPage - 1;
    }

    return renderPage;
  }

  @override
  double? get page {
    return loop
        ? _getRenderPageFromRealPage(realPage, loop, itemCount, reverse)
        : realPage;
  }

  int getRealIndexFromRenderIndex(num index) {
    return _getRealIndexFromRenderIndex(index, loop, itemCount, reverse);
  }

  static int _getRealIndexFromRenderIndex(
      num index, bool loop, int itemCount, bool reverse) {
    int result = reverse ? itemCount - index - 1 as int : index as int;
    if (loop) {
      result += kMiddleValue;
    }
    return result;
  }
}

class TransformerPageView extends StatefulWidget {
  /// Create a `transformed` widget base on the widget that has been passed to  the [PageTransformer.transform].
  /// See [TransformInfo]
  ///
  final PageTransformer? transformer;

  /// Same as [PageView.scrollDirection]
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Same as [PageView.physics]
  final ScrollPhysics? physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  /// Same as [PageView.pageSnapping]
  final bool pageSnapping;

  /// Called whenever the page in the center of the viewport changes.
  /// Same as [PageView.onPageChanged]
  final ValueChanged<int>? onPageChanged;

  final IndexedWidgetBuilder? itemBuilder;

  // See [IndexController.mode],[IndexController.next],[IndexController.previous]
  final IndexController? controller;

  /// Animation duration
  final Duration duration;

  /// Animation curve
  final Curve curve;

  final TransformerPageController? pageController;

  /// Set true to open infinity loop mode.
  final bool loop;

  /// This value is only valid when `pageController` is not set,
  final int itemCount;

  /// This value is only valid when `pageController` is not set,
  final double viewportFraction;

  /// If not set, it is controlled by this widget.
  final int? index;

  final bool allowImplicitScrolling;

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [PageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  const TransformerPageView({
    super.key,
    this.index,
    Duration? duration,
    this.curve = Curves.ease,
    this.viewportFraction = 1.0,
    required this.loop,
    this.scrollDirection = Axis.horizontal,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.controller,
    this.transformer,
    this.allowImplicitScrolling = false,
    this.itemBuilder,
    this.pageController,
    required this.itemCount,
  })  : assert(itemCount == 0 || itemBuilder != null || transformer != null),
        duration = duration ??
            const Duration(milliseconds: kDefaultTransactionDuration);

  factory TransformerPageView.children({
    Key? key,
    int? index,
    Duration? duration,
    Curve curve = Curves.ease,
    double viewportFraction = 1.0,
    bool loop = false,
    Axis scrollDirection = Axis.horizontal,
    ScrollPhysics? physics,
    bool pageSnapping = true,
    ValueChanged<int?>? onPageChanged,
    IndexController? controller,
    PageTransformer? transformer,
    bool allowImplicitScrolling = false,
    required List<Widget> children,
    TransformerPageController? pageController,
  }) {
    return TransformerPageView(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      pageController: pageController,
      transformer: transformer,
      pageSnapping: pageSnapping,
      key: key,
      index: index,
      loop: loop,
      duration: duration,
      curve: curve,
      viewportFraction: viewportFraction,
      scrollDirection: scrollDirection,
      physics: physics,
      allowImplicitScrolling: allowImplicitScrolling,
      onPageChanged: onPageChanged,
      controller: controller,
    );
  }

  @override
  State<StatefulWidget> createState() => _TransformerPageViewState();

  static int getRealIndexFromRenderIndex({
    required bool reverse,
    int index = 0,
    int itemCount = 0,
    required bool loop,
  }) {
    int initPage = reverse ? (itemCount - index - 1) : index;
    if (loop) {
      initPage += kMiddleValue;
    }
    return initPage;
  }

  static PageController createPageController({
    required bool reverse,
    int index = 0,
    int itemCount = 0,
    required bool loop,
    required double viewportFraction,
  }) {
    return PageController(
      initialPage: getRealIndexFromRenderIndex(
        reverse: reverse,
        index: index,
        itemCount: itemCount,
        loop: loop,
      ),
      viewportFraction: viewportFraction,
    );
  }
}

class _TransformerPageViewState extends State<TransformerPageView> {
  Size? _size;
  int _activeIndex = 0;
  late double _currentPixels;
  bool _done = false;

  ///This value will not change until user end drag.
  late int _fromIndex;

  PageTransformer? _transformer;

  late TransformerPageController _pageController;

  Widget _buildItemNormal(BuildContext context, int index) {
    int renderIndex = _pageController.getRenderIndexFromRealIndex(index);
    return widget.itemBuilder!(context, renderIndex);
  }

  Widget _buildItem(BuildContext context, int index) {
    return AnimatedBuilder(
        animation: _pageController,
        builder: (c, w) {
          int renderIndex = _pageController.getRenderIndexFromRealIndex(index);
          Widget child = widget.itemBuilder?.call(context, renderIndex) ??
              const SizedBox.shrink();
          if (_size == null) {
            return child;
          }

          double position;

          double page = _pageController.realPage;

          if (_transformer!.reverse) {
            position = page - index;
          } else {
            position = index - page;
          }
          position *= widget.viewportFraction;

          TransformInfo info = TransformInfo(
            index: renderIndex,
            width: _size!.width,
            height: _size!.height,
            position: position.clamp(-1.0, 1.0),
            activeIndex:
                _pageController.getRenderIndexFromRealIndex(_activeIndex),
            fromIndex: _fromIndex,
            forward: _pageController.position.pixels - _currentPixels >= 0,
            done: _done,
            scrollDirection: widget.scrollDirection,
            viewportFraction: widget.viewportFraction,
          );
          return _transformer!.transform(child, info);
        });
  }

  double? _calcCurrentPixels() {
    _currentPixels = _pageController.getRenderIndexFromRealIndex(_activeIndex) *
        _pageController.position.viewportDimension *
        widget.viewportFraction;

    //  print("activeIndex:$_activeIndex , pix:$_currentPixels");

    return _currentPixels;
  }

  @override
  Widget build(BuildContext context) {
    IndexedWidgetBuilder builder =
        _transformer == null ? _buildItemNormal : _buildItem;
    Widget child = PageView.builder(
      allowImplicitScrolling: widget.allowImplicitScrolling,
      itemBuilder: builder,
      itemCount: _pageController.getRealItemCount(),
      onPageChanged: _onIndexChanged,
      controller: _pageController,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      reverse: _pageController.reverse,
    );
    if (_transformer == null) {
      return child;
    }
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _calcCurrentPixels();
          _done = false;
          _fromIndex = _activeIndex;
        } else if (notification is ScrollEndNotification) {
          _calcCurrentPixels();
          _fromIndex = _activeIndex;
          _done = true;
        }

        return false;
      },
      child: child,
    );
  }

  void _onIndexChanged(int index) {
    _activeIndex = index;
    widget.onPageChanged
        ?.call(_pageController.getRenderIndexFromRealIndex(index));
  }

  void _onGetSize(Duration _) {
    if (!mounted) return;
    Size? size;
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject != null) {
      Rect bounds = renderObject.paintBounds;
      size = bounds.size;
    }
    _calcCurrentPixels();
    onGetSize(size);
  }

  void onGetSize(Size? size) {
    if (mounted) {
      setState(() {
        _size = size;
      });
    }
  }

  IndexController? _controller;

  @override
  void initState() {
    _transformer = widget.transformer;
    //  int index = widget.index ?? 0;
    _pageController = widget.pageController ??
        TransformerPageController(
          initialPage: widget.index ?? 0,
          itemCount: widget.itemCount,
          loop: widget.loop,
          reverse: widget.transformer?.reverse ?? false,
        );
    // int initPage = _getRealIndexFromRenderIndex(index);
    // _pageController = PageController(initialPage: initPage,viewportFraction: widget.viewportFraction);
    _fromIndex = _activeIndex = _pageController.initialPage;

    _controller = widget.controller;
    _controller?.addListener(onChangeNotifier);
    super.initState();
  }

  @override
  void didUpdateWidget(TransformerPageView oldWidget) {
    _transformer = widget.transformer;
    int index = widget.index ?? 0;
    bool created = false;
    if (_pageController != widget.pageController) {
      if (widget.pageController != null) {
        _pageController = widget.pageController!;
      } else {
        created = true;
        _pageController = TransformerPageController(
          initialPage: widget.index ?? 0,
          itemCount: widget.itemCount,
          loop: widget.loop,
          reverse: widget.transformer?.reverse ?? false,
        );
      }
    }

    if (_pageController.getRenderIndexFromRealIndex(_activeIndex) != index) {
      _fromIndex = _activeIndex = _pageController.initialPage;
      if (!created) {
        int initPage = _pageController.getRealIndexFromRenderIndex(index);
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            initPage,
            duration: widget.duration,
            curve: widget.curve,
          );
        }
      }
    }
    if (_transformer != null) {
      WidgetsBinding.instance.addPostFrameCallback(_onGetSize);
    }

    if (_controller != widget.controller) {
      _controller?.removeListener(onChangeNotifier);
      _controller = widget.controller;
      _controller?.addListener(onChangeNotifier);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (_transformer != null) {
      WidgetsBinding.instance.addPostFrameCallback(_onGetSize);
    }
    super.didChangeDependencies();
  }

  void onChangeNotifier() {
    final controller = widget.controller!;
    final event = controller.event;
    int index;
    if (event == null) return;
    if (event is MoveIndexControllerEvent) {
      index = _pageController.getRealIndexFromRenderIndex(event.newIndex);
    } else if (event is StepBasedIndexControllerEvent) {
      index = event.calcNextIndex(
        currentIndex: _activeIndex,
        itemCount: _pageController.itemCount,
        loop: _pageController.loop,
        reverse: _pageController.reverse,
      );
    } else {
      //ignore other events
      return;
    }
    if (_pageController.hasClients) {
      if (event.animation) {
        _pageController
            .animateToPage(
              index,
              duration: widget.duration,
              curve: widget.curve,
            )
            .whenComplete(event.complete);
      } else {
        event.complete();
      }
    } else {
      event.complete();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(onChangeNotifier);
    super.dispose();
  }
}
