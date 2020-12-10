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

class Review extends StatefulWidget {
  final review;
  final vinId;
  final admin;
  final username;
  Review(this.review, this.vinId, this.admin, this.username){
    if(review.containsKey('date')){
      DateTime date =  new DateTime.fromMicrosecondsSinceEpoch(review['date']*1000);
      review['dateString'] = date.day.toString()+"/"+date.month.toString()+"/"+date.year.toString();
    }
    else
       review['dateString'] = "";
    
  }
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  
  bool deleted = false;

  List<Widget> reviewPrint(review) {
    List<Widget> liste  = new List<Widget>();
    liste.add(Expanded(child: Text(review['review']), flex:7));
    log(widget.username+" "+review['username']);
    if(widget.admin|| review['username'] == widget.username)
      liste.add(Expanded(child: IconButton(icon: Icon(Icons.delete, color: Colors.redAccent), onPressed: () async {
      widget.review['vinId'] = widget.vinId;
      widget.review['note'] = widget.review['note'].toString();
      widget.review['date'] = widget.review['date'].toString();
      var result = await ApiCall.deleteReview(widget.review);
      if(result.containsKey("success")){
        setState((){
          deleted = true;
        });
      }
    },), flex:1));
    return liste;
  }
  @override
  Widget build(BuildContext context) {
      return 
      deleted?Text("Commentaire supprimé!"):Container(
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.review['username']),
            RatingBarIndicator(
                        rating: double.parse( widget.review['note']),
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15.0,
                        unratedColor: Colors.amber.withAlpha(50),
                        direction: Axis.horizontal,
            ),
            Text(widget.review['dateString'])
          ],),
          Container(child: Row(
            children: reviewPrint(widget.review),
          ), margin: EdgeInsets.only(top: 15),),
        ]
        
        ),
      );
  }
}


