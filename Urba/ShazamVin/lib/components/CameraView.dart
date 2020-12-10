import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ShazamVin/components/PictureTaken.dart';
import 'package:ShazamVin/views/listeVin.dart';
import 'package:ShazamVin/views/login.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:camera/camera.dart';
class CameraView extends StatefulWidget {
  CameraView({
    Key key
  }) : super(key: key);

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> {
  CameraController _controller;
  CameraDescription camera;
  Future<void> _initializeControllerFuture;
  String username;
  bool admin= false;
  @override
  void initState() {
    super.initState();
    
  initCamera();
  }
  void initCamera() async{
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    camera = firstCamera;
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );
    await loadUser();
    setState(() {
      _initializeControllerFuture = _controller.initialize();

    });
  }
  loadUser() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString("username");
    admin = sharedPreferences.getBool("admin");
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      body: Column(
        children: [
          Padding(
                padding: const EdgeInsets.only(top:30.0, bottom: 10, left: 15),
                child: Row(children: [Expanded(child: Text("ShazamVin", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),flex:2), Expanded(child: RaisedButton(child: Text("Déconnexion"),color: Colors.redAccent, onPressed: () async {
                  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                  sharedPreferences.remove("token");
                  sharedPreferences.remove("user");
                  
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
                },),
                 flex: 2,)],),
              ),
          Stack(
            children: [
              
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(child: CameraPreview(_controller), aspectRatio: _controller.value.aspectRatio,);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top:20.0, bottom: 10, left: 15),
                child: Text("Scannez le vin",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ),
              admin?Padding(padding: EdgeInsets.only(left: 200), child: RaisedButton(child: Text("Vins"),color: Colors.redAccent, onPressed: () async {
                     Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ListeVin()));
                },)):Text(""),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            await _controller.takePicture(path);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PictureTaken(imagePath: path),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

