import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/catalog.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        const PageHeading('Settings'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  Stack(
                    children: [
                      const Artwork(2, size: 110, circle: true),
                      Positioned(
                        right: -2,
                        bottom: -4,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: orange,
                            minimumSize: const Size(36, 36),
                          ),
                          onPressed: () => editAccount(
                            context,
                            'Username',
                            c.username,
                            (v) => c.username = v,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${33 + c.customPlaylists.length} Playlists  ·  ${125 + c.selectedArtists.length} Following',
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),
              ...settingsLabels.map(
                (label) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 59,
                  title: Text(label, style: const TextStyle(fontSize: 16)),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Color(0xff777777),
                  ),
                  onTap: () {
                    if (label == 'Devices') {
                      showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => const Padding(
                          padding: EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connect to a device',
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(height: 24),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.phone_android,
                                  color: orange,
                                ),
                                title: Text('This device'),
                                subtitle: Text('Playing locally'),
                                trailing: Icon(Icons.check, color: orange),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    } else {
                      c.go(
                        {
                          'Account': AppScreen.account,
                          'Languages': AppScreen.language,
                          'Data Saver': AppScreen.dataSaver,
                          'Social': AppScreen.social,
                          'Playback': AppScreen.playback,
                          'Equalizer': AppScreen.equalizer,
                        }[label]!,
                      );
                    }
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

Future<void> editAccount(
  BuildContext context,
  String title,
  String value,
  void Function(String) save,
) async {
  final c = AppScope.of(context), field = TextEditingController(text: value);
  final next = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: field,
        autofocus: true,
        maxLength: title == 'Username' ? 40 : 100,
        keyboardType: title == 'Email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(labelText: title),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final text = field.text.trim();
            if (text.isNotEmpty &&
                (title != 'Email' ||
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))) {
              Navigator.pop(context, text);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (next != null) {
    save(next);
    c.refresh();
    unawaited(c.save());
  }
  await Future<void>.delayed(const Duration(milliseconds: 250));
  field.dispose();
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        const PageHeading('Account'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 10, 26, 30),
            children: [
              _AccountField(
                'Username',
                c.username,
                () => editAccount(
                  context,
                  'Username',
                  c.username,
                  (v) => c.username = v,
                ),
              ),
              _AccountField(
                'Email',
                c.email,
                () =>
                    editAccount(context, 'Email', c.email, (v) => c.email = v),
              ),
              _AccountField(
                'Password',
                '***********',
                () => message(
                  context,
                  'This demo uses a verification PIN. No password is stored.',
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: _AccountField('Subscription', 'FREE', null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('MusicPod Free'),
                          content: const Text(
                            'Enjoy the music and podcast preview. Subscription purchases are not enabled in this demo.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField(this.title, this.value, this.onTap);
  final String title, value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: muted, fontSize: 13)),
        ],
      ),
    ),
  );
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        const PageHeading('Languages Options for Music'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 26),
            children: languages
                .map(
                  (l) => InkWell(
                    onTap: () => c.toggleSet(c.selectedLanguages, l),
                    child: SizedBox(
                      height: 61,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Checkbox(
                              value: c.selectedLanguages.contains(l),
                              activeColor: orange,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              side: const BorderSide(color: Color(0xff777777)),
                              onChanged: (_) =>
                                  c.toggleSet(c.selectedLanguages, l),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(l, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final title = switch (c.screen) {
      AppScreen.dataSaver => 'Data Saver',
      AppScreen.social => 'Social',
      _ => 'Playback',
    };
    final rows = switch (c.screen) {
      AppScreen.dataSaver => [
        (
          'Data Saver',
          'Converts music quality to low and disables artist canvases.',
        ),
        (
          'Audio-only podcasts',
          'Saves only the audio when downloading your favourite video podcasts.',
        ),
      ],
      AppScreen.social => [
        (
          'Private session',
          'For listening anonymously, you can start your private session.',
        ),
        ('Listen activity', 'Share your favourite songs with your friends.'),
        (
          'Recently played artists',
          'Show your recently played artists on your profile.',
        ),
      ],
      _ => [
        ('Hide Unplayable Songs', ''),
        ('Enable Audio Normalization', ''),
        ('Mono Audio', ''),
        ('Play Feedback Sounds', ''),
        ('Autoplay', ''),
      ],
    };
    return Column(
      children: [
        PageHeading(title),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 32),
            children: [
              if (c.screen == AppScreen.playback) ...[
                const Text(
                  'Choose how to fade songs in and out, change music sound quality during playback, and more.',
                  style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 38),
              ],
              ...rows.map(
                (r) => Padding(
                  padding: EdgeInsets.only(
                    bottom: c.screen == AppScreen.playback ? 4 : 56,
                  ),
                  child: SettingToggle(r.$1, subtitle: r.$2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingToggle extends StatelessWidget {
  const SettingToggle(this.label, {super.key, this.subtitle = ''});
  final String label, subtitle;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Transform.scale(
          scale: .83,
          alignment: Alignment.centerRight,
          child: Switch(
            value: c.settings[label] ?? false,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xff39b536),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xff555555),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            onChanged: (v) => c.setSetting(label, v),
          ),
        ),
      ],
    );
  }
}

class EqualizerPage extends StatelessWidget {
  const EqualizerPage({super.key});
  static const profiles = [
    [.2, .3, .55, .6, .5, .6],
    [.3, .5, .15, .32, .18, .58],
    [.6, .3, .4, .25, .5, .3],
    [.25, .4, .65, .3, .4, .3],
    [.4, .2, .65, .6, .4, .2],
    [.45, .45, .45, .45, .45, .45],
    [.1, .4, .5, .3, .25, .5],
  ];
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        const PageHeading('Equalizer'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 28),
            children: [
              Opacity(
                opacity: c.settings['Equalizer']! ? 1 : .4,
                child: Container(
                  height: 203,
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff352314),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xff493c30)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _EqualizerPainter(
                            profiles[equalizerPresets
                                .indexOf(c.preset)
                                .clamp(0, 6)],
                          ),
                          size: Size.infinite,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            [
                                  '60 Hz',
                                  '150 Hz',
                                  '400 Hz',
                                  '1 kHz',
                                  '2.4 kHz',
                                  '15 kHz',
                                ]
                                .map(
                                  (s) => Text(
                                    s,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xffb59c85),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SettingToggle('Equalizer'),
              const SettingToggle('Also apply to podcasts'),
              const SizedBox(height: 16),
              ...equalizerPresets.map(
                (p) => InkWell(
                  onTap: c.settings['Equalizer']!
                      ? () {
                          c.preset = p;
                          c.refresh();
                          unawaited(c.save());
                        }
                      : null,
                  child: SizedBox(
                    height: 61,
                    child: Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: p == c.preset
                                  ? const Color(0xffaa743f)
                                  : const Color(0xff666666),
                            ),
                          ),
                          child: p == c.preset
                              ? const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: orange,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 17),
                        Text(p, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter(this.values);
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    final points = List.generate(
      6,
      (i) => Offset(12 + (size.width - 24) * i / 5, size.height * values[i]),
    );
    final line = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      final mid = (a.dx + b.dx) / 2;
      line.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }
    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [orange.withValues(alpha: .22), orange.withValues(alpha: 0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    final grid = Paint()
      ..color = const Color(0xff745134)
      ..strokeWidth = .7;
    for (final p in points) {
      for (double y = p.dy + 8; y < size.height; y += 7) {
        canvas.drawLine(
          Offset(p.dx, y),
          Offset(p.dx, math.min(y + 3, size.height)),
          grid,
        );
      }
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xffbd8750)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    for (final p in points) {
      canvas.drawCircle(p, 3.5, Paint()..color = orange);
      canvas.drawCircle(p, 2, Paint()..color = const Color(0xff55402b));
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter oldDelegate) =>
      oldDelegate.values != values;
}
