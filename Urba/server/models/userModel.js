const mongoose = require('mongoose') 
var UserSchema = mongoose.Schema({
    username: String,
    password: String,
    email: String,
    nom: String,
    prenom: String,
    Admin: Number,
    tokens: Array
}); 
 
const User = mongoose.model('user', UserSchema);;

exports.User = User;