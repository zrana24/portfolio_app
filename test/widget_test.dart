import 'package:flutter_test/flutter_test.dart';
import 'package:portfoy_app/app/app.dart';
import 'package:portfoy_app/app/routes.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.login));
  });
}