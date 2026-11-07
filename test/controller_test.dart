import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/core/catalog.dart';
import 'package:musicpod/core/controller.dart';

void main() {
  late AppController c;
  setUp(() => c = AppController(persist: false, audioEnabled: false));
  tearDown(() => c.dispose());
  test(
    'Search matches titles and artists and returns no unrelated results',
    () {
      c.updateQuery('peach');
      expect(c.searchResults.length, 4);
      c.updateQuery('ADELE');
      expect(c.searchResults.single.id, 'hello');
      c.updateQuery('this does not exist');
      expect(c.searchResults, isEmpty);
    },
  );
  test('Album filtering and sorting compose', () {
    c.sort = 'Title';
    expect(c.visibleAlbum.first.id, 'baila');
    c.albumQuery = 'selena';
    expect(c.visibleAlbum.length, 2);
    c.sort = 'Recently added';
    expect(c.visibleAlbum.first.id, 'scary');
  });
  test('Queue supports reorder, removal, next and previous', () async {
    final first = c.queue.first;
    c.reorderQueue(0, 3);
    expect(c.queue[2], first);
    c.removeQueue({first.id});
    expect(c.queue.any((t) => t.id == first.id), isFalse);
    await c.next();
    expect(c.current, c.queue.first);
    await c.next(previous: true);
    expect(c.current.id, 'frank');
    c.enqueue(albumTracks[0]);
    expect(c.queue.last.id, 'isralea');
  });
  test('Likes, playlists and settings update independent state', () {
    c.toggleSet(c.likes, 'frank');
    expect(c.likes, contains('frank'));
    c.toggleSet(c.likes, 'frank');
    expect(c.likes, isEmpty);
    c.createPlaylist('   ');
    expect(c.customPlaylists, isEmpty);
    c.createPlaylist('  Evening  ');
    expect(c.customPlaylists.single.title, 'Evening');
    final playlist = c.customPlaylists.single;
    c.addToPlaylist(playlist, albumTracks[1]);
    c.addToPlaylist(playlist, albumTracks[1]);
    c.openAlbum(playlist: playlist);
    expect(c.visibleAlbum.single.id, 'frank');
    c.setSetting('Data Saver', false);
    expect(c.settings['Data Saver'], isFalse);
  });
  test('Navigation returns to source and section selection clears history', () {
    c.go(AppScreen.home);
    c.go(AppScreen.album);
    c.go(AppScreen.player);
    c.back();
    expect(c.screen, AppScreen.album);
    c.selectTab(2);
    expect(c.screen, AppScreen.libraryPlaylists);
    c.back();
    expect(c.screen, AppScreen.home);
  });
}
