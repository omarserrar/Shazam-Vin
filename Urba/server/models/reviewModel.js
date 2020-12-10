const mongoose = require('mongoose') 
var reviewSchema = mongoose.Schema({
    user: String,
    review: String,
    note: String,
    date: Date
}); 
 
const Review = mongoose.model('review', reviewSchema);;

exports.Review = Review;