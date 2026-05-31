import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid/src/rendering/sliver_simple_grid_delegate.dart';
import 'package:flutter_staggered_grid/src/widgets/sliver_aligned_grid.dart';
import 'package:flutter_staggered_grid/src/widgets/animated_base.dart';

/// A sliver version of [AnimatedAlignedGridView].
class SliverAnimatedAlignedGrid extends FSGSliverAnimatedMultiBoxAdaptor {
  /// Creates a sliver version of [AnimatedAlignedGridView].
  const SliverAnimatedAlignedGrid({
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
  SliverAnimatedAlignedGridState createState() => SliverAnimatedAlignedGridState();

  /// Accesses the closest state of [SliverAnimatedAlignedGrid].
  static SliverAnimatedAlignedGridState of(BuildContext context) {
    final SliverAnimatedAlignedGridState? result = maybeOf(context);
    assert(() {
      if (result == null) {
        throw FlutterError(
          'SliverAnimatedAlignedGrid.of() called with a context that does not contain a SliverAnimatedAlignedGrid.',
        );
      }
      return true;
    }());
    return result!;
  }

  /// Safely accesses the closest state of [SliverAnimatedAlignedGrid].
  static SliverAnimatedAlignedGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SliverAnimatedAlignedGridState>();
  }
}

class SliverAnimatedAlignedGridState extends FSGSliverAnimatedMultiBoxAdaptorState<SliverAnimatedAlignedGrid> {
  @override
  Widget build(BuildContext context) {
    return SliverAlignedGrid(
      itemBuilder: itemBuilder,
      itemCount: itemsCount,
      gridDelegate: widget.gridDelegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
    );
  }
}

/// A scrollable, 2D array of widgets placed according to an aligned layout that animates items when they are inserted or removed.
class AnimatedAlignedGridView extends StatefulWidget {
  /// Creates an animated aligned grid.
  const AnimatedAlignedGridView({
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
  AnimatedAlignedGridViewState createState() => AnimatedAlignedGridViewState();
}

class AnimatedAlignedGridViewState extends State<AnimatedAlignedGridView> {
  final GlobalKey<SliverAnimatedAlignedGridState> _sliverAnimatedAlignedGridKey = GlobalKey();

  /// Insert an item at [index] and start an animation.
  void insertItem(int index, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedAlignedGridKey.currentState!.insertItem(index, duration: duration);
  }

  /// Insert multiple items at [index] and start an animation.
  void insertAllItems(int index, int length, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedAlignedGridKey.currentState!.insertAllItems(index, length, duration: duration);
  }

  /// Remove the item at [index] and start an animation using [builder].
  void removeItem(int index, AnimatedRemovedItemBuilder builder, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedAlignedGridKey.currentState!.removeItem(index, builder, duration: duration);
  }

  /// Remove all the items and start an animation using [builder].
  void removeAllItems(AnimatedRemovedItemBuilder builder, {Duration duration = const Duration(milliseconds: 300)}) {
    _sliverAnimatedAlignedGridKey.currentState!.removeAllItems(builder, duration: duration);
  }

  @override
  Widget build(BuildContext context) {
    Widget sliver = SliverAnimatedAlignedGrid(
      key: _sliverAnimatedAlignedGridKey,
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
