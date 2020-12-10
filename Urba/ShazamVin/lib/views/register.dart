import 'dart:convert';
import 'dart:developer';

import 'package:ShazamVin/components/CameraView.dart';
import 'package:ShazamVin/services/apiCall.dart';
import 'package:ShazamVin/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String errorMessage;
  bool _isLoading = false;
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  void register(username, email, password) async {
    Map data = {"username": username, "password": password, "email": email};
    var loginResult = await ApiCall.register(data);
    if(loginResult != null && loginResult.containsKey("success")){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
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
            Text("Email"),
            TextFormField(
              controller: emailController,
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
                if(usernameController.text.trim() != ""&& usernameController.text.trim() != ""&& passwordController.text.trim() != "")
                  register(usernameController.text, emailController.text, passwordController.text);
              },
              elevation: 0.0,
              color: Colors.purple,
              child: Text("Inscription", style: TextStyle(color: Colors.white70)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              
            ),
            Text(errorMessage!=null?errorMessage:""),
          ],
        ),
      ),
    );
  }
}