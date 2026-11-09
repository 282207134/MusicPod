/// Public feeds linked by each publisher. Metadata is loaded only when opened.
class PodcastPick {
  const PodcastPick(this.title, this.url, this.language, this.description);
  final String title, url, language, description;
}

const podcastLanguages = {
  'zh': 'Chinese podcasts',
  'ja': 'Japanese podcasts',
  'en': 'English podcasts',
};

const podcastPicks = [
  PodcastPick(
    '硅谷101',
    'https://feeds.fireside.fm/sv101/rss',
    'zh',
    'Chinese · Technology, business and innovation',
  ),
  PodcastPick(
    '少数派播客',
    'https://sspai.typlog.io/feed/audio.xml',
    'zh',
    'Chinese · Digital tools, productivity and life',
  ),
  PodcastPick(
    'Rebuild',
    'https://feeds.rebuild.fm/rebuildfm',
    'ja',
    'Mostly Japanese · Technology and software',
  ),
  PodcastPick(
    '4989 American Life',
    'https://feed.podbean.com/americanlife4989/feed.xml',
    'ja',
    'Japanese · Everyday life in America',
  ),
  PodcastPick(
    'NPR · Planet Money',
    'https://feeds.npr.org/510289/podcast.xml',
    'en',
    'English · Economics and everyday life',
  ),
];
