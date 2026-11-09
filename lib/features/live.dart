import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/catalog.dart';
import '../core/live_controller.dart';
import '../core/podcast_catalog.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'library.dart';
import 'settings.dart';

Widget? livePage(AppScreen screen, LiveController c) => switch (screen) {
  AppScreen.home => LiveHomePage(c),
  AppScreen.search || AppScreen.searchResults => LiveSearchPage(c),
  AppScreen.podcasts => LivePodcastsPage(c),
  AppScreen.podcastDetail => LiveFeedPage(c),
  AppScreen.libraryPlaylists ||
  AppScreen.libraryArtists ||
  AppScreen.libraryAlbums ||
  AppScreen.libraryEpisodes ||
  AppScreen.libraryDownloads => LiveLibraryPage(c),
  AppScreen.signup || AppScreen.otp || AppScreen.account => LiveAccountPage(c),
  _ => null,
};

class _Notice extends StatelessWidget {
  const _Notice(this.text, {this.retry});
  final String text;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(text),
          style: const TextStyle(color: muted, height: 1.5),
        ),
        if (retry != null)
          TextButton(onPressed: retry, child: Text(context.tr('Try again'))),
      ],
    ),
  );
}

Widget _track(BuildContext context, LiveController c, Track t) => TrackTile(
  t,
  selected: c.current.id == t.id,
  onTap: () {
    c.play(t);
    c.go(AppScreen.player);
  },
  onMore: () => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(t.title, maxLines: 2), subtitle: Text(t.artist)),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(
              context.tr(
                c.likes.contains(t.id) ? 'Remove favorite' : 'Add favorite',
              ),
            ),
            onTap: () {
              c.toggleFavorite(t);
              Navigator.pop(sheet);
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: Text(context.tr('Add to queue')),
            onTap: () {
              c.enqueue(t);
              Navigator.pop(sheet);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: Text(context.tr('Add to playlist')),
            onTap: () async {
              Navigator.pop(sheet);
              await _choosePlaylist(context, c, t);
            },
          ),
          if (t.isPodcast)
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(
                context.tr(
                  c.downloads.contains(t.id)
                      ? 'Unsave episode'
                      : 'Save for later',
                ),
              ),
              onTap: () {
                c.saveEpisode(t);
                Navigator.pop(sheet);
              },
            ),
          if (t.sourceUrl != null)
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(context.tr('View original source')),
              onTap: () => launchUrl(
                Uri.parse(t.sourceUrl!),
                mode: LaunchMode.externalApplication,
              ),
            ),
        ],
      ),
    ),
  ),
);

Future<void> _choosePlaylist(
  BuildContext context,
  LiveController c,
  Track track,
) async {
  if (c.customPlaylists.isEmpty) {
    await showCreatePlaylist(context);
    if (!context.mounted || c.customPlaylists.isEmpty) return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(title: Text(context.tr('Choose a playlist'))),
          ...c.customPlaylists.map(
            (p) => ListTile(
              title: Text(p.title),
              onTap: () {
                c.addToPlaylist(p, track);
                Navigator.pop(sheet);
                message(
                  context,
                  context.tr('Added to {name}', {'name': p.title}),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class LiveHomePage extends StatelessWidget {
  const LiveHomePage(this.c, {super.key});
  final LiveController c;
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: c.loadMusic,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(26, 36, 26, 26),
      children: [
        Text(
          context.tr('Find your next sound'),
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 10),
        Text(
          context.tr('Independent music · powered by Jamendo'),
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          children: [
            ActionChip(
              label: Text(context.tr('Search music')),
              onPressed: () => c.selectTab(1),
            ),
            ActionChip(
              label: Text(context.tr('Podcasts')),
              onPressed: () => c.go(AppScreen.podcasts),
            ),
          ],
        ),
        if (!c.signedIn)
          _Notice('Listen as a guest, or sign in to sync your library.'),
        if (c.recent.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(context.tr('Recently played'), style: TextStyle(fontSize: 23)),
          ...c.recent.take(4).map((t) => _track(context, c, t)),
        ],
        const SizedBox(height: 24),
        Text(context.tr('Discover music'), style: TextStyle(fontSize: 23)),
        if (c.loadingMusic)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (c.musicError != null) _Notice(c.musicError!, retry: c.loadMusic),
        if (!c.loadingMusic && c.musicError == null && c.featured.isEmpty)
          const _Notice(
            'No music is available right now. Pull down to refresh.',
          ),
        ...c.featured.map((t) => _track(context, c, t)),
      ],
    ),
  );
}

class LiveSearchPage extends StatelessWidget {
  const LiveSearchPage(this.c, {super.key});
  final LiveController c;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(26, 32, 26, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('Search'), style: TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: c.query,
              onChanged: c.updateQuery,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: context.tr('Search Jamendo songs or artists'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => c.go(AppScreen.podcasts),
              icon: const Icon(Icons.podcasts),
              label: Text(context.tr('Browse podcasts')),
            ),
          ],
        ),
      ),
      if (c.searching) const LinearProgressIndicator(),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          children: [
            if (c.searchError != null)
              _Notice(c.searchError!, retry: () => c.updateQuery(c.query)),
            if (c.query.trim().isEmpty)
              const _Notice(
                'Search independent music from the Jamendo catalog.',
              ),
            if (!c.searching &&
                c.searchError == null &&
                c.query.trim().isNotEmpty &&
                c.results.isEmpty)
              const _Notice('No results. Try another song, artist or keyword.'),
            ...c.results.map((t) => _track(context, c, t)),
          ],
        ),
      ),
    ],
  );
}

