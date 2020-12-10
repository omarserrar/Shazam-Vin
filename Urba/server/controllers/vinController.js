const { mongo } = require("mongoose");
const {Vin} = require("../models/vinModel");
const {User} = require("../models/userModel");
var ObjectId = require('mongoose').Types.ObjectId;

const fs = require('fs')
exports.addVin = async function(data, res, req, mongoose){
    Vin.find().exec(function(err, res){
        res.map(elem => {
            let a = elem.keywords.split(/[\s,-]+/);
            elem.path = elem._id+".jpg";
            elem.save();
        });
    });
  /*  let vin = new Vin(data)
    vin.save()
    res.json(data)*/
};
exports.getAllVin = function(req, res, user){
    Vin.find().exec((err, resp) =>{
        let respJson=[];
        for(var i = 0;i<resp.length;i++){
            let elem = resp[i];
            elem.keywords = (elem.keys)?elem.keys.join(' '):"";
            respJson.push(elem)
        }
        res.json(respJson);
    });
};
exports.getReview = async function(req, res, user){
    console.log(req.query);
    if(!req.query.vinId) return res.json({error: true});
    Vin.findById(req.query.vinId).exec(async (err, resp) => {
      //  console.log(resp)
        let reviews = [];
        let reviewAvg = 0;
        if(resp.reviews){
            let size = resp.reviews.length;
            for(let i = 0; i<size ; i++){
                let review = resp.reviews[i];
                let userId = review.user;
                let user = await User.findById(userId);
                reviewAvg += Number(review.note);
                review.username = user.username;
                console.log(user);
                reviews.push(review);
            }
            reviewAvg = (size!=0)?reviewAvg/size:0;
        }
        
        
        if(resp)
            res.json({reviews, avg: reviewAvg });
    });

};
exports.addReview = function(req, res, user){
    let vinId = req.body.vinId;
    let userId = user._id;
    Vin.findById(vinId).exec((err, resp)=>{
     //   console.log(res);
        if(resp){
            if(!resp.reviews){
                res.reviews = [];
            }
            else{
                for(var i =0;i<resp.reviews.length;i++){
                    if(resp.reviews[i].user.toString() == user._id){
                        console.log("V")
                        return res.json({error:true, message:"Vous ne pouvez pas écrire plus d'un commentaire"})
                    }
                        
                }
                //return res.json({error:true, message:"Vous ne pouvez pas écrire plus d'un commentaire"})
            }
            resp.reviews.push({note: req.body.note, review: req.body.review, user: userId, date: new Date().getTime()});
            resp.save();
            res.json({success:true})
        }
    });
};
exports.editVin = function(req, res, user){

    let vinId = req.body.vinId;
    console.log(req.body)
   // let userId = user._id;
    let data = req.body;
    if(data.cepage !== null && data.name !== null && data.prix !== null && data.description !== null && data.domaine !== null)
        Vin.findById(vinId).exec((err, resp)=>{
            if(resp){
                resp.name = data.name;
                resp.cepage = data.cepage;
                resp.prix = data.prix;
                resp.description = data.description;
                resp.domaine = data.domaine;
                resp.keys = data.key.split(/[\s,-]+/);;
                resp.save();
                console.log("Success")
                res.json({success: true});
            }
            else{
                res.json({error: true});
            }
        });
    else
        res.json({error: true});
};
exports.addVin = function(req, res, user){
    let vin = new Vin();
    let data = req.body;
    vin.name = data.name;
    vin.cepage = data.cepage;
    vin.prix = data.prix;
    vin.description = data.description;
    vin.domaine = data.domaine;
    vin.keys = data.key.split(/[\s,-]+/);
    vin.save().then((resp) => {
        if(resp){
            console.log(resp)
            res.json({success: true, vinId: resp._id})
        }
        else{
            res.json({error: true})
        }
    });
};
exports.uploadImage = function(req, res, user){
    let vinId = req.body.vinId;
    let image = req.files.picture;
    let ext = image.name.split('.').pop();
    console.log("Upload "+vinId)
    Vin.findById(vinId).exec((err, resp)=>{
        if(resp){
            resp.path = vinId+"."+ext;
            resp.save().then((doc) => {
                req.files.picture.mv("./data/pictures/"+resp.path, (err) =>{
                    //console.log(err)
                });
                res.json({success: true, path: resp.path})
            })
        }
        else
            res.json({error: false})
    })
};
exports.deleteVin = async function(req, res, user)  {
    let vinId = req.body.vinId;
    console.log("Upload "+vinId)
    let vin = await Vin.findById(vinId);
    if(!vin) res.json({error: true})
    Vin.deleteOne({"_id": vinId}, (err) =>{
        if(err)
            res.json({error: true});
        else{
            if(vin.path){
                fs.unlinkSync("./data/pictures/"+vin.path)              
            }
            res.json({success: true});    
        }
            
    })
};
exports.deleteReview = async function(req, res, user)  {
    console.log(req.body)
    try{
        Vin.findByIdAndUpdate(
            req.body.vinId, { $pull: { "reviews": { user: new ObjectId(req.body.user) } } }, { safe: true, upsert: true },
            function(err, node) {
                if (err) { res.json({error :true}) }
                return res.json({success :true}) 
        });
    }
    catch(e){
        res.json({error :true}) 
    }
    

};