import 'package:equatable/equatable.dart';

class Song extends Equatable {
  const Song({
    required this.album,
    required this.artist,
    required this.blocked,
    required this.duration,
    required this.path,
    required this.title,
    required this.likeCount,
    required this.skipCount,
    required this.playCount,
    required this.discNumber,
    required this.next,
    required this.previous,
    required this.timeAdded,
    required this.trackNumber,
    this.albumArtPath,
    this.year,
  });

  final String album;
  final String artist;

  /// Is this song blocked in shuffle mode?
  final bool blocked;

  final Duration duration;
  final String path;
  final String title;

  final int likeCount;
  final int skipCount;
  final int playCount;

  final int discNumber;
  final int trackNumber;
  
  final String next;
  final String previous;

  final String? albumArtPath;
  final int? year;

  final DateTime timeAdded;

  @override
  List<Object?> get props => [
        path,
        title,
        album,
        artist,
        year,
        blocked,
        next,
        previous,
        likeCount,
        playCount,
        skipCount,
        timeAdded,
      ];
}
