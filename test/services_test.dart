import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:musicpod/core/catalog.dart';
import 'package:musicpod/core/live_controller.dart';
import 'package:musicpod/services/catalog_service.dart';
import 'package:musicpod/services/config.dart';
import 'package:musicpod/services/library_cloud.dart';

const sampleRss = '''<?xml version="1.0"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"><channel>
<title>Sample Show</title><itunes:author>Host</itunes:author>
<itunes:image href="https://example.com/cover.png" />
<item><guid>episode-1</guid><title>First episode</title>
<description><![CDATA[<p>Some notes.</p>]]></description>
<itunes:duration>1:02:03</itunes:duration>
<enclosure url="https://example.com/audio.mp3" type="audio/mpeg" /></item>
<item><title>Insecure media</title><enclosure url="http://example.com/no.mp3" /></item>
</channel></rss>''';

class MemoryCloud implements LibraryCloud {
  @override
  String? userId = 'user-a';
  @override
  String get displayName => userId ?? 'Guest';
  @override
  String get email => '${userId ?? 'guest'}@example.com';
  final events = StreamController<void>.broadcast(sync: true);
  final rows = <String, Map<String, dynamic>>{};
  bool failWrites = false;
  Completer<void>? gate;
  @override
  Stream<void> get changes => events.stream;
  @override
  Future<void> signIn() async {}
  @override
  Future<void> signOut() async {
    userId = null;
    events.add(null);
  }

  @override
  Future<Map<String, dynamic>?> load() async => rows[userId];
  @override
  Future<void> save(String userId, Map<String, dynamic> data) async {
    if (failWrites) throw StateError('offline');
    await gate?.future;
    rows[userId] = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
  }
}

LiveController controller({MemoryCloud? cloud, CatalogService? catalog}) =>
    LiveController(
      catalog: catalog ?? CatalogService(const ServiceConfig()),
      cloud: cloud,
      audioEnabled: false,
      localStorage: false,
    );

