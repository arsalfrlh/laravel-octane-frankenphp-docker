import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko/viewmodels/auth_viewmodel.dart';
import 'package:toko/viewmodels/barang_viewmodel.dart';
import 'package:toko/viewmodels/message_viewmodel.dart';
import 'package:toko/viewmodels/song_viewmodel.dart';
import 'package:toko/views/barang_view.dart';
import 'package:toko/views/chat_view.dart';
import 'package:toko/views/login_view.dart';
import 'package:toko/views/song_view.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final key = await SharedPreferences.getInstance();
  final statusLogin = key.getBool("statusLogin") ?? false;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => BarangViewmodel()),
    ChangeNotifierProvider(create: (_) => SongViewmodel()),
    ChangeNotifierProvider(create: (_) => AuthViewmodel()),
    ChangeNotifierProvider(create: (_) => MessageViewmodel())
  ],
  child: MyApp(status: statusLogin,),));
}

class MyApp extends StatelessWidget {
  MyApp({required this.status});
  bool status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Barang",
      home: status ? ChatView() : LoginView(),
    );
  }
}

// ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['pesan']), backgroundColor: Colors.green,));
// http://10.0.2.2:8000/api
// {'Content-Type': 'application/json'}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
