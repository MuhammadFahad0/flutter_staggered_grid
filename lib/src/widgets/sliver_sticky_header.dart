// ignore_for_file: public_member_api_docs
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid/src/rendering/sliver_sticky_header.dart';

/// A sliver that has a header widget that sticks to the top of the viewport
/// while its child sliver is visible.
class SliverStickyHeader extends RenderObjectWidget {
  /// Creates a sliver that has a sticky header.
  const SliverStickyHeader({
    super.key,
    required this.header,
    required this.child,
  });

  /// The header widget that will pin at the top of the viewport.
  final Widget header;

  /// The child sliver that scrolls under the header.
  final Widget child;

  @override
  RenderSliverStickyHeader createRenderObject(BuildContext context) {
    return RenderSliverStickyHeader();
  }

  @override
  RenderObjectElement createElement() => _SliverStickyHeaderElement(this);
}

class _SliverStickyHeaderElement extends RenderObjectElement {
  _SliverStickyHeaderElement(SliverStickyHeader super.widget);

  Element? _header;
  Element? _child;

  @override
  RenderSliverStickyHeader get renderObject => super.renderObject as RenderSliverStickyHeader;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_child != null) visitor(_child!);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final SliverStickyHeader stickyHeaderWidget = widget as SliverStickyHeader;
    _header = updateChild(_header, stickyHeaderWidget.header, _headerSlot);
    _child = updateChild(_child, stickyHeaderWidget.child, _childSlot);
  }

  @override
  void update(SliverStickyHeader newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    final SliverStickyHeader stickyHeaderWidget = widget as SliverStickyHeader;
    _header = updateChild(_header, stickyHeaderWidget.header, _headerSlot);
    _child = updateChild(_child, stickyHeaderWidget.child, _childSlot);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    if (slot == _headerSlot) {
      renderObject.header = child as RenderBox;
    } else if (slot == _childSlot) {
      renderObject.child = child as RenderSliver;
    } else {
      assert(false);
    }
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    if (renderObject.header == child) {
      renderObject.header = null;
    } else if (renderObject.child == child) {
      renderObject.child = null;
    } else {
      assert(false);
    }
  }

  static const _SliverStickyHeaderSlot _headerSlot = _SliverStickyHeaderSlot.header;
  static const _SliverStickyHeaderSlot _childSlot = _SliverStickyHeaderSlot.child;
}

enum _SliverStickyHeaderSlot {
  header,
  child,
}
