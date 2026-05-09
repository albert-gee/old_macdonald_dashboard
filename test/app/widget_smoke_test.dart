import 'package:dashboard/src/app/dashboard_app.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_cluster_repository.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';
import 'package:dashboard/src/features/thread/presentation/screens/thread_screen.dart';
import 'package:dashboard/src/features/wifi/presentation/screens/wifi_sta_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = AppConfig(
    appTitle: 'Old MacDonald',
    appSubtitle: 'Controlled Environment',
    defaultWebSocketUrl: 'ws://localhost/ws',
    rootCaAssetPath: 'assets/rootCA.pem',
  );

  testWidgets('Wi-Fi form validation prevents empty SSID/password',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WifiStaScreen())),
      ),
    );

    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.text('SSID is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('thread screen smoke test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ThreadScreen())),
      ),
    );
    expect(find.text('Thread Status'), findsOneWidget);
    expect(find.text('Thread Commands'), findsOneWidget);
    expect(find.text('Thread Dataset'), findsOneWidget);
  });

  testWidgets('dataset form validation prevents invalid fields',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ThreadDatasetForm())),
      ),
    );

    await tester.tap(find.text('Initialize'));
    await tester.pump();

    expect(find.text('Channel is required.'), findsOneWidget);
    expect(find.text('PAN ID is required.'), findsOneWidget);
    expect(find.text('Network name is required.'), findsOneWidget);
  });

  testWidgets('matter controller validates unsigned node ID', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: MatterControllerInitForm())),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tester.tap(find.text('Initialize Controller'));
    await tester.pump();

    expect(
      find.text('Node ID must be an unsigned decimal integer.'),
      findsOneWidget,
    );
  });

  testWidgets('matter screen and dashboard navigation smoke test',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orchestrator'), findsWidgets);
    await tester.tap(find.text('Wi-Fi STA').first);
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi STA Connection'), findsOneWidget);

    await tester.tap(find.text('Thread Network').first);
    await tester.pumpAndSettle();
    expect(find.text('Thread Commands'), findsOneWidget);

    await tester.tap(find.text('Matter Network').first);
    await tester.pumpAndSettle();
    expect(find.text('Controller Init'), findsOneWidget);
    expect(find.text('Pair BLE Thread'), findsWidgets);
    expect(find.text('Cluster Command'), findsOneWidget);
    expect(find.text('Read Attribute'), findsWidgets);
    expect(find.text('Subscribe Attribute'), findsWidgets);
  });
}

final class _ClusterRepo implements MatterClusterRepository {
  @override
  Future<Result<List<MatterCluster>>> loadClusters() async {
    return const Success([
      MatterCluster(
        id: '0x0006',
        name: 'On/Off',
        attributes: [
          MatterAttribute(id: '0x0000', name: 'OnOff'),
        ],
      ),
    ]);
  }
}
