import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_fl/src/app.dart';
import 'package:vocab_fl/src/state/app_controller.dart';

void main() {
  testWidgets('Onboarding renders splash controls', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await AppController.create();
    await tester.pumpWidget(LexoraApp(controller: controller));

    expect(find.text('Lexora Solutions'), findsOneWidget);
    expect(find.text('Пропустить'), findsOneWidget);
    expect(find.text('Далее'), findsOneWidget);
  });
}
