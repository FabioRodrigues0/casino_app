import 'package:casino_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CasinoApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(CasinoApp());
    expect(find.text('Casino Slots'), findsOneWidget);
  });
}
