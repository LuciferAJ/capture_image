import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capture_image/configuration/camera_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraConfigs cameraConfigs;
  final ResolutionPreset resolutionPreset;
  final CameraLensDirection cameraLensDirection;

  CameraController _controller;

  CameraBloc({
    @required this.cameraConfigs,
    this.resolutionPreset = ResolutionPreset.high,
    this.cameraLensDirection = CameraLensDirection.back,
  }) : super(CameraInitial());

  CameraController getController() => _controller;

  bool isInitialized() => _controller?.value?.isInitialized ?? false;

  @override
  Stream<CameraState> mapEventToState(
    CameraEvent event,
  ) async* {
    if (event is CameraInitialized)
      yield* _mapCameraInitializedToState(event);
    else if (event is CameraCaptured)
      yield* _mapCameraCapturedToState(event);
    else if (event is CameraStopped) yield* _mapCameraStoppedToState(event);
  }

  Stream<CameraState> _mapCameraInitializedToState(
      CameraInitialized event) async* {
    try {
      _controller = await cameraConfigs.getCameraController(
          resolutionPreset, cameraLensDirection);
      await _controller.initialize();
      yield CameraReady();
    } on CameraException catch (error) {
      _controller?.dispose();
      yield CameraFailure(error: error.description);
    } catch (error) {
      yield CameraFailure(error: error.toString());
    }
  }

  Stream<CameraState> _mapCameraCapturedToState(CameraCaptured event) async* {
    if (state is CameraReady) {
      yield CameraCaptureInProgress();
      try {
        File result;
        XFile capturedFile = await _controller.takePicture();
        int fileLength = await capturedFile.length();
        print(capturedFile.path);
        print(fileLength);
        if ((fileLength / (1024 * 1024)) > 4) {
          await FlutterImageCompress.compressAndGetFile(
                  capturedFile.path, 'output_' + capturedFile.path,
                  quality: ((100 / (fileLength / (1024 * 1024))) * 4).toInt())
              .then((value) => result = value);
          if (result != null) {
            var base64ImageData = await result.readAsBytes();
            yield CameraCaptureSuccess(base64Encode(base64ImageData));
          }
        } else {
          var bytesImageFile = await capturedFile.readAsBytes();
          yield CameraCaptureSuccess(base64Encode(bytesImageFile));
        }
      } on CameraException catch (error) {
        yield CameraCaptureFailure(error: error.description);
      }
    }
  }

  Stream<CameraState> _mapCameraStoppedToState(CameraStopped event) async* {
    _controller?.dispose();
    yield CameraInitial();
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
