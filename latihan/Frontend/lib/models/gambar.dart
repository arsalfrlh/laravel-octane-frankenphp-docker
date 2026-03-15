class Gambar {
  final int id;
  final String namaGambar;

  Gambar({required this.id, required this.namaGambar});
  factory Gambar.fromJson(Map<String, dynamic> json){
    return Gambar(
      id: json['id'],
      namaGambar: json['nama_gambar']
    );
  }
}
