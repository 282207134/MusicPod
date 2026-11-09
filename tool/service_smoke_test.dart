// Optional real-network probe, separate from the deterministic test suite.
// flutter test tool/service_smoke_test.dart
// Add --dart-define=JAMENDO_CLIENT_ID=... to also probe your own music app.
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/core/podcast_catalog.dart';
import 'package:musicpod/services/catalog_service.dart';
import 'package:musicpod/services/config.dart';

void main() {
  final service = CatalogService(ServiceConfig.environment);
  tearDownAll(service.dispose);
  test('Public NPR RSS can be fetched and parsed', () async {
    final feed = await service.podcast(
      'https://feeds.npr.org/510289/podcast.xml',
    );
    expect(feed.title, isNotEmpty);
    expect(feed.episodes, isNotEmpty);
    expect(feed.episodes.first.audioUrl, startsWith('https://'));
  });
  for (final pick in podcastPicks.where((pick) => pick.language != 'en')) {
    test('${pick.title}: public RSS can be fetched and parsed', () async {
      final feed = await service.podcast(pick.url);
      expect(feed.episodes, isNotEmpty);
      expect(feed.episodes.length, lessThanOrEqualTo(100));
      expect(feed.episodes.first.audioUrl, startsWith('https://'));
    });
  }
  test(
    'Own Jamendo Client ID can retrieve music',
    () async {
      final tracks = await service.music(query: 'piano');
      expect(tracks, isNotEmpty);
      expect(tracks.first.audioUrl, startsWith('https://'));
    },
    skip: !ServiceConfig.environment.hasMusic
        ? 'Configure your own JAMENDO_CLIENT_ID first.'
        : false,
  );
}
