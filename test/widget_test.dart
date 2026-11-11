import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/screens/home.dart';
import 'package:lingkungan_sehat/screens/information.dart';
import 'package:lingkungan_sehat/services/environment.dart';

void main() {
  const environment = EnvData(
    location: 'Ciledug 1',
    localTime: '14:40',
    weather: Weather(
      ispu: 108,
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
    expect(find.byType(SingleChildScrollView), findsOneWidget);
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
        ispu: 156,
        aqi: 205,
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
    expect(find.text('Hati-hati'), findsOneWidget);
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
    testWidgets('renders dashboard at ${size.width}x${size.height}', (
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
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  }

  for (final size in <Size>[const Size(320, 700), const Size(1024, 768)]) {
    testWidgets('whole page scrolls at ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpHome(tester);

      final pageScrollable = find.ancestor(
        of: find.byKey(const Key('recommendations-list')),
        matching: find.byType(Scrollable),
      );
      expect(pageScrollable, findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('recommendations-list')),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
      final scrollable = tester.state<ScrollableState>(pageScrollable);
      expect(scrollable.position.maxScrollExtent, greaterThan(0));

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -160),
      );
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, greaterThan(0));
    });
  }

  testWidgets('metric dialogs show ranges and highlight current category', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(407, 904));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHome(tester);

    await tester.tap(find.text('ISPU'));
    await tester.pumpAndSettle();
    expect(find.text('Kualitas udara (ISPU)'), findsOneWidget);
    expect(find.text('101-200'), findsOneWidget);
    expect(find.text('Tidak sehat · risiko Tinggi'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Tidak sehat · risiko Tinggi')).dy,
      greaterThan(tester.getTopLeft(find.text('108 ISPU · AQI US EPA 134')).dy),
    );
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('UV'));
    await tester.pumpAndSettle();
    expect(find.text('Indeks UV'), findsOneWidget);
    expect(find.text('6-7'), findsOneWidget);
    expect(find.text('Tinggi'), findsWidgets);
    expect(find.text('Tinggi · risiko Sedang'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('WHO: Indeks UV'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Sumber'), findsOneWidget);
    expect(find.text('WHO: Indeks UV'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suhu'));
    await tester.pumpAndSettle();
    expect(find.text('Suhu & indeks panas'), findsOneWidget);
    expect(find.textContaining('terasa'), findsWidgets);
    expect(find.text('39,4–51,7°C'), findsOneWidget);
    expect(find.text('Bahaya'), findsWidgets);
  });

  testWidgets('swipe reveals weather and humidity metrics on mobile', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHome(tester);

    expect(find.text('ISPU'), findsOneWidget);
    expect(find.text('Cuaca'), findsNothing);

    await tester.drag(
      find.byKey(const Key('environment-stats-pager')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cuaca'), findsOneWidget);
    expect(find.text('Hujan'), findsOneWidget);
    expect(find.text('Kelembapan'), findsOneWidget);
    expect(find.text('68%'), findsOneWidget);

    await tester.tap(find.text('Kelembapan'));
    await tester.pumpAndSettle();
    expect(find.text('Kelembapan udara'), findsOneWidget);
    expect(find.text('≥18,3°C'), findsOneWidget);
    expect(find.text('Gerah'), findsWidgets);
    expect(find.textContaining('titik embun'), findsWidgets);
  });

  testWidgets('information screen shows disclaimer and sources', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: InformationScreen()));

    expect(find.text('Bukan saran medis'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('BMKG: peringatan dini cuaca resmi'), 200);
    expect(find.text('Sumber & metode'), findsOneWidget);
    expect(find.text('NOAA/NWS: klasifikasi indeks panas'), findsOneWidget);
    expect(find.text('BMKG: peringatan dini cuaca resmi'), findsOneWidget);
  });
}
