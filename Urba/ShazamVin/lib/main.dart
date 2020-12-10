import 'dart:async';
import 'dart:io';

import 'package:ShazamVin/components/CameraView.dart';
import 'package:ShazamVin/views/listeVin.dart';
import 'package:ShazamVin/views/login.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  

  // Get a specific camera from the list of available cameras.
  /* TODO :
    Confirm delete
    Liste Vin
    Fix Text Vin
    Soigne Interface
*/
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: LoginPage()
      /*home: LoginPage(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),*/
    ),
  );
}