class LivePodcastsPage extends StatelessWidget {
  const LivePodcastsPage(this.c, {super.key});
  final LiveController c;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
    children: [
      const PageHeading('Podcasts'),
      Text(context.tr('Follow a conversation'), style: TextStyle(fontSize: 26)),
      const SizedBox(height: 12),
      Text(
        context.tr(
          'Add a public HTTPS RSS feed to browse and play its episodes.',
        ),
        style: TextStyle(color: muted, height: 1.5),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => _addFeed(context, c),
        icon: const Icon(Icons.add),
        label: Text(context.tr('Add RSS feed')),
      ),
      const SizedBox(height: 28),
      for (final language in podcastLanguages.entries) ...[
        Text(context.tr(language.value), style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        ...podcastPicks
            .where((pick) => pick.language == language.key)
            .map(
              (pick) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.podcasts, color: orange),
                title: Text(pick.title),
                subtitle: Text(context.tr(pick.description)),
                trailing: const Icon(Icons.chevron_right, color: muted),
                onTap: () => c.openFeed(pick.url),
              ),
            ),
        const SizedBox(height: 24),
      ],
      if (c.subscriptions.isNotEmpty) ...[
        const SizedBox(height: 26),
        Text(context.tr('Your subscriptions'), style: TextStyle(fontSize: 22)),
        ...c.subscriptions.map(
          (url) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.rss_feed),
            title: Text(
              podcastPicks
                      .where((pick) => pick.url == url)
                      .firstOrNull
                      ?.title ??
                  url,
              maxLines: 2,
            ),
            onTap: () => c.openFeed(url),
          ),
        ),
      ],
    ],
  );
}

Future<void> _addFeed(BuildContext context, LiveController c) async {
  final url = await showTextInput(
    context,
    title: 'Add podcast RSS',
    hint: 'https://…/feed.xml',
    action: 'Open',
    keyboardType: TextInputType.url,
    autofocus: false,
  );
  if (url != null) await c.openFeed(url);
}

