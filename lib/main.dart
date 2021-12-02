import 'package:apollo_bengkel/pages/router.dart';
import 'package:apollo_bengkel/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// untuk sementara sign in anonimously dulu
  // await firebaseAuth.signInAnonymously();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'apollo_bengkel',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      onGenerateRoute: onGenerateRoute,
      initialRoute: '/splash_page',
    );
  }
}
