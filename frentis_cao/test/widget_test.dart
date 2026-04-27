import 'package:flutter_test/flutter_test.dart';
import 'package:frentis_cao/main.dart';

void main() {
  testWidgets('App starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FrentisCaoApp());
    await tester.pumpAndSettle();
    expect(find.text('Entrar'), findsOneWidget);
  });
}
