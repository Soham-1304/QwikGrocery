library widgets;

import 'foundation.dart';
export 'foundation.dart';

abstract class BuildContext {
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();
  dynamic getElementForInheritedWidgetOfExactType<T extends InheritedWidget>();
}

abstract class Widget {
  const Widget({this.key});
  final Key? key;
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});
  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});
  State createState();
}

abstract class State<T extends StatefulWidget> {
  late T widget;
  late BuildContext context;
  void initState() {}
  void didUpdateWidget(T oldWidget) {}
  void dispose() {}
  void setState(VoidCallback fn) {
    fn();
  }
  Widget build(BuildContext context);
}

abstract class InheritedWidget extends Widget {
  const InheritedWidget({super.key, required this.child});
  final Widget child;
  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

class InheritedNotifier<T extends Listenable> extends InheritedWidget {
  const InheritedNotifier({super.key, this.notifier, required super.child});
  final T? notifier;

  @override
  bool updateShouldNotify(InheritedNotifier<T> oldWidget) =>
      notifier != oldWidget.notifier;
}

class Text extends Widget {
  const Text(this.data, {super.key, this.style, this.maxLines, this.overflow});
  final String data;
  final dynamic style;
  final int? maxLines;
  final dynamic overflow;
  @override
  String toString() => 'Text("$data")';
}

class Icon extends Widget {
  const Icon(this.icon, {super.key, this.size, this.color});
  final dynamic icon;
  final double? size;
  final dynamic color;
  @override
  String toString() => 'Icon($icon)';
}

class SizedBox extends Widget {
  const SizedBox({super.key, this.width, this.height, this.child});
  const SizedBox.shrink({super.key}) : width = 0.0, height = 0.0, child = null;
  final double? width;
  final double? height;
  final Widget? child;
}

class Spacer extends Widget {
  const Spacer({super.key, this.flex = 1});
  final int flex;
}

class Container extends Widget {
  const Container({super.key, this.width, this.height, this.padding, this.margin, this.decoration, this.child, this.color});
  final double? width;
  final double? height;
  final dynamic padding;
  final dynamic margin;
  final dynamic decoration;
  final dynamic color;
  final Widget? child;
}

class Column extends Widget {
  const Column({super.key, this.children = const [], this.mainAxisAlignment, this.crossAxisAlignment, this.mainAxisSize});
  final List<Widget> children;
  final dynamic mainAxisAlignment;
  final dynamic crossAxisAlignment;
  final dynamic mainAxisSize;
}

class Row extends Widget {
  const Row({super.key, this.children = const [], this.mainAxisAlignment, this.crossAxisAlignment, this.mainAxisSize});
  final List<Widget> children;
  final dynamic mainAxisAlignment;
  final dynamic crossAxisAlignment;
  final dynamic mainAxisSize;
}

class Stack extends Widget {
  const Stack({super.key, this.children = const []});
  final List<Widget> children;
}

class Positioned extends Widget {
  const Positioned({super.key, this.left, this.top, this.right, this.bottom, required this.child});
  final double? left, top, right, bottom;
  final Widget child;
}

class Expanded extends Widget {
  const Expanded({super.key, required this.child, this.flex = 1});
  final Widget child;
  final int flex;
}

class Padding extends Widget {
  const Padding({super.key, required this.padding, this.child});
  final dynamic padding;
  final Widget? child;
}

class Center extends Widget {
  const Center({super.key, this.child});
  final Widget? child;
}

class InkWell extends Widget {
  const InkWell({super.key, this.onTap, this.child});
  final VoidCallback? onTap;
  final Widget? child;
}

class ElevatedButton extends Widget {
  const ElevatedButton({super.key, required this.onPressed, required this.child, this.style});
  final VoidCallback? onPressed;
  final Widget child;
  final dynamic style;
  static dynamic styleFrom({dynamic backgroundColor, dynamic foregroundColor, dynamic side, dynamic elevation, dynamic padding, dynamic shape}) => null;
}

class FilledButton extends Widget {
  const FilledButton({super.key, required this.onPressed, required this.child, this.style});
  final VoidCallback? onPressed;
  final Widget child;
  final dynamic style;
  static dynamic styleFrom({dynamic backgroundColor, dynamic foregroundColor, dynamic elevation, dynamic padding, dynamic shape, dynamic textStyle}) => null;
}

class OutlinedButton extends Widget {
  const OutlinedButton({super.key, required this.onPressed, required this.child, this.style});
  final VoidCallback? onPressed;
  final Widget child;
  final dynamic style;
  static dynamic styleFrom({dynamic foregroundColor, dynamic side, dynamic shape, dynamic padding, dynamic textStyle}) => null;
}

class TextButton extends Widget {
  const TextButton({super.key, required this.onPressed, required this.child, this.style});
  final VoidCallback? onPressed;
  final Widget child;
  final dynamic style;
  static dynamic styleFrom({dynamic foregroundColor, dynamic shape, dynamic textStyle}) => null;
}

class IconButton extends Widget {
  const IconButton({super.key, required this.onPressed, required this.icon, this.padding, this.iconSize});
  final VoidCallback? onPressed;
  final Widget icon;
  final dynamic padding;
  final double? iconSize;
}

class Card extends Widget {
  const Card({super.key, this.elevation, this.shape, this.child});
  final double? elevation;
  final dynamic shape;
  final Widget? child;
}

class ListView extends Widget {
  ListView.separated({
    super.key,
    this.scrollDirection,
    this.padding,
    required int itemCount,
    required Widget Function(BuildContext, int) separatorBuilder,
    required Widget Function(BuildContext, int) itemBuilder,
  });
  final dynamic scrollDirection;
  final dynamic padding;
}

class LinearProgressIndicator extends Widget {
  const LinearProgressIndicator({super.key, this.value, this.backgroundColor, this.valueColor});
  final double? value;
  final dynamic backgroundColor;
  final dynamic valueColor;
}

class AlwaysStoppedAnimation<T> {
  const AlwaysStoppedAnimation(this.value);
  final T value;
}

class Divider extends Widget {
  const Divider({super.key});
}

enum Axis { horizontal, vertical }
enum MainAxisSize { min, max }
enum CrossAxisAlignment { start, end, center, stretch, baseline }
enum MainAxisAlignment { start, end, center, spaceBetween, spaceAround, spaceEvenly }
enum TextOverflow { clip, fade, ellipsis, visible }
