import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catalog.dart';

class AppController extends ChangeNotifier {
  AppController({this.persist = true, bool audioEnabled = true}) {
    if (audioEnabled) {
      _audio = AudioPlayer();
      _subscriptions.addAll([
        _audio!.onPositionChanged.listen((value) {
          position = value;
          notifyListeners();
        }),
        _audio!.onDurationChanged.listen((value) {
          duration = value;
          notifyListeners();
        }),
        _audio!.onPlayerComplete.listen((_) {
          if (repeat) {
            play(current);
          } else if (settings['Autoplay'] == true) {
            next();
          } else {
            playing = false;
            position = Duration.zero;
            notifyListeners();
          }
        }),
        _audio!.onPlayerStateChanged.listen((value) {
          playing = value == PlayerState.playing;
          notifyListeners();
        }),
      ]);
    }
  }
  final bool persist;
  bool get isOnline => false;
  bool get persistDevicePreferences => persist;
  final interfaceLanguageChanges = ValueNotifier<String>('system');
  String get interfaceLanguage => interfaceLanguageChanges.value;
  Future<void> restoreInterfaceLanguage() async {
    if (!persistDevicePreferences) return;
    final saved = await _preferences.getString('musicpod.interfaceLanguage');
    if (['system', 'en', 'zh', 'ja'].contains(saved)) {
      interfaceLanguageChanges.value = saved!;
    }
  }

  Future<void> restoreContentLanguages() async {
    if (!persistDevicePreferences) return;
    final saved = await _preferences.getStringList('musicpod.contentLanguages');
    if (saved != null) {
      selectedLanguages
        ..clear()
        ..addAll(saved.where(languages.contains));
    }
  }

  Future<void> setInterfaceLanguage(String language) async {
    if (!['system', 'en', 'zh', 'ja'].contains(language)) return;
    interfaceLanguageChanges.value = language;
    notifyListeners();
    if (persistDevicePreferences) {
      await _preferences.setString('musicpod.interfaceLanguage', language);
    }
  }

  late final _preferences = SharedPreferencesAsync();
  AudioPlayer? _audio;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<AppScreen> _history = [];
  AppScreen screen = AppScreen.splash;
  int tab = 0;
  bool onboarded = false,
      playing = false,
      shuffle = false,
      repeat = false,
      miniVisible = false;
  String phone = '',
      query = '',
      albumQuery = '',
      sort = 'Custom order',
      preset = 'Bass Reducer';
  String username = 'Eugene Hawkins', email = 'francine.wood@mail.com';
  String? audioError;
  Track current = albumTracks[1];
  Duration position = Duration.zero, duration = const Duration(seconds: 24);
  final List<Track> queue = [...queueTracks];
  final List<Track> customPlaylists = [];
  final Map<String, List<Track>> playlistSongs = {};
  final Set<String> hiddenTracks = {};
  Track? selectedPlaylist;
  final Set<String> likes = {},
      selectedArtists = {},
      downloads = {'daymond', 'bruce-jane'};
  final Set<String> selectedLanguages = {
    'English',
    'Chinese',
    'Hindi',
    'German',
    'Russian',
  };
  final Map<String, bool> settings = {
    'Data Saver': true,
    'Audio-only podcasts': false,
    'Private session': true,
    'Listen activity': false,
    'Recently played artists': false,
    'Hide Unplayable Songs': true,
    'Enable Audio Normalization': false,
    'Mono Audio': false,
    'Play Feedback Sounds': true,
    'Autoplay': true,
    'Equalizer': true,
    'Also apply to podcasts': false,
  };

