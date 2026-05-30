import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid/flutter_staggered_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const zeroExtentConstraints = SliverConstraints(
    axisDirection: AxisDirection.down,
    cacheOrigin: 0,
    crossAxisDirection: AxisDirection.right,
    crossAxisExtent: 0,
    growthDirection: GrowthDirection.forward,
    scrollOffset: 0,
    overlap: 0,
    viewportMainAxisExtent: 400,
    precedingScrollExtent: 0,
    remainingCacheExtent: 400,
    remainingPaintExtent: 400,
    userScrollDirection: ScrollDirection.idle,
  );

  test('max extent delegates keep at least one track for zero extent', () {
    expect(
      const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
      ).getCrossAxisCount(zeroExtentConstraints, 0),
      1,
    );
    expect(
      const StaggeredGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
      ).getCrossAxisCount(0, 0),
      1,
    );
  });

  test('pattern layouts handle zero extent scroll queries', () {
    final quiltedLayout = SliverQuiltedGridDelegate(
      crossAxisCount: 2,
      pattern: const [
        QuiltedGridTile(1, 1),
      ],
    ).getLayout(zeroExtentConstraints);

    expect(quiltedLayout.getMinChildIndexForScrollOffset(0), 0);
    expect(quiltedLayout.getMaxChildIndexForScrollOffset(0), 0);

    final wovenLayout = SliverWovenGridDelegate.extent(
      maxCrossAxisExtent: 200,
      pattern: const [
        WovenGridTile(1),
      ],
    ).getLayout(zeroExtentConstraints);

    expect(wovenLayout.getMinChildIndexForScrollOffset(0), 0);
    expect(wovenLayout.getMaxChildIndexForScrollOffset(0), 0);
  });
}
