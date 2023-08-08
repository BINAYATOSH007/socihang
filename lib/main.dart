import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socihang/auth.dart';
import 'package:socihang/chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socihang/splash.dart';
import 'package:firebase_storage/firebase_storage.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOCIHANG',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(0,1,1,1))
      ),
      home: StreamBuilder(stream:FirebaseAuth.instance.authStateChanges() ,builder: (ctx,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return SplashScreen();
        }
       if(snapshot.hasData){
         return const ChatScreen();
       }
       return AuthScreen();
      },),
    );
  }
}



