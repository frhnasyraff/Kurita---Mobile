import 'package:flutter_test/flutter_test.dart';
import 'package:workwise/main.dart';

void main() {
  testWidgets('navigates from welcome screen to dashboard through login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WorkwiseApp());

    expect(find.text('Workwise'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);

    await tester.tap(find.text('LOG IN'));
    await tester.pumpAndSettle();

    expect(find.text('WorkWise'), findsOneWidget);
    expect(find.text('SECURE ACCESS'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('RECEIVING SUMMARY'), findsOneWidget);
    expect(find.text('DAILY STATISTICS'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
  });

  testWidgets('navigates from welcome screen to dashboard through sign up', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WorkwiseApp());

    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('NEW ACCOUNT'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
    expect(find.text('SIGN UP'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('SIGN UP').last);
    await tester.pumpAndSettle();

    expect(find.text('RECEIVING SUMMARY'), findsOneWidget);
    expect(find.text('Industrial Alloys Inc.'), findsOneWidget);
    expect(find.text('TOTAL COMPLETED'), findsOneWidget);
  });
}
