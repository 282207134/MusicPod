import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/catalog_service.dart';
import '../services/library_cloud.dart';
import 'catalog.dart';
import 'controller.dart';

class LiveController extends AppController {
  LiveController({
    required this.catalog,
    this.cloud,
    this.localStorage = true,
    super.audioEnabled,
  }) : super(persist: false) {
    _resetLibrary();
    current = const Track('none', 'Choose something to play', '', 64);
    queue.clear();
    duration = Duration.zero;
  }
  final CatalogService catalog;
  final LibraryCloud? cloud;
  final bool localStorage;
  late final _local = SharedPreferencesAsync();
  final List<Track> featured = [], results = [], recent = [];
  final Map<String, Track> knownTracks = {};
  final List<String> subscriptions = [];
  PodcastFeed? feed;
  bool loadingMusic = false,
      searching = false,
      loadingFeed = false,
      syncing = false,
      signingIn = false;
  String? musicError, searchError, feedError, accountError;
  String syncStatus = 'Saved on this device';
  String? _activeUser;
  StreamSubscription<void>? _auth;
  Timer? _searchTimer;
  int _searchRequest = 0, _feedRequest = 0, _identity = 0, _revision = 0;
  bool _disposed = false, _dirty = false;
  Future<void> _writes = Future.value();
  @override
  bool get isOnline => true;
  @override
  bool get persistDevicePreferences => localStorage;
  bool get signedIn => _activeUser != null;
  String get _storageKey => 'musicpod.online.${_activeUser ?? 'guest'}';
  String? startupError;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void _resetLibrary() {
    username = 'Guest';
    email = '';
    likes.clear();
    downloads.clear();
    selectedArtists.clear();
    customPlaylists.clear();
    playlistSongs.clear();
    subscriptions.clear();
    recent.clear();
    knownTracks.clear();
    _dirty = false;
  }

  Map<String, dynamic> _snapshot() => {
    'version': 1,
    'onboarded': onboarded,
    'username': username,
    'likes': likes.toList(),
    'savedEpisodes': downloads.toList(),
    'subscriptions': subscriptions.toList(),
    'playlists': customPlaylists.map((t) => t.toJson()).toList(),
    'playlistSongs': playlistSongs.map(
      (id, list) => MapEntry(id, list.map((t) => t.toJson()).toList()),
    ),
    'tracks': knownTracks.values.map((t) => t.toJson()).toList(),
    'recent': recent.map((t) => t.toJson()).toList(),
  };