void main() {
  test('Missing credentials make no upstream request', () async {
    var calls = 0;
    final service = CatalogService(
      const ServiceConfig(),
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    await expectLater(service.music(), throwsA(isA<ServiceFailure>()));
    expect(calls, 0);
    service.dispose();
  });

  test(
    'Jamendo maps playable tracks, excludes unsafe media and caches queries',
    () async {
      var calls = 0;
      final service = CatalogService(
        const ServiceConfig(jamendoClientId: 'test-id'),
        client: MockClient((request) async {
          calls++;
          expect(request.url.queryParameters['client_id'], 'test-id');
          expect(request.url.queryParameters['search'], '夜');
          return http.Response(
            jsonEncode({
              'headers': {'status': 'success'},
              'results': [
                {
                  'id': '1',
                  'name': 'Title',
                  'artist_name': 'Artist',
                  'duration': 123,
                  'audio': 'https://example.com/1.mp3',
                  'image': 'https://example.com/1.png',
                },
                {
                  'id': '2',
                  'name': 'Unsafe',
                  'artist_name': 'Artist',
                  'audio': 'http://example.com/2.mp3',
                },
              ],
            }),
            200,
          );
        }),
      );
      final tracks = await service.music(query: '夜');
      expect(tracks.single.id, 'jamendo:1');
      expect(
        Track.fromJson(tracks.single.toJson()).audioUrl,
        tracks.single.audioUrl,
      );
      await service.music(query: ' 夜 ');
      expect(calls, 1);
      service.dispose();
    },
  );

  test(
    'Provider errors are not disguised as empty successful results',
    () async {
      final service = CatalogService(
        const ServiceConfig(jamendoClientId: 'invalid'),
        client: MockClient(
          (_) async => http.Response(
            '''{"headers":{"status":"failed"},"results":[]}''',
            200,
          ),
        ),
      );
      await expectLater(service.music(), throwsA(isA<ServiceFailure>()));
      service.dispose();
    },
  );

  test(
    'RSS handles namespaces, CDATA, duration, cover and HTTPS enclosures',
    () {
      final feed = CatalogService.parsePodcast(
        sampleRss,
        'https://example.com/feed',
      );
      expect(feed.title, 'Sample Show');
      expect(feed.episodes.single.artist, 'Host');
      expect(feed.episodes.single.imageUrl, 'https://example.com/cover.png');
      expect(feed.episodes.single.durationSeconds, 3723);
      expect(feed.episodes.single.description, 'Some notes.');
      expect(feed.episodes.single.isPodcast, isTrue);
    },
  );

  test(
    'Online playback and playlists never fall back to demo content',
    () async {
      final c = controller();
      final list = c.createPlaylist('Empty')!;
      c.openAlbum(playlist: list);
      expect(c.visibleAlbum, isEmpty);
      await c.play(albumTracks.first);
      expect(c.current.id, 'none');
      const t = Track(
        'real',
        'Real',
        'Artist',
        64,
        audioUrl: 'https://example.com/a.mp3',
      );
      c.addToPlaylist(list, t);
      expect(c.visibleAlbum.single.id, 'real');
      c.current = t;
      c.toggleSet(c.likes, t.id);
      expect(c.knownTracks[t.id], t);
      c.dispose();
    },
  );

  test(
    'Online albums and queue navigation keep their own track sources',
    () async {
      final c = controller();
      addTearDown(c.dispose);
      const z = Track(
        'z',
        'Zulu',
        'Artist',
        64,
        audioUrl: 'https://example.com/z',
      );
      const a = Track(
        'a',
        'Alpha',
        'Artist',
        64,
        audioUrl: 'https://example.com/a',
      );
      const m = Track(
        'm',
        'Middle',
        'Other',
        64,
        audioUrl: 'https://example.com/m',
      );
      c.featured.addAll([z, a, m]);
      c.albumQuery = 'old query';
      c.openAlbum();
      expect(c.albumQuery, isEmpty);
      c.sort = 'Title';
      expect(c.visibleAlbum, [a, m, z]);
      c.albumQuery = 'ARTIST';
      expect(c.visibleAlbum, [a, z]);
      c.hiddenTracks.add('z');
      expect(c.visibleAlbum, [a]);
      c.openAlbum(playlist: const Track('missing', 'Missing', '', 64));
      expect(c.visibleAlbum, isEmpty);

      c.hiddenTracks
        ..clear()
        ..add('m');
      c.queue.addAll([z, a, m]);
      await c.play(z);
      await c.next();
      expect(c.current, a);
      await c.next();
      expect(c.current, z);
      await c.next(previous: true);
      expect(c.current, a);
      c.queue.clear();
      await c.next();
      expect(c.current, a);
      expect(c.playing, isTrue);
    },
  );

  test('Cloud failure preserves edits and retry uploads them', () async {
    final cloud = MemoryCloud()..failWrites = true;
    final c = controller(cloud: cloud);
    await c.restore();
    c.likes.add('jamendo:1');
    await c.save();
    expect(c.likes, contains('jamendo:1'));
    expect(c.accountError, isNotNull);
    cloud.failWrites = false;
    await c.syncNow();
    expect(cloud.rows['user-a']!['likes'], contains('jamendo:1'));
    expect(c.syncStatus, 'Synced to cloud');
    c.dispose();
    await cloud.events.close();
  });

  test(
    'An edit during a cloud upload is uploaded before sync becomes clean',
    () async {
      final cloud = MemoryCloud()..gate = Completer<void>();
      final c = controller(cloud: cloud);
      await c.restore();
      final syncing = c.syncNow();
      await Future<void>.delayed(Duration.zero);
      c.likes.add('latest');
      await c.save();
      cloud.gate!.complete();
      await syncing;
      expect(cloud.rows['user-a']!['likes'], contains('latest'));
      expect(c.syncStatus, 'Synced to cloud');
      c.dispose();
      await cloud.events.close();
    },
  );

  test('Signing out clears account library, current track and queue', () async {
    final cloud = MemoryCloud();
    final c = controller(cloud: cloud);
    await c.restore();
    c.likes.add('private');
    await c.save();
    c.enqueue(const Track('private', 'Private', 'Artist', 64));
    await c.signOut();
    expect(c.likes, isEmpty);
    expect(c.customPlaylists, isEmpty);
    expect(c.queue, isEmpty);
    expect(c.current.id, 'none');
    expect(c.signedIn, isFalse);
    expect(cloud.rows['user-a']!['likes'], contains('private'));
    c.dispose();
    await cloud.events.close();
  });

  testWidgets('A late search response cannot overwrite a newer search', (
    tester,
  ) async {
    final old = Completer<http.Response>();
    final service = CatalogService(
      const ServiceConfig(jamendoClientId: 'test'),
      client: MockClient((request) {
        if (request.url.queryParameters['search'] == 'old') return old.future;
        return Future.value(
          http.Response('{"headers":{"status":"success"},"results":[]}', 200),
        );
      }),
    );
    final c = controller(catalog: service);
    c.updateQuery('old');
    await tester.pump(const Duration(milliseconds: 500));
    c.updateQuery('new');
    await tester.pump(const Duration(milliseconds: 500));
    old.complete(http.Response('{"headers":{"status":"failed"}}', 200));
    await tester.pump();
    expect(c.query, 'new');
    expect(c.searchError, isNull);
    expect(c.searching, isFalse);
    c.dispose();
  });
}
