import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Example app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('RepoNotifier Example'), findsOneWidget);
    expect(find.text('No user data'), findsOneWidget);
  });
}
