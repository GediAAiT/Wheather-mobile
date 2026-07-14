import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_mobile/main.dart';
import 'package:weather_mobile/state/app_state.dart';

void main() {
  testWidgets('WeatherApp builds without crashing', (WidgetTester tester) async {
    final state = AppState();

    await tester.pumpWidget(WeatherApp(state: state));

    // The app's root MaterialApp should be present after the first frame.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
