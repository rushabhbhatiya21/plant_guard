// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:image/image.dart';
// import 'auth_screen.dart'; // Import AuthScreen
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Plant Guard',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: AuthScreen(),
//     );
//   }
// }
////////////////////new code////////////////////

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:plant_guard/pages/camera_screen.dart';
//
// void main() => runApp(CameraApp());
//
// class CameraApp extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//         statusBarColor: Colors.black
//     ));
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.black,
//
//       ),
//       debugShowCheckedModeBanner: false,
//       home:CameraScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:plant_guard/auth/login_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black
    ));
    return MaterialApp(
      title: 'Plant Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
