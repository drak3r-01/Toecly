import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toecly/app/app_services.dart';
import 'package:toecly/app/toecly_app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ToeclyApp(services: await AppServices.create()));
    await tester.pumpAndSettle();
  }

  testWidgets('téléphone : barre de navigation en bas', (tester) async {
    await pumpApp(tester, const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('PC : rail de navigation latéral', (tester) async {
    await pumpApp(tester, const Size(1200, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
