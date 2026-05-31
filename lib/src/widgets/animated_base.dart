import 'package:flutter/widgets.dart';

int _binarySearch<T extends Comparable<T>>(List<T> sortedList, T value) {
  int min = 0;
  int max = sortedList.length - 1;
  while (min <= max) {
    final int mid = min + ((max - min) >> 1);
    final int comp = sortedList[mid].compareTo(value);
    if (comp == 0) {
      return mid;
    } else if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid - 1;
    }
  }
  return -1;
}

class FSGActiveItem implements Comparable<FSGActiveItem> {
  FSGActiveItem.incoming(this.controller, this.itemIndex) : removedItemBuilder = null;

  FSGActiveItem.outgoing(this.controller, this.itemIndex, this.removedItemBuilder);

  FSGActiveItem.index(this.itemIndex) : controller = null, removedItemBuilder = null;

  final AnimationController? controller;
  final AnimatedRemovedItemBuilder? removedItemBuilder;
  int itemIndex;

  @override
  int compareTo(FSGActiveItem other) => itemIndex - other.itemIndex;
}

abstract class FSGSliverAnimatedMultiBoxAdaptor extends StatefulWidget {
  const FSGSliverAnimatedMultiBoxAdaptor({
    super.key,
    required this.itemBuilder,
    this.findChildIndexCallback,
    this.initialItemCount = 0,
  }) : assert(initialItemCount >= 0);

  final AnimatedItemBuilder itemBuilder;
  final ChildIndexGetter? findChildIndexCallback;
  final int initialItemCount;
}

abstract class FSGSliverAnimatedMultiBoxAdaptorState<T extends FSGSliverAnimatedMultiBoxAdaptor>
    extends State<T> with TickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    _itemsCount = widget.initialItemCount;
  }

  @override
  void dispose() {
    for (final FSGActiveItem item in _incomingItems.followedBy(_outgoingItems)) {
      item.controller!.dispose();
    }
    super.dispose();
  }

  final List<FSGActiveItem> _incomingItems = <FSGActiveItem>[];
  final List<FSGActiveItem> _outgoingItems = <FSGActiveItem>[];
  int _itemsCount = 0;

  FSGActiveItem? _removeActiveItemAt(List<FSGActiveItem> items, int itemIndex) {
    final int i = _binarySearch(items, FSGActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  FSGActiveItem? _activeItemAt(List<FSGActiveItem> items, int itemIndex) {
    final int i = _binarySearch(items, FSGActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  int _indexToItemIndex(int index) {
    var itemIndex = index;
    for (final FSGActiveItem item in _outgoingItems) {
      if (item.itemIndex <= itemIndex) {
        itemIndex += 1;
      } else {
        break;
      }
    }
    return itemIndex;
  }

  int _itemIndexToIndex(int itemIndex) {
    var index = itemIndex;
    for (final FSGActiveItem item in _outgoingItems) {
      assert(item.itemIndex != itemIndex);
      if (item.itemIndex < itemIndex) {
        index -= 1;
      } else {
        break;
      }
    }
    return index;
  }

  SliverChildDelegate createDelegate() {
    return SliverChildBuilderDelegate(
      _itemBuilder,
      childCount: _itemsCount,
      findChildIndexCallback: widget.findChildIndexCallback == null
          ? null
          : (Key key) {
               final int? index = widget.findChildIndexCallback!(key);
               return index != null ? _indexToItemIndex(index) : null;
             },
    );
  }

  Widget _itemBuilder(BuildContext context, int itemIndex) {
    final FSGActiveItem? outgoingItem = _activeItemAt(_outgoingItems, itemIndex);
    if (outgoingItem != null) {
      return outgoingItem.removedItemBuilder!(context, outgoingItem.controller!.view);
    }

    final FSGActiveItem? incomingItem = _activeItemAt(_incomingItems, itemIndex);
    final Animation<double> animation = incomingItem?.controller?.view ?? kAlwaysCompleteAnimation;
    return widget.itemBuilder(context, _itemIndexToIndex(itemIndex), animation);
  }

  void insertItem(int index, {Duration duration = const Duration(milliseconds: 300)}) {
    assert(index >= 0);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex <= _itemsCount);

    for (final FSGActiveItem item in _incomingItems) {
      if (item.itemIndex >= itemIndex) {
        item.itemIndex += 1;
      }
    }
    for (final FSGActiveItem item in _outgoingItems) {
      if (item.itemIndex >= itemIndex) {
        item.itemIndex += 1;
      }
    }

    final controller = AnimationController(duration: duration, vsync: this);
    final incomingItem = FSGActiveItem.incoming(controller, itemIndex);
    setState(() {
      _incomingItems
        ..add(incomingItem)
        ..sort();
      _itemsCount += 1;
    });

    controller.forward().then<void>((_) {
      final removed = _removeActiveItemAt(_incomingItems, incomingItem.itemIndex);
      if (removed != null) {
        removed.controller!.dispose();
      }
    });
  }

  void insertAllItems(int index, int length, {Duration duration = const Duration(milliseconds: 300)}) {
    for (var i = 0; i < length; i++) {
      insertItem(index + i, duration: duration);
    }
  }

  void removeItem(int index, AnimatedRemovedItemBuilder builder, {Duration duration = const Duration(milliseconds: 300)}) {
    assert(index >= 0);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex < _itemsCount);
    assert(_activeItemAt(_outgoingItems, itemIndex) == null);

    final FSGActiveItem? incomingItem = _removeActiveItemAt(_incomingItems, itemIndex);
    final AnimationController controller =
        incomingItem?.controller ??
        AnimationController(duration: duration, value: 1.0, vsync: this);
    final outgoingItem = FSGActiveItem.outgoing(controller, itemIndex, builder);
    setState(() {
      _outgoingItems
        ..add(outgoingItem)
        ..sort();
    });

    controller.reverse().then<void>((void value) {
      final removed = _removeActiveItemAt(_outgoingItems, outgoingItem.itemIndex);
      if (removed != null) {
        removed.controller!.dispose();
      }

      for (final FSGActiveItem item in _incomingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) {
          item.itemIndex -= 1;
        }
      }
      for (final FSGActiveItem item in _outgoingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) {
          item.itemIndex -= 1;
        }
      }

      setState(() => _itemsCount -= 1);
    });
  }

  void removeAllItems(AnimatedRemovedItemBuilder builder, {Duration duration = const Duration(milliseconds: 300)}) {
    assert(_itemsCount >= 0);
    assert(_itemsCount - _outgoingItems.length >= 0);
    final int visibleItemCount = _itemsCount - _outgoingItems.length;
    for (int i = visibleItemCount - 1; i >= 0; i--) {
      removeItem(i, builder, duration: duration);
    }
  }

  /// Exposes the number of active items (including animating ones).
  @protected
  int get itemsCount => _itemsCount;

  /// Exposes the item builder logic that handles active/animating items.
  @protected
  Widget itemBuilder(BuildContext context, int itemIndex) => _itemBuilder(context, itemIndex);
}
