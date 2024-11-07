
import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/auth/login.dart';
// import 'package:holtelmanagement/features/auth/login.dart';


void main()async{


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white
      ),
        home:   const LoginPage(),
       // home:   NotificationPage(),
    );
  }
}   