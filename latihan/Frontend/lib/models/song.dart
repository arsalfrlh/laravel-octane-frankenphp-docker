class Song {
  final int id;
  final String title;
  final String artisName;
  final String coverPath;
  final String audioPath;
  final int duration;

  Song({required this.id, required this.title, required this.artisName, required this.coverPath, required this.audioPath, required this.duration});
  factory Song.fromJson(Map<String, dynamic> json){
    return Song(
      id: json['id'],
      title: json['title'],
      artisName: json['artis_name'],
      coverPath: json['cover_path'],
      audioPath: json['audio_path'],
      duration: json['duration']
    );
  }
}
