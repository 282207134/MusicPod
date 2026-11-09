import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../core/catalog.dart';
import 'config.dart';

class ServiceFailure implements Exception {
  const ServiceFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class PodcastFeed {
  const PodcastFeed(
    this.url,
    this.title,
    this.author,
    this.image,
    this.episodes,
  );
  final String url, title, author;
  final String? image;
  final List<Track> episodes;
}

/// Only HTTPS media is accepted. No Jamendo client secret is used by the app.
String? httpsUrl(Object? value) {
  final uri = Uri.tryParse(value?.toString() ?? '');
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
      ? uri.toString()
      : null;
}

class CatalogService {
  CatalogService(this.config, {http.Client? client})
    : _client = client ?? http.Client();
  final ServiceConfig config;
  final http.Client _client;
  final _cache = <String, (DateTime, List<Track>)>{};

  Future<List<Track>> music({String query = ''}) async {
    if (!config.hasMusic) {
      throw const ServiceFailure(
        'Music is not connected yet. Follow docs/SERVICE_SETUP.md to add your Jamendo Client ID.',
      );
    }
    final clean = query.trim();
    final cached = _cache[clean];
    if (cached != null && DateTime.now().difference(cached.$1).inMinutes < 10) {
      return cached.$2;
    }
    final uri = Uri.https('api.jamendo.com', '/v3.0/tracks/', {
      'client_id': config.jamendoClientId,
      'format': 'json',
      'limit': '30',
      'audioformat': 'mp31',
      'imagesize': '300',
      'type': 'single albumtrack',
      if (clean.isNotEmpty) 'search': clean,
      if (clean.isEmpty) 'order': 'popularity_total',
    });
    final response = await _get(uri);
    final data = jsonDecode(response) as Map<String, dynamic>;
    if ((data['headers'] as Map?)?['status'] != 'success') {
      throw const ServiceFailure(
        'Jamendo rejected the request. Check your Client ID and API quota.',
      );
    }
    final tracks = (data['results'] as List)
        .map((raw) {
          final t = raw as Map<String, dynamic>;
          return Track(
            'jamendo:${t['id']}',
            t['name'] as String,
            t['artist_name'] as String,
            64,
            audioUrl: httpsUrl(t['audio']),
            imageUrl: httpsUrl(t['image']),
            durationSeconds: (t['duration'] as num?)?.toInt() ?? 0,
            sourceUrl: httpsUrl(t['shareurl']),
            licenseUrl: t['license_ccurl']?.toString(),
          );
        })
        .where((t) => t.audioUrl != null)
        .toList();
    if (_cache.length >= 30) _cache.remove(_cache.keys.first);
    _cache[clean] = (DateTime.now(), tracks);
    return tracks;
  }

  Future<PodcastFeed> podcast(String url) async {
    if (httpsUrl(url) == null) {
      throw const ServiceFailure('Enter an HTTPS podcast RSS feed URL.');
    }
    Uri target = Uri.parse(url);
    Map<String, String> headers = {};
    if (kIsWeb) {
      if (!config.hasSupabase) {
        throw const ServiceFailure(
          'Web podcasts need the RSS proxy. Follow docs/SERVICE_SETUP.md.',
        );
      }
      target = Uri.parse(
        '${config.supabaseUrl}/functions/v1/rss-proxy',
      ).replace(queryParameters: {'url': url});
      headers = {'apikey': config.supabaseKey};
    }
    final xml = await _get(target, headers: headers);
    try {
      return parsePodcast(xml, url);
    } on ServiceFailure {
      rethrow;
    } catch (_) {
      throw const ServiceFailure('This URL is not a podcast RSS feed.');
    }
  }

  Future<String> _get(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 18));
      if (response.statusCode != 200) {
        throw ServiceFailure(
          'Content request failed (${response.statusCode}). Check the connection, feed URL or service configuration.',
        );
      }
      if (response.bodyBytes.length > 5 * 1024 * 1024) {
        throw const ServiceFailure(
          'This feed is too large. Choose a smaller feed.',
        );
      }
      return utf8.decode(response.bodyBytes);
    } on ServiceFailure {
      rethrow;
    } catch (_) {
      throw const ServiceFailure(
        'Could not load content. Check your internet connection and try again.',
      );
    }
  }

  static PodcastFeed parsePodcast(String source, String url) {
    final document = XmlDocument.parse(source);
    final channel = document.findAllElements('channel').firstOrNull;
    if (channel == null) {
      throw const ServiceFailure('This URL is not a podcast RSS feed.');
    }
    String child(XmlElement node, String name) =>
        node.children
            .whereType<XmlElement>()
            .where((e) => e.name.local == name)
            .firstOrNull
            ?.innerText
            .trim() ??
        '';
    String? image(XmlElement node) {
      for (final e in node.childElements.where(
        (e) => e.name.local == 'image',
      )) {
        final value = httpsUrl(e.getAttribute('href') ?? child(e, 'url'));
        if (value != null) return value;
      }
      return null;
    }

    final title = child(channel, 'title');
    final author = child(channel, 'author');
    final cover = image(channel);
    final episodes = channel
        .findElements('item')
        .take(100)
        .map((item) {
          final enclosure = item.findElements('enclosure').firstOrNull;
          final audio = httpsUrl(enclosure?.getAttribute('url'));
          final seconds = child(item, 'duration')
              .split(':')
              .fold<int>(
                0,
                (total, part) => total * 60 + (int.tryParse(part) ?? 0),
              );
          return Track(
            'podcast:${child(item, 'guid').isEmpty ? audio : child(item, 'guid')}',
            child(item, 'title'),
            author.isEmpty ? title : author,
            40,
            audioUrl: audio,
            imageUrl: image(item) ?? cover,
            durationSeconds: seconds,
            isPodcast: true,
            sourceUrl: httpsUrl(child(item, 'link')),
            description: child(
              item,
              'description',
            ).replaceAll(RegExp('<[^>]*>'), '').trim(),
          );
        })
        .where((t) => t.audioUrl != null)
        .toList();
    if (episodes.isEmpty) {
      throw const ServiceFailure(
        'No playable HTTPS audio episodes were found in this feed.',
      );
    }
    return PodcastFeed(url, title, author, cover, episodes);
  }

  void dispose() => _client.close();
}
