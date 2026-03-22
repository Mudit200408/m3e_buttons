import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('M3E demo screen renders expected tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('M3E Buttons'), findsOneWidget);
    expect(find.text('M3EButton'), findsOneWidget);
    expect(find.text('M3EToggleButton'), findsOneWidget);
    expect(find.text('M3EToggleButtonGroup'), findsOneWidget);
    expect(find.text('M3ESplitButton'), findsOneWidget);
  });
}
