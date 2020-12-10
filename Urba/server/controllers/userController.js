const {User} = require("../models/userModel")
const sha1 = require('sha1');
var jwt = require('jsonwebtoken');

exports.verifyLogin = async function(req, res){
    let token = req.body.token
    if(token){
        User.find({tokens: token}).exec((req, resp)=>{
            if(resp.length){
                resp[0].password = ""
                res.json({success:true, user: resp[0]})
            }
            else
                res.json({error: true})
        })
    }
    else{
        res.json({error: true})
    }
}
exports.isUserConnected = async function(req, res, callback){
    let token = req.body.token
    if(token){
        User.find({tokens: token}).exec((reqq, resp)=>{
            if(resp.length){
                resp[0].password = ""
                callback(req, res, resp[0])
            }
            else
            res.json({error: true, message: "Not connected"})
        })
    }
    else{
        res.json({error: true, message: "Not connected"})
    }
}
exports.login = async function(req, res){
    let username = req.body.username
    let password = sha1(req.body.password)
    User.find().where('username', username).where('password', password).exec(async (err, resp)=>{
        if(resp.length != 0){
            let user = resp[0]
            var token = jwt.sign({ user_id: user._id, date: Date() }, 'SEcreeeeeeeeeeeeeeeeeeeeet');
            user.tokens.push(token)
            await user.save()
            user.tokens = []
            user.password = ""
            res.json({connected: true, user, token})
        }
            
        else   
            res.json({error: true, message: "Nom d'utilisateur ou mot de passe incorrect"})
    })
}
exports.register = function(req, res){
    let username = req.body.username
    let password = sha1(req.body.password)
    let user = new User({username, password})
    User.find().where('username', username).exec((err, resp) =>{
        console.log(resp)
        if(resp.length==0){
            user.save()
            res.json({success:true})
        }
        else{
            res.json({error: true, message: "Nom d'utilisateur déja utilisé"})
        }
        
    })
}
exports.postReview = function(req, res){
    let username = req.body.username
    let password = sha1(req.body.password)
    let user = new User({username, password})
    User.find().where('username', username).exec((err, resp) =>{
        console.log(resp)
        if(resp.length==0){
            user.save()
            res.json({success:true})
        }
        else{
            res.json({error: true, message: "Nom d'utilisateur déja utilisé"})
        }
        
    })
}

