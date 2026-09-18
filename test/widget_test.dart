import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/screens/home.dart';
import 'package:lingkungan_sehat/services/environment.dart';

void main() {
  testWidgets('renders environment overview', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          environmentLoader: ({String? query}) async => const EnvData(
            location: 'Ciledug 1',
            localTime: '14:40',
            weather: Weather(
              aqi: 134,
              uv: 6.1,
              temp: 32.9,
              humidity: 68,
              condition: 'Light rain',
              conditionCode: 1183,
            ),
            status: EnvironmentStatus.success,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LingkunganSehat'), findsOneWidget);
    expect(find.text('Ciledug 1'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    expect(find.text('Kondisi Lingkungan Saat Ini'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    expect(find.text('Saran untuk Anda'), findsOneWidget);
  });
}
