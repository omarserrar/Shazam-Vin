import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PictureVerification{
  uploadPic(File file) async{

   var request = http.MultipartRequest("POST", Uri.parse("http://192.168.1.58:3000/file"));


   var pic = await http.MultipartFile.fromPath("picture", file.path);

   request.files.add(pic);
   var response = await request.send();
   

   var responseData = await response.stream.toBytes();
   var responseString = utf8.decode(responseData);
   var responseJSON = await jsonDecode(responseString);
   return responseJSON;
}

}