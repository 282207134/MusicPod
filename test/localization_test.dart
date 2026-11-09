import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app.dart';
import 'package:musicpod/core/catalog.dart';
import 'package:musicpod/core/controller.dart';
import 'package:musicpod/core/live_controller.dart';
import 'package:musicpod/services/catalog_service.dart';
import 'package:musicpod/services/config.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

LiveController live({bool localStorage = false}) => LiveController(
  catalog: CatalogService(const ServiceConfig()),
  localStorage: localStorage,
  audioEnabled: false,
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'Roboto',
    )..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))).load();
  });
  test(
    'Interface language persists independently of content preferences and accounts',
    () async {
      final previous = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
      final first = live(localStorage: true);
      final original = Set<String>.from(first.selectedLanguages);
      await first.setInterfaceLanguage('ja');
      expect(first.selectedLanguages, original);
      first.toggleSet(first.selectedLanguages, 'Japanese');
      await first.save();
      await first.signOut();
      expect(first.interfaceLanguage, 'ja');
      first.dispose();
      final restored = live(localStorage: true);
      await restored.restoreInterfaceLanguage();
      await restored.restoreContentLanguages();
      expect(restored.interfaceLanguage, 'ja');
      expect(restored.selectedLanguages, contains('Japanese'));
      await restored.setInterfaceLanguage('unsupported');
      expect(restored.interfaceLanguage, 'ja');
      restored.dispose();
    },
  );

  testWidgets(
    'Language selection updates controls without translating provider or user names',
    (tester) async {
      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = live()..go(AppScreen.language);
      c.featured.add(const Track('provider', 'Home', 'Japanese', 64));
      await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('interface-language-zh')));
      await tester.pumpAndSettle();
      expect(c.interfaceLanguage, 'zh');
      expect(find.text('界面语言'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
      expect(
        Localizations.localeOf(
          tester.element(find.byType(Scaffold)),
        ).languageCode,
        'zh',
      );
      c.selectTab(0);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
      c.createPlaylist('Search');
      c.selectTab(2);
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
      await tester.tap(find.byTooltip('创建歌单'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My playlist');
      await c.setInterfaceLanguage('ja');
      await tester.pumpAndSettle();
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('作成'), findsOneWidget);
      expect(find.text('My playlist'), findsOneWidget);
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    },
  );

  testWidgets(
    'Follow device reacts to locale changes and unsupported languages fall back to English',
    (tester) async {
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('fr', 'FR'),
      ];
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final c = live()..go(AppScreen.home);
      await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
      await tester.pumpAndSettle();
      expect(find.text('Find your next sound'), findsOneWidget);
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('ja', 'JP'),
      ];
      await tester.pumpAndSettle();
      expect(find.text('次のお気に入りを見つけよう'), findsOneWidget);
      expect(c.interfaceLanguage, 'system');
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    },
  );

  for (final language in ['zh', 'ja']) {
    for (final width in [320.0, 428.0]) {
      for (final online in [true, false]) {
        testWidgets('$language layouts at $width px, online=$online', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, width == 320 ? 690 : 926);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final AppController c = online
              ? live()
              : AppController(persist: false, audioEnabled: false);
          await c.setInterfaceLanguage(language);
          await tester.pumpWidget(
            MusicPodApp(controller: c, autoAdvance: false),
          );
          final issues = <String>[];
          for (final screen in AppScreen.values) {
            c.go(screen);
            await tester.pumpAndSettle();
            final error = tester.takeException();
            if (error != null) issues.add('${screen.name}: $error');
          }
          expect(issues, isEmpty);
          await tester.pumpWidget(const SizedBox.shrink());
          c.dispose();
        });
      }
    }
  }
}