class LiveFeedPage extends StatelessWidget {
  const LiveFeedPage(this.c, {super.key});
  final LiveController c;
  @override
  Widget build(BuildContext context) {
    final feed = c.feed;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      children: [
        const PageHeading('Podcast'),
        if (c.loadingFeed)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          ),
        if (c.feedError != null) _Notice(c.feedError!),
        if (feed != null) ...[
          Center(child: Artwork(40, url: feed.image, size: 180, radius: 20)),
          const SizedBox(height: 20),
          Text(feed.title, style: const TextStyle(fontSize: 26)),
          Text(feed.author, style: const TextStyle(color: muted)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: c.subscribeFeed,
            icon: Icon(
              c.subscriptions.contains(feed.url) ? Icons.check : Icons.add,
            ),
            label: Text(
              context.tr(
                c.subscriptions.contains(feed.url) ? 'Subscribed' : 'Subscribe',
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...feed.episodes.map(
            (t) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _track(context, c, t),
                if (t.description.isNotEmpty)
                  Text(
                    t.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, height: 1.5),
                  ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => c.saveEpisode(t),
                      icon: Icon(
                        c.downloads.contains(t.id)
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                      ),
                      label: Text(context.tr('Save for later')),
                    ),
                    const Spacer(),
                    if (t.durationSeconds > 0)
                      Text(
                        context.tr('{count} min', {
                          'count': (t.durationSeconds / 60).ceil(),
                        }),
                        style: const TextStyle(color: muted),
                      ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LiveLibraryPage extends StatelessWidget {
  const LiveLibraryPage(this.c, {super.key});
  final LiveController c;
  @override
  Widget build(BuildContext context) {
    final favorites = c.knownTracks.values
        .where((t) => c.likes.contains(t.id))
        .toList();
    final saved = c.knownTracks.values
        .where((t) => c.downloads.contains(t.id))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 36, 26, 28),
      children: [
        Text(context.tr('Your library'), style: TextStyle(fontSize: 32)),
        const SizedBox(height: 10),
        Text(context.tr(c.syncStatus), style: const TextStyle(color: muted)),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('Playlists'),
                style: TextStyle(fontSize: 23),
              ),
            ),
            IconButton(
              tooltip: context.tr('Create playlist'),
              onPressed: () => showCreatePlaylist(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (c.customPlaylists.isEmpty)
          const _Notice(
            'Create your first playlist, then add songs from their menu.',
          ),
        ...c.customPlaylists.map(
          (p) => TrackTile(p, onTap: () => c.openAlbum(playlist: p)),
        ),
        const SizedBox(height: 24),
        Text(context.tr('Favorites'), style: TextStyle(fontSize: 23)),
        if (favorites.isEmpty)
          const _Notice('Your favorite songs will appear here.'),
        ...favorites.map((t) => _track(context, c, t)),
        const SizedBox(height: 24),
        Text(context.tr('Saved episodes'), style: TextStyle(fontSize: 23)),
        const _Notice(
          'Saved for later. Playback still needs an internet connection.',
        ),
        ...saved.map((t) => _track(context, c, t)),
        TextButton.icon(
          onPressed: () => c.go(AppScreen.podcasts),
          icon: const Icon(Icons.rss_feed),
          label: Text(
            context.tr('Podcast subscriptions ({count})', {
              'count': c.subscriptions.length,
            }),
          ),
        ),
      ],
    );
  }
}

class LiveAccountPage extends StatelessWidget {
  const LiveAccountPage(this.c, {super.key});
  final LiveController c;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
    children: [
      const PageHeading('Your account'),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => c.go(AppScreen.language),
          icon: const Icon(Icons.language),
          label: Text(context.tr('App language')),
        ),
      ),
      const SizedBox(height: 28),
      Text(
        c.signedIn ? c.username : context.tr('Bring your library along'),
        style: const TextStyle(fontSize: 29),
      ),
      const SizedBox(height: 14),
      Text(
        c.signedIn
            ? c.email
            : context.tr(
                'Sign in with GitHub to sync favorites, playlists and podcast subscriptions.',
              ),
        style: const TextStyle(color: muted, height: 1.6),
      ),
      const SizedBox(height: 28),
      if (c.accountError != null) _Notice(c.accountError!),
      if (!c.signedIn) ...[
        FilledButton.icon(
          onPressed: c.signingIn ? null : c.signIn,
          icon: const Icon(Icons.login),
          label: Text(
            context.tr(
              c.signingIn ? 'Opening GitHub…' : 'Continue with GitHub',
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: c.finishSignup,
          child: Text(context.tr('Continue as guest')),
        ),
        const _Notice(
          'Guest libraries stay on this device. Account libraries are kept separate.',
        ),
      ] else ...[
        Text(context.tr(c.syncStatus), style: const TextStyle(color: muted)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: c.syncing ? null : c.syncNow,
          child: Text(context.tr(c.syncing ? 'Syncing…' : 'Sync now')),
        ),
        TextButton(
          onPressed: () => editAccount(
            context,
            'Username',
            c.username,
            (v) => c.username = v,
          ),
          child: Text(context.tr('Edit display name')),
        ),
        TextButton(onPressed: c.signOut, child: Text(context.tr('Sign out'))),
      ],
    ],
  );
}
