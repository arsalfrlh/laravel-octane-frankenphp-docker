import 'package:just_audio/just_audio.dart';

class AudioService {
  final _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> playSong(String audioPath) async {
    await _player.setUrl("http://10.0.2.2:8081/storage/$audioPath");
    _player.play();
  }

  Future<void> pause() async => _player.pause();
  Future<void> play() async => _player.play();
  Future<void> seek(Duration value) async => _player.seek(value);
}
