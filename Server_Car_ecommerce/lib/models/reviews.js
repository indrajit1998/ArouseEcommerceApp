const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    name: {type: String, required: true},
    designation: {type: String, required: true},
    image: {type: String, required: true},
    review: {type: String, required: true},
    rating: {type: Number, required: true, min: 1, max: 5},
});

const Review = mongoose.model('Review', reviewSchema);
module.exports = Review;