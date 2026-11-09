import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app.dart';
import 'package:musicpod/core/catalog.dart';
import 'package:musicpod/core/live_controller.dart';
import 'package:musicpod/services/catalog_service.dart';
import 'package:musicpod/services/config.dart';

void main() {
  for (final size in [const Size(320, 690), const Size(428, 926)]) {
    testWidgets('Online flows render at ${size.width}px without demo results', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LiveController(
        catalog: CatalogService(const ServiceConfig()),
        audioEnabled: false,
        localStorage: false,
      );
      c.featured.add(
        const Track(
          'online:1',
          'A real track title',
          'Independent artist',
          64,
          audioUrl: 'https://example.com/test.mp3',
          durationSeconds: 100,
        ),
      );
      c.feed = PodcastFeed(
        'https://example.com/rss',
        'Podcast test title',
        'Host',
        null,
        [
          const Track(
            'episode:1',
            'An episode',
            'Host',
            40,
            isPodcast: true,
            audioUrl: 'https://example.com/episode.mp3',
            description: 'Episode notes.',
          ),
        ],
      );
      await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
      for (final screen in [
        AppScreen.signup,
        AppScreen.home,
        AppScreen.search,
        AppScreen.podcasts,
        AppScreen.podcastDetail,
        AppScreen.libraryPlaylists,
        AppScreen.account,
        AppScreen.album,
        AppScreen.player,
      ]) {
        c.go(screen);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: screen.name);
        expect(find.text('Peaches'), findsNothing);
        expect(find.text('Demo PIN: 1234'), findsNothing);
      }
      c.go(AppScreen.account);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with GitHub'));
      await tester.pumpAndSettle();
      expect(find.textContaining('not configured'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    });
  }
}
