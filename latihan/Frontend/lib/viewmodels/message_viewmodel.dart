import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko/models/message.dart';
import 'package:toko/models/user.dart';
import 'package:toko/services/api_service.dart';
import 'package:toko/services/reverb_service.dart';

class MessageViewmodel extends ChangeNotifier {
  final apiService = ApiService();
  bool isLoading = false;
  String? message;
  User? currentUser;
  List<User> userList = [];
  List<Message> messageList = [];
  int? chatRoomId;
  int? messageId;
  bool isUpdate = false;
  final reverService = ReverbService();

  Future<void> fetchAllUser() async {
    isLoading = true;
    notifyListeners();
    userList = await apiService.getAllUser();
    currentUser = await apiService.currentUser();
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMessage(int receiverId)async{
    isLoading = true;
    notifyListeners();
    final response = await apiService.getAllMessage(receiverId);
    messageList = (response['data'] as List).map((item) => Message.fromJson(item)).toList();
    chatRoomId = response['chat_room_id'];
    reverService.connect(chatRoomId!);
    reverService.onMessage = (data) => _hanldeRealtime(data);
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(int receiverId, String message, XFile? gambar)async{
    isLoading = true;
    notifyListeners();
    MultipartFile? imagePath;
    if(gambar != null){
      imagePath = await MultipartFile.fromFile(gambar.path, filename: gambar.name);
    }
    await apiService.sendMessage(receiverId, message, imagePath);
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateMessage(String message, XFile? gambar)async{
    isLoading = true;
    notifyListeners();
    MultipartFile? imagePath;
    if(gambar != null){
      imagePath = await MultipartFile.fromFile(gambar.path, filename: gambar.name);
    }
    await apiService.updateMessage(messageId!, message, imagePath);
    isLoading = false;
    messageId = null;
    isUpdate = false;
    notifyListeners();
  }

  Future<void> deleteMessage(int messageId)async{
    isLoading = true;
    notifyListeners();
    await apiService.deleteMessage(messageId);
    isLoading = false;
    notifyListeners();
  }
  
  void _hanldeRealtime(Map<String, dynamic> data){
    final action = data['action'];
    final message = Message.fromJson(data['message']);

    if(action == "create"){
      messageList.add(message);
    }else if(action == "update"){
      final index = messageList.indexWhere((m) => m.id == message.id);
      if(index >= 0){
        messageList[index] = message;
      }
    }else if(action == "delete"){
      final index = messageList.indexWhere((m) => m.id == message.id);
      if(index >= 0){
        messageList.removeAt(index);
      }
    }
    notifyListeners();
  }

  void onUpdate(int messageId){
    this.messageId = messageId;
    isUpdate = true;
    notifyListeners();
  }

  void onCancelUpdate(){
    messageId = null;
    isUpdate = false;
    notifyListeners();
  }
}
