import 'dart:math';

import 'package:groupify/common/common.dart';

class Track {
  final String id;
  final String name;
  final List<Artist> artists;
  final Album album;
  final int durationMs;

  int votes;
  bool voted;
  bool liked;

  Track({
    required this.id,
    required this.artists,
    required this.durationMs,
    required this.name,
    required this.album,
    this.votes = 0,
    this.voted = false,
    this.liked = false,
  });

  factory Track.random() {
    return Track(
      votes: Random().nextInt(99),
      id: 'id_1234',
      artists: [Artist('Mike Posner'), Artist('Avicii')],
      durationMs: 180000,
      name: "I'm Not Dead Yet",
      album: Album('At Night, Alone',
          [SpotifyImage('https://e.snmc.io/i/1200/s/9ac6d9769a6639a4a2fdf736a0e86310/5901318', 600, 600)]),
      voted: Random().nextInt(2) == 1,
      liked: Random().nextInt(2) == 1,
    );
  }
}
