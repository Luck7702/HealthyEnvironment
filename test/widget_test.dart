import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/main.dart';

void main() {
  testWidgets('renders environment overview', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

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
