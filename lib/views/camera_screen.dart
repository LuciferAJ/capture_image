import 'package:camera/camera.dart';
import 'package:capture_image/blocs/camera/camera_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = BlocProvider.of<CameraBloc>(context);

    if (!bloc.isInitialized()) return;

    if (state == AppLifecycleState.inactive)
      bloc.add(CameraStopped());
    else if (state == AppLifecycleState.resumed) bloc.add(CameraInitialized());
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CameraBloc, CameraState>(
      listener: (_, state) {
        if (state is CameraCaptureSuccess) {
          Navigator.of(context).pop(state.path);
        } else if (state is CameraCaptureFailure)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A SnackBar has been shown.'),
            ),
          );
      },
      builder: (_, state) => Scaffold(
            key: globalKey,
            backgroundColor: Colors.black,
            appBar: AppBar(title: Text("Camera")),
            body: (state is CameraReady)
                ? Container(
                    child: CameraPreview(
                        BlocProvider.of<CameraBloc>(context).getController()))
                : state is CameraFailure
                    ? Container()
                    : Container(),
            floatingActionButton: state is CameraReady
                ? FloatingActionButton(
                    child: Icon(Icons.camera_alt),
                    onPressed: () => BlocProvider.of<CameraBloc>(context)
                        .add(CameraCaptured()),
                  )
                : Container(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ));
}
