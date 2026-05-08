import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_weavers_pick_counter/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MyApp(preferences: prefs));
    await tester.pump();

    expect(find.text('THE WEAVER\'S\nPICK COUNTER'), findsOneWidget);
  });
}
