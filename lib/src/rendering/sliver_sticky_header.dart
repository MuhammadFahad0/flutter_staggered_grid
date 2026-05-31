// ignore_for_file: public_member_api_docs
import 'dart:math' as math;
import 'package:flutter/rendering.dart';

class RenderSliverStickyHeader extends RenderSliver with RenderSliverHelpers {
  RenderSliverStickyHeader({
    RenderBox? header,
    RenderSliver? child,
  }) {
    this.header = header;
    this.child = child;
  }

  RenderBox? _header;
  RenderBox? get header => _header;
  set header(RenderBox? value) {
    if (_header != null) {
      dropChild(_header!);
    }
    _header = value;
    if (_header != null) {
      adoptChild(_header!);
    }
    markNeedsLayout();
  }

  RenderSliver? _child;
  RenderSliver? get child => _child;
  set child(RenderSliver? value) {
    if (_child != null) {
      dropChild(_child!);
    }
    _child = value;
    if (_child != null) {
      adoptChild(_child!);
    }
    markNeedsLayout();
  }

  bool _isPinned = false;
  double? _headerExtent;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_header != null) _header!.attach(owner);
    if (_child != null) _child!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (_header != null) _header!.detach();
    if (_child != null) _child!.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_child != null) visitor(_child!);
  }

  @override
  void performLayout() {
    if (header == null && child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final AxisDirection axisDirection = applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    );

    if (header != null) {
      header!.layout(
        constraints.asBoxConstraints(),
        parentUsesSize: true,
      );
      _headerExtent = constraints.axis == Axis.vertical
          ? header!.size.height
          : header!.size.width;
    } else {
      _headerExtent = 0.0;
    }

    final double headerExtent = _headerExtent ?? 0.0;
    final double headerPaintExtent = calculatePaintOffset(constraints, from: 0.0, to: headerExtent);
    final double headerCacheExtent = calculateCacheOffset(constraints, from: 0.0, to: headerExtent);

    if (child == null) {
      geometry = SliverGeometry(
        scrollExtent: headerExtent,
        maxPaintExtent: headerExtent,
        paintExtent: headerPaintExtent,
        cacheExtent: headerCacheExtent,
        hitTestExtent: headerPaintExtent,
        hasVisualOverflow: headerExtent > constraints.remainingPaintExtent ||
            constraints.scrollOffset > 0.0,
      );
    } else {
      child!.layout(
        constraints.copyWith(
          scrollOffset: math.max(0.0, constraints.scrollOffset - headerExtent),
          cacheOrigin: math.min(0.0, constraints.cacheOrigin + headerExtent),
          overlap: math.min(headerExtent, constraints.scrollOffset) + constraints.overlap,
          remainingPaintExtent: constraints.remainingPaintExtent - headerPaintExtent,
          remainingCacheExtent: constraints.remainingCacheExtent - headerCacheExtent,
        ),
        parentUsesSize: true,
      );

      final SliverGeometry childLayoutGeometry = child!.geometry!;
      if (childLayoutGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection,
        );
        return;
      }

      final double paintExtent = math.min(
        headerPaintExtent + math.max(childLayoutGeometry.paintExtent, childLayoutGeometry.layoutExtent),
        constraints.remainingPaintExtent,
      );

      geometry = SliverGeometry(
        scrollExtent: headerExtent + childLayoutGeometry.scrollExtent,
        maxScrollObstructionExtent: headerPaintExtent,
        paintExtent: paintExtent,
        layoutExtent: math.min(
          headerPaintExtent + childLayoutGeometry.layoutExtent,
          paintExtent,
        ),
        cacheExtent: math.min(
          headerCacheExtent + childLayoutGeometry.cacheExtent,
          constraints.remainingCacheExtent,
        ),
        maxPaintExtent: headerExtent + childLayoutGeometry.maxPaintExtent,
        hitTestExtent: math.max(
          headerPaintExtent + childLayoutGeometry.paintExtent,
          headerPaintExtent + childLayoutGeometry.hitTestExtent,
        ),
        hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
      );

      final SliverPhysicalParentData? childParentData =
          child!.parentData as SliverPhysicalParentData?;
      switch (axisDirection) {
        case AxisDirection.up:
          childParentData!.paintOffset = Offset.zero;
          break;
        case AxisDirection.right:
          childParentData!.paintOffset = Offset(
            calculatePaintOffset(constraints, from: 0.0, to: headerExtent),
            0.0,
          );
          break;
        case AxisDirection.down:
          childParentData!.paintOffset = Offset(
            0.0,
            calculatePaintOffset(constraints, from: 0.0, to: headerExtent),
          );
          break;
        case AxisDirection.left:
          childParentData!.paintOffset = Offset.zero;
          break;
      }
    }

    if (header != null) {
      final SliverPhysicalParentData? headerParentData =
          header!.parentData as SliverPhysicalParentData?;
      final double childScrollExtent = child?.geometry?.scrollExtent ?? 0.0;
      final double headerPosition = math.min(
        constraints.overlap,
        childScrollExtent - constraints.scrollOffset,
      );

      _isPinned = (constraints.scrollOffset + constraints.overlap) > 0.0 ||
          constraints.remainingPaintExtent == constraints.viewportMainAxisExtent;

      switch (axisDirection) {
        case AxisDirection.up:
          headerParentData!.paintOffset = Offset(
            0.0,
            geometry!.paintExtent - headerPosition - headerExtent,
          );
          break;
        case AxisDirection.down:
          headerParentData!.paintOffset = Offset(0.0, headerPosition);
          break;
        case AxisDirection.left:
          headerParentData!.paintOffset = Offset(
            geometry!.paintExtent - headerPosition - headerExtent,
            0.0,
          );
          break;
        case AxisDirection.right:
          headerParentData!.paintOffset = Offset(headerPosition, 0.0);
          break;
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      if (child != null && child!.geometry!.visible) {
        final SliverPhysicalParentData childParentData =
            child!.parentData! as SliverPhysicalParentData;
        context.paintChild(child!, offset + childParentData.paintOffset);
      }

      if (header != null) {
        final SliverPhysicalParentData headerParentData =
            header!.parentData! as SliverPhysicalParentData;
        context.paintChild(header!, offset + headerParentData.paintOffset);
      }
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0.0);
    final double childScrollExtent = child?.geometry?.scrollExtent ?? 0.0;
    final double headerPosition = math.min(
      constraints.overlap,
      childScrollExtent - constraints.scrollOffset,
    );

    if (header != null && (mainAxisPosition - headerPosition) <= (_headerExtent ?? 0.0)) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        header!,
        mainAxisPosition: mainAxisPosition - childMainAxisPosition(header!) - headerPosition,
        crossAxisPosition: crossAxisPosition,
      );

      return didHitHeader ||
          (child != null &&
              child!.geometry!.hitTestExtent > 0.0 &&
              child!.hitTest(
                result,
                mainAxisPosition: mainAxisPosition - childMainAxisPosition(child!),
                crossAxisPosition: crossAxisPosition,
              ));
    } else if (child != null && child!.geometry!.hitTestExtent > 0.0) {
      return child!.hitTest(
        result,
        mainAxisPosition: mainAxisPosition - childMainAxisPosition(child!),
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) {
    if (child == header) {
      return _isPinned ? 0.0 : -(constraints.scrollOffset + constraints.overlap);
    }
    if (child == this.child) {
      return calculatePaintOffset(constraints, from: 0.0, to: _headerExtent ?? 0.0);
    }
    return 0.0;
  }

  @override
  double childCrossAxisPosition(covariant RenderObject child) => 0.0;

  @override
  double? childScrollOffset(covariant RenderObject child) {
    assert(child.parent == this);
    if (child == this.child) {
      return _headerExtent;
    } else {
      return super.childScrollOffset(child);
    }
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    final SliverPhysicalParentData childParentData =
        child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }
}
