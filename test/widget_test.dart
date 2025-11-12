import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedules_flutter/main.dart';

void main() {
  testWidgets('Shows Login screen when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SchedulesApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
