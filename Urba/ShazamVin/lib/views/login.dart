import 'dart:convert';
import 'dart:developer';

import 'package:ShazamVin/components/CameraView.dart';
import 'package:ShazamVin/services/apiCall.dart';
import 'package:ShazamVin/views/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String errorMessage;
  bool _isLoading = false;
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  void login(username, password) async {
    log(username+" "+password);
    var loginResult = await ApiCall.login(username, password);
    log(loginResult.toString());
    if(loginResult != Null && loginResult.containsKey("connected")){
      
      
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("username", loginResult['user']['username']);
      sharedPreferences.setString("token", loginResult['token']);
      log((loginResult['user'].containsKey("admin") && loginResult['user']['admin'] == 1).toString());
      sharedPreferences.setBool("admin", loginResult['user'].containsKey("admin") && loginResult['user']['admin'] == 1);
      var usname = sharedPreferences.getString("username");
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => CameraView()), (Route<dynamic> route) => false);
  //    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CameraView()));
      log("Logged h"+usname);
    }
    else if(loginResult != false && loginResult.containsKey("error")){
      setState(() {
        errorMessage = loginResult["message"];
      });
    }
 }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            Text("Nom d'utilisateur"),
            TextFormField(
              controller: usernameController,
              cursorColor: Colors.white,
            ),
            Text("Mot de passe"),
            TextFormField(
              controller: passwordController,
              cursorColor: Colors.white,
              obscureText: true,
            ),
            RaisedButton(
              onPressed: () {
                log("Click");
                login(usernameController.text, passwordController.text);
              },
              elevation: 0.0,
              color: Colors.amber,
              child: Text("Connexion", style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              
            ),
            Text(errorMessage!=null?errorMessage:""),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegisterPage()));
              },
              elevation: 0.0,
              color: Colors.amber,
              child: Text("Inscription", style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              
            ),
            
            
          ],
        ),
      ),
    );
  }
}