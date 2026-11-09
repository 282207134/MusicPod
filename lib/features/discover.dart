import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../core/catalog.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(top: 42, bottom: 32),
    children: const [
      _Shelf('Recently Played', [
        Track('retro', 'Retro Artist', '', 74),
        Track('insomnia', 'Insomnia (Album)', '', 75),
        Track('love', 'Love Story', '', 76),
      ], circle: true),
      SizedBox(height: 44),
      _Shelf('Try new release', [
        Track('new', 'Real As It Gets (feat. EST)', 'Drale', 72),
        Track('incomplete', 'Incomplete', 'Jay Sean', 73),
      ], size: 210),
      SizedBox(height: 44),
      _Charts(),
      SizedBox(height: 44),
      _Shelf('Recommended for you', [
        Track('jean', 'Jean Dale', 'Lullaboy', 67),
        Track('nobody', 'Nobody is Listening', 'Tate McRae', 68),
        Track('bang', 'Bang', 'CKay', 69),
      ]),
    ],
  );
}

class _Shelf extends StatelessWidget {
  const _Shelf(this.title, this.items, {this.size = 150, this.circle = false});
  final String title;
  final List<Track> items;
  final double size;
  final bool circle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Text(context.tr(title), style: const TextStyle(fontSize: 25)),
      ),
      const SizedBox(height: 26),
      SizedBox(
        height: size + (circle ? 42 : 62),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 18),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => AppScope.of(context).openAlbum(),
              child: SizedBox(
                width: size,
                child: Column(
                  crossAxisAlignment: circle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Artwork(item.art, size: size, circle: circle, radius: 14),
                    const SizedBox(height: 14),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (item.artist.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.artist,
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class _Charts extends StatelessWidget {
  const _Charts();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Text(
          context.tr('Featured Charts'),
          style: TextStyle(fontSize: 25),
        ),
      ),
      const SizedBox(height: 26),
      SizedBox(
        height: 208,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 18),
          itemBuilder: (context, index) => InkWell(
            onTap: () => AppScope.of(context).openAlbum(),
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          [const Color(0xffffc08d), const Color(0xffffda9a)],
                          [const Color(0xfff5c85f), const Color(0xfffff4a5)],
                          [const Color(0xff48d4d0), const Color(0xffb9f5eb)],
                        ][index],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr(
                            ['Top Songs', 'Viral 50', 'Evergreen'][index],
                          ),
                          style: const TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          context.tr(index == 2 ? 'Songs' : 'Global'),
                          style: const TextStyle(
                            color: Color(0xff555555),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(
                      [
                        'Weekly update of the\nmost played tracks…',
                        'Your daily update of\nmost played tracks',
                        'Update of the most\nplayed tracks…',
                      ][index],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 42, 26, 28),
      children: [
        Text(context.tr('Search'), style: TextStyle(fontSize: 32)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SearchPill(onTap: () => c.go(AppScreen.searchResults)),
            ),
            const SizedBox(width: 12),
            TapIcon(
              Icons.camera_alt_outlined,
              label: 'Scan music code',
              onTap: () => message(
                context,
                'Search for a song or artist using the search bar.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(context.tr('Browse all'), style: TextStyle(fontSize: 22)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => c.go(AppScreen.podcasts),
          child: Container(
            height: 148,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: warmGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: warmGradient.createShader,
                    blendMode: BlendMode.modulate,
                    child: Image.asset(
                      'assets/images/art-57.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 145,
                  bottom: 24,
                  child: Icon(
                    Icons.graphic_eq,
                    size: 64,
                    color: Colors.white.withValues(alpha: .5),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    context.tr('Podcasts'),
                    style: TextStyle(fontSize: 23),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 22,
          crossAxisSpacing: 22,
          childAspectRatio: 1.11,
          children: List.generate(6, (i) {
            const titles = [
              'Home',
              'New\nReleases',
              'Charts',
              'Made for\nyou',
              'Love',
              'Equal',
            ];
            const arts = [55, 56, 53, 54, 51, 52];
            return InkWell(
              onTap: () {
                if (i == 0) {
                  c.selectTab(0);
                } else {
                  c.openAlbum();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (i == 1) Container(color: const Color(0xff6ef4cf)),
                    Image.asset(
                      'assets/images/art-${arts[i]}.png',
                      fit: BoxFit.cover,
                    ),
                    if (i == 4)
                      Positioned(
                        top: 24,
                        left: 20,
                        child: Text(
                          context.tr('Love'),
                          style: TextStyle(color: ink, fontSize: 20),
                        ),
                      ),
                    if (i != 0 && i != 4 && i != 5)
                      Center(
                        child: Text(
                          context.tr(titles[i]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: i == 1 ? ink : Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});
  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  TextEditingController? field;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    field ??= TextEditingController(text: AppScope.of(context).query);
  }

  @override
  void dispose() {
    field?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final tracks = c.query.isEmpty ? searchTracks : c.searchResults;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 12, 18),
          child: Row(
            children: [
              Expanded(
                child: SearchPill(
                  hint: 'Songs, artists, albums',
                  controller: field,
                  onChanged: c.updateQuery,
                ),
              ),
              TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  c.back();
                },
                child: Text(
                  context.tr('Cancel'),
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tracks.isEmpty
              ? EmptyState(
                  context.tr(
                    'No results for “{query}”.\nTry another song or artist.',
                    {'query': c.query},
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  itemCount: tracks.length,
                  itemBuilder: (context, i) => TrackTile(
                    tracks[i],
                    onTap: () {
                      c.play(tracks[i]);
                      FocusScope.of(context).unfocus();
                      c.go(AppScreen.player);
                    },
                    onMore: () {
                      c.current = tracks[i];
                      c.go(AppScreen.trackOptions);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(top: 42, bottom: 32),
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Text(context.tr('Podcasts'), style: TextStyle(fontSize: 34)),
      ),
      const SizedBox(height: 36),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Text(
          context.tr('Podcasts for foodies'),
          style: TextStyle(fontSize: 22),
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        height: 234,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, i) => InkWell(
            onTap: () => AppScope.of(context).go(AppScreen.podcastDetail),
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Artwork(40 + i, size: 150, radius: 12),
                  const SizedBox(height: 12),
                  Text(
                    [
                      'The First Bite: US Food History',
                      'Naan Curry with Sadef and Archi',
                      'Kya Swaad Hai',
                    ][i],
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ['1435 Followers', 'IVM Podcasts', 'WYN Studio'][i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 32),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Text(context.tr('Categories'), style: TextStyle(fontSize: 22)),
      ),
      const SizedBox(height: 22),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 22,
          crossAxisSpacing: 24,
          children: List.generate(
            4,
            (i) => InkWell(
              onTap: () => AppScope.of(context).go(AppScreen.podcastDetail),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      [const Color(0xffff7f85), const Color(0xffffd580)],
                      [const Color(0xffaedff3), const Color(0xffb191ff)],
                      [const Color(0xff76edcb), const Color(0xff9dffcf)],
                      [const Color(0xffff9db3), const Color(0xfff48091)],
                    ][i],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      [
                        Icons.mic_none,
                        Icons.menu_book_outlined,
                        Icons.star_border,
                        Icons.auto_stories_outlined,
                      ][i],
                      color: ink,
                      size: 29,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        [
                          'Podcast\nCharts',
                          'Stories',
                          'Original &\nExclusives',
                          'Educational',
                        ][i],
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class PodcastDetailPage extends StatelessWidget {
  const PodcastDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return ListView(
      children: [
        SizedBox(
          height: 290,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/art-39.png', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, ink],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 7,
                child: TapIcon(
                  Icons.arrow_back_ios_new,
                  label: 'Back',
                  onTap: c.back,
                ),
              ),
              const Positioned(
                left: 26,
                right: 26,
                bottom: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The First Bite: US’s\nFood History',
                      style: TextStyle(fontSize: 32, height: 1.2),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Conversations about Indian food to feed your curiosity.',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('23,433 Likes  •  6h 23m'),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    Row(
                      children: [
                        TapIcon(
                          c.likes.contains('podcast')
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: 'Like podcast',
                          color: c.likes.contains('podcast') ? orange : muted,
                          onTap: () => c.toggleSet(c.likes, 'podcast'),
                        ),
                        TapIcon(
                          Icons.more_horiz,
                          label: 'Podcast options',
                          onTap: () => message(
                            context,
                            'Follow this podcast by tapping the heart.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PlayButton(
                onTap: () => c.play(
                  const Track(
                    'sourdough',
                    'San Francisco sourdough bread',
                    'The First Bite',
                    6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              EpisodeCard(
                'sourdough',
                'San Francisco sourdough bread',
                'Naan Curry with Sadef and Archit',
                6,
                duration: '17 min left',
              ),
              EpisodeCard(
                'potroast',
                'Pot roast',
                'Braised beef and vegetables — Warming hot pot',
                5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EpisodeCard extends StatelessWidget {
  const EpisodeCard(
    this.id,
    this.title,
    this.author,
    this.art, {
    super.key,
    this.duration = '25 min',
  });
  final String id, title, author, duration;
  final int art;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackTile(
            Track(id, title, author, art),
            onTap: () {
              c.play(Track(id, title, author, art));
              c.go(AppScreen.player);
            },
          ),
          const Text(
            'Curabitur vulputate arcu odio, ac facilisis diam accumsan ut. Ut imperdiet et leo in vulputate.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          Text(
            '${MaterialLocalizations.of(context).formatMediumDate(DateTime(2019, 10, 12))} · ${context.tr(duration)}',
            style: const TextStyle(fontSize: 12, color: muted),
          ),
          Row(
            children: [
              TapIcon(
                c.downloads.contains(id)
                    ? Icons.check_circle
                    : Icons.add_circle_outline,
                label: context.tr('Save episode {title}', {'title': title}),
                size: 23,
                color: c.downloads.contains(id) ? orange : muted,
                onTap: () => c.toggleSet(c.downloads, id),
              ),
              TapIcon(
                Icons.more_horiz,
                label: context.tr('Episode options {title}', {'title': title}),
                onTap: () {
                  c.enqueue(Track(id, title, author, art));
                  message(context, 'Added to queue');
                },
              ),
              const Spacer(),
              TapIcon(
                Icons.play_circle_outline,
                label: context.tr('Play {title}', {'title': title}),
                onTap: () => c.play(Track(id, title, author, art)),
                size: 34,
              ),
            ],
          ),
          const Divider(height: 14),
        ],
      ),
    );
  }
}
