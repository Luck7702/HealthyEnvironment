import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/screens/home.dart';
import 'package:lingkungan_sehat/services/environment.dart';

void main() {
  const environment = EnvData(
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
  );

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          environmentLoader: ({String? query}) async => environment,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders environment overview', (WidgetTester tester) async {
    await pumpHome(tester);

    expect(find.text('LingkunganSehat'), findsOneWidget);
    expect(find.text('Ciledug 1'), findsOneWidget);
    expect(find.text('Kondisi Lingkungan Saat Ini'), findsOneWidget);
    expect(find.text('Saran untuk Anda'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byKey(const Key('recommendations-list')), findsOneWidget);
  });

  testWidgets(
    'submits a manual location without a controller lifecycle error',
    (WidgetTester tester) async {
      final queries = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            environmentLoader: ({String? query}) async {
              queries.add(query);
              return environment;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ciledug 1'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  Bandung  ');
      await tester.tap(find.widgetWithText(FilledButton, 'Cari'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(queries, contains('Bandung'));
    },
  );

  testWidgets('smoky haze with complete core readings is not incomplete', (
    WidgetTester tester,
  ) async {
    const smokyHazeEnvironment = EnvData(
      location: 'Karetsemanggi',
      localTime: '22:16',
      weather: Weather(
        aqi: 156,
        uv: 0,
        temp: 28.6,
        humidity: 66,
        condition: 'Smoky haze',
        conditionCode: 1036,
      ),
      status: EnvironmentStatus.success,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          environmentLoader: ({String? query}) async => smokyHazeEnvironment,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tinggi'), findsOneWidget);
    expect(find.text('Data belum lengkap'), findsNothing);
    expect(find.text('Terasa panas'), findsOneWidget);
  });

  for (final size in <Size>[
    const Size(320, 700),
    const Size(375, 667),
    const Size(390, 844),
    const Size(407, 904),
    const Size(768, 900),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('server config failure fits at ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            environmentLoader: ({String? query}) async => const EnvData(
              location: 'Bandung',
              weather: Weather.emptyWeather,
              status: EnvironmentStatus.serverMisconfigured,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Bandung'), findsOneWidget);
      expect(find.text('Layanan belum dikonfigurasi'), findsOneWidget);
      expect(
        find.textContaining('Konfigurasi layanan bermasalah'),
        findsOneWidget,
      );
      expect(find.text('Lokasi otomatis gagal.'), findsNothing);
      expect(find.text('Coba lagi'), findsNothing);
      expect(find.text('Belum diketahui'), findsNothing);
    });
  }

  testWidgets('failed refresh keeps data and reuses active query', (
    WidgetTester tester,
  ) async {
    final key = GlobalKey<HomeScreenState>();
    final queries = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          key: key,
          environmentLoader: ({String? query}) async {
            queries.add(query);
            if (query == null) return environment;
            return EnvData(
              location: query,
              weather: Weather.emptyWeather,
              status: EnvironmentStatus.networkError,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await key.currentState!.initializeEnvironment(query: 'Bandung');
    await tester.pumpAndSettle();

    expect(find.text('Ciledug 1'), findsOneWidget);
    expect(find.textContaining('Koneksi gagal'), findsOneWidget);

    await key.currentState!.initializeEnvironment();
    await tester.pumpAndSettle();

    expect(queries.sublist(queries.length - 2), ['Bandung', 'Bandung']);
    expect(find.text('Ciledug 1'), findsOneWidget);
  });

  testWidgets('unexpected loader exception becomes failure state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          environmentLoader: ({String? query}) async {
            throw StateError('unexpected');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Data lingkungan tidak tersedia'), findsOneWidget);
    expect(find.textContaining('Koneksi gagal'), findsOneWidget);
  });

  for (final size in <Size>[
    const Size(320, 700),
    const Size(375, 667),
    const Size(390, 844),
    const Size(407, 904),
    const Size(768, 900),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('fits fixed dashboard at ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpHome(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.text('Kondisi Lingkungan Saat Ini'),
        size.width < 600 ? findsNothing : findsOneWidget,
      );
      if (size.width < 600) {
        expect(find.text('Risiko'), findsOneWidget);
      }
      expect(find.text('Saran untuk Anda'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  }

  testWidgets('only recommendations scroll when advice exceeds space', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHome(tester);

    expect(find.byType(Scrollable), findsOneWidget);
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    await tester.drag(
      find.byKey(const Key('recommendations-list')),
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('metric dialogs show ranges and highlight current category', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(407, 904));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHome(tester);

    await tester.tap(find.text('AQI'));
    await tester.pumpAndSettle();
    expect(find.text('Kualitas udara (AQI)'), findsOneWidget);
    expect(find.text('101-150'), findsOneWidget);
    expect(find.text('Tidak sehat bagi kelompok sensitif'), findsWidgets);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('UV'));
    await tester.pumpAndSettle();
    expect(find.text('Indeks UV'), findsOneWidget);
    expect(find.text('6-7'), findsOneWidget);
    expect(find.text('Tinggi'), findsWidgets);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suhu'));
    await tester.pumpAndSettle();
    expect(find.text('Suhu udara'), findsOneWidget);
    expect(find.textContaining('terasa'), findsWidgets);
    expect(find.text('31-35°C'), findsOneWidget);
    expect(find.text('Panas'), findsWidgets);
  });
}
