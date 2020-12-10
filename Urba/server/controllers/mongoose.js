const mongoose = require('mongoose');
var urlmongo = "mongodb://localhost:27017/db"; 
 
// Nous connectons l'API à notre base de données
mongoose.connect(urlmongo, {useNewUrlParser: true, useUnifiedTopology: true});

exports.mongoose = mongoose;
