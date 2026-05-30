# flutter_staggered_grid

Flutter grid layouts for staggered, masonry, quilted, woven, staired, and aligned patterns.

> **Note:** This is a custom version of `flutter_staggered_grid`. It is not published on pub.dev. To use this specific version, please install it directly from this GitHub repository.

## Install

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_staggered_grid:
    git:
      url: https://github.com/MuhammadFahad0/flutter_staggered_grid.git
      ref: main
```

```dart
import 'package:flutter_staggered_grid/flutter_staggered_grid.dart';
```

## Included layouts

- `StaggeredGrid`: manual non-sliver staggered layout for a small number of items
- `MasonryGridView`: Pinterest-style layout with variable item heights
- `SliverQuiltedGridDelegate`: repeating quilted pattern for `GridView` / `SliverGrid`
- `SliverWovenGridDelegate`: rhythmic woven pattern with varying item ratios
- `SliverStairedGridDelegate`: offset stepped pattern
- `AlignedGridView`: CSS-grid-like rows where items align to the tallest sibling

## Quick examples

### Staggered

![Staggered Grid Layout][staggered_preview]

```dart
StaggeredGrid.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  children: const [
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: Placeholder(),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1,
      child: Placeholder(),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Placeholder(),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Placeholder(),
    ),
  ],
);
```

### Masonry

![Masonry Grid Layout][masonry_preview]

```dart
MasonryGridView.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  itemBuilder: (context, index) {
    return SizedBox(
      height: (index % 5 + 1) * 100,
      child: const Placeholder(),
    );
  },
);
```

### Quilted

![Quilted Grid Layout][quilted_preview]

```dart
GridView.custom(
  gridDelegate: SliverQuiltedGridDelegate(
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    repeatPattern: QuiltedGridRepeatPattern.inverted,
    pattern: const [
      QuiltedGridTile(2, 2),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 2),
    ],
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => const Placeholder(),
  ),
);
```

### Woven

![Woven Grid Layout][woven_preview]

```dart
GridView.custom(
  gridDelegate: SliverWovenGridDelegate.count(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    pattern: const [
      WovenGridTile(1),
      WovenGridTile(
        5 / 7,
        crossAxisRatio: 0.9,
        alignment: AlignmentDirectional.centerEnd,
      ),
    ],
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => const Placeholder(),
  ),
);
```

### Staired

![Staired Grid Layout][staired_preview]

```dart
GridView.custom(
  gridDelegate: SliverStairedGridDelegate(
    crossAxisSpacing: 48,
    mainAxisSpacing: 24,
    startCrossAxisDirectionReversed: true,
    pattern: const [
      StairedGridTile(0.5, 1),
      StairedGridTile(0.5, 3 / 4),
      StairedGridTile(1.0, 10 / 4),
    ],
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => const Placeholder(),
  ),
);
```

### Aligned

![Aligned Grid Layout][aligned_preview]

```dart
AlignedGridView.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  itemBuilder: (context, index) {
    return SizedBox(
      height: (index % 7 + 1) * 30,
      child: const Placeholder(),
    );
  },
);
```

## Example app

The repository includes a complete demo app in `example/` showing all supported layouts.

<!-- Links -->
[staggered_preview]: doc/images/staggered.png
[masonry_preview]: doc/images/masonry.png
[quilted_preview]: doc/images/quilted.png
[woven_preview]: doc/images/woven.png
[staired_preview]: doc/images/staired.png
[aligned_preview]: doc/images/aligned.png
