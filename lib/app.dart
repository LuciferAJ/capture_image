import 'package:capture_image/views/homepage.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Bloc Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        buttonColor: Colors.black,
      ),
      home: HomePage(),
    );
  }
}
