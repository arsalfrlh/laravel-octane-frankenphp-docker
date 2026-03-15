import 'package:toko/models/gambar.dart';

class Barang {
  final int id;
  final String namaBarang;
  final String merk;
  final int stok;
  final int harga;
  final List<Gambar> gambarList;

  Barang({required this.id, required this.namaBarang, required this.merk, required this.stok, required this.harga, required this.gambarList});
  factory Barang.fromJson(Map<String, dynamic> json){
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      merk: json['merk'],
      stok: json['stok'],
      harga: json['harga'],
      gambarList: (json['gambar'] as List).map((item) => Gambar.fromJson(item)).toList()
    );
  }
}
