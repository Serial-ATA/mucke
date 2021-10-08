import '../repositories/audio_player_repository.dart';
import '../repositories/platform_integration_repository.dart';
import '../usecases/seek_to_next.dart';

class PlatformIntegrationActor {
  PlatformIntegrationActor(
    this._platformIntegrationInfoRepository,
    this._seekToNext,
    this._audioPlayerRepository,
  ) {
    _platformIntegrationInfoRepository.eventStream
        .listen((event) => _handlePlatformIntegrationEvent(event));
  }

  final AudioPlayerRepository _audioPlayerRepository;
  final PlatformIntegrationInfoRepository _platformIntegrationInfoRepository;

  final SeekToNext _seekToNext;

  void _handlePlatformIntegrationEvent(PlatformIntegrationEvent event) {
    switch (event.type) {
      case PlatformIntegrationEventType.play:
        _audioPlayerRepository.play();
        break;
      case PlatformIntegrationEventType.pause:
        _audioPlayerRepository.pause();
        break;
      case PlatformIntegrationEventType.skipNext:
        _seekToNext();
        break;
      case PlatformIntegrationEventType.skipPrevious:
        _audioPlayerRepository.seekToPrevious();
        break;
      default:
    }
  }
}
