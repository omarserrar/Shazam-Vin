import 'dart:developer';
import 'dart:io';
import 'package:ShazamVin/services/PictureVerification.dart';
import 'package:ShazamVin/views/vin.dart';
import 'package:flutter/material.dart';

import 'Resultat.dart';

class NoResult extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Text("Aucun résultat", style: TextStyle(fontSize: 36),),
    );
  }
}