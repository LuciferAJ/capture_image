import 'package:capture_image/app.dart';
import 'package:capture_image/bloc_oserver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = HelperBlocObserver();
  return runApp(MyApp());
}
