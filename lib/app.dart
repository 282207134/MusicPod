import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_strings.dart';
import 'core/catalog.dart';
import 'core/controller.dart';
import 'core/live_controller.dart';
import 'core/theme.dart';
import 'features/auth.dart';
import 'features/discover.dart';
import 'features/library.dart';
import 'features/live.dart';
import 'features/playback.dart';
import 'features/settings.dart';
import 'widgets/common.dart';

class MusicPodApp extends StatefulWidget {
  const MusicPodApp({
    super.key,
    required this.controller,
    this.autoAdvance = true,
  });
  final AppController controller;
  final bool autoAdvance;
  @override
  State<MusicPodApp> createState() => _MusicPodAppState();
}

class _MusicPodAppState extends State<MusicPodApp> {
  Timer? _splash;
  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) {
      _splash = Timer(const Duration(milliseconds: 1800), () {
        if (widget.controller.screen == AppScreen.splash) {
          widget.controller.go(
            widget.controller.onboarded ? AppScreen.home : AppScreen.signup,
            remember: false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _splash?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller.interfaceLanguageChanges,
    builder: (context, _) => MaterialApp(
      title: 'MusicPod',
      debugShowCheckedModeBanner: false,
      theme: musicTheme,
      locale: widget.controller.interfaceLanguage == 'system'
          ? null
          : Locale(widget.controller.interfaceLanguage),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: AppScope(controller: widget.controller, child: const _AppShell()),
    ),
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final fullscreen = [
      AppScreen.splash,
      AppScreen.signup,
      AppScreen.otp,
      AppScreen.player,
      AppScreen.trackOptions,
      AppScreen.queue,
      AppScreen.chooseArtists,
      AppScreen.searchResults,
    ].contains(c.screen);
    return PopScope(
      canPop: c.screen == AppScreen.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) c.back();
      },
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: KeyedSubtree(
                          key: ValueKey(c.screen),
                          child: _page(c.screen, context),
                        ),
                      ),
                      if (!fullscreen) const AppFooter(),
                    ],
                  ),
                  if (c.screen == AppScreen.albumFilter) ...[
                    ModalBarrier(
                      color: Colors.black.withValues(alpha: .4),
                      dismissible: true,
                      onDismiss: c.back,
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: SortPanel(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(AppScreen screen, BuildContext context) {
    final c = AppScope.of(context);
    if (c is LiveController) {
      final page = livePage(screen, c);
      if (page != null) return page;
    }
    return switch (screen) {
      AppScreen.splash => const SplashPage(),
      AppScreen.signup => const SignupPage(),
      AppScreen.otp => const SignupPage(otp: true),
      AppScreen.home => const HomePage(),
      AppScreen.album || AppScreen.albumFilter => const AlbumPage(),
      AppScreen.player => const PlayerPage(),
      AppScreen.trackOptions => const TrackOptionsPage(),
      AppScreen.queue => const QueuePage(),
      AppScreen.search => const SearchPage(),
      AppScreen.searchResults => const SearchResultsPage(),
      AppScreen.podcasts => const PodcastsPage(),
      AppScreen.podcastDetail => const PodcastDetailPage(),
      AppScreen.libraryPlaylists ||
      AppScreen.libraryArtists ||
      AppScreen.libraryAlbums ||
      AppScreen.libraryEpisodes ||
      AppScreen.libraryDownloads => const LibraryPage(),
      AppScreen.chooseArtists => const ChooseArtistsPage(),
      AppScreen.settings => const SettingsPage(),
      AppScreen.account => const AccountPage(),
      AppScreen.language => const LanguagePage(),
      AppScreen.dataSaver ||
      AppScreen.social ||
      AppScreen.playback => const PreferencesPage(),
      AppScreen.equalizer => const EqualizerPage(),
    };
  }
}
