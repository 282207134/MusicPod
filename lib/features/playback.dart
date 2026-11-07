import 'package:flutter/material.dart';
import '../core/catalog.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'library.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 20, 6, 20),
          child: Row(
            children: [
              TapIcon(
                Icons.arrow_back_ios_new,
                label: 'Back',
                size: 22,
                onTap: c.back,
              ),
              Expanded(
                child: SearchPill(
                  dark: true,
                  onChanged: (v) {
                    c.albumQuery = v;
                    c.refresh();
                  },
                ),
              ),
              TapIcon(
                Icons.tune,
                label: 'Sort album',
                onTap: () => c.go(AppScreen.albumFilter),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: LayoutBuilder(
                      builder: (_, b) => Artwork(
                        c.selectedPlaylist?.art ?? 65,
                        size: (b.maxWidth - 56).clamp(180, 280),
                        radius: 25,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: -32,
                    child: PlayButton(
                      onTap: () {
                        if (c.visibleAlbum.isNotEmpty) {
                          c.play(c.visibleAlbum.first);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(left: 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.selectedPlaylist?.title ?? 'Insomnia (Album)',
                      style: TextStyle(fontSize: 23),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      c.selectedPlaylist?.artist ?? 'Jay Sean, Selena, Bruno',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            '1,39,005 likes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: muted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TapIcon(
                          c.likes.contains('album')
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: 'Like album',
                          size: 23,
                          color: c.likes.contains('album') ? orange : muted,
                          onTap: () => c.toggleSet(c.likes, 'album'),
                        ),
                        TapIcon(
                          Icons.more_horiz,
                          label: 'Album options',
                          onTap: () => c.go(AppScreen.trackOptions),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (c.visibleAlbum.isEmpty)
                const EmptyState('No songs match your search.'),
              ...c.visibleAlbum.map(
                (t) => TrackTile(
                  t,
                  selected: c.current.id == t.id,
                  onTap: () {
                    c.play(t);
                    c.go(AppScreen.player);
                  },
                  onMore: () {
                    c.current = t;
                    c.go(AppScreen.trackOptions);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SortPanel extends StatelessWidget {
  const SortPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(34, 28, 34, 18),
      decoration: const BoxDecoration(
        gradient: panelGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sort by', style: TextStyle(color: muted, fontSize: 16)),
          const SizedBox(height: 26),
          ...['Custom order', 'Title', 'Artist', 'Album', 'Recently added'].map(
            (s) => InkWell(
              onTap: () => c.setSort(s),
              child: SizedBox(
                height: 46,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 17,
                          color: c.sort == s ? orange : Colors.white,
                        ),
                      ),
                    ),
                    if (c.sort == s)
                      const Icon(Icons.check, color: orange, size: 23),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: c.back,
            child: const Text(
              'Cancel',
              style: TextStyle(color: muted, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        gradient: panelGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(44)),
      ),
      child: LayoutBuilder(
        builder: (context, b) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: b.maxHeight - 42),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 3,
                        color: const Color(0xffcccccc),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Insomnia (Album)',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 30),
                    Artwork(
                      c.current.art,
                      size: (b.maxWidth - 60).clamp(180, b.maxHeight * .39),
                      radius: 28,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.current.title,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 23),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                c.current.artist,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TapIcon(
                          c.likes.contains(c.current.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: 'Like track',
                          color: c.likes.contains(c.current.id)
                              ? orange
                              : muted,
                          onTap: () => c.toggleSet(c.likes, c.current.id),
                        ),
                        TapIcon(
                          Icons.more_horiz,
                          label: 'Track options',
                          onTap: () => c.go(AppScreen.trackOptions),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: c.position.inMilliseconds.toDouble().clamp(
                        0,
                        c.duration.inMilliseconds.toDouble(),
                      ),
                      max: c.duration.inMilliseconds.toDouble().clamp(
                        1,
                        99999999,
                      ),
                      onChanged: (v) => c.seek(v / 1000),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeLabel(c.position),
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                        Text(
                          '-${timeLabel(c.duration - c.position)}',
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                    if (c.audioError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          c.audioError!,
                          style: const TextStyle(color: orange, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: TransportControls(large: true),
                ),
                Column(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xff76716a)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 46),
                      ),
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        backgroundColor: const Color(0xff2c2522),
                        builder: (_) => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'A moment to listen',
                                style: TextStyle(fontSize: 25),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Original instrumental preview\n\nNo lyrics are available for this track.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: muted, height: 1.8),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      child: const Text(
                        'Lyrics',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TapIcon(
                      Icons.keyboard_arrow_down,
                      label: 'Close player',
                      onTap: c.back,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String timeLabel(Duration value) =>
    '${value.inSeconds.clamp(0, 999999) ~/ 60}:${(value.inSeconds.clamp(0, 999999) % 60).toString().padLeft(2, '0')}';

class TransportControls extends StatelessWidget {
  const TransportControls({super.key, this.large = false});
  final bool large;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TapIcon(
          Icons.shuffle,
          label: 'Shuffle',
          color: c.shuffle ? orange : muted,
          onTap: () {
            c.shuffle = !c.shuffle;
            c.refresh();
          },
        ),
        TapIcon(
          Icons.fast_rewind_rounded,
          label: 'Previous track',
          size: 34,
          onTap: () => c.next(previous: true),
        ),
        PlayButton(
          size: large ? (MediaQuery.sizeOf(context).width < 360 ? 64 : 76) : 70,
          onTap: c.togglePlayback,
          playing: c.playing,
        ),
        TapIcon(
          Icons.fast_forward_rounded,
          label: 'Next track',
          size: 34,
          onTap: c.next,
        ),
        TapIcon(
          Icons.repeat,
          label: 'Repeat',
          color: c.repeat ? orange : muted,
          onTap: () {
            c.repeat = !c.repeat;
            c.refresh();
          },
        ),
      ],
    );
  }
}

class TrackOptionsPage extends StatelessWidget {
  const TrackOptionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3a2321), ink],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, b) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 54, 28, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: b.maxHeight - 74),
            child: Column(
              children: [
                Artwork(c.current.art, size: 215, radius: 25),
                const SizedBox(height: 24),
                Text(
                  c.current.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  c.current.artist,
                  style: const TextStyle(fontSize: 14, color: muted),
                ),
                const SizedBox(height: 34),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _OptionAction(Icons.shuffle, 'Shuffle', () {
                      c.shuffle = !c.shuffle;
                      c.refresh();
                    }, active: c.shuffle),
                    _OptionAction(Icons.repeat, 'Repeat', () {
                      c.repeat = !c.repeat;
                      c.refresh();
                    }, active: c.repeat),
                    _OptionAction(
                      Icons.playlist_play,
                      'Go to queue',
                      () => c.go(AppScreen.queue),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                _OptionRow(
                  c.likes.contains(c.current.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  c.likes.contains(c.current.id) ? 'Liked' : 'Like',
                  () => c.toggleSet(c.likes, c.current.id),
                ),
                _OptionRow(
                  Icons.indeterminate_check_box_outlined,
                  'Hide song',
                  () {
                    c.hiddenTracks.add(c.current.id);
                    c.back();
                    message(context, 'Song hidden from this listening session');
                    c.next();
                  },
                ),
                _OptionRow(
                  Icons.playlist_add,
                  'Add to playlist',
                  () => showAddToPlaylist(context),
                ),
                _OptionRow(Icons.queue_music, 'Add to queue', () {
                  c.enqueue(c.current);
                  message(context, 'Added to queue');
                }),
                const SizedBox(height: 28),
                TapIcon(
                  Icons.close,
                  label: 'Close track options',
                  size: 32,
                  onTap: c.back,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionAction extends StatelessWidget {
  const _OptionAction(this.icon, this.label, this.onTap, {this.active = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? orange : Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, size: 27, color: const Color(0xffdddddd)),
    title: Text(label, style: const TextStyle(fontSize: 16)),
    onTap: onTap,
  );
}

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});
  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  final Set<String> selected = {};
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Now Playing', style: TextStyle(fontSize: 20)),
              ),
              TapIcon(Icons.close, label: 'Close queue', onTap: c.back),
            ],
          ),
          TrackTile(
            Track(
              c.current.id,
              '${c.current.title} - From ‘Insomnia’',
              c.current.artist,
              c.current.art,
            ),
            selected: true,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  selected.isEmpty
                      ? 'Next From: Latest Trends'
                      : '${selected.length} selected',
                  style: const TextStyle(fontSize: 19),
                ),
              ),
              if (selected.isNotEmpty)
                TextButton(
                  onPressed: () {
                    c.removeQueue(selected);
                    setState(selected.clear);
                  },
                  child: const Text('Remove'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: c.queue.length,
              onReorder: c.reorderQueue,
              itemBuilder: (context, i) {
                final t = c.queue[i];
                return SizedBox(
                  key: ValueKey('${t.id}-$i'),
                  height: 68,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Checkbox(
                          value: selected.contains(t.id),
                          visualDensity: VisualDensity.compact,
                          activeColor: orange,
                          checkColor: Colors.white,
                          side: const BorderSide(color: Color(0xff777777)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (_) => setState(() {
                            if (!selected.remove(t.id)) selected.add(t.id);
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => c.play(t),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                t.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.drag_handle,
                            color: Color(0xff666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const TransportControls(),
        ],
      ),
    );
  }
}
