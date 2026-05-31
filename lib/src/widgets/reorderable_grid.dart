import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid/src/rendering/sliver_simple_grid_delegate.dart';
import 'package:flutter_staggered_grid/src/widgets/masonry_grid_view.dart';
import 'package:flutter_staggered_grid/src/widgets/aligned_grid_view.dart';

class _ReorderableGridItem extends StatelessWidget {
  const _ReorderableGridItem({
    super.key,
    required this.index,
    required this.child,
    required this.onReorder,
    required this.draggingIndex,
    required this.onDragStarted,
    required this.onDragEnded,
    this.proxyDecorator,
  });

  final int index;
  final Widget child;
  final ReorderCallback onReorder;
  final int? draggingIndex;
  final ValueChanged<int> onDragStarted;
  final VoidCallback onDragEnded;
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAccept: (oldIndex) {
        if (oldIndex != null && oldIndex != index) {
          onReorder(oldIndex, index);
          return true;
        }
        return false;
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingThis = draggingIndex == index;

        Widget dragChild = child;
        if (proxyDecorator != null && isDraggingThis) {
          dragChild = proxyDecorator!(child, index, kAlwaysCompleteAnimation);
        }

        return LongPressDraggable<int>(
          data: index,
          axis: null,
          feedback: Material(
            color: Colors.transparent,
            child: dragChild,
          ),
          childWhenDragging: Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: child,
          ),
          onDragStarted: () => onDragStarted(index),
          onDraggableCanceled: (_, __) => onDragEnded(),
          onDragEnd: (_) => onDragEnded(),
          child: child,
        );
      },
    );
  }
}

/// A scrollable, 2D array of widgets placed according to a masonry layout that allows users to interactively reorder items via drag-and-drop.
class ReorderableMasonryGridView extends StatefulWidget {
  /// Creates a reorderable masonry grid with a fixed number of tiles in the cross axis.
  const ReorderableMasonryGridView.count({
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
    required int crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.proxyDecorator,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.cacheExtent,
  }) : gridDelegate = null,
       maxCrossAxisExtent = null,
       crossAxisCount = crossAxisCount;

  /// Creates a reorderable masonry grid with tiles that have a maximum cross-axis extent.
  const ReorderableMasonryGridView.extent({
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
    required double maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.proxyDecorator,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.cacheExtent,
  }) : gridDelegate = null,
       crossAxisCount = null,
       maxCrossAxisExtent = maxCrossAxisExtent;

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
  final SliverSimpleGridDelegate? gridDelegate;

  /// The number of tiles in the cross axis.
  final int? crossAxisCount;

  /// The maximum extent of tiles in the cross axis.
  final double? maxCrossAxisExtent;

  /// Spacing along the scroll direction.
  final double mainAxisSpacing;

  /// Spacing along the cross-axis.
  final double crossAxisSpacing;

  /// Callback to build grid items.
  final IndexedWidgetBuilder itemBuilder;

  /// The total number of items.
  final int itemCount;

  /// Callback when an item is successfully reordered.
  final ReorderCallback onReorder;

  /// A decorator that can be used to customize the item while it is being dragged.
  final ReorderItemProxyDecorator? proxyDecorator;

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
  State<ReorderableMasonryGridView> createState() => _ReorderableMasonryGridViewState();
}

class _ReorderableMasonryGridViewState extends State<ReorderableMasonryGridView> {
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    final SliverSimpleGridDelegate delegate = widget.gridDelegate ?? 
        (widget.crossAxisCount != null 
            ? SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.crossAxisCount!)
            : SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: widget.maxCrossAxisExtent!));

    return MasonryGridView.custom(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      header: widget.header,
      footer: widget.footer,
      gridDelegate: delegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      cacheExtent: widget.cacheExtent,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          final child = widget.itemBuilder(context, index);
          assert(child.key != null, 'All reorderable items must have a key.');
          
          return _ReorderableGridItem(
            key: ValueKey('reorderable-${child.key}'),
            index: index,
            onReorder: (oldIndex, newIndex) {
              if (_draggingIndex != null) {
                widget.onReorder(oldIndex, newIndex);
                setState(() {
                  _draggingIndex = newIndex;
                });
              }
            },
            draggingIndex: _draggingIndex,
            onDragStarted: (idx) {
              setState(() {
                _draggingIndex = idx;
              });
            },
            onDragEnded: () {
              setState(() {
                _draggingIndex = null;
              });
            },
            proxyDecorator: widget.proxyDecorator,
            child: child,
          );
        },
        childCount: widget.itemCount,
      ),
    );
  }
}

/// A scrollable, 2D array of widgets placed according to an aligned layout that allows users to interactively reorder items via drag-and-drop.
class ReorderableAlignedGridView extends StatefulWidget {
  /// Creates a reorderable aligned grid with a fixed number of tiles in the cross axis.
  const ReorderableAlignedGridView.count({
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
    required int crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.proxyDecorator,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.cacheExtent,
  }) : gridDelegate = null,
       maxCrossAxisExtent = null,
       crossAxisCount = crossAxisCount;

  /// Creates a reorderable aligned grid with tiles that have a maximum cross-axis extent.
  const ReorderableAlignedGridView.extent({
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
    required double maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.proxyDecorator,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.cacheExtent,
  }) : gridDelegate = null,
       crossAxisCount = null,
       maxCrossAxisExtent = maxCrossAxisExtent;

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
  final SliverSimpleGridDelegate? gridDelegate;

  /// The number of tiles in the cross axis.
  final int? crossAxisCount;

  /// The maximum extent of tiles in the cross axis.
  final double? maxCrossAxisExtent;

  /// Spacing along the scroll direction.
  final double mainAxisSpacing;

  /// Spacing along the cross-axis.
  final double crossAxisSpacing;

  /// Callback to build grid items.
  final IndexedWidgetBuilder itemBuilder;

  /// The total number of items.
  final int itemCount;

  /// Callback when an item is successfully reordered.
  final ReorderCallback onReorder;

  /// A decorator that can be used to customize the item while it is being dragged.
  final ReorderItemProxyDecorator? proxyDecorator;

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
  State<ReorderableAlignedGridView> createState() => _ReorderableAlignedGridViewState();
}

class _ReorderableAlignedGridViewState extends State<ReorderableAlignedGridView> {
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    final SliverSimpleGridDelegate delegate = widget.gridDelegate ?? 
        (widget.crossAxisCount != null 
            ? SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.crossAxisCount!)
            : SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: widget.maxCrossAxisExtent!));

    return AlignedGridView.custom(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      header: widget.header,
      footer: widget.footer,
      gridDelegate: delegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      cacheExtent: widget.cacheExtent,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        final child = widget.itemBuilder(context, index);
        assert(child.key != null, 'All reorderable items must have a key.');
        
        return _ReorderableGridItem(
          key: ValueKey('reorderable-${child.key}'),
          index: index,
          onReorder: (oldIndex, newIndex) {
            if (_draggingIndex != null) {
              widget.onReorder(oldIndex, newIndex);
              setState(() {
                _draggingIndex = newIndex;
              });
            }
          },
          draggingIndex: _draggingIndex,
          onDragStarted: (idx) {
            setState(() {
              _draggingIndex = idx;
            });
          },
          onDragEnded: () {
            setState(() {
              _draggingIndex = null;
            });
          },
          proxyDecorator: widget.proxyDecorator,
          child: child,
        );
      },
    );
  }
}
