import 'dart:async';
import 'package:flutter/material.dart';
import 'package:apollo_bengkel/firebase.dart';


class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), _authenticate);
  }

 void _authenticate() {
    if (fireAuth.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home_page');
      return;
    }

    Navigator.pushReplacementNamed(context, '/login_page');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: [
              Container(
                height: 300.0,
                width: 300.0,
                margin: const EdgeInsets.only(
                  bottom: 50.0,
                ),
                child: Image.asset(
                  'assets/logo_mitra.png',
                  fit: BoxFit.contain,
                ),
              ),
              Spacer(),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