  Future<void> restore() async {
    if (!persist) return;
    final raw = await _preferences.getString('musicpod.v1');
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      onboarded = data['onboarded'] == true;
      username = data['username'] as String? ?? username;
      email = data['email'] as String? ?? email;
      preset = data['preset'] as String? ?? preset;
      for (final entry
          in (data['settings'] as Map<String, dynamic>? ?? {}).entries) {
        if (entry.value is bool) settings[entry.key] = entry.value as bool;
      }
      for (final entry in {
        'likes': likes,
        'artists': selectedArtists,
        'languages': selectedLanguages,
        'downloads': downloads,
      }.entries) {
        final saved = data[entry.key];
        if (saved is List) {
          entry.value
            ..clear()
            ..addAll(saved.whereType<String>());
        }
      }
      for (final name
          in (data['playlists'] as List? ?? []).whereType<String>()) {
        customPlaylists.add(Track('custom-$name', name, 'By $username', 69));
      }
      for (final entry
          in (data['playlistSongs'] as Map<String, dynamic>? ?? {}).entries) {
        playlistSongs[entry.key] = (entry.value as List)
            .map((t) => Track.fromJson(Map<String, dynamic>.from(t as Map)))
            .toList();
      }
    } on FormatException {
      /* Ignore an incomplete local preference file. */
    }
  }

  Future<void> save() async {
    if (!persist) return;
    await _preferences.setString(
      'musicpod.v1',
      jsonEncode({
        'onboarded': onboarded,
        'username': username,
        'email': email,
        'preset': preset,
        'settings': settings,
        'likes': likes.toList(),
        'artists': selectedArtists.toList(),
        'languages': selectedLanguages.toList(),
        'downloads': downloads.toList(),
        'playlists': customPlaylists.map((e) => e.title).toList(),
        'playlistSongs': playlistSongs.map(
          (id, tracks) => MapEntry(id, tracks.map((t) => t.toJson()).toList()),
        ),
      }),
    );
  }

  void go(AppScreen value, {bool remember = true}) {
    if (value == screen) return;
    if (remember) _history.add(screen);
    screen = value;
    if (!isOnline && value.index >= AppScreen.album.index) miniVisible = true;
    notifyListeners();
  }

  void back() {
    screen = _history.isNotEmpty ? _history.removeLast() : AppScreen.home;
    if (screen == AppScreen.home) tab = 0;
    notifyListeners();
  }

  void selectTab(int value) {
    tab = value;
    _history.clear();
    screen = [
      AppScreen.home,
      AppScreen.search,
      AppScreen.libraryPlaylists,
      AppScreen.settings,
    ][value];
    notifyListeners();
  }

  void finishSignup() {
    onboarded = true;
    _history.clear();
    go(AppScreen.home, remember: false);
    unawaited(save());
  }

  void refresh() => notifyListeners();
  void updateQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setSort(String value) {
    sort = value;
    back();
  }

  void setSetting(String key, bool value) {
    settings[key] = value;
    notifyListeners();
    unawaited(save());
  }

  void toggleSet(Set<String> set, String value) {
    if (!set.remove(value)) set.add(value);
    if (identical(set, selectedLanguages) && persistDevicePreferences) {
      unawaited(
        _preferences.setStringList('musicpod.contentLanguages', set.toList()),
      );
    }
    notifyListeners();
    unawaited(save());
  }

  Track? createPlaylist(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return null;
    final existing = customPlaylists.where((p) => p.title == clean);
    if (existing.isNotEmpty) return existing.first;
    final playlist = Track('custom-$clean', clean, 'By $username', 69);
    customPlaylists.insert(0, playlist);
    playlistSongs[playlist.id] = [];
    notifyListeners();
    unawaited(save());
    return playlist;
  }

  void openAlbum({Track? playlist}) {
    selectedPlaylist = playlist;
    albumQuery = '';
    go(AppScreen.album);
  }

  void addToPlaylist(Track playlist, Track track) {
    final songs = playlistSongs.putIfAbsent(
      playlist.id,
      () => [...albumTracks],
    );
    if (!songs.any((t) => t.id == track.id)) songs.add(track);
    notifyListeners();
    unawaited(save());
  }

  List<Track> get albumSource => selectedPlaylist == null
      ? albumTracks
      : playlistSongs[selectedPlaylist!.id] ?? albumTracks;

  List<Track> get visibleAlbum {
    final tracks = albumSource
        .where(
          (t) =>
              !hiddenTracks.contains(t.id) &&
              '${t.title} ${t.artist}'.toLowerCase().contains(
                albumQuery.toLowerCase(),
              ),
        )
        .toList();
    if (sort == 'Title') tracks.sort((a, b) => a.title.compareTo(b.title));
    if (sort == 'Artist') tracks.sort((a, b) => a.artist.compareTo(b.artist));
    return sort == 'Recently added' ? tracks.reversed.toList() : tracks;
  }

  List<Track> get searchResults =>
      [...searchTracks, ...albumTracks, ...libraryAlbums]
          .where(
            (t) => '${t.title} ${t.artist}'.toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
  Future<void> play(Track track) async {
    current = track;
    miniVisible = true;
    position = Duration.zero;
    audioError = null;
    playing = true;
    if (track.durationSeconds > 0) {
      duration = Duration(seconds: track.durationSeconds);
    }
    notifyListeners();
    try {
      if (isOnline && track.audioUrl == null) {
        throw StateError('No online audio source');
      }
      await _audio?.play(
        track.audioUrl != null
            ? UrlSource(track.audioUrl!)
            : AssetSource('audio/preview.wav'),
      );
    } catch (_) {
      audioError =
          'Unable to play this audio. Please check your connection and try again.';
      playing = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayback() async {
    if (playing) {
      await _audio?.pause();
      playing = false;
    } else if (position == Duration.zero) {
      await play(current);
      return;
    } else {
      await _audio?.resume();
      playing = true;
    }
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    playing = false;
    miniVisible = false;
    position = Duration.zero;
    await _audio?.stop();
    notifyListeners();
  }

  Future<void> seek(double seconds) async {
    position = Duration(milliseconds: (seconds * 1000).round());
    await _audio?.seek(position);
    notifyListeners();
  }

  List<Track> get playbackTracks => [albumTracks[1], ...queue];

  Future<void> next({bool previous = false}) async {
    final tracks = playbackTracks
        .where((t) => !hiddenTracks.contains(t.id))
        .toList();
    if (tracks.isEmpty) {
      if (playing && !isOnline) await togglePlayback();
      return;
    }
    final index = tracks.indexWhere((t) => t.id == current.id);
    final nextIndex = shuffle
        ? Random().nextInt(tracks.length)
        : (index + (previous ? -1 : 1)) % tracks.length;
    await play(tracks[nextIndex]);
  }

  void enqueue(Track track) {
    queue.add(track);
    notifyListeners();
  }

  void removeQueue(Set<String> ids) {
    queue.removeWhere((t) => ids.contains(t.id));
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    queue.insert(newIndex, queue.removeAt(oldIndex));
    notifyListeners();
  }

  @override
  void dispose() {
    interfaceLanguageChanges.dispose();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_audio?.dispose());
    super.dispose();
  }
}
