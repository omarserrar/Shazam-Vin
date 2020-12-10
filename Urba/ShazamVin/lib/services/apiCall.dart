import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCall{
  static final String HOSTNAME = "http://192.168.1.58:3000";
  static final String PIC_UPLOAD = "/file";
  static final String LOGIN = "/login";
  static final String REGISTER = "/register";
  static final String REVIEW = "/review";
  static final String VINS = "/vins";
  static final String VIN_EDIT = "/vin/edit";
  static final String VIN_ADD = "/vin/add";
  static final String VIN_IMAGE = "/vin/image";
  static final String VIN_DELETE = "/vin/delete";
  static final String REVIEW_DELETE = "/review/delete";
  static uploadPic(File file) async{

    var request = http.MultipartRequest("POST", Uri.parse(HOSTNAME+PIC_UPLOAD));
    var pic = await http.MultipartFile.fromPath("picture", file.path);

    request.files.add(pic);
    var response = await request.send();
    

    var responseData = await response.stream.toBytes();
    var responseString = utf8.decode(responseData);
    var responseJSON = await jsonDecode(responseString);
    return responseJSON;
  }
  static login(username, password) async{
    Map data = {'username':username, 'password': password};
    var response = await http.post(HOSTNAME+LOGIN, body: data);
    if(response.statusCode == 200){
      return json.decode(response.body);
    }
    return false;
  }
  static addReview(vinId, review, note) async {
    log(review+" "+note.toString());
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    if( token != null) {
      Map data = {'token': token, 'review': review, 'note': note.toString(), 'vinId': vinId};
      return await json.decode((await http.post(HOSTNAME+REVIEW,body: data)).body);
    }
    return false;
  }
  static getAllVIn() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    if( token != null) {
      Map data = {'token': token};
      var response = await http.get(HOSTNAME+VINS+"?token="+token);
      return await json.decode(response.body);
    }
    return false;
  }

  static getVinReviews(String id) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    if( token != null) {
      Map data = {'token': token};
      var response = await http.get(HOSTNAME+REVIEW+"?token="+token+"&vinId="+id);
      return await json.decode(response.body);
    }
    return false;
  }

  static editVin(data) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
   
    if( token != null) {
      data['token'] = token;
      var response = await http.post(HOSTNAME+VIN_EDIT, body: data);
      return await json.decode(response.body);
    }
    return false;
  }
  static addVin(data) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
   
    if( token != null) {
      data['token'] = token;
      var response = await http.post(HOSTNAME+VIN_ADD, body: data);
      return await json.decode(response.body);
    }
    return false;
  }
  static changeVinPic(File file, String id) async{

    var request = http.MultipartRequest("POST", Uri.parse(HOSTNAME+VIN_IMAGE));
    var pic = await http.MultipartFile.fromPath("picture", file.path);
    request.fields['vinId'] = id;
    request.files.add(pic);
    var response = await request.send();
    

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var responseJSON = await jsonDecode(responseString);
    return responseJSON;
  }

  static deleteVin(data) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
   
    if( token != null) {
      data['token'] = token;
      var response = await http.post(HOSTNAME+VIN_DELETE, body: data);
      return await json.decode(response.body);
    }
    return false;
  }
  static deleteReview(data) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
   
    if( token != null) {
      data['token'] = token;
      log(data.toString());
      var response = await http.post(HOSTNAME+REVIEW_DELETE, body: data);
      return await json.decode(response.body);
    }
    return false;
  }
  static register(data) async {
    log(data.toString());
    var response = await http.post(HOSTNAME+REGISTER, body: data);
    return await json.decode(response.body);

  }
}