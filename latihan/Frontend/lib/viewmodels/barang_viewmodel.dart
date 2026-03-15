import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko/models/barang.dart';
import 'package:toko/services/api_service.dart';

class BarangViewmodel extends ChangeNotifier {
  final apiService = ApiService();
  bool isLoading = false;
  String? message;
  List<Barang> barangList = [];
  Barang? currentBarang;

  Future<void> fetchBarang() async {
    isLoading = true;
    notifyListeners();
    barangList = await apiService.getAllBarang();
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addBarang(String nmBarang, String merk, int stok, int harga, List<XFile> gambars)async{
    isLoading = true;
    message = null;
    notifyListeners();
    final barang = Barang(
      id: 0,
      namaBarang: nmBarang,
      merk: merk,
      stok: stok,
      harga: harga,
      gambarList: []
    );
    List<MultipartFile> gambarList = [];
    for(int i = 0; i < gambars.length; i++){
      gambarList.add(await MultipartFile.fromFile(gambars[i].path, filename: gambars[i].name));
    }
    final response = await apiService.addBarang(barang, gambarList);
    message = response['message'];
    isLoading = false;
    notifyListeners();
    return(response['success'] as bool);
  }

  Future<bool> updateBarang(int barangId, String namaBarang, String merk, int stok, int harga, List<XFile> gambars, List<Map<String, dynamic>> gambarOld)async{
    isLoading = true;
    message = null;
    notifyListeners();
    final updateBarang = Barang(
      id: barangId,
      namaBarang: namaBarang,
      merk: merk,
      stok: stok,
      harga: harga,
      gambarList: []
    );
    List<MultipartFile> gambarList = [];
    for(var gambar in gambars){
      gambarList.add(await MultipartFile.fromFile(gambar.path, filename: gambar.name));
    }

    final response = await apiService.updateBarang(updateBarang, gambarList, gambarOld);
    isLoading = false;
    message = response['message'];
    notifyListeners();
    return(response['success'] as bool);
  }

  Future<void> deleteBarang(int barangId)async{
    await apiService.deleteBarang(barangId);
  }

  Future<void> showBarang(int barangId)async{
    isLoading = true;
    notifyListeners();
    currentBarang = await apiService.showBarang(barangId);
    isLoading = false;
    notifyListeners();
  }
}
