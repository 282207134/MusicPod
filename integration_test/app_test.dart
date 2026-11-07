import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:musicpod/app.dart';
import 'package:musicpod/core/catalog.dart';
import 'package:musicpod/core/controller.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'End-to-end navigation, native audio, persistence and 26 screenshots',
    (tester) async {
      final c = AppController(persist: false);
      await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold));
      await tester.runAsync(() async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        await Future.wait(
          manifest
              .listAssets()
              .where((p) => p.startsWith('assets/images/'))
              .map((p) => precacheImage(AssetImage(p), context)),
        );
      });
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      const names = [
        '01-splash',
        '02-signup',
        '03-otp',
        '04-home',
        '05-album',
        '06-album-filter',
        '07-player',
        '08-track-options',
        '09-queue',
        '10-search',
        '11-search-results',
        '12-podcasts',
        '13-podcast-detail',
        '14-library-playlists',
        '15-library-artists',
        '16-choose-artists',
        '17-library-albums',
        '18-library-episodes',
        '19-library-downloads',
        '20-settings',
        '21-account',
        '22-language',
        '23-data-saver',
        '24-social',
        '25-playback',
        '26-equalizer',
      ];
      for (final screen in AppScreen.values) {
        c.tab = screen.index >= 19
            ? 3
            : screen.index >= 13 && screen.index <= 18
            ? 2
            : screen == AppScreen.search || screen == AppScreen.searchResults
            ? 1
            : 0;
        c.miniVisible = screen.index >= 4;
        c.phone = '8493856738';
        if (screen == AppScreen.searchResults) c.query = 'Peach';
        c.go(screen);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: screen.name);
        await binding.takeScreenshot(names[screen.index]);
        if ([
          AppScreen.home,
          AppScreen.search,
          AppScreen.podcasts,
        ].contains(screen)) {
          await tester.drag(find.byType(ListView).first, const Offset(0, -620));
          await tester.pumpAndSettle();
          await binding.takeScreenshot('${names[screen.index]}-more');
        }
      }
      // Use one input connection for deterministic text entry after native screenshots.
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      c.go(AppScreen.home);
      c.miniVisible = false;
      await tester.pumpAndSettle();
      await tester.tap(find.text('Insomnia (Album)').first);
      await tester.pumpAndSettle();
      expect(c.screen, AppScreen.album);
      await tester.tap(find.text('Frank Septilion').first);
      // Playback updates continuously; it cannot become an idle animation.
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.screen, AppScreen.player);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1500)),
      );
      await tester.pump();
      expect(c.audioError, isNull);
      expect(c.playing, isTrue);
      expect(c.position.inMilliseconds, greaterThan(0));
      await c.togglePlayback();
      expect(c.playing, isFalse);
      c.selectTab(1);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(c.screen, AppScreen.searchResults);
      await tester.enterText(find.byType(TextField), 'Adele');
      await tester.pumpAndSettle();
      expect(c.query, 'Adele');
      expect(find.text('Hello'), findsOneWidget);
      c.selectTab(2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create playlist'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Evening Mix');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Evening Mix'), findsOneWidget);
      c.addToPlaylist(c.customPlaylists.first, albumTracks[1]);
      await tester.tap(find.text('Evening Mix'));
      await tester.pumpAndSettle();
      expect(find.text('Evening Mix'), findsOneWidget);
      expect(c.visibleAlbum.single.id, 'frank');
      final saved = AppController(audioEnabled: false);
      saved.username = 'MusicPod verification';
      saved.setSetting('Data Saver', false);
      await saved.save();
      final restored = AppController(audioEnabled: false);
      await restored.restore();
      expect(restored.username, 'MusicPod verification');
      expect(restored.settings['Data Saver'], isFalse);
      saved.username = 'Eugene Hawkins';
      saved.setSetting('Data Saver', true);
      await saved.save();
      saved.dispose();
      restored.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    },
  );
}
