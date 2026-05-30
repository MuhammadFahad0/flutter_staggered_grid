import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// An empty [SliverGridGeometry].
const kZeroGeometry = SliverGridGeometry(
  scrollOffset: 0,
  crossAxisOffset: 0,
  mainAxisExtent: 0,
  crossAxisExtent: 0,
);

/// Computes a non-negative child extent for evenly divided tracks.
double computeSafeChildExtent({
  required double totalExtent,
  required double spacing,
  required int division,
}) {
  assert(division > 0);
  final childExtent = (totalExtent + spacing) / division - spacing;
  return math.max(0, childExtent);
}
