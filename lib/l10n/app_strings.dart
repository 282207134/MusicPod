import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Only explicitly marked interface copy is translated. Provider titles,
/// artist names, descriptions and user-entered text retain their original text.
class AppStrings {
  const AppStrings(this.locale, [this.translations = const {}]);
  final Locale locale;
  final Map<String, List<String>> translations;
  static const supportedLocales = [Locale('en'), Locale('zh'), Locale('ja')];
  static const delegate = _AppStringsDelegate();

  String text(String source, [Map<String, Object> arguments = const {}]) {
    final minutes = RegExp(r'^(\d+) min( left)?$').firstMatch(source);
    if (minutes != null) {
      return text(minutes[2] == null ? '{count} min' : '{count} min left', {
        'count': minutes[1]!,
      });
    }
    final status = RegExp(
      r'^Content request failed \((\d+)\)\. Check the connection, feed URL or service configuration\.$',
    ).firstMatch(source);
    if (status != null) {
      return text(
        'Content request failed ({status}). Check the connection, feed URL or service configuration.',
        {'status': status[1]!},
      );
    }
    final entry = translations[source];
    final translation = switch (locale.languageCode) {
      'zh' => entry?[0] ?? source,
      'ja' => entry?[1] ?? source,
      _ => source,
    };
    return translation.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (match) => arguments[match[1]]?.toString() ?? match[0]!,
    );
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();
  static Map<String, List<String>>? _cache;
  @override
  bool isSupported(Locale locale) =>
      ['en', 'zh', 'ja'].contains(locale.languageCode);
  @override
  Future<AppStrings> load(Locale locale) {
    if (_cache != null) return SynchronousFuture(AppStrings(locale, _cache!));
    return _load(locale);
  }

  Future<AppStrings> _load(Locale locale) async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/i18n/ui.json'))
            as Map<String, dynamic>;
    _cache = Map.unmodifiable(
      data.map((key, value) {
        final pair = List<String>.unmodifiable(value as List);
        if (pair.length != 2) {
          throw FormatException(
            'Expected Chinese and Japanese translations for $key',
          );
        }
        return MapEntry(key, pair);
      }),
    );
    return AppStrings(locale, _cache!);
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

extension InterfaceCopy on BuildContext {
  String tr(String source, [Map<String, Object> arguments = const {}]) =>
      (Localizations.of<AppStrings>(this, AppStrings) ??
              const AppStrings(Locale('en')))
          .text(source, arguments);
}
