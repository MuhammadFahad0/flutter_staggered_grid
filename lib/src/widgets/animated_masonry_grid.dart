import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid/src/rendering/sliver_simple_grid_delegate.dart';
import 'package:flutter_staggered_grid/src/widgets/sliver_masonry_grid.dart';
import 'package:flutter_staggered_grid/src/widgets/animated_base.dart';

/// A sliver version of [AnimatedMasonryGridView].
class SliverAnimatedMasonryGrid extends FSGSliverAnimatedMultiBoxAdaptor {
  /// Creates a sliver version of [AnimatedMasonryGridView].
  const SliverAnimatedMasonryGrid({
    super.key,
    required super.itemBuilder,
    required this.gridDelegate,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    super.findChildIndexCallback,
    super.initialItemCount = 0,
  });

  /// Delegate that controls the size and position of tiles in the cross axis.
  final SliverSimpleGridDelegate gridDelegate;

  /// Spacing along the scroll direction.
  final double mainAxisSpacing;

  /// Spacing along the cross-axis.
  final double crossAxisSpacing;

  @override
  SliverAnimatedMasonryGridState createState() => SliverAnimatedMasonryGridState();

  /// Accesses the closest state of [SliverAnimatedMasonryGrid].
  static SliverAnimatedMasonryGridState of(BuildContext context) {
    final SliverAnimatedMasonryGridState? result = maybeOf(context);
    assert(() {
      if (result == null) {
        throw FlutterError(
          'SliverAnimatedMasonryGrid.of() called with a context that does not contain a SliverAnimatedMasonryGrid.',
        );
      }
      return true;
    }());
    return result!;
  }

  /// Safely accesses the closest state of [SliverAnimatedMasonryGrid].
  static SliverAnimatedMasonryGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SliverAnimatedMasonryGridState>();
  }
}

class SliverAnimatedMasonryGridState extends FSGSliverAnimatedMultiBoxAdaptorState<SliverAnimatedMasonryGrid> {
  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid(
      delegate: createDelegate(),
      gridDelegate: widget.gridDelegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
    );
  }
}

/// A scrollable, 2D array of widgets placed according to a masonry layout that animates items when they are inserted or removed.
class AnimatedMasonryGridView extends StatefulWidget {
  /// Creates an animated masonry grid.
  const AnimatedMasonryGridView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.header,
    this.footer,
    required this.gridDelegate,
    required this.itemBuilder,
    this.initialItemCount = 0,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.cacheExtent,
  });

  /// The scroll direction of the grid.
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll view is scrolled.
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent.
  final bool? primary;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the scroll direction should be determined by the contents being viewed.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// A widget to place above the grid.
  final Widget? header;

  /// A widget to place below the grid.
  final Widget? footer;

  /// Delegate that controls the size and position of tiles in the cross axis.
  final SliverSimpleGridDelegate gridDelegate;

  /// Callback to build animated items.
  final AnimatedItemBuilder itemBuilder;

  /// The initial number of items.
  final int initialItemCount;

  /// Spacing along the scroll direction.
  final double mainAxisSpacing;

  /// Spacing along the cross-axis.
  final double crossAxisSpacing;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// How to clip children.
  final Clip clipBehavior;

  /// How to dismiss the keyboard when scrolling.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Restoration ID to save and restore the scroll offset.
  final String? restorationId;

  /// Scroll cache extent.
  final double? cacheExtent;

  @override
  AnimatedMasonryGridViewState createState() => AnimatedMasonryGridViewState();
}

class AnimatedMasonryGridViewState extends State<AnimatedMasonryGridView> {
  final GlobalKey<SliverAnimatedMasonryGridState> _sliverAnimatedMasonryGridKey = GlobalKey();

  /// Insert an item at [index] and start an animation.
  void insertItem(int index, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedMasonryGridKey.currentState!.insertItem(index, duration: duration);
  }

  /// Insert multiple items at [index] and start an animation.
  void insertAllItems(int index, int length, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedMasonryGridKey.currentState!.insertAllItems(index, length, duration: duration);
  }

  /// Remove the item at [index] and start an animation using [builder].
  void removeItem(int index, AnimatedRemovedItemBuilder builder, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedMasonryGridKey.currentState!.removeItem(index, builder, duration: duration);
  }

  /// Remove all the items and start an animation using [builder].
  void removeAllItems(AnimatedRemovedItemBuilder builder, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedMasonryGridKey.currentState!.removeAllItems(builder, duration: duration);
  }

  @override
  Widget build(BuildContext context) {
    Widget sliver = SliverAnimatedMasonryGrid(
      key: _sliverAnimatedMasonryGridKey,
      itemBuilder: widget.itemBuilder,
      gridDelegate: widget.gridDelegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      initialItemCount: widget.initialItemCount,
    );

    if (widget.padding != null) {
      sliver = SliverPadding(
        padding: widget.padding!,
        sliver: sliver,
      );
    }

    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      cacheExtent: widget.cacheExtent,
      slivers: <Widget>[
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
        sliver,
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer!),
      ],
    );
  }
}
