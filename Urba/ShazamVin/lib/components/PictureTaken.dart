import 'dart:developer';
import 'dart:io';
import 'package:ShazamVin/components/noResult.dart';
import 'package:ShazamVin/services/PictureVerification.dart';
import 'package:ShazamVin/views/vin.dart';
import 'package:flutter/material.dart';

import 'Resultat.dart';

class PictureTaken extends StatelessWidget {
  final String imagePath;

  String erreur;

  PictureTaken({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Image.file(File(imagePath)),
      floatingActionButton:
            FloatingActionButton(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.search), onPressed:  () async{
                  Map<String, dynamic> result = await PictureVerification().uploadPic(File(imagePath));
                  if(result.containsKey("bestMatch")){
                    log("Resultat Trouve "+result['bestMatch']['name']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Vin(resultJson : result['bestMatch']),
                      )
                    );
                  }
                  else{
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoResult()
                      )
                    );
                  }
                  log("Heeeey "+imagePath );
                }),
    );
  }
}