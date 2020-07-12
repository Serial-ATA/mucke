import 'dart:async';

import 'package:audio_service/audio_service.dart';

import '../../domain/entities/playback_state.dart' as entity;
import '../models/playback_state_model.dart';
import '../models/song_model.dart';
import 'audio_manager_contract.dart';
import 'audio_player_task.dart';

typedef Conversion<S, T> = T Function(S);

// index geht verloren, wenn noch kein Subscriber vorhanden ist, weil die events nicht gebuffert werden (kann ich nicht ändern)
// deshalb sollte sofort ein listener erstellt werden, der den jeweils letzten wert speichert
// der fertige Stream nimmt dann diesen letzten Wert, wenn er keinen im source stream findet
// so sollte kein memory leak entstehen, weil immer nur ein wert gebuffert wird

class AudioManagerImpl implements AudioManager {
  AudioManagerImpl() {
    AudioService.customEventStream.listen((event) {
      final data = event as Map<String, dynamic>;
      if (data.containsKey(KEY_INDEX)) {
        _queueIndex = data[KEY_INDEX] as int;
      }
    });
  }

  final Stream<MediaItem> _currentMediaItemStream =
      AudioService.currentMediaItemStream;
  final Stream<PlaybackState> _sourcePlaybackStateStream =
      AudioService.playbackStateStream;
  final Stream<List<MediaItem>> _queue = AudioService.queueStream;
  @override
  final Stream customEventStream = AudioService.customEventStream;

  int _queueIndex;

  @override
  Stream<SongModel> get currentSongStream =>
      _filterStream<MediaItem, SongModel>(
        _currentMediaItemStream,
        (MediaItem mi) => SongModel.fromMediaItem(mi),
      );

  @override
  Stream<entity.PlaybackState> get playbackStateStream => _filterStream(
        _sourcePlaybackStateStream,
        (PlaybackState ps) => PlaybackStateModel.fromASPlaybackState(ps),
      );

  // TODO: test
  @override
  Stream<List<SongModel>> get queueStream {
    return _queue.map((mediaItems) =>
        mediaItems.map((m) => SongModel.fromMediaItem(m)).toList());
  }

  @override
  Stream<int> get queueIndexStream =>
      _queueIndexStream(AudioService.customEventStream.cast());

  // TODO: test
  Stream<int> _queueIndexStream(Stream<Map<String, dynamic>> source) async* {
    if (_queueIndex != null) {
      yield _queueIndex;
    }

    await for (final data in source) {
      if (data.containsKey(KEY_INDEX)) {
        yield data[KEY_INDEX] as int;
      }
    }
  }

  @override
  Stream<int> get currentPositionStream => _position().distinct();

  @override
  Future<void> playSong(int index, List<SongModel> songList) async {
    await _startAudioService();
    final List<String> queue = songList.map((s) => s.path).toList();
    await AudioService.customAction(PLAY_WITH_CONTEXT, [queue, index]);
  }

  @override
  Future<void> play() async {
    await AudioService.play();
  }

  @override
  Future<void> pause() async {
    await AudioService.pause();
  }

  Future<void> _startAudioService() async {
    if (!AudioService.running) {
      await AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        androidEnableQueue: true,
      );
      await AudioService.customAction(INIT);
    }
  }

  @override
  Future<void> skipToNext() async {
    await AudioService.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await AudioService.skipToPrevious();
  }

  Stream<T> _filterStream<S, T>(Stream<S> stream, Conversion<S, T> fn) async* {
    T lastItem;

    await for (final S item in stream) {
      final T newItem = fn(item);
      if (newItem != lastItem) {
        lastItem = newItem;
        yield newItem;
      }
    }
  }

  Stream<int> _position() async* {
    PlaybackState state;
    Duration updateTime;
    Duration statePosition;

    // should this class get an init method for this?
    _sourcePlaybackStateStream.listen((currentState) {
      state = currentState;
      updateTime = currentState?.updateTime;
      statePosition = currentState?.position;
    });

    while (true) {
      if (statePosition != null && updateTime != null && state != null) {
        if (state.playing) {
          yield statePosition.inMilliseconds +
              (DateTime.now().millisecondsSinceEpoch -
                  updateTime.inMilliseconds);
        } else {
          yield statePosition.inMilliseconds;
        }
      } else {
        yield 0;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}

void _backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