  void _apply(Map<String, dynamic> data) {
    List<String> strings(String key) =>
        (data[key] as List? ?? []).whereType<String>().toList();
    List<Track> tracks(Object? raw) => (raw as List? ?? [])
        .map((t) => Track.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList();
    // Parse before changing state, so a malformed snapshot cannot half-replace a library.
    final playlists = tracks(data['playlists']);
    final songs = (data['playlistSongs'] as Map? ?? {}).map(
      (id, raw) => MapEntry(id.toString(), tracks(raw)),
    );
    final known = tracks(data['tracks']);
    final history = tracks(data['recent']);
    username = data['username'] as String? ?? username;
    onboarded = data['onboarded'] == true;
    likes
      ..clear()
      ..addAll(strings('likes'));
    downloads
      ..clear()
      ..addAll(strings('savedEpisodes'));
    subscriptions
      ..clear()
      ..addAll(strings('subscriptions'));
    customPlaylists
      ..clear()
      ..addAll(playlists);
    playlistSongs
      ..clear()
      ..addAll(songs);
    knownTracks
      ..clear()
      ..addEntries(known.map((t) => MapEntry(t.id, t)));
    recent
      ..clear()
      ..addAll(history);
  }

  @override
  Future<void> restore() async {
    _activeUser = cloud?.userId;
    await _restoreLocal();
  }

  Future<void> _restoreLocal() async {
    if (!localStorage) return;
    final epoch = _identity;
    final raw = await _local.getString(_storageKey);
    if (raw == null || epoch != _identity || _disposed) return;
    try {
      final state = jsonDecode(raw) as Map<String, dynamic>;
      _apply(Map<String, dynamic>.from(state['data'] as Map));
      _dirty = state['dirty'] == true;
    } catch (_) {
      accountError =
          'The local library could not be restored. Your cloud copy has not been changed.';
    }
  }

  void start() {
    _auth = cloud?.changes.listen(
      (_) {
        unawaited(_changeIdentity());
      },
      onError: (Object _) {
        accountError =
            'Sign-in could not finish. Return to Account and try again.';
        signingIn = false;
        notifyListeners();
      },
    );
    unawaited(_changeIdentity(force: true));
    unawaited(loadMusic());
  }

  Future<void> _changeIdentity({bool force = false}) async {
    final id = cloud?.userId;
    if (!force && id == _activeUser) return;
    final changed = id != _activeUser;
    final epoch = ++_identity;
    _activeUser = id;
    signingIn = false;
    syncing = false;
    accountError = null;
    if (changed) {
      _resetLibrary();
      selectedPlaylist = null;
      queue.clear();
      feed = null;
      _feedRequest++;
      current = const Track('none', 'Choose something to play', '', 64);
      await stopPlayback();
      if (epoch != _identity || _disposed) return;
      await _restoreLocal();
      if (epoch != _identity || _disposed) return;
    }
    if (id != null) {
      if (username == 'Guest') username = cloud!.displayName;
      email = cloud!.email;
      onboarded = true;
      if (screen == AppScreen.signup || screen == AppScreen.splash) {
        go(AppScreen.home, remember: false);
      }
      await syncNow();
    } else {
      syncStatus = 'Saved on this device';
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    if (cloud == null) {
      accountError =
          startupError ??
          'Account service is not configured. Follow docs/SERVICE_SETUP.md.';
      notifyListeners();
      return;
    }
    signingIn = true;
    accountError = null;
    notifyListeners();
    try {
      await cloud!.signIn();
    } catch (_) {
      accountError =
          'Could not open GitHub sign-in. Check the provider settings and try again.';
    } finally {
      signingIn = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await cloud?.signOut();
      await _changeIdentity();
    } catch (_) {
      accountError = 'Could not sign out. Please try again.';
      notifyListeners();
    }
  }

  Future<void> _storeLocal(
    String key,
    Map<String, dynamic> data,
    bool dirty,
  ) async {
    if (localStorage) {
      await _local.setString(key, jsonEncode({'data': data, 'dirty': dirty}));
    }
  }

  @override
  Future<void> save() async {
    _revision++;
    _dirty = true;
    final snapshot = _snapshot(), key = _storageKey;
    final id = _activeUser, epoch = _identity, revision = _revision;
    await _storeLocal(key, snapshot, true);
    if (epoch != _identity || _disposed) return;
    if (id == null) {
      syncStatus = 'Saved on this device';
      notifyListeners();
      return;
    }
    if (syncing) {
      return; // syncNow observes _revision and uploads the newer snapshot.
    }
    _writes = _writes.then((_) async {
      if (epoch != _identity || _disposed) return;
      try {
        await cloud!.save(id, snapshot).timeout(const Duration(seconds: 15));
        if (epoch != _identity || revision != _revision || _disposed) return;
        _dirty = false;
        await _storeLocal(key, snapshot, false);
        syncStatus = 'Synced to cloud';
        accountError = null;
      } catch (_) {
        if (epoch != _identity || _disposed) return;
        syncStatus = 'Saved locally · sync pending';
        accountError =
            'Cloud sync failed. Check your connection and database setup, then tap Sync now.';
      }
      notifyListeners();
    });
    await _writes;
  }

  Future<void> syncNow() async {
    if (!signedIn || syncing) return;
    final epoch = _identity, id = _activeUser!, revision = _revision;
    syncing = true;
    syncStatus = 'Syncing…';
    notifyListeners();
    try {
      await _writes;
      if (epoch != _identity || _disposed) return;
      final remote = await cloud!.load().timeout(const Duration(seconds: 15));
      if (epoch != _identity || _disposed) return;
      if (!_dirty && revision == _revision && remote != null) _apply(remote);
      // Offline edits take precedence; snapshots use last-write-wins, not realtime merging.
      // Repeat when an edit occurs during an upload so it cannot be marked clean prematurely.
      while (epoch == _identity && !_disposed) {
        final currentRevision = _revision, snapshot = _snapshot();
        if (_dirty || remote == null) {
          await cloud!.save(id, snapshot).timeout(const Duration(seconds: 15));
        }
        if (epoch != _identity || _disposed) return;
        if (currentRevision != _revision) continue;
        await _storeLocal(_storageKey, snapshot, false);
        if (currentRevision != _revision) continue;
        _dirty = false;
        break;
      }
      syncStatus = 'Synced to cloud';
      accountError = null;
    } catch (_) {
      if (epoch == _identity) {
        syncStatus = 'Saved locally · sync pending';
        accountError =
            'Cloud sync failed. Check your connection and run the database setup SQL.';
      }
    } finally {
      if (epoch == _identity) {
        syncing = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMusic() async {
    if (loadingMusic) return;
    loadingMusic = true;
    musicError = null;
    notifyListeners();
    try {
      final loaded = await catalog.music();
      featured
        ..clear()
        ..addAll(loaded);
    } catch (e) {
      musicError = e.toString();
    } finally {
      loadingMusic = false;
      notifyListeners();
    }
  }

  @override
  void updateQuery(String value) {
    query = value;
    _searchTimer?.cancel();
    final request = ++_searchRequest;
    results.clear();
    searchError = null;
    searching = value.trim().isNotEmpty;
    notifyListeners();
    if (!searching) return;
    _searchTimer = Timer(const Duration(milliseconds: 450), () async {
      try {
        final tracks = await catalog.music(query: value);
        if (request != _searchRequest || _disposed) return;
        results
          ..clear()
          ..addAll(tracks);
      } catch (e) {
        if (request == _searchRequest) searchError = e.toString();
      } finally {
        if (request == _searchRequest) {
          searching = false;
          notifyListeners();
        }
      }
    });
  }

  Future<void> openFeed(String url) async {
    final request = ++_feedRequest;
    loadingFeed = true;
    feedError = null;
    feed = null;
    go(AppScreen.podcastDetail);
    try {
      final loaded = await catalog.podcast(url);
      if (request == _feedRequest && !_disposed) feed = loaded;
    } catch (e) {
      if (request == _feedRequest) feedError = e.toString();
    } finally {
      if (request == _feedRequest) {
        loadingFeed = false;
        notifyListeners();
      }
    }
  }

  void subscribeFeed() {
    if (feed == null) return;
    if (!subscriptions.remove(feed!.url)) subscriptions.add(feed!.url);
    notifyListeners();
    unawaited(save());
  }

  void remember(Track t) => knownTracks[t.id] = t;
  @override
  void toggleSet(Set<String> set, String value) {
    if (identical(set, likes) &&
        value == current.id &&
        current.audioUrl != null) {
      remember(current);
    }
    super.toggleSet(set, value);
  }

  void toggleFavorite(Track t) {
    remember(t);
    toggleSet(likes, t.id);
  }

  void saveEpisode(Track t) {
    remember(t);
    toggleSet(downloads, t.id);
  }

  @override
  Future<void> play(Track track) async {
    if (track.audioUrl == null) return;
    remember(track);
    recent.removeWhere((t) => t.id == track.id);
    recent.insert(0, track);
    if (recent.length > 20) recent.removeLast();
    if (!queue.any((t) => t.id == track.id)) queue.add(track);
    await super.play(track);
    unawaited(save());
  }

  @override
  List<Track> get playbackTracks => queue;

  @override
  List<Track> get albumSource => selectedPlaylist == null
      ? featured
      : playlistSongs[selectedPlaylist!.id] ?? <Track>[];

  @override
  void addToPlaylist(Track playlist, Track track) {
    remember(track);
    playlistSongs.putIfAbsent(playlist.id, () => []);
    super.addToPlaylist(playlist, track);
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    unawaited(_auth?.cancel());
    catalog.dispose();
    super.dispose();
  }
}
