import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ShazamVin/components/CameraView.dart';
import 'package:ShazamVin/services/apiCall.dart';
import 'package:ShazamVin/views/vin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditVin extends StatefulWidget {
  final vin;
  const EditVin(this.vin);
  @override
  _EditVinState createState() => _EditVinState();
}

class _EditVinState extends State<EditVin> {
  TextEditingController nomController = new TextEditingController();
  TextEditingController keywordController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController domaineController = new TextEditingController();
  TextEditingController cepageController = new TextEditingController();
  TextEditingController prixController = new TextEditingController();
  bool error = false;
  bool imageChanged = false;
  String type;
  String imagePath;
  Image image;
  String errorMessage;
  @override
  bool loading = false;
  @override
  void initState() {
    super.initState();
    if(!widget.vin.containsKey('_id'))
      type = "add";
    else 
      type = "edit";
    if(widget.vin != {}){
      nomController.text = (widget.vin.containsKey('name'))?widget.vin['name']:"";
      keywordController.text = (widget.vin.containsKey('keywords'))?widget.vin['keywords']:"";
      descriptionController.text = (widget.vin.containsKey('description'))?widget.vin['description']:"";
      domaineController.text = (widget.vin.containsKey('domaine'))?widget.vin['domaine']:"";
      cepageController.text = (widget.vin.containsKey('cepage'))?widget.vin['cepage']:"";
      prixController.text = (widget.vin.containsKey('prix'))?widget.vin['prix']:"";
      imagePath = (widget.vin.containsKey('path'))?widget.vin['path']:null;
      if(imagePath!=null)
        image = Image.network(ApiCall.HOSTNAME+"/"+imagePath+"?v="+new DateTime.now().microsecondsSinceEpoch.toString());
    }
  
    log(widget.vin['keywords'].toString());
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
       child: ListView(children: [
         Text("Nom"),
         TextField(controller: nomController,),
         Text("Mots clefs"),
         TextField(controller: keywordController,),
         Text("Description"),
         TextField(controller: descriptionController,),
         Text("Cépage"),
         TextField(controller: cepageController,),
         Text("Domaine"),
         TextField(controller: domaineController,),
         Text("Prix"),
         TextField(controller: prixController,),
         
         Row(children: [
           Expanded(child: (image!=null)?image:Image.network("https://hearhear.org/wp-content/uploads/2019/09/no-image-icon-300x300.png")),
           Expanded(child: RaisedButton(onPressed: () async {
             PickedFile imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
             imagePath = imageFile.path;
             setState((){
               image = Image.file(File(imagePath));
               imageChanged = true;
             });
             }, child: Text("Modifier l'image"),))
         ],),
         errorMessage!=null?Text(errorMessage):Text(""),
         RaisedButton(onPressed: () async{
           if(nomController.text.trim() == ""){
             setState(() {
                  errorMessage = "Le vin doit au moins avoir un nom !";
                });
              return;
           }
           log("Edit");
           widget.vin['name'] = nomController.text.trim();
           widget.vin['prix'] = prixController.text.trim();
           widget.vin['cepage'] = cepageController.text.trim();
           widget.vin['domaine'] = domaineController.text.trim();
           widget.vin['description'] = descriptionController.text.trim();
           widget.vin['key'] = keywordController.text.trim();
           if(type=='add'){
             var result = await ApiCall.addVin(widget.vin);
              if(result.containsKey("vinId")){
                if(imageChanged){
                  await ApiCall.changeVinPic(File(imagePath), result['vinId']);
                }
                Navigator.pop(context, result);
               // 
              }
              else{
                setState(() {
                  errorMessage = "Une erreure s'est produite !";
                });
              }
           }
           else{
              var result = await ApiCall.editVin({"name": nomController.text.trim(), "prix": prixController.text.trim(), "cepage": cepageController.text.trim(), "domaine": domaineController.text.trim()
              ,"description": descriptionController.text.trim(), "key": keywordController.text.trim(), "vinId": widget.vin['_id']});
              if(imageChanged){
                log("Image Change");
                await ApiCall.changeVinPic(File(imagePath), widget.vin['_id']);
              }
              if(result.containsKey("success")){
                Navigator.pop(context, widget.vin);
              }
              else{
                setState(() {
                  errorMessage = "Une erreure s'est produite !";
                });
              }
           }
           
           }
         , child: Text(type=="add"?"Ajouter":"Sauvegarder"),)
       ],),
      ),
    );
  }
}