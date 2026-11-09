import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../core/catalog.dart';
import '../core/controller.dart';
import '../core/theme.dart';

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class Artwork extends StatelessWidget {
  const Artwork(
    this.id, {
    super.key,
    this.size = 60,
    this.radius = 8,
    this.circle = false,
    this.fit = BoxFit.cover,
    this.url,
  });
  final int id;
  final String? url;
  final double size, radius;
  final bool circle;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(circle ? size / 2 : radius),
    child: url != null
        ? Image.network(
            url!,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, _, _) => SizedBox(
              width: size,
              height: size,
              child: const ColoredBox(
                color: Color(0xff292929),
                child: Icon(Icons.music_note, color: muted),
              ),
            ),
          )
        : Image.asset(
            'assets/images/art-${id.toString().padLeft(2, '0')}.png',
            width: size,
            height: size,
            fit: fit,
          ),
  );
}

class TapIcon extends StatelessWidget {
  const TapIcon(
    this.icon, {
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.size = 25,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.tr(label),
    onPressed: onTap,
    icon: Icon(icon, size: size, color: color ?? const Color(0xffdddddd)),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 68,
    child: Row(
      children: [
        TapIcon(
          Icons.arrow_back_ios_new,
          label: 'Back',
          size: 22,
          onTap: AppScope.of(context).back,
        ),
        Expanded(
          child: Text(
            context.tr(title),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(width: 48, child: trailing),
      ],
    ),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton(
    this.label, {
    super.key,
    required this.onTap,
    this.width,
  });
  final String label;
  final VoidCallback onTap;
  final double? width;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 50,
    decoration: BoxDecoration(
      gradient: warmGradient,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Center(
          child: Text(
            context.tr(label),
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.onTap,
    this.playing = false,
    this.size = 66,
  });
  final VoidCallback onTap;
  final bool playing;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: warmGradient,
    ),
    child: IconButton(
      tooltip: context.tr(playing ? 'Pause' : 'Play'),
      onPressed: onTap,
      icon: Icon(
        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: size * .62,
        color: Colors.white,
      ),
    ),
  );
}

class SearchPill extends StatelessWidget {
  const SearchPill({
    super.key,
    this.hint = 'Find in playlist',
    this.onChanged,
    this.onTap,
    this.controller,
    this.dark = false,
    this.autofocus = false,
  });
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool dark, autofocus;
  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        readOnly: onTap != null,
        style: TextStyle(fontSize: 14, color: dark ? Colors.white : ink),
        decoration: InputDecoration(
          hintText: context.tr(hint),
          hintStyle: TextStyle(
            color: dark ? muted : const Color(0xff888888),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 21,
            color: dark ? muted : const Color(0xff555555),
          ),
          filled: true,
          fillColor: dark ? const Color(0xff393939) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: orange),
          ),
        ),
      ),
    );
    return onTap == null
        ? field
        : Semantics(
            button: true,
            label: context.tr(hint),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: IgnorePointer(child: field),
            ),
          );
  }
}

class TrackTile extends StatelessWidget {
  const TrackTile(
    this.track, {
    super.key,
    this.onTap,
    this.onMore,
    this.circle = false,
    this.trailing,
    this.selected = false,
  });
  final Track track;
  final VoidCallback? onTap, onMore;
  final bool circle, selected;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Artwork(track.art, url: track.imageUrl, size: 60, circle: circle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: selected ? orange : Colors.white,
                  ),
                ),
                if (track.artist.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    track.id.startsWith('custom-')
                        ? context.tr('By {name}', {
                            'name': track.artist.replaceFirst(
                              RegExp(r'^By '),
                              '',
                            ),
                          })
                        : track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: muted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onMore != null)
            TapIcon(
              Icons.more_horiz,
              label: context.tr('More about {title}', {'title': track.title}),
              onTap: onMore!,
              size: 22,
            ),
        ],
      ),
    ),
  );
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff54473b), Color(0xff3e3b21)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (c.miniVisible) ...[
            LinearProgressIndicator(
              value:
                  c.position.inMilliseconds /
                  c.duration.inMilliseconds.clamp(1, 9999999),
              minHeight: 2,
              color: orange,
              backgroundColor: const Color(0xffbbbbbb),
            ),
            InkWell(
              onTap: () => c.go(AppScreen.player),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 12, 12, 10),
                child: Row(
                  children: [
                    Artwork(
                      c.current.art,
                      url: c.current.imageUrl,
                      size: 56,
                      radius: 6,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.current.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            c.current.artist,
                            style: const TextStyle(
                              color: Color(0xffbdb6b0),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TapIcon(
                      c.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_outlined,
                      label: 'Mini player ${c.playing ? 'pause' : 'play'}',
                      onTap: c.togglePlayback,
                      size: 32,
                    ),
                    TapIcon(
                      Icons.close,
                      label: 'Close mini player',
                      size: 24,
                      onTap: () {
                        if (c.playing) c.togglePlayback();
                        c.miniVisible = false;
                        c.refresh();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(20, c.miniVisible ? 0 : 12, 20, 18),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(4, (index) {
                  const labels = ['Home', 'Search', 'Library', 'Settings'];
                  const icons = [
                    Icons.home_outlined,
                    Icons.search,
                    Icons.library_music_outlined,
                    Icons.settings_outlined,
                  ];
                  final active = c.tab == index;
                  return Expanded(
                    child: Semantics(
                      selected: active,
                      button: true,
                      child: InkWell(
                        key: ValueKey('tab-$index'),
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => c.selectTab(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[index],
                              size: 25,
                              color: active ? orange : muted,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.tr(labels[index]),
                              style: TextStyle(
                                fontSize: 12,
                                color: active ? orange : muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(text)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

class EmptyState extends StatelessWidget {
  const EmptyState(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        const Icon(Icons.search_off, size: 40, color: muted),
        const SizedBox(height: 16),
        Text(
          context.tr(text),
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
      ],
    ),
  );
}
