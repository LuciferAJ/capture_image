import 'package:capture_image/blocs/camera/camera_bloc.dart';
import 'package:capture_image/configuration/camera_config.dart';
import 'package:capture_image/views/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void openCamera() {
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CameraBloc(cameraConfigs: CameraConfigs())
              ..add(CameraInitialized()),
            child: CameraScreen(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        child: Text("Capture"),
        onPressed: () => openCamera(),
        style: ElevatedButton.styleFrom(
            primary: Colors.black, textStyle: TextStyle(color: Colors.white)),
      )),
    );
  }
}
