const express = require('express')
const fileUpload = require('express-fileupload')
const bodyParser = require('body-parser');
const path    = require('path')

const app = express()
app.use(bodyParser.urlencoded({ extended: true }));
const OCRController = require('./controllers/OCRController')
const vinController = require('./controllers/vinController')
const userController = require('./controllers/userController')
const mongoose = require('./controllers/mongoose') 

app.use(express.static(path.join(__dirname,'data/pictures')));

app.use(fileUpload({
    limits: { fileSize: 50 * 1024 * 1024 },
  }));

app.get('/', function (req, res) {
    res.sendFile('index.html' , { root : __dirname});
})
app.post('/file', function( req, res){
    if (!req.files || ! req.files.picture) {
        return res.status(400).send('No files were uploaded.');
      }
      let picFile = req.files.picture;
      let path = './tmp/'+picFile.name;
      picFile.mv(path, function(err) {
        if (err)
          return res.status(500).send(err);
      
      OCRController.processPicture(path, res, req, mongoose)
      });
})
app.get('/addVin', function(req, res){
  vinController.addVin({}, res, req, mongoose)
  res.sendFile('addVin.html' , { root : __dirname});
})
app.post('/addVin', function(req, res){
  let name = req.body.nom
  let keywords = req.body.keywords
  let picFile = req.files.picture;
  let path = './data/pictures/'+name+".jpg";
  picFile.mv(path, function(err) {
    if (err)
      return res.status(500).send(err);
  data = {path, name, keywords}
      vinController.addVin(data, res, req, mongoose)
  });
})
app.post('/register', function(req, res){
  userController.register(req, res)
})
app.post('/login', function(req, res){
  userController.login(req, res)
})

app.post('/verifyLogin', function(req, res){
  userController.verifyLogin(req, res)
})
// LOGGED IN
app.post('/review', function(req, res){
  console.log(req.body)
  userController.isUserConnected(req, res, vinController.addReview)
})
app.get('/review', function(req, res){
  vinController.getReview(req, res, null)
 // userController.isUserConnected(req, res, vinController.getReview)
})
app.get('/vins', function(req, res){
  //console.log(req.body)
  vinController.getAllVin(req, res, null)
  //userController.isUserConnected(req, res, vinController.getAllVin)
})
// ADMIN
app.post('/vin/edit', function(req, res){
  console.log("Edit")
  vinController.editVin(req, res, null)
})
app.post('/vin/add', function(req, res){
  console.log("add")
  vinController.addVin(req, res, null)
})
app.post('/vin/image', function(req, res){
  if(req.files && req.files.picture){
    
  vinController.uploadImage(req, res, null)
  }
  else
    res.json({error:true})
  
})
app.post('/vin/delete', function(req, res){
  console.log("delete")
  vinController.deleteVin(req, res, null)
})
app.post('/review/delete', function(req, res){
  console.log("delete rev")
  vinController.deleteReview(req, res, null)
})

app.listen(3000)