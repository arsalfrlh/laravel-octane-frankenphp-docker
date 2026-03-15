import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toko/models/song.dart';
import 'package:toko/services/api_service.dart';
import 'package:toko/services/audio_service.dart';

class SongViewmodel extends ChangeNotifier {
  final apiService = ApiService();
  final _audioService = AudioService();
  bool isLoading = false;
  List<Song> currentQueueSong = [];
  List<Song> songList = [];
  Song? currentSong;
  int? currentIndex;
  int isComplete = 0;

  AudioPlayer get player => _audioService.player;

  SongViewmodel() {
    _audioService.player.processingStateStream.listen((p) {
      if(p == ProcessingState.completed){
        isComplete += 1;
        notifyListeners();
        skipToNext();
      }
    });
  }

  Future<void> fetchSong() async {
    isLoading = true;
    notifyListeners();
    songList = await apiService.getAllSong();
    isLoading = false;
    notifyListeners();
  }

  Future<void> playSong({List<Song>? songListQueue, required Song song, required int index}) async {
    if (currentSong?.id != song.id) {
      await _audioService.playSong(song.audioPath);
    }
    if(songListQueue != null && songListQueue.isNotEmpty){
      currentQueueSong = songListQueue;
    }
    currentSong = song;
    currentIndex = index;
    notifyListeners();
  }

  Future<void> skipToNext() async {
    if (currentIndex == null) return;
    final next = currentIndex! + 1;
    if(next < currentQueueSong.length){
      await playSong(songListQueue: currentQueueSong, song: currentQueueSong[next], index: next);
    }
  }

  Future<void> skipToPrev()async{
    if(currentIndex == null) return;
    final prev = currentIndex! - 1;
    if(prev >= 0){
      await playSong(songListQueue: currentQueueSong, song: currentQueueSong[prev], index: prev);
    }
  }
  
  Future<void> play() async => _audioService.play();
  Future<void> pause() async => _audioService.pause();
  Future<void> seek(Duration value) async => _audioService.seek(value);
}
