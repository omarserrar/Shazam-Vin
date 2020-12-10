import 'dart:convert';
import 'dart:developer';

import 'package:ShazamVin/components/CameraView.dart';
import 'package:ShazamVin/services/apiCall.dart';
import 'package:ShazamVin/views/editVin.dart';
import 'package:ShazamVin/views/vin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ListeVin extends StatefulWidget {
  @override
  _ListeVinState createState() => _ListeVinState();
}

class _ListeVinState extends State<ListeVin> {
  @override
  bool loading = true;
  bool changed = false;
  var vinListe;
  void initState(){
    super.initState();
    getAllVin();
  }
  getAllVin() async {
    vinListe = await ApiCall.getAllVIn();
   /* vinListe= new List<Row>();
    if(vins != null)
    vins.forEach((vin) => {
      vinListe.add(new Row(children: [
        Text(vin["name"])
      ],))
    });*/
    setState(() {
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => EditVin({}))).then((value) {
          if(value!=null){
            getAllVin();
            setState(){
              loading = true;
            }
          }
          
        });
      },),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: loading ? Center(child: CircularProgressIndicator()) : ListView.builder(
          itemCount: vinListe.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(vinListe[index]["name"]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Vin(resultJson: vinListe[index]))).then((value) {
                  if(value != null && value == true){
                    getAllVin();
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }
}