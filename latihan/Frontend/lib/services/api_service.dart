import 'package:dio/dio.dart';
import 'package:toko/models/barang.dart';
import 'package:toko/models/message.dart';
import 'package:toko/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko/models/user.dart';

class ApiService {
  final dio = Dio(BaseOptions(
      baseUrl: "http://10.0.2.2:8081/api",
      sendTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20)));

  ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final key = await SharedPreferences.getInstance();
        final token = key.getString("token");

        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
    ));
  }

  Future<List<Barang>> getAllBarang() async {
    try {
      final response = await dio.get("/barang");
      return (response.data['data'] as List)
          .map((item) => Barang.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> addBarang(
      Barang barang, List<MultipartFile> gambarList) async {
    try {
      final request = FormData.fromMap({
        "nama_barang": barang.namaBarang,
        "merk": barang.merk,
        "stok": barang.stok,
        "harga": barang.harga,
        "gambar[]": gambarList
      });

      final response = await dio.post("/barang", data: request);
      return response.data;
    } on DioException catch (e) {
      return {"success": false, "message": e.response.toString()};
    }
  }

  Future<Barang> showBarang(int barangId) async {
    try {
      final response = await dio.get('/barang/$barangId');
      return Barang.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> updateBarang(
      Barang barang,
      List<MultipartFile> gambarList,
      List<Map<String, dynamic>> gambarOld) async {
    try {
      final request = FormData.fromMap({
        "_method": "PUT",
        "nama_barang": barang.namaBarang,
        "merk": barang.merk,
        "stok": barang.stok,
        "harga": barang.harga,
        if (gambarList.isNotEmpty) "gambar[]": gambarList,
        if (gambarOld.isNotEmpty) "gambar_old": gambarOld
      });

      final response = await dio.post("/barang/${barang.id}", data: request);
      return response.data;
    } on DioException catch (e) {
      return {"success": false, "message": e.response.toString()};
    }
  }

  Future<void> deleteBarang(int barangId) async {
    try {
      await dio.delete("/barang/$barangId");
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<List<Song>> getAllSong() async {
    try {
      final response = await dio.get("/song");
      return (response.data['data'] as List)
          .map((item) => Song.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio
          .post("/login", data: {"email": email, "password": password});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool("statusLogin", true);
      }
      return response.data;
    } on DioException catch (e) {
      return {"success": false, 'message': e.response.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await dio.post("/register",
          data: {"name": name, "email": email, "password": password});
      if (response.statusCode == 201 &&
          response.data['data']['success'] == true) {
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool("statusLogin", true);
      }
      return response.data;
    } on DioException catch (e) {
      return {"success": false, "message": e.response.toString()};
    }
  }

  Future<User> currentUser() async {
    try {
      final response = await dio.get("/user");
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<List<User>> getAllUser() async {
    try {
      final response = await dio.get("/message");
      return (response.data['data'] as List)
          .map((item) => User.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> getAllMessage(int receiverId) async {
    try {
      final response = await dio.get("/message/$receiverId");
      return response.data;
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response.toString(),
      };
    }
  }

  Future<void> sendMessage(
      int receiverId, String message, MultipartFile? imagePath) async {
    try {
      final request = FormData.fromMap({
        "receiver_id": receiverId,
        "message": message,
        if (imagePath != null) "gambar": imagePath
      });
      await dio.post("/message", data: request);
    } on DioException catch (e) {
      print(e.response);
      throw Exception(e.response);
    }
  }

  Future<void> updateMessage(
      int messageId, String message, MultipartFile? gambar) async {
    try {
      final request = FormData.fromMap({
        "message": message,
        if (gambar != null) "gambar": gambar,
        "_method": "PUT"
      });

      await dio.post("/message/$messageId", data: request);
    } on DioException catch (e) {
      print(e.response);
      throw Exception(e.response);
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await dio.delete("/message/$messageId");
    } on DioException catch (e) {
      print(e.response);
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> authBroadcast(
      String? socketId, String channelName) async {
    try {
      final response = await dio.post("/broadcasting/auth",
          data: {"socket_id": socketId, "channel_name": channelName});
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e.response);
    }
  }
}
