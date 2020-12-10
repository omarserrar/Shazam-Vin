const vision = require('@google-cloud/vision');
const {Vin} = require("../models/vinModel")
const levenshtein = require('js-levenshtein');

exports.processPicture = async function(picture, res, req, mongoose){
    const client = new vision.ImageAnnotatorClient({projectId:"vinShaz", keyFilename: "./VinShaz-4f7356fa0ef9.json"});

    const [result] = await client.textDetection(picture);
    const detections = result.textAnnotations;
    console.log('Text:');
    detections.forEach(text => console.log(text));
    if(detections.length > 0 && detections[0].description){
        findInDb(detections[0].description, mongoose, res)
    }
    else{
        res.json({result: 0});
    }
}
function findInDb(words, mongoose, res){
    words = words.split(/[\s,-]+/)
    
    let highScore = 0
    let bestMatch
    Vin.find().exec(function(err, resp){
        resp.map(elem => {
            let score = 0
            if(elem.keys){
                elem.keys.map(key =>{
                    words.map(word =>{
                        key = key.toLocaleUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                        word = word.toLocaleUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                        score += levenshtein(key, word) < key.length * 0.4 ? key.length : 0
                    })
                })
                if(score>highScore){
                    highScore = score
                    bestMatch = elem
                }
            }
        })
        res.json({words, bestMatch, highScore})
    })
}
