import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko/viewmodels/song_viewmodel.dart';

class SongView extends StatefulWidget {
  const SongView({super.key});

  @override
  State<SongView> createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = Provider.of<SongViewmodel>(context, listen: false);
      vm.fetchSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SongViewmodel>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Lagu Selesai diputar: ${vm.isComplete}"),
          backgroundColor: Colors.blue,
        ),
        body: vm.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: vm.songList.length,
                  itemBuilder: (context, index) {
                    final song = vm.songList[index];
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl:
                            "http://10.0.2.2:8081/storage/${song.coverPath}",
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image,
                          size: 80,
                        ),
                      ),
                      title: Text(song.title),
                      subtitle: Text(
                          "${song.artisName} | ${Duration(seconds: song.duration).inMinutes} m"),
                      trailing: IconButton(
                          onPressed: () async => await vm.playSong(
                              songListQueue: vm.songList,
                              song: song,
                              index: index),
                          icon: Icon(Icons.play_arrow)),
                    );
                  },
                ),
              ),
        bottomSheet: vm.currentSong != null
            ? Container(
                width: 600,
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              "http://10.0.2.2:8081/storage/${vm.currentSong?.coverPath}",
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 60,
                          ),
                        ),
                        Text(vm.currentSong!.title),
                        Text(vm.currentSong!.artisName),
                        StreamBuilder<Duration?>(
                          stream: vm.player.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: vm.player.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                return Slider(
                                  min: 0,
                                  max: duration.inMilliseconds.toDouble(),
                                  value: position.inMilliseconds
                                      .clamp(0, duration.inMilliseconds)
                                      .toDouble(),
                                  onChanged: (value) async {
                                    await vm.seek(
                                        Duration(milliseconds: value.toInt()));
                                  },
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => vm.skipToPrev(),
                            icon: Icon(Icons.skip_previous)),
                        StreamBuilder<bool>(
                          stream: vm.player.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                                onPressed: () =>
                                    isPlaying ? vm.pause() : vm.play(),
                                icon: Icon(isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow));
                          },
                        ),
                        IconButton(
                            onPressed: () => vm.skipToNext(),
                            icon: Icon(Icons.skip_next)),
                        StreamBuilder<Duration?>(
                          stream: vm.player.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: vm.player.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                return Text(
                                    "${position.inMinutes}/${duration.inMinutes}m");
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ))
            : SizedBox());
  }
}
