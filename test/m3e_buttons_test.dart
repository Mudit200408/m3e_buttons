import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

double _uniformRadiusValue(BorderRadiusGeometry geometry) {
  final radius = geometry.resolve(TextDirection.ltr);
  expect(radius.topLeft, radius.topRight);
  expect(radius.topLeft, radius.bottomLeft);
  expect(radius.topLeft, radius.bottomRight);
  return radius.topLeft.x;
}

void main() {
  testWidgets('M3EButton renders and triggers onPressed', (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      _testApp(
        M3EButton(child: const Text('Save'), onPressed: () => pressed++),
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
          onPressed: () => pressed++,
          enabled: false,
          child: const Text('Disabled'),
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();

    expect(pressed, 0);
  });

  testWidgets('M3EButton.icon respects decoration iconAlignment end', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        M3EButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Aligned'),
          decoration: const M3EButtonDecoration(
            iconAlignment: IconAlignment.end,
          ),
        ),
      ),
    );

    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(filledButton.style?.iconAlignment, IconAlignment.end);

    final textLeft = tester.getTopLeft(find.text('Aligned')).dx;
    final iconLeft = tester
        .getTopLeft(find.byIcon(Icons.arrow_forward_rounded))
        .dx;
    expect(textLeft, lessThan(iconLeft));
  });

  testWidgets('M3EButton decoration borderRadius overrides shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        M3EButton(
          onPressed: () {},
          shape: M3EButtonShape.square,
          decoration: const M3EButtonDecoration(borderRadius: 14),
          child: const Text('Radius'),
        ),
      ),
    );

    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    final shape =
        filledButton.style!.shape!.resolve(<WidgetState>{})!
            as RoundedRectangleBorder;

    expect(_uniformRadiusValue(shape.borderRadius), 14);
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

  testWidgets('M3EToggleButton decoration borderRadius sets resting shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        M3EToggleButton(
          icon: const Icon(Icons.favorite_border),
          decoration: const M3EToggleButtonDecoration(borderRadius: 18),
          onCheckedChange: (_) {},
        ),
      ),
    );

    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    final shape =
        filledButton.style!.shape!.resolve(<WidgetState>{})!
            as RoundedRectangleBorder;

    expect(_uniformRadiusValue(shape.borderRadius), 18);
  });

  testWidgets('M3ESplitButton opens menu and returns selected item', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _testApp(
        M3ESplitButton<String>(
          label: 'Actions',
          leadingIcon: Icons.more_horiz,
          decoration: const M3ESplitButtonDecoration(
            menuStyle: SplitButtonMenuStyle.native,
          ),
          items: const [
            M3ESplitButtonItem(value: 'one', child: Text('First')),
            M3ESplitButtonItem(value: 'two', child: Text('Second')),
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

  testWidgets('M3ESplitButton applies backgroundBuilder', (tester) async {
    await tester.pumpWidget(
      _testApp(
        M3ESplitButton<String>(
          label: 'Styled',
          leadingIcon: Icons.gradient_rounded,
          items: const [M3ESplitButtonItem(value: 'one', child: Text('First'))],
          decoration: M3ESplitButtonDecoration(
            backgroundBuilder: (context, states, child) => Stack(
              fit: StackFit.passthrough,
              children: [
                const Positioned.fill(
                  child: ColoredBox(
                    key: Key('split-background-layer'),
                    color: Colors.red,
                  ),
                ),
                child ?? const SizedBox.shrink(),
              ],
            ),
          ),
          onPressed: () {},
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('split-background-layer')), findsWidgets);
  });

  testWidgets('M3ESplitButton decoration borderRadius overrides shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        M3ESplitButton<String>(
          label: 'Styled',
          leadingIcon: Icons.gradient_rounded,
          shape: M3EButtonShape.square,
          items: const [M3ESplitButtonItem(value: 'one', child: Text('First'))],
          decoration: const M3ESplitButtonDecoration(borderRadius: 18),
          onPressed: () {},
          onSelected: (_) {},
        ),
      ),
    );

    final containers = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final radii = containers
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.borderRadius)
        .whereType<BorderRadiusGeometry>()
        .map(_uniformRadiusValue)
        .toList();

    expect(radii, isNotEmpty);
    expect(radii, contains(18));
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

  test('M3ESplitButton rejects text style', () {
    expect(
      () => M3ESplitButton<String>(
        style: M3EButtonStyle.text,
        label: 'Invalid',
        items: const [M3ESplitButtonItem(value: 'v', child: Text('Value'))],
      ),
      throwsAssertionError,
    );
  });
}
