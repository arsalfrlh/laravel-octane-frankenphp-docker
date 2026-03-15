import 'package:toko/models/user.dart';

class Message {
  final int id;
  final String message;
  final String? gambar;
  final User user;

  Message({required this.id, required this.message, this.gambar, required this.user});
  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json['id'],
      message: json['message'],
      gambar: json['gambar'],
      user: User.fromJson(json['user'])
    );
  }
}
