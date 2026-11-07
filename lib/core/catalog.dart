enum AppScreen {
  splash,
  signup,
  otp,
  home,
  album,
  albumFilter,
  player,
  trackOptions,
  queue,
  search,
  searchResults,
  podcasts,
  podcastDetail,
  libraryPlaylists,
  libraryArtists,
  chooseArtists,
  libraryAlbums,
  libraryEpisodes,
  libraryDownloads,
  settings,
  account,
  language,
  dataSaver,
  social,
  playback,
  equalizer,
}

class Track {
  const Track(this.id, this.title, this.artist, this.art);
  final String id, title, artist;
  final int art;
  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'art': art,
  };
  factory Track.fromJson(Map<String, dynamic> json) => Track(
    json['id'] as String,
    json['title'] as String,
    json['artist'] as String,
    json['art'] as int,
  );
}

const albumTracks = [
  Track('isralea', 'Isralea Palacio', 'Jay Sean', 64),
  Track('frank', 'Frank Septilion', 'Jay Sean', 66),
  Track(
    'missing',
    'Missing My Baby - Extended Version',
    'Selena, Jay Sean',
    62,
  ),
  Track('scary', 'Scary Hours 2', 'Selena, Jay Sean, Bruno', 61),
  Track('baila', 'Baila Conmigo', 'Jay Sean, Bruno', 60),
];
const queueTracks = [
  Track('real', 'Real As It Gets (feat. EST Gee)', 'Lil Baby, EST Gee', 72),
  Track('jiyen', 'Jiyen Kyun', 'Pritam', 73),
  Track(
    'skip',
    'Skip.that.party (with Jensen McRae)',
    'X Ambassadors, Jensen McRae',
    67,
  ),
  Track('boyfriend', 'Boyfriend', 'CKay', 69),
  Track('tears', 'Save Your Tears (Remix)', 'The Weeknd, Ariana Grande', 68),
  Track('see', 'I’ll see you when I see you', 'LambC', 44),
  Track('come', 'Come Through', 'Chris Brown', 48),
];
const searchTracks = [
  Track(
    'peaches1',
    'Peaches (feat. Daniel Caesar & Giveon)',
    'Justin Bieber, Daniel Caesar, Giveon',
    44,
  ),
  Track('peaches2', 'Peaches', 'Justin Bieber, Daniel Caesar, Giveon', 45),
  Track('peach', 'Peach Munde', 'DJ Frenzy, AP Dhillon, Gurinder Gill', 46),
  Track('peachlist', 'Peaches Stream Playlist', 'Playlist', 64),
  Track('peaky', 'Peaky Blinders', 'Klem Schen', 45),
  Track('peakylist', 'Peaky Blinders Playlist', 'Playlist', 44),
  Track(
    'challa',
    'Challakuttiye (Avastha Love Song)',
    'Jecin George, Pearle Maaney',
    47,
  ),
];
const playlists = [
  Track('eminem', 'Eminem Loose yourself', 'By Aiden', 30),
  Track('wafa', 'Wafa Na Raa Aayee', 'By Aiden', 31),
  Track(
    'onme',
    'On Me (Remix) (with Megan Thee Stallion)',
    'Lil Baby, Megan Thee Stallion',
    34,
  ),
  Track('die', 'Die For a Man', 'Bebe Rexha, Lil Uzi Vert', 33),
  Track('power', 'Your Power', 'By Aiden', 32),
  Track('hold', 'Hold On', 'Justin Bieber', 35),
  Track('leave', 'Leave the door open', 'Bruno Mars, Anderson .Paak', 36),
];
const libraryAlbums = [
  Track('hello', 'Hello', 'By Adele', 12),
  Track('uptown', 'Uptown Funk', 'By Mark Ronson ft. Bruno Mars', 11),
  Track('again', 'See You Again', 'By Wiz Khalifa ft. Charlie Puth', 10),
  Track('shake', 'Shake It Off', 'By Taylor Swift', 9),
  Track('bass', 'All About That Bass', 'Meghan Trainor', 8),
  Track('nobody', 'Nobody Knows Me', 'Madonna', 7),
];
const artists = [
  Track('beyonce', 'Beyonce', '', 17),
  Track('taylor', 'Taylor Swift', '', 16),
  Track('gaga', 'Lady Gaga', '', 15),
  Track('justin', 'Justin Bieber', '', 14),
  Track('bruno', 'Bruno Mars', '', 13),
];
const settingsLabels = [
  'Account',
  'Languages',
  'Devices',
  'Data Saver',
  'Social',
  'Playback',
  'Equalizer',
];
const languages = [
  'English',
  'Chinese',
  'Hindi',
  'Spanish',
  'German',
  'French',
  'Standard Arabic',
  'Russian',
  'Japanese',
  'Korean',
  'Italian',
  'Urdu',
  'Kannada',
];
const equalizerPresets = [
  'Bass Booster',
  'Bass Reducer',
  'Classical',
  'Dance',
  'Deep',
  'Flat',
  'Hip-Hop',
];
