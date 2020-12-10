import 'dart:convert';
import 'dart:developer';

import 'package:ShazamVin/components/CameraView.dart';
import 'package:ShazamVin/components/review.dart';
import 'package:ShazamVin/services/apiCall.dart';
import 'package:ShazamVin/views/editVin.dart';
import 'package:ShazamVin/views/vin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vin extends StatefulWidget {
  @override
  Map<String, dynamic> resultJson;
  Vin({Map<String, dynamic> this.resultJson, Key key}): super(key: key);
  _VinState createState() => _VinState();
}

class _VinState extends State<Vin> {
  var reviews;
  var noteMoyenne;
  bool loadingReview = true;
  bool changed = false;
  bool admin = false;
  String user;
  void initState(){
    super.initState();
    getReviews();
  }
  getReviews() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    admin = sharedPreferences.getBool("admin");
    user = sharedPreferences.getString("username");
    var res = await ApiCall.getVinReviews(widget.resultJson["_id"]);
    reviews = res['reviews'];
    noteMoyenne = res['avg'];
      setState(() {
        loadingReview=false;
      });
   
  }
  void OnBack(){
    Navigator.pop(context, changed);
  }
  String error;
  String reviewError;
  final TextEditingController reviewController = new TextEditingController();
  String reviewScore = "5";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      body: ListView(children: [
        Text((error==null)?"":error),
        (admin)?
        Row(children: [
          
          Expanded(
            child: RaisedButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EditVin(widget.resultJson))).then((value) {
            if(value != null){
              widget.resultJson = value;
              
              setState(() {
                changed = true;
              });
            }
            log("Retour");
        });}, child: Text("Modifier"),),
          flex: 1,),
        Expanded(
          child: RaisedButton(onPressed: () async {
            var result = await ApiCall.deleteVin({"vinId": widget.resultJson['_id']});
            if(result.containsKey("success")){
              Navigator.pop(context, true);
            }
            else{
              setState(() {error="Une erreur s'est produite";});
            }
            }, color: Colors.redAccent, child: Text("Supprimer"),), flex: 1,
        ),
        ],):Text(""),
        Container(child: Text(widget.resultJson['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), alignment: Alignment.center,),
        Container(child: RatingBarIndicator(
                        rating: (noteMoyenne==null)?0.0:noteMoyenne.toDouble(),
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 25.0,
                        unratedColor: Colors.amber.withAlpha(50),
                        direction: Axis.horizontal,
            ),alignment: Alignment.center,),
        
        Container(
          child: Table(
            columnWidths: {0: FractionColumnWidth(0.25)},
            children: [
              TableRow(children: [
                Container(child: Text("Description"), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.redAccent),
                Container(child: Text(widget.resultJson.containsKey("description")?widget.resultJson['description'] : "", style: TextStyle(color: Colors.black87)), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.red[100])
              ]),
              TableRow(children: [
                Container(child: Text("Domaine"), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.redAccent),
                Container(child: Text(widget.resultJson.containsKey("domaine")?widget.resultJson['domaine'] : "", style: TextStyle(color: Colors.black87)), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.red[100])
              ]),
              TableRow(children: [
                Container(child: Text("Cépage"), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.redAccent),
                Container(child: Text(widget.resultJson.containsKey("cepage")?widget.resultJson['cepage'] : "", style: TextStyle(color: Colors.black87)), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.red[100])
              ]),
              TableRow(children: [
                Container(child: Text("Prix"), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.redAccent),
                Container(child: Text(widget.resultJson.containsKey("prix")?widget.resultJson['prix'] : "", style: TextStyle(color: Colors.black87),), padding: EdgeInsets.only(bottom: 5, top: 5), color: Colors.red[100],)
              ])
            ],
          ),
          color: Colors.redAccent,
        ),
        (widget.resultJson.containsKey('path') && widget.resultJson['path'] != "" )?Image.network('http://192.168.1.58:3000/'+widget.resultJson['path']+"?v="+(DateTime.now().microsecondsSinceEpoch.toString())):Image.network("https://hearhear.org/wp-content/uploads/2019/09/no-image-icon-300x300.png"),
        (reviewError!=null)?Text(reviewError):Text(""),
        Container(
          child: 
              Text("Note /5:"),
        ),
          RatingBar.builder(
          initialRating: 2,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          unratedColor: Colors.amber.withAlpha(50),
          itemCount: 5,
          itemSize: 50.0,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            reviewScore = rating.toString();
          },
          updateOnDrag: true,
        ),
        Container(
          child: 
              TextField(
                controller: reviewController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(filled: true , fillColor: Colors.white, hintText: "Votre avis..."),
                style: TextStyle(color: Colors.black87),
              ),
            height: 100,
          ),
          RaisedButton(
              onPressed: ()async {
                if(reviewController.text.trim() != ""){
                  var result = await ApiCall.addReview(widget.resultJson["_id"], reviewController.text.trim(), reviewScore);
                  if(result.containsKey("error") && result.containsKey("message"))
                    setState(() {
                      reviewError = result['message'];
                    });
                  else if(result.containsKey("success")){
                     reviewController.text = "";
                      getReviews();
                      setState(() {
                      reviewError = "";
                    });
                  }
                 
                }
                  
              },
              elevation: 0.0,
              color: Colors.purple,
              child: Text("Envoyer", style: TextStyle(color: Colors.white70)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              
            ),

            
            Container(
              child: loadingReview ? Center(child: CircularProgressIndicator()) : 
              
              ListView.builder(
                itemCount: reviews.length,
                 scrollDirection: Axis.vertical,
                 shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Review(reviews[index], widget.resultJson["_id"], admin, user),
                    onTap: () {

                    },
                  );
                },
              ),
            )
        ]
        )
      ), onWillPop: () async {OnBack(); return false;});
    
  }
}
