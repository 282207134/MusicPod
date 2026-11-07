import 'package:flutter/material.dart';
import '../core/catalog.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'discover.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final podcasts = [
      AppScreen.libraryEpisodes,
      AppScreen.libraryDownloads,
    ].contains(c.screen);
    final options = podcasts
        ? ['Episodes', 'Downloads']
        : ['Playlists', 'Artists', 'Albums'];
    final pages = podcasts
        ? [AppScreen.libraryEpisodes, AppScreen.libraryDownloads]
        : [
            AppScreen.libraryPlaylists,
            AppScreen.libraryArtists,
            AppScreen.libraryAlbums,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 48, 26, 28),
          child: Row(
            children: [
              _TopTab(
                'Music',
                !podcasts,
                () => c.go(AppScreen.libraryPlaylists),
              ),
              const SizedBox(width: 25),
              _TopTab(
                'Podcasts',
                podcasts,
                () => c.go(AppScreen.libraryEpisodes),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            children: List.generate(
              options.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 32),
                child: InkWell(
                  onTap: () => c.go(pages[i]),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: c.screen == pages[i]
                              ? orange
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      options[i],
                      style: TextStyle(
                        fontSize: 16,
                        color: c.screen == pages[i] ? Colors.white : muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
            children: [
              if (c.screen == AppScreen.libraryPlaylists) ...[
                _AddRow(
                  'Create playlist',
                  circle: false,
                  onTap: () => showCreatePlaylist(context),
                ),
                ...[...c.customPlaylists, ...playlists].map(
                  (t) => TrackTile(t, onTap: () => c.openAlbum(playlist: t)),
                ),
              ],
              if (c.screen == AppScreen.libraryArtists) ...[
                _AddRow(
                  'Choose artists',
                  circle: true,
                  onTap: () => c.go(AppScreen.chooseArtists),
                ),
                ...artists.map(
                  (t) => TrackTile(t, circle: true, onTap: () => c.openAlbum()),
                ),
                ...c.selectedArtists
                    .where((s) => !artists.any((t) => t.id == s))
                    .map(
                      (s) => TrackTile(
                        Track(
                          s,
                          artistName(int.tryParse(s) ?? 0),
                          '',
                          29 - (int.tryParse(s) ?? 0),
                        ),
                        circle: true,
                        onTap: () => c.openAlbum(),
                      ),
                    ),
              ],
              if (c.screen == AppScreen.libraryAlbums)
                ...libraryAlbums.map(
                  (t) => TrackTile(t, onTap: () => c.openAlbum()),
                ),
              if (c.screen == AppScreen.libraryEpisodes) ...[
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff29d4c8), Color(0xff8cf1c3)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.play_circle_outline, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Episodes',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${c.downloads.length} episodes',
                          style: const TextStyle(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text('Unplayed', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                const EpisodeCard(
                  'feeney',
                  'S1 E2: Bruce Feeney',
                  'Business Unusual',
                  6,
                  duration: '20 min',
                ),
                const EpisodeCard(
                  'arianna',
                  'S1 E1: Arianna Huffington',
                  'Business Unusual',
                  5,
                ),
              ],
              if (c.screen == AppScreen.libraryDownloads) ...[
                if (c.downloads.isEmpty)
                  const EmptyState(
                    'No saved episodes yet.\nSave an episode to listen later.',
                  ),
                if (c.downloads.contains('daymond'))
                  const EpisodeCard(
                    'daymond',
                    'S1 E5: Daymond John',
                    'Business Unusual',
                    4,
                    duration: '40 min',
                  ),
                if (c.downloads.contains('bruce-jane'))
                  const EpisodeCard(
                    'bruce-jane',
                    'S6 E3: Bruce Jane',
                    'Productive thought process',
                    3,
                    duration: '40 min',
                  ),
                ...c.downloads
                    .where((s) => s != 'daymond' && s != 'bruce-jane')
                    .map(
                      (s) => EpisodeCard(
                        s,
                        switch (s) {
                          'sourdough' => 'San Francisco sourdough bread',
                          'potroast' => 'Pot roast',
                          'feeney' => 'S1 E2: Bruce Feeney',
                          _ => 'S1 E1: Arianna Huffington',
                        },
                        'Your saved episodes',
                        s == 'potroast' || s == 'arianna' ? 5 : 6,
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab(this.text, this.selected, this.onTap);
  final String text;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 32,
        color: selected ? Colors.white : const Color(0xff555555),
      ),
    ),
  );
}

class _AddRow extends StatelessWidget {
  const _AddRow(this.title, {required this.circle, required this.onTap});
  final String title;
  final bool circle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 14),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff666666)),
              borderRadius: BorderRadius.circular(circle ? 30 : 8),
            ),
            child: const Icon(Icons.add, color: muted, size: 26),
          ),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

Future<Track?> showCreatePlaylist(BuildContext context) async {
  final c = AppScope.of(context);
  final field = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create playlist'),
      content: TextField(
        controller: field,
        autofocus: true,
        maxLength: 50,
        decoration: const InputDecoration(labelText: 'Playlist name'),
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) Navigator.pop(context, v);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (field.text.trim().isNotEmpty) {
              Navigator.pop(context, field.text);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
  final playlist = name == null ? null : c.createPlaylist(name);
  // Let the closing dialog finish using its controller before disposal.
  await Future<void>.delayed(const Duration(milliseconds: 250));
  field.dispose();
  return playlist;
}

String artistName(int index) =>
    ['Arijit Singh', 'Insomnia (Album)', 'Love Story'][index % 3];

Future<void> showAddToPlaylist(BuildContext context) async {
  final c = AppScope.of(context), track = c.current;
  final playlist = await showModalBottomSheet<Track>(
    context: context,
    showDragHandle: true,
    builder: (context) => ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(26, 4, 26, 28),
      children: [
        const Text('Add to playlist', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.add),
          title: const Text('Create playlist'),
          onTap: () => Navigator.pop(context, const Track('new', '', '', 69)),
        ),
        ...[
          ...c.customPlaylists,
          ...playlists,
        ].map((p) => TrackTile(p, onTap: () => Navigator.pop(context, p))),
      ],
    ),
  );
  if (playlist == null || !context.mounted) return;
  final target = playlist.id == 'new'
      ? await showCreatePlaylist(context)
      : playlist;
  if (target != null) {
    c.addToPlaylist(target, track);
    if (context.mounted) message(context, 'Added to ${target.title}');
  }
}

class ChooseArtistsPage extends StatefulWidget {
  const ChooseArtistsPage({super.key});
  @override
  State<ChooseArtistsPage> createState() => _ChooseArtistsPageState();
}

class _ChooseArtistsPageState extends State<ChooseArtistsPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final entries = List.generate(12, (i) => i)
        .where((i) => artistName(i).toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        gradient: panelGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 18, bottom: 34),
              width: 48,
              height: 3,
              color: const Color(0xffbbbbbb),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 26),
            child: Text(
              'Choose artists you like',
              style: TextStyle(fontSize: 30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 32),
            child: SearchPill(
              hint: 'Search here',
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: .78,
              ),
              itemCount: entries.length,
              itemBuilder: (context, n) {
                final i = entries[n],
                    selected = c.selectedArtists.contains('$i');
                const arts = [29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18];
                return InkWell(
                  onTap: () => c.toggleSet(c.selectedArtists, '$i'),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: LayoutBuilder(
                                builder: (_, bounds) => Artwork(
                                  arts[i],
                                  size: bounds.maxWidth,
                                  circle: true,
                                ),
                              ),
                            ),
                            if (selected)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: orange,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.check, size: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        artistName(i),
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ink,
                  minimumSize: const Size(130, 45),
                ),
                onPressed: c.back,
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
