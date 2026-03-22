import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('M3EButton renders and triggers onPressed', (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      _testApp(
        M3EButton(label: const Text('Save'), onPressed: () => pressed++),
      ),
    );

    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(pressed, 1);
  });

  testWidgets('M3EButton does not trigger when disabled', (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      _testApp(
        M3EButton(
          label: const Text('Disabled'),
          onPressed: () => pressed++,
          enabled: false,
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();

    expect(pressed, 0);
  });

  testWidgets('M3EToggleButton reports checked changes', (tester) async {
    bool? lastValue;

    await tester.pumpWidget(
      _testApp(
        M3EToggleButton(
          icon: const Icon(Icons.favorite_border),
          checkedIcon: const Icon(Icons.favorite),
          onCheckedChange: (checked) => lastValue = checked,
        ),
      ),
    );

    await tester.tap(find.byType(M3EToggleButton));
    await tester.pumpAndSettle();
    expect(lastValue, true);

    await tester.tap(find.byType(M3EToggleButton));
    await tester.pumpAndSettle();
    expect(lastValue, false);
  });

  testWidgets('SplitButtonM3E opens menu and returns selected item', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _testApp(
        SplitButtonM3E<String>(
          label: 'Actions',
          leadingIcon: Icons.more_horiz,
          decoration: const M3ESplitButtonDecoration(
            menuStyle: SplitButtonMenuStyle.native,
          ),
          items: const [
            SplitButtonM3EItem(value: 'one', child: Text('First')),
            SplitButtonM3EItem(value: 'two', child: Text('Second')),
          ],
          onSelected: (value) => selected = value,
          onPressed: () {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    expect(selected, 'two');
  });

  testWidgets('M3EToggleButtonGroup emits selected index', (tester) async {
    int? selectedIndex;

    await tester.pumpWidget(
      _testApp(
        M3EToggleButtonGroup(
          selectedIndex: 0,
          onSelectedIndexChanged: (index) => selectedIndex = index,
          actions: const [
            M3EToggleButtonGroupAction(icon: Icon(Icons.looks_one)),
            M3EToggleButtonGroupAction(icon: Icon(Icons.looks_two)),
          ],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.looks_two));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
  });

  test('SplitButtonM3E rejects text style', () {
    expect(
      () => SplitButtonM3E<String>(
        style: M3EButtonStyle.text,
        label: 'Invalid',
        items: const [SplitButtonM3EItem(value: 'v', child: Text('Value'))],
      ),
      throwsAssertionError,
    );
  });
}
