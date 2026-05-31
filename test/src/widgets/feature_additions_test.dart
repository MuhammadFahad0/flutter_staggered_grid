import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_staggered_grid/flutter_staggered_grid.dart';

void main() {
  testWidgets('MasonryGridView header and footer rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MasonryGridView.count(
            crossAxisCount: 2,
            itemCount: 4,
            header: const SizedBox(height: 50, child: Text('Header')),
            footer: const SizedBox(height: 50, child: Text('Footer')),
            itemBuilder: (context, index) {
              return SizedBox(height: 100, child: Text('Item $index'));
            },
          ),
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);

    final double headerTop = tester.getTopLeft(find.text('Header')).dy;
    final double item0Top = tester.getTopLeft(find.text('Item 0')).dy;
    expect(headerTop < item0Top, isTrue);
  });

  testWidgets('SliverStickyHeader rendering and layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverStickyHeader(
                header: const SizedBox(height: 50, child: Text('Sticky Header')),
                child: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  childCount: 20,
                  itemBuilder: (context, index) {
                    return SizedBox(height: 100, child: Text('Item $index'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Sticky Header'), findsOneWidget);
    
    // Scroll down
    await tester.drag(find.text('Item 0'), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Verify Sticky Header is still at the top of the viewport (y = 0.0)
    final double stickyHeaderTop = tester.getTopLeft(find.text('Sticky Header')).dy;
    expect(stickyHeaderTop, 0.0);
  });

  testWidgets('AnimatedMasonryGridView insertion and removal', (WidgetTester tester) async {
    final list = <int>[1, 2, 3];
    final key = GlobalKey<AnimatedMasonryGridViewState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedMasonryGridView(
            key: key,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            initialItemCount: list.length,
            itemBuilder: (context, index, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: SizedBox(height: 100, child: Text('Item ${list[index]}')),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);

    // Insert item
    list.add(4);
    key.currentState!.insertItem(3);
    await tester.pumpAndSettle();
    
    expect(find.text('Item 4'), findsOneWidget);

    // Remove item
    key.currentState!.removeItem(1, (context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: const SizedBox(height: 100, child: Text('Removed Item')),
      );
    });
    await tester.pump();
    expect(find.text('Removed Item'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Removed Item'), findsNothing);
  });

  testWidgets('ReorderableMasonryGridView builds and drag starts', (WidgetTester tester) async {
    final list = <String>['A', 'B', 'C'];
    int reorderCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableMasonryGridView.count(
            crossAxisCount: 2,
            itemCount: list.length,
            onReorder: (oldIndex, newIndex) {
              reorderCount++;
            },
            itemBuilder: (context, index) {
              return SizedBox(
                key: ValueKey(list[index]),
                height: 100,
                child: Text('Item ${list[index]}'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Item A'), findsOneWidget);
    
    // Start drag on 'Item A'
    final TestGesture gesture = await tester.startGesture(tester.getCenter(find.text('Item A')));
    await tester.pump(const Duration(milliseconds: 600)); // wait for long press (default is 500ms)
    
    // Drag to another position
    await gesture.moveTo(tester.getCenter(find.text('Item B')));
    await tester.pumpAndSettle();
    
    expect(reorderCount > 0, isTrue);
    await gesture.up();
  });
}
