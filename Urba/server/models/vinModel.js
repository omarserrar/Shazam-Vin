const mongoose = require('mongoose') 
var vinSchema = mongoose.Schema({
    keywords: String,
    name: String,
    domaine: String,
    cepage: String,
    prix: String,
    description: String,
    path: String,
    keys: Array,
    reviews: Array,
}); 
 
const Vin = mongoose.model('vin', vinSchema);;

exports.Vin = Vin;